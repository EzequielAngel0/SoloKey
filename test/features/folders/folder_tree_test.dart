import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/folders/domain/folder_tree.dart';

Folder _f(String id, {String? parent, String? name}) => Folder(
      id: id,
      parentId: parent,
      name: name ?? id,
      createdAt: DateTime(2020),
    );

void main() {
  // work
  //  ├─ alpha
  //  └─ beta
  // Personal
  // orphan (parent 'ghost' does not exist)
  final work = _f('work', name: 'work');
  final personal = _f('personal', name: 'Personal');
  final alpha = _f('alpha', parent: 'work', name: 'alpha');
  final beta = _f('beta', parent: 'work', name: 'Beta');
  final orphan = _f('orphan', parent: 'ghost', name: 'orphan');
  final all = [beta, work, personal, alpha, orphan];

  group('folderChildren', () {
    test('roots are folders with no parent, sorted case-insensitively', () {
      final roots = folderChildren(all, null);
      expect(roots.map((f) => f.id), ['personal', 'work']); // Personal < work
    });

    test('children of a parent are returned sorted', () {
      final kids = folderChildren(all, 'work');
      expect(kids.map((f) => f.id), ['alpha', 'beta']); // alpha < Beta (ci)
    });

    test('orphans (parent missing) are not listed as roots', () {
      final roots = folderChildren(all, null);
      expect(roots.map((f) => f.id), isNot(contains('orphan')));
    });

    test('a leaf has no children', () {
      expect(folderChildren(all, 'alpha'), isEmpty);
    });
  });

  group('folderAncestorIds', () {
    test('null selection yields no ancestors', () {
      expect(folderAncestorIds(all, null), isEmpty);
    });

    test('includes the node and every ancestor up to root', () {
      expect(folderAncestorIds(all, 'alpha'), {'alpha', 'work'});
    });

    test('a root selection is just itself', () {
      expect(folderAncestorIds(all, 'personal'), {'personal'});
    });

    test('is cycle-safe (self-referential parent does not loop)', () {
      final loop = [_f('x', parent: 'x')];
      expect(folderAncestorIds(loop, 'x'), {'x'});
    });
  });

  group('folderDescendantIds', () {
    test('null root yields no descendants', () {
      expect(folderDescendantIds(all, null), isEmpty);
    });

    test('unknown root yields no descendants', () {
      expect(folderDescendantIds(all, 'ghost'), isEmpty);
    });

    test('includes the root and its whole subtree', () {
      expect(folderDescendantIds(all, 'work'), {'work', 'alpha', 'beta'});
    });

    test('a leaf is just itself', () {
      expect(folderDescendantIds(all, 'alpha'), {'alpha'});
    });

    test('is cycle-safe (mutual parent references do not loop)', () {
      final a = _f('a', parent: 'b');
      final b = _f('b', parent: 'a');
      expect(folderDescendantIds([a, b], 'a'), {'a', 'b'});
    });

    test('nested subtree walks multiple levels', () {
      final root = _f('r');
      final mid = _f('m', parent: 'r');
      final leaf = _f('l', parent: 'm');
      expect(folderDescendantIds([root, mid, leaf], 'r'), {'r', 'm', 'l'});
    });
  });

  group('flattenVisibleFolders', () {
    test('collapsed: only roots, depth 1, hasChildren flagged', () {
      final rows = flattenVisibleFolders(all, {});
      expect(rows.map((r) => r.folder.id), ['personal', 'work']);
      expect(rows.every((r) => r.depth == 1), isTrue);
      expect(rows.firstWhere((r) => r.folder.id == 'work').hasChildren, isTrue);
      expect(
          rows.firstWhere((r) => r.folder.id == 'personal').hasChildren, isFalse);
    });

    test('expanding a node reveals its children at depth+1, in order', () {
      final rows = flattenVisibleFolders(all, {'work'});
      expect(rows.map((r) => r.folder.id), ['personal', 'work', 'alpha', 'beta']);
      final alphaRow = rows.firstWhere((r) => r.folder.id == 'alpha');
      expect(alphaRow.depth, 2);
    });

    test('orphans never surface even when everything is expanded', () {
      final rows = flattenVisibleFolders(all, {'work', 'personal', 'ghost'});
      expect(rows.map((r) => r.folder.id), isNot(contains('orphan')));
    });
  });
}
