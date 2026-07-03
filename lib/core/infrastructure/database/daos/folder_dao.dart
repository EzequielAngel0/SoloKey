import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/folder_entries.dart';

part 'folder_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [FolderEntries])
class FolderDao extends DatabaseAccessor<AppDatabase>
    with _$FolderDaoMixin {
  FolderDao(super.db);

  Future<List<FolderEntry>> getAll() =>
      (select(folderEntries)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<FolderEntry?> getById(String id) =>
      (select(folderEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsert(FolderEntriesCompanion companion) =>
      into(folderEntries).insertOnConflictUpdate(companion);

  /// Re-parents every direct child of [fromParentId] to [toParentId] (`null` =
  /// vault root). Used when deleting a folder so its subfolders are never
  /// orphaned (left pointing at a parent id that no longer exists).
  Future<void> reparentChildren(String fromParentId, String? toParentId) =>
      (update(folderEntries)..where((t) => t.parentId.equals(fromParentId)))
          .write(FolderEntriesCompanion(parentId: Value(toParentId)));

  Future<void> deleteById(String id) =>
      (delete(folderEntries)..where((t) => t.id.equals(id))).go();
}
