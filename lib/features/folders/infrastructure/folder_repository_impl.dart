import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/vault/vault_store.dart';
import '../domain/entities/folder.dart';
import '../domain/repositories/i_folder_repository.dart';

/// Carpetas en la boveda v2 (NUC-2): un registro `folder` por carpeta.
@LazySingleton(as: IFolderRepository)
class FolderRepositoryImpl implements IFolderRepository {
  const FolderRepositoryImpl(this._vault);

  final VaultStore _vault;

  @override
  Future<List<Folder>> getAll() async {
    final list = [for (final m in await _vault.list(RecordKind.folder)) _from(m)]
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Folder?> getById(String id) async {
    final m = await _vault.get(RecordKind.folder, id);
    return m == null ? null : _from(m);
  }

  @override
  Future<void> save(Folder folder) =>
      _vault.put(RecordKind.folder, {folder.id: _to(folder)});

  @override
  Future<void> delete(String id) => _vault.remove(id);

  @override
  Future<void> reparentChildren(String fromParentId, String? toParentId) async {
    await _vault.put(RecordKind.folder, {
      for (final f in await getAll())
        if (f.parentId == fromParentId) f.id: _to(f.copyWith(parentId: toParentId)),
    });
  }

  Folder _from(Map<String, dynamic> m) => Folder(
        id: m['id'] as String,
        parentId: m['parentId'] as String?,
        name: m['name'] as String? ?? '',
        icon: m['icon'] as String? ?? 'folder',
        colorHex: m['colorHex'] as String? ?? '#6C63FF',
        isFavorite: m['isFavorite'] as bool? ?? false,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as num).toInt()),
      );

  Map<String, dynamic> _to(Folder f) => {
        'id': f.id,
        'parentId': f.parentId,
        'name': f.name,
        'icon': f.icon,
        'colorHex': f.colorHex,
        'isFavorite': f.isFavorite,
        'createdAt': f.createdAt.millisecondsSinceEpoch,
      };
}
