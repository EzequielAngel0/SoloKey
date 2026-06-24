import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/credentials/domain/entities/credential.dart';
import '../../features/credentials/domain/repositories/i_credential_repository.dart';
import '../../features/folders/domain/entities/folder.dart';
import '../../features/folders/domain/repositories/i_folder_repository.dart';
import '../infrastructure/security/i_security_service.dart';
import '../infrastructure/security/session_manager.dart';
import 'csv_import_service.dart';

/// Encrypted vault export/import service.
///
/// Binary format v2 (cross-device capable):
///   [magic: 8B "SKVE2\0\0\0"]
///   [salt:  32B  — Argon2id salt for the export password]
///   [AES-256-GCM blob]  — encrypts the JSON payload
///
/// The export password is chosen by the user at export time and must
/// be re-entered when importing on any device. This makes the backup
/// portable across devices regardless of each vault's internal key.
///
/// Legacy v1 format ("SKVE1\0\0\0" without embedded salt) is still
/// accepted for same-device imports only: it falls back to the current
/// session key exactly as before.
///
/// File extension: .skvault
///
/// Sentinel folder id used inside a `folderFilter` to represent credentials
/// that are not assigned to any folder ("Sin carpeta"). Lets the caller decide
/// whether unfiled credentials are included in a selective export/import.
const String kNoFolderFilterId = '__no_folder__';

@lazySingleton
class VaultExportService {
  VaultExportService(
    this._credRepo,
    this._folderRepo,
    this._security,
    this._session,
  );

  final ICredentialRepository _credRepo;
  final IFolderRepository _folderRepo;
  final ISecurityService _security;
  final SessionManager _session;

  static const _magicV1 = 'SKVE1\x00\x00\x00'; // 8 bytes — legacy
  static const _magicV2 = 'SKVE2\x00\x00\x00'; // 8 bytes — cross-device
  static const _magicLegacyVG = 'VGVAULT1';    // 8 bytes — very old format
  static const _saltLen = 32;

  // Argon2id params for export key (lighter than vault unlock — no session risk)
  static const _exportMemory = 65536;   // 64 MiB
  static const _exportIter = 3;
  static const _exportParallelism = 2;

  // ── Export ──────────────────────────────────────────────────────────────────

