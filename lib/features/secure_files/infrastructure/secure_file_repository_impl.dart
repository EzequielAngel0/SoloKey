import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../core/infrastructure/vault/vault_store.dart';
import '../domain/entities/secure_file.dart';
import '../domain/repositories/i_secure_file_repository.dart';

/// Archivos seguros en la boveda v2 (NUC-2): los metadatos son un registro `file` y el contenido un blob con el
/// mismo id, los dos cifrados por el nucleo dentro del mismo archivo de boveda (ya no hay `secure_files/` aparte).
@LazySingleton(as: ISecureFileRepository)
class SecureFileRepositoryImpl implements ISecureFileRepository {
  SecureFileRepositoryImpl(this._vault);

  final VaultStore _vault;

  static const _uuid = Uuid();

  @override
  Future<List<SecureFile>> getAll() async {
    final list = [for (final m in await _vault.list(RecordKind.file)) _from(m)]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<SecureFile?> getById(String id) async {
    final m = await _vault.get(RecordKind.file, id);
    return m == null ? null : _from(m);
  }

  @override
  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final file = SecureFile(
      id: id,
      name: name,
      sizeBytes: bytes.length,
      storedFileName: id,
      mimeHint: _extensionOf(name),
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _vault.putBlob(id, bytes);
    await _vault.put(RecordKind.file, {id: _to(file)});
    return file;
  }

  @override
  Future<void> updateMeta(SecureFile file) => _vault.put(
      RecordKind.file, {file.id: _to(file.copyWith(updatedAt: DateTime.now()))});

  @override
  Future<Uint8List> readDecrypted(String id) async {
    final bytes = await _vault.getBlob(id);
    if (bytes == null) throw StateError('File not found');
    return bytes;
  }

  @override
  Future<void> applySynced(SecureFile meta, Uint8List plainBytes) async {
    await _vault.putBlob(meta.id, plainBytes);
    await _vault.put(RecordKind.file, {meta.id: _to(meta)});
  }

  @override
  Future<void> delete(String id) async {
    await _vault.deleteBlob(id);
    await _vault.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    for (final f in await getAll()) {
      await delete(f.id);
    }
  }

  static String? _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return null;
    return name.substring(dot + 1).toLowerCase();
  }

  SecureFile _from(Map<String, dynamic> m) {
    DateTime date(String k) =>
        DateTime.fromMillisecondsSinceEpoch((m[k] as num).toInt());
    return SecureFile(
      id: m['id'] as String,
      name: m['name'] as String? ?? '',
      sizeBytes: (m['sizeBytes'] as num?)?.toInt() ?? 0,
      storedFileName: m['id'] as String,
      mimeHint: m['mimeHint'] as String?,
      note: m['note'] as String?,
      folderId: m['folderId'] as String?,
      isFavorite: m['isFavorite'] as bool? ?? false,
      createdAt: date('createdAt'),
      updatedAt: date('updatedAt'),
    );
  }

  Map<String, dynamic> _to(SecureFile f) => {
        'id': f.id,
        'name': f.name,
        'sizeBytes': f.sizeBytes,
        'mimeHint': f.mimeHint,
        'note': f.note,
        'folderId': f.folderId,
        'isFavorite': f.isFavorite,
        'createdAt': f.createdAt.millisecondsSinceEpoch,
        'updatedAt': f.updatedAt.millisecondsSinceEpoch,
      };
}
