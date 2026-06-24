import 'package:drift/drift.dart';

/// Metadata for securely-stored files. The encrypted contents live on disk
/// (see [storedFileName]); this row is non-sensitive plaintext metadata.
class SecureFileEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get storedFileName => text()();
  TextColumn get mimeHint => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