  /// Exports credentials/folders to an AES-encrypted `.skvault` v2 file.
  ///
  /// [exportPassword] is the password chosen by the user for this backup.
  /// It must be entered again when importing on another device.
  ///
  /// Pass `null` for [typeFilter] to export every credential type.
  ///
  /// Pass `null` for [folderFilter] to export from every folder. When a set is
  /// given, only credentials whose folder id is in the set are exported (use
  /// [kNoFolderFilterId] to include unfiled credentials), and only the listed
  /// folders are written to the backup.
  ///
  /// [credentialIds] takes precedence over [typeFilter]/[folderFilter]: when
  /// given, ONLY those exact credentials are exported, together with the folder
  /// hierarchy (ancestors) they belong to, so they re-import into place.
  ///
  /// Returns the [ExportSummary], or `null` if the user cancelled the desktop
  /// save dialog.
  Future<ExportSummary?> exportVault({
    required String exportPassword,
    Set<CredentialType>? typeFilter,
    Set<String>? folderFilter,
    Set<String>? credentialIds,
  }) async {
    final built = await _buildEncryptedBackup(
      exportPassword: exportPassword,
      typeFilter: typeFilter,
      folderFilter: folderFilter,
      credentialIds: credentialIds,
    );

    final fileName = 'solokey_${DateTime.now().millisecondsSinceEpoch}.skvault';

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Desktop: a native Save dialog. The Windows "share" sheet is unreliable
      // for unpackaged apps ("could not show all the ways to share content"),
      // so we let the user choose where to write the .skvault file.
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'SoloKey Backup',
        fileName: fileName,
        bytes: built.bytes,
      );
      if (path == null) return null; // cancelled
      // On desktop saveFile only returns the path — write the bytes ourselves.
      await File(path).writeAsBytes(built.bytes, flush: true);
      return built.summary;
    }

    // Mobile: share sheet from a temp file, deleted afterwards.
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(built.bytes);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'SoloKey Backup',
        ),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }

    return built.summary;
  }

  /// Writes an encrypted `.skvault` backup directly into [directoryPath] (no
  /// share sheet). Used by the scheduled-backup service. Returns the file path.
  Future<String> exportVaultToDirectory({
    required String exportPassword,
    required String directoryPath,
    Set<CredentialType>? typeFilter,
    Set<String>? folderFilter,
  }) async {
    final built = await _buildEncryptedBackup(
      exportPassword: exportPassword,
      typeFilter: typeFilter,
      folderFilter: folderFilter,
    );
    final ts = DateTime.now();
    final stamp = '${ts.year}${_two(ts.month)}${_two(ts.day)}-'
        '${_two(ts.hour)}${_two(ts.minute)}${_two(ts.second)}';
    final file = File('$directoryPath/SoloKey-backup-$stamp.skvault');
    await file.writeAsBytes(built.bytes);
    return file.path;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Builds the encrypted backup bytes (magic|salt|AES-GCM blob) + a summary.
  Future<({Uint8List bytes, ExportSummary summary})> _buildEncryptedBackup({
    required String exportPassword,
    Set<CredentialType>? typeFilter,
    Set<String>? folderFilter,
    Set<String>? credentialIds,
  }) async {
    if (exportPassword.isEmpty) throw ArgumentError('Export password required');

    final allCredentials = await _credRepo.getAll();
    final allFolders = await _folderRepo.getAll();

    final List<Credential> credentials;
    final List<Folder> folders;

    if (credentialIds != null) {
      // Per-credential selection: export exactly these, plus the folder
      // hierarchy (ancestors) so they re-import into the right place.
      credentials =
          allCredentials.where((c) => credentialIds.contains(c.id)).toList();
      final byId = {for (final f in allFolders) f.id: f};
      final keep = <String>{};
      for (final c in credentials) {
        var fid = c.folderId;
        while (fid != null && byId.containsKey(fid) && keep.add(fid)) {
          fid = byId[fid]!.parentId;
        }
      }
      folders = allFolders.where((f) => keep.contains(f.id)).toList();
    } else {
      credentials = allCredentials.where((c) {
        final typeOk = typeFilter == null || typeFilter.contains(c.type);
        final folderOk = folderFilter == null ||
            folderFilter.contains(c.folderId ?? kNoFolderFilterId);
        return typeOk && folderOk;
      }).toList();
      folders = folderFilter == null
          ? allFolders
          : allFolders.where((f) => folderFilter.contains(f.id)).toList();
    }

    // Build JSON payload
    final payload = jsonEncode({
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'credentials': credentials.map((c) => c.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
    });

    // Generate a fresh salt for this export
    final saltBase64 = await _security.generateSaltBase64();
    final saltBytes = base64Decode(saltBase64);

    // Derive a key from the export password + this salt
    final exportKey = await _security.deriveKey(
      password: exportPassword,
      saltBase64: saltBase64,
      memory: _exportMemory,
      iterations: _exportIter,
      parallelism: _exportParallelism,
    );

    late Uint8List encrypted;
    try {
      encrypted = await _security.encrypt(
        Uint8List.fromList(utf8.encode(payload)),
        exportKey,
      );
    } finally {
      // Zero the derived key to minimize memory exposure window.
      exportKey.fillRange(0, exportKey.length, 0);
    }

    // Build file: magic(8) | salt(32) | encrypted blob
    final magic = utf8.encode(_magicV2);
    final fileBytes = Uint8List(magic.length + _saltLen + encrypted.length);
    fileBytes.setAll(0, magic);
    fileBytes.setAll(magic.length, saltBytes);
    fileBytes.setAll(magic.length + _saltLen, encrypted);

    final countsByType = <CredentialType, int>{};
    for (final c in credentials) {
      countsByType[c.type] = (countsByType[c.type] ?? 0) + 1;
    }

    return (
      bytes: fileBytes,
      summary: ExportSummary(
        totalCredentials: credentials.length,
        totalFolders: folders.length,
        countsByType: countsByType,
      ),
    );
  }

  // ── Import ──────────────────────────────────────────────────────────────────

  /// Decrypts a backup file and returns the decrypted credentials and folders.
  /// Does not persist anything to the database.
  Future<DecryptedBackup> decryptBackup({
    required Uint8List fileBytes,
    required String exportPassword,
  }) async {
    if (fileBytes.length < 8) {
      throw ArgumentError('Archivo inválido o vacío');
    }

    final headerStr = utf8.decode(fileBytes.sublist(0, 8), allowMalformed: true);
    late Uint8List encrypted;

    if (headerStr == _magicV2) {
      if (fileBytes.length < 8 + _saltLen) {
        throw ArgumentError('Archivo corrupto (v2)');
      }
      final saltBytes = fileBytes.sublist(8, 8 + _saltLen);
      encrypted = fileBytes.sublist(8 + _saltLen);

      if (exportPassword.isEmpty) {
        throw ArgumentError('Se requiere contraseña de exportación');
      }

      final exportKey = await _security.deriveKey(
        password: exportPassword,
        saltBase64: base64Encode(saltBytes),
        memory: _exportMemory,
        iterations: _exportIter,
        parallelism: _exportParallelism,
      );

      try {
        final decryptedBytes = await _security.decrypt(encrypted, exportKey);
        final json = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
        
        final credentials = (json['credentials'] as List)
            .map((e) => Credential.fromJson(e as Map<String, dynamic>))
            .toList();
        final folders = (json['folders'] as List)
            .map((e) => Folder.fromJson(e as Map<String, dynamic>))
            .toList();

        return DecryptedBackup(credentials: credentials, folders: folders);
      } catch (e) {
        throw ArgumentError('Contraseña de exportación incorrecta o archivo corrupto.');
      } finally {
        exportKey.fillRange(0, exportKey.length, 0);
      }
    } else if (headerStr == _magicV1 || headerStr == _magicLegacyVG) {
      final sessionKey = _session.getKeyCopy();
      if (sessionKey == null) {
        throw StateError('La bóveda está bloqueada');
      }
      encrypted = fileBytes.sublist(8);

      try {
        final decryptedBytes = await _security.decrypt(encrypted, sessionKey);
        final json = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
        
        final credentials = (json['credentials'] as List)
            .map((e) => Credential.fromJson(e as Map<String, dynamic>))
            .toList();
        final folders = (json['folders'] as List)
            .map((e) => Folder.fromJson(e as Map<String, dynamic>))
            .toList();

        return DecryptedBackup(credentials: credentials, folders: folders);
      } catch (_) {
        throw ArgumentError(
            'Este backup fue creado en este mismo dispositivo. La bóveda puede haber cambiado.');
      } finally {
        sessionKey.fillRange(0, sessionKey.length, 0);
      }
    } else {
      throw ArgumentError(
          'El archivo no es un backup válido de SoloKey. Asegúrate de exportar desde Ajustes → Sincronizar/Transferir.');
    }
  }

  /// Parses CSV content and returns a [DecryptedBackup] with folders being empty.
  DecryptedBackup parseCsvBackup(String csvContent, CsvImportService csvService) {
    final credentials = csvService.parseCsv(csvContent);
    if (credentials.isEmpty) {
      throw ArgumentError('No se encontraron credenciales válidas en el archivo CSV');
    }
    return DecryptedBackup(credentials: credentials, folders: []);
  }

  /// Saves selected elements from [backup] to the database.
  Future<ImportResult> performSelectiveImport({
    required DecryptedBackup backup,
    required ImportMode mode,
    required Set<CredentialType> typeFilter,
    required Set<String> folderFilter,
  }) async {
    try {
      final credentialsToImport = backup.credentials
          .where((c) =>
              typeFilter.contains(c.type) &&
              folderFilter.contains(c.folderId ?? kNoFolderFilterId))
          .toList();
      
      final foldersToImport = backup.folders
          .where((f) => folderFilter.contains(f.id))
          .toList();

      if (mode == ImportMode.replace) {
        final existing = await _credRepo.getAll();
        for (final c in existing) {
          await _credRepo.delete(c.id);
        }
        final existingFolders = await _folderRepo.getAll();
        for (final f in existingFolders) {
          await _folderRepo.delete(f.id);
        }
      }

      for (final f in foldersToImport) {
        await _folderRepo.save(f);
      }
      for (final c in credentialsToImport) {
        await _credRepo.save(c);
      }

      final countsByType = <CredentialType, int>{};
      for (final c in credentialsToImport) {
        countsByType[c.type] = (countsByType[c.type] ?? 0) + 1;
      }

      return ImportResult(
        success: true,
        message: 'Importadas ${credentialsToImport.length} credenciales y ${foldersToImport.length} carpetas',
        credentialsImported: credentialsToImport.length,
        foldersImported: foldersToImport.length,
        countsByType: countsByType,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Error al importar datos: $e',
      );
    }
  }
}

// ── Supporting types ─────────────────────────────────────────────────────────

enum ImportMode { merge, replace }

class DecryptedBackup {
  const DecryptedBackup({
    required this.credentials,
    required this.folders,
  });

  final List<Credential> credentials;
  final List<Folder> folders;
}

class ExportSummary {
  const ExportSummary({
    required this.totalCredentials,
    required this.totalFolders,
    required this.countsByType,
  });
  final int totalCredentials;
  final int totalFolders;
  final Map<CredentialType, int> countsByType;
}

class ImportResult {
  const ImportResult({
    required this.success,
    required this.message,
    this.credentialsImported = 0,
    this.foldersImported = 0,
    this.countsByType = const {},
  });
  final bool success;
  final String message;
  final int credentialsImported;
  final int foldersImported;
  final Map<CredentialType, int> countsByType;
}
