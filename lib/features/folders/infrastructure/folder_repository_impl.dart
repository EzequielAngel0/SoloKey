import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/database/daos/folder_dao.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../domain/entities/folder.dart';
import '../domain/repositories/i_folder_repository.dart';

@LazySingleton(as: IFolderRepository)
class FolderRepositoryImpl implements IFolderRepository {
  const FolderRepositoryImpl(this._dao);

  final FolderDao _dao;

  @override
  Future<List<Folder>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map(_fromEntry).toList();
  }

  @override
  Future<Folder?> getById(String id) async {
    final e = await _dao.getById(id);
    return e == null ? null : _fromEntry(e);
  }

  @override
  Future<void> save(Folder folder) =>
      _dao.upsert(_toCompanion(folder));

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  @override
  Future<void> reparentChildren(String fromParentId, String? toParentId) =>
      _dao.reparentChildren(fromParentId, toParentId);

  Folder _fromEntry(FolderEntry e) => Folder(
        id: e.id,
        parentId: e.parentId,
        name: e.name,
        icon: e.icon,
        colorHex: e.colorHex,
        isFavorite: e.isFavorite,
        createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt),
      );

  FolderEntriesCompanion _toCompanion(Folder f) =>
      FolderEntriesCompanion.insert(
        id: f.id,
        parentId: Value(f.parentId),
        name: f.name,
        icon: Value(f.icon),
        colorHex: Value(f.colorHex),
        isFavorite: Value(f.isFavorite),
        createdAt: f.createdAt.millisecondsSinceEpoch,
      );
}
