import 'dart:typed_data';

import 'package:password_manager/features/secure_files/domain/entities/secure_file.dart';
import 'package:password_manager/features/secure_files/domain/repositories/i_secure_file_repository.dart';

/// In-memory [ISecureFileRepository] for widget tests. `addFile`/`delete`/
/// `updateMeta` mutate the backing list so the screen's list reflects the change
/// after the notifier refreshes. `readDecrypted` returns fixed [decryptedBytes]
/// — never real plaintext (Zero-Print). Counters let a test assert the auth-gated
/// paths actually reached the store.
class FakeSecureFileRepository implements ISecureFileRepository {
  FakeSecureFileRepository([List<SecureFile>? seed]) : store = [...?seed];
  final List<SecureFile> store;

  Uint8List decryptedBytes = Uint8List.fromList(const [1, 2, 3, 4]);
  int readDecryptedCalls = 0;
  int addFileCalls = 0;

  @override
  Future<List<SecureFile>> getAll() async => List.of(store);

  @override
  Future<SecureFile?> getById(String id) async =>
      store.where((f) => f.id == id).firstOrNull;

  @override
  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  }) async {
    addFileCalls++;
    final id = 'id-${store.length + 1}';
    final dot = name.lastIndexOf('.');
    final ext = dot > 0 ? name.substring(dot + 1).toLowerCase() : null;
    final now = DateTime(2021, 1, 1);
    final file = SecureFile(
      id: id,
      name: name,
      sizeBytes: bytes.length,
      storedFileName: '$id.enc',
      mimeHint: ext,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    store.add(file);
    return file;
  }

  @override
  Future<void> updateMeta(SecureFile file) async {
    final i = store.indexWhere((f) => f.id == file.id);
    if (i != -1) store[i] = file;
  }

  @override
  Future<Uint8List> readDecrypted(String id) async {
    readDecryptedCalls++;
    return Uint8List.fromList(decryptedBytes);
  }

  @override
  Future<void> delete(String id) async => store.removeWhere((f) => f.id == id);

  @override
  Future<void> deleteAll() async => store.clear();
}
