import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
  Future<ExportSummary> exportVault({
    required String exportPassword,
    Set<CredentialType>? typeFilter,
  }) async {
    final built = await _buildEncryptedBackup(
      exportPassword: exportPassword,
      typeFilter: typeFilter,
    );

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/solokey_$ts.skvault');
    await file.writeAsBytes(built.bytes);

    // SEC-002: Delete temp file after sharing
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
  }) async {
    final built = await _buildEncryptedBackup(
      exportPassword: exportPassword,
      typeFilter: typeFilter,
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
  }) async {
    if (exportPassword.isEmpty) throw ArgumentError('Export password required');

    final allCredentials = await _credRepo.getAll();
    final credentials = typeFilter == null
        ? allCredentials
        : allCredentials.where((c) => typeFilter.contains(c.type)).toList();
    final folders = await _folderRepo.getAll();

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

  /// Picks and imports a `.skvault` file.
  ///
  /// [exportPassword]: the password that was used to encrypt the backup.
  ///   - For v2 files: uses the embedded salt + this password to derive key.
  ///   - For legacy v1 files: falls back to the current session key
  ///     (same-device only). [exportPassword] is ignored in that case.
  ///
  /// [mode]: `ImportMode.merge`   — keep existing items, add new ones.
  ///         `ImportMode.replace` — delete all current data, then import.
  Future<ImportResult> importVault({
    required String exportPassword,
    ImportMode mode = ImportMode.merge,
  }) async {
    // Pick file — use FileType.any for broad Android compatibility;
    // Android does not recognize custom extensions like .skvault.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return ImportResult(success: false, message: 'Importación cancelada');
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null || fileBytes.length < 8) {
      return ImportResult(success: false, message: 'Archivo inválido o vacío');
    }

    // Detect format version
    final headerStr = utf8.decode(fileBytes.sublist(0, 8),
        allowMalformed: true);

    late Uint8List encrypted;

    if (headerStr == _magicV2) {
      // v2: magic(8) | salt(32) | blob
      if (fileBytes.length < 8 + _saltLen) {
        return ImportResult(success: false, message: 'Archivo corrupto (v2)');
      }
      final saltBytes = fileBytes.sublist(8, 8 + _saltLen);
      encrypted = fileBytes.sublist(8 + _saltLen);

      if (exportPassword.isEmpty) {
        return ImportResult(
          success: false,
          message: 'Ingresa la contraseña de exportación',
        );
      }

      final exportKey = await _security.deriveKey(
        password: exportPassword,
        saltBase64: base64Encode(saltBytes),
        memory: _exportMemory,
        iterations: _exportIter,
        parallelism: _exportParallelism,
      );

      try {
        return await _decryptAndSave(
          encrypted: encrypted,
          keyBytes: exportKey,
          mode: mode,
        );
      } finally {
        // Zero the derived key to minimize memory exposure window.
        exportKey.fillRange(0, exportKey.length, 0);
      }
    } else if (headerStr == _magicV1 || headerStr == _magicLegacyVG) {
      // Legacy v1: same-device only — use session key
      final sessionKey = _session.getKeyCopy();
      if (sessionKey == null) {
        return ImportResult(success: false, message: 'La bóveda está bloqueada');
      }
      encrypted = fileBytes.sublist(8);

      return _decryptAndSave(
        encrypted: encrypted,
        keyBytes: sessionKey,
        mode: mode,
        isLegacy: true,
      );
    } else {
      // Unknown magic — try interpreting as plain JSON (CSV/other)
      return ImportResult(
        success: false,
        message: 'El archivo no es un backup válido de SoloKey.\n'
            'Asegúrate de exportar desde Ajustes → Transferir datos.',
      );
    }
  }

  Future<ImportResult> _decryptAndSave({
    required Uint8List encrypted,
    required Uint8List keyBytes,
    required ImportMode mode,
    bool isLegacy = false,
  }) async {
    late Uint8List decrypted;
    try {
      decrypted = await _security.decrypt(encrypted, keyBytes);
    } catch (_) {
      final hint = isLegacy
          ? 'Este backup fue creado en este mismo dispositivo. '
              'La bóveda puede haber cambiado.'
          : 'Contraseña de exportación incorrecta o archivo corrupto.';
      return ImportResult(success: false, message: hint);
    }

    late Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
    } catch (_) {
      return ImportResult(
          success: false, message: 'El contenido del backup está corrupto');
    }

    final credentials = (json['credentials'] as List)
        .map((e) => Credential.fromJson(e as Map<String, dynamic>))
        .toList();
    final folders = (json['folders'] as List)
        .map((e) => Folder.fromJson(e as Map<String, dynamic>))
        .toList();

    if (mode == ImportMode.replace) {
      final existing = await _credRepo.getAll();
      for (final c in existing) {
        await _credRepo.delete(c.id);
      }
    }

    for (final f in folders) {
      await _folderRepo.save(f);
    }
    for (final c in credentials) {
      await _credRepo.save(c);
    }

    final countsByType = <CredentialType, int>{};
    for (final c in credentials) {
      countsByType[c.type] = (countsByType[c.type] ?? 0) + 1;
    }

    return ImportResult(
      success: true,
      message:
          'Importados ${credentials.length} credenciales y ${folders.length} carpetas',
      credentialsImported: credentials.length,
      foldersImported: folders.length,
      countsByType: countsByType,
    );
  }

  Future<ImportResult> importCsv({
    required CsvImportService csvService,
    ImportMode mode = ImportMode.merge,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return const ImportResult(success: false, message: 'Importación cancelada');
    }

    final fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      return const ImportResult(success: false, message: 'Archivo inválido o vacío');
    }

    late String csvContent;
    try {
      csvContent = utf8.decode(fileBytes);
    } catch (_) {
      return const ImportResult(
        success: false,
        message: 'No se pudo decodificar el archivo como texto CSV UTF-8 válido.',
      );
    }

    final credentials = csvService.parseCsv(csvContent);

    if (credentials.isEmpty) {
      return const ImportResult(
        success: false,
        message: 'No se encontraron credenciales válidas en el archivo CSV',
      );
    }

    if (mode == ImportMode.replace) {
      final existing = await _credRepo.getAll();
      for (final c in existing) {
        await _credRepo.delete(c.id);
      }
    }

    for (final c in credentials) {
      await _credRepo.save(c);
    }

    final countsByType = <CredentialType, int>{};
    for (final c in credentials) {
      countsByType[c.type] = (countsByType[c.type] ?? 0) + 1;
    }

    return ImportResult(
      success: true,
      message: 'Importadas ${credentials.length} credenciales desde CSV',
      credentialsImported: credentials.length,
      countsByType: countsByType,
    );
  }
}

// ── Supporting types ─────────────────────────────────────────────────────────

enum ImportMode { merge, replace }

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
