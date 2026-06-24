import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/secure_file_entries.dart';

part 'secure_file_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [SecureFileEntries])
class SecureFileDao extends DatabaseAccessor<AppDatabase>
    with _$SecureFileDaoMixin {
  SecureFileDao(super.db);

  Future<List<SecureFileEntry>> getAll() =>
      (select(secureFileEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<SecureFileEntry?> getById(String id) =>
      (select(secureFileEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsert(SecureFileEntriesCompanion companion) =>
      into(secureFileEntries).insertOnConflictUpdate(companion);

  Future<void> deleteById(String id) =>
      (delete(secureFileEntries)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAll() => delete(secureFileEntries).go();
}
