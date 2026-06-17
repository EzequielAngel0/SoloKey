import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/credential_entries.dart';

part 'credential_dao.g.dart';

@DriftAccessor(tables: [CredentialEntries])
class CredentialDao extends DatabaseAccessor<AppDatabase>
    with _$CredentialDaoMixin {
  CredentialDao(super.db);

  Future<List<CredentialEntry>> getAll() =>
      select(credentialEntries).get();

  Future<CredentialEntry?> getById(String id) =>
      (select(credentialEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<CredentialEntry>> getByCategory(String categoryId) =>
      (select(credentialEntries)
            ..where((t) => t.categoryId.equals(categoryId)))
          .get();

  Future<List<CredentialEntry>> getFavorites() =>
      (select(credentialEntries)..where((t) => t.isFavorite.equals(true)))
          .get();

  Future<List<CredentialEntry>> searchByTitle(String query) =>
      (select(credentialEntries)
            ..where((t) => t.title.like('%$query%')))
          .get();

  Future<void> upsert(CredentialEntriesCompanion entry) =>
      into(credentialEntries).insertOnConflictUpdate(entry);

  /// Stamps [timestampMs] (epoch ms) into `lastRotationPromptedAt` without
  /// touching the encrypted payload — usable from a background isolate that
  /// has no master key in RAM.
  Future<void> markRotationPrompted(String id, int timestampMs) =>
      (update(credentialEntries)..where((t) => t.id.equals(id))).write(
        CredentialEntriesCompanion(
          lastRotationPromptedAt: Value(timestampMs),
        ),
      );

  Future<int> deleteById(String id) =>
      (delete(credentialEntries)..where((t) => t.id.equals(id))).go();
}
