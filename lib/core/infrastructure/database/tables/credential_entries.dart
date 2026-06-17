import 'package:drift/drift.dart';

/// Drift table for credentials.
/// Only non-sensitive metadata is stored in plain text.
/// All sensitive fields (username, password, website, notes, customFields,
/// passkeyMetadata private key handle) are serialised to JSON and stored
/// as a single AES-256-GCM encrypted blob.
class CredentialEntries extends Table {
  /// Unique credential ID (UUID v4).
  TextColumn get id => text()();

  /// Human-readable title — not considered a secret (shown in vault list).
  TextColumn get title => text()();

  /// Credential type enum string (password, apiKey, secureNote, totp, passkey).
  TextColumn get type => text()();

  /// Optional category ID — unencrypted for filtering.
  TextColumn get categoryId => text().nullable()();

  /// Optional folder ID — unencrypted for tree navigation.
  TextColumn get folderId => text().nullable()();

  /// Favourite flag — unencrypted for quick access.
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();

  /// Whether the credential is double-encrypted using a secondary PIN.
  BoolColumn get isDoubleEncrypted =>
      boolean().withDefault(const Constant(false))();

  /// AES-256-GCM blob: nonce(12) || ciphertext || tag(16).
  /// Contains JSON-encoded sensitive payload including passkeyMetadata.
  BlobColumn get encryptedPayload => blob()();

  /// Unix timestamp in milliseconds.
  IntColumn get createdAt => integer()();

  /// Unix timestamp in milliseconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
