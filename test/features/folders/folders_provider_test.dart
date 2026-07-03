import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';

import '../../support/fake_folder_repository.dart';

Folder _f(String id, String name, {String? parent}) =>
    Folder(id: id, name: name, parentId: parent, createdAt: DateTime(2020));

ProviderContainer _container(FakeFolderRepository repo) {
  final c = ProviderContainer(overrides: [
    folderRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('createFolder persists a subfolder under the given parent', () async {
    final repo = FakeFolderRepository([_f('work', 'Work')]);
    final c = _container(repo);
    await c.read(foldersNotifierProvider.future);

    final created = await c
        .read(foldersNotifierProvider.notifier)
        .createFolder(name: 'Cloud', parentId: 'work');

    expect(created.parentId, 'work');
    expect(repo.folders.any((f) => f.id == created.id && f.name == 'Cloud'),
        isTrue);
  });

  test('renameFolder updates the stored name', () async {
    final repo = FakeFolderRepository([_f('work', 'Work')]);
    final c = _container(repo);
    await c.read(foldersNotifierProvider.future);

    await c.read(foldersNotifierProvider.notifier).renameFolder('work', 'Job');

    expect(repo.folders.single.name, 'Job');
  });

  test('toggleFavorite flips the flag', () async {
    final repo = FakeFolderRepository([_f('work', 'Work')]);
    final c = _container(repo);
    await c.read(foldersNotifierProvider.future);

    await c.read(foldersNotifierProvider.notifier).toggleFavorite('work');

    expect(repo.folders.single.isFavorite, isTrue);
  });

  test(
      'deleteFolder re-parents its subfolders to the destination and drops the '
      'folder', () async {
    final repo = FakeFolderRepository([
      _f('work', 'Work'),
      _f('sub', 'Sub', parent: 'work'),
    ]);
    final c = _container(repo);
    await c.read(foldersNotifierProvider.future);

    // Delete "work", moving its subfolders up to the root (null).
    await c
        .read(foldersNotifierProvider.notifier)
        .deleteFolder('work', reparentSubfoldersTo: null);

    expect(repo.folders.any((f) => f.id == 'work'), isFalse);
    expect(repo.folders.single.id, 'sub');
    expect(repo.folders.single.parentId, isNull); // promoted, not orphaned
  });

  test('deleteFolder can re-parent subfolders to a specific parent', () async {
    final repo = FakeFolderRepository([
      _f('a', 'A'),
      _f('b', 'B', parent: 'a'),
      _f('c', 'C', parent: 'b'),
    ]);
    final c = _container(repo);
    await c.read(foldersNotifierProvider.future);

    // Delete "b" (child of a), moving its subfolders into "a".
    await c
        .read(foldersNotifierProvider.notifier)
        .deleteFolder('b', reparentSubfoldersTo: 'a');

    expect(repo.folders.any((f) => f.id == 'b'), isFalse);
    expect(repo.folders.firstWhere((f) => f.id == 'c').parentId, 'a');
  });
}
