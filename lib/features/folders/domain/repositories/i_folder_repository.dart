import '../entities/folder.dart';

abstract interface class IFolderRepository {
  Future<List<Folder>> getAll();
  Future<Folder?> getById(String id);
  Future<void> save(Folder folder);
  Future<void> delete(String id);

  /// Re-parents the direct children of [fromParentId] to [toParentId]
  /// (`null` = vault root). Keeps subfolders reachable when their parent is
  /// deleted instead of orphaning them.
  Future<void> reparentChildren(String fromParentId, String? toParentId);
}
