import 'dart:io';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/database/daos/secure_file_dao.dart';
import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../domain/entities/secure_file.dart';
import '../domain/repositories/i_secure_file_repository.dart';

/// Stores files encrypted-at-rest on disk (AES-256-GCM with the session key),
/// keeping only non-sensitive metadata in the database.
@LazySingleton(as: ISecureFileRepository)
class SecureFileRepositoryImpl implements ISecureFileRepository {
  SecureFileRepositoryImpl(this._dao, this._security, this._session);

  final SecureFileDao _dao;
  final ISecurityService _security;
  final SessionManager _session;

  static const _subdir = 'secure_files';
  static const _uuid = Uuid();

  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$_subdir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<List<SecureFile>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map(_fromEntry).toList();
  }

  @override
  Future<SecureFile?> getById(String id) async {
    final e = await _dao.getById(id);
    return e == null ? null : _fromEntry(e);
  }

  @override
  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  }) async {
    final key = _session.getKeyCopy();
    if (key == null) throw StateError('Vault is locked');

    final id = _uuid.v4();
    final storedFileName = '$id.enc';

    try {
      final encrypted = await _security.encrypt(bytes, key);
      final dir = await _dir();
      final file = File('${dir.path}${Platform.pathSeparator}$storedFileName');
      await file.writeAsBytes(encrypted, flush: true);
    } finally {
      key.fillRange(0, key.length, 0);
    }

    final now = DateTime.now();
    final secureFile = SecureFile(
      id: id,
      name: name,
      sizeBytes: bytes.length,
      storedFileName: storedFileName,
      mimeHint: _extensionOf(name),
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _dao.upsert(_toCompanion(secureFile));
    return secureFile;
  }

  @override
  Future<void> updateMeta(SecureFile file) =>
      _dao.upsert(_toCompanion(file.copyWith(updatedAt: DateTime.now())));

  @override
  Future<Uint8List> readDecrypted(String id) async {
    final entry = await _dao.getById(id);
    if (entry == null) throw StateError('File not found');

    final key = _session.getKeyCopy();
    if (key == null) throw StateError('Vault is locked');

    try {
      final dir = await _dir();
      final file =
          File('${dir.path}${Platform.pathSeparator}${entry.storedFileName}');
      final encrypted = await file.readAsBytes();
      return await _security.decrypt(encrypted, key);
    } finally {
      key.fillRange(0, key.length, 0);
    }
  }

  @override
  Future<void> delete(String id) async {
    final entry = await _dao.getById(id);
    if (entry != null) {
      try {
        final dir = await _dir();
        final file =
            File('${dir.path}${Platform.pathSeparator}${entry.storedFileName}');
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort — always remove the metadata row even if the blob is gone.
      }
    }
    await _dao.deleteById(id);
  }

  @override
  Future<void> deleteAll() async {
    await _dao.deleteAll();
    try {
      final dir = await _dir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {
      // Best-effort.
    }
  }

  static String? _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return null;
    return name.substring(dot + 1).toLowerCase();
  }

  SecureFile _fromEntry(SecureFileEntry e) => SecureFile(
        id: e.id,
        name: e.name,
        sizeBytes: e.sizeBytes,
        storedFileName: e.storedFileName,
        mimeHint: e.mimeHint,
        note: e.note,
        folderId: e.folderId,
        isFavorite: e.isFavorite,
        createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(e.updatedAt),
      );

  SecureFileEntriesCompanion _toCompanion(SecureFile f) =>
      SecureFileEntriesCompanion.insert(
        id: f.id,
        name: f.name,
        sizeBytes: f.sizeBytes,
        storedFileName: f.storedFileName,
        mimeHint: Value(f.mimeHint),
        note: Value(f.note),
        folderId: Value(f.folderId),
        isFavorite: Value(f.isFavorite),
        createdAt: f.createdAt.millisecondsSinceEpoch,
        updatedAt: f.updatedAt.millisecondsSinceEpoch,
      );
}
