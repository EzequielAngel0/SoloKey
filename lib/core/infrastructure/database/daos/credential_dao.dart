import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/credential_entries.dart';

part 'credential_dao.g.dart';

@DriftAccessor(tables: [CredentialEntries])
class CredentialDao extends DatabaseAccessor<AppDatabase>
    with _$CredentialDaoMixin {
  CredentialDao(super.db);

  Future<List<CredentialEntry>> getAll() => (select(credentialEntries)
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
      .get();

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

  /// Toggles the hidden/archive flag without touching the encrypted payload.
  Future<void> setHidden(String id, bool hidden) =>
      (update(credentialEntries)..where((t) => t.id.equals(id))).write(
        CredentialEntriesCompanion(isHidden: Value(hidden)),
      );

  /// Sets the manual sort order without touching the encrypted payload.
  Future<void> setSortOrder(String id, int order) =>
      (update(credentialEntries)..where((t) => t.id.equals(id))).write(
        CredentialEntriesCompanion(sortOrder: Value(order)),
      );

  /// Moves a credential to [categoryId] (`null` = vault root / unfiled) without
  /// touching the encrypted payload. Bumps `updatedAt` so the change is picked
  /// up by delta sync (LWW compares `updatedAt`).
  Future<void> setCategory(String id, String? categoryId, int updatedAtMs) =>
      (update(credentialEntries)..where((t) => t.id.equals(id))).write(
        CredentialEntriesCompanion(
          categoryId: Value(categoryId),
          updatedAt: Value(updatedAtMs),
        ),
      );

  /// Bulk-reassigns every credential currently in [fromCategoryId] to
  /// [toCategoryId] (`null` = vault root). Bumps `updatedAt` so the moves sync.
  /// Used when a folder is deleted so its credentials are never orphaned.
  Future<void> reassignCategory(
    String fromCategoryId,
    String? toCategoryId,
    int updatedAtMs,
  ) =>
      (update(credentialEntries)
            ..where((t) => t.categoryId.equals(fromCategoryId)))
          .write(
        CredentialEntriesCompanion(
          categoryId: Value(toCategoryId),
          updatedAt: Value(updatedAtMs),
        ),
      );

  Future<int> deleteById(String id) =>
      (delete(credentialEntries)..where((t) => t.id.equals(id))).go();
}
