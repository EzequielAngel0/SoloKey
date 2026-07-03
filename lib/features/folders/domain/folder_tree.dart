import 'entities/folder.dart';

/// Pure hierarchy helpers for the folder tree, extracted from `FolderTree` so
/// the parent/child/ordering/ancestor logic is unit-testable without a widget.
/// Behaviour is identical to the previous in-widget implementation.

/// Direct children of [parentId] (`null` = vault root), ordered A→Z
/// case-insensitively by name. Non-matching / orphan folders are excluded.
List<Folder> folderChildren(List<Folder> folders, String? parentId) {
  final list = folders.where((f) => f.parentId == parentId).toList();
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
}

/// Ids of [selectedId] and all of its ancestors, walking `parentId` up to the
/// root. Guards against cycles. Empty when [selectedId] is `null` or unknown.
Set<String> folderAncestorIds(List<Folder> folders, String? selectedId) {
  final byId = {for (final f in folders) f.id: f};
  final acc = <String>{};
  Folder? cur = selectedId == null ? null : byId[selectedId];
  while (cur != null && acc.add(cur.id)) {
    final pid = cur.parentId;
    cur = pid == null ? null : byId[pid];
  }
  return acc;
}

/// One visible row of the tree: the [folder], its [depth] (roots = 1) and
/// whether it [hasChildren] (to show the expander).
class FolderRow {
  const FolderRow(this.folder, this.depth, this.hasChildren);
  final Folder folder;
  final int depth;
  final bool hasChildren;
}

/// Depth-first flatten of the visible tree: starts at the roots and only
/// descends into folders whose id is in [expanded]. Mirrors the row order the
/// widget paints. Orphans (parent id not present) never surface.
List<FolderRow> flattenVisibleFolders(
  List<Folder> folders,
  Set<String> expanded,
) {
  final rows = <FolderRow>[];
  void walk(Folder f, int depth) {
    final children = folderChildren(folders, f.id);
    rows.add(FolderRow(f, depth, children.isNotEmpty));
    if (expanded.contains(f.id)) {
      for (final c in children) {
        walk(c, depth + 1);
      }
    }
  }

  for (final root in folderChildren(folders, null)) {
    walk(root, 1);
  }
  return rows;
}
