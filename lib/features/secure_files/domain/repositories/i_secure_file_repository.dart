import 'dart:typed_data';

import '../entities/secure_file.dart';

abstract interface class ISecureFileRepository {
  /// Lists stored files (metadata only).
  Future<List<SecureFile>> getAll();

  Future<SecureFile?> getById(String id);

  /// Encrypts [bytes] with the active session key, writes the blob to the app's
  /// private directory and persists the metadata. Throws [StateError] if the
  /// vault is locked (no session key available).
  Future<SecureFile> addFile({
    required String name,
    required Uint8List bytes,
    String? note,
  });

  /// Updates the (non-sensitive) metadata of a file — name, folder, favourite,
  /// note. Does NOT touch the encrypted blob on disk.
  Future<void> updateMeta(SecureFile file);

  /// Reads and decrypts the contents of the file with [id]. Throws
  /// [StateError] if the vault is locked.
  Future<Uint8List> readDecrypted(String id);

  /// Sync-apply: re-encrypts [plainBytes] with the LOCAL session key, writes the
  /// blob to disk and upserts [meta] VERBATIM (ids and timestamps untouched —
  /// LWW depends on `updatedAt` staying exactly as the source device set it).
  /// Throws [StateError] if the vault is locked.
  Future<void> applySynced(SecureFile meta, Uint8List plainBytes);

  /// Deletes a single file (disk blob + metadata).
  Future<void> delete(String id);

  /// Deletes every stored file and the on-disk directory. Used on full vault
  /// wipe.
  Future<void> deleteAll();
}
