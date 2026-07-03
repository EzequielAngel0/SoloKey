import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/folders/domain/repositories/i_folder_repository.dart';

/// In-memory [IFolderRepository] for logic/widget tests. Mutates its backing
/// list so tests can assert on re-parenting / deletion side effects.
class FakeFolderRepository implements IFolderRepository {
  FakeFolderRepository(this.folders);
  final List<Folder> folders;

  @override
  Future<List<Folder>> getAll() async => List.of(folders);

  @override
  Future<Folder?> getById(String id) async =>
      folders.where((f) => f.id == id).firstOrNull;

  @override
  Future<void> save(Folder folder) async {
    final i = folders.indexWhere((f) => f.id == folder.id);
    if (i == -1) {
      folders.add(folder);
    } else {
      folders[i] = folder;
    }
  }

  @override
  Future<void> delete(String id) async => folders.removeWhere((f) => f.id == id);

  @override
  Future<void> reparentChildren(String fromParentId, String? toParentId) async {
    for (var i = 0; i < folders.length; i++) {
      if (folders[i].parentId == fromParentId) {
        folders[i] = folders[i].copyWith(parentId: toParentId);
      }
    }
  }
}
