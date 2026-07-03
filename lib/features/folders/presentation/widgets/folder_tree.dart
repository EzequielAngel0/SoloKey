import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../theme/app_palette.dart';
import '../../domain/entities/folder.dart';
import '../../domain/folder_tree.dart';

/// Expandable folder tree for the desktop master-detail. Lets the user jump to
/// ANY folder/level in one click (no "go back to root"), with the full
/// hierarchy always visible. Selecting a node calls [onSelect]; `null` = the
/// vault root (unfiled credentials).
class FolderTree extends StatefulWidget {
  const FolderTree({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Folder> folders;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  State<FolderTree> createState() => _FolderTreeState();
}

class _FolderTreeState extends State<FolderTree> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _expandAncestors();
  }

  @override
  void didUpdateWidget(covariant FolderTree old) {
    super.didUpdateWidget(old);
    if (old.selectedId != widget.selectedId) _expandAncestors();
  }

  void _expandAncestors() {
    _expanded.addAll(folderAncestorIds(widget.folders, widget.selectedId));
  }

  List<Folder> _childrenOf(String? parentId) =>
      folderChildren(widget.folders, parentId);

  void _append(List<Widget> rows, Folder f, int depth) {
    final children = _childrenOf(f.id);
    final hasChildren = children.isNotEmpty;
    final expanded = _expanded.contains(f.id);
    rows.add(_TreeRow(
      label: f.name,
      icon: f.isFavorite ? Icons.folder_special_rounded : Icons.folder_rounded,
      color: f.colorHex.toColor(),
      depth: depth,
      selected: widget.selectedId == f.id,
      hasChildren: hasChildren,
      expanded: expanded,
      onTap: () => widget.onSelect(f.id),
      onToggle: hasChildren
          ? () => setState(() =>
              expanded ? _expanded.remove(f.id) : _expanded.add(f.id))
          : null,
    ));
    if (expanded) {
      for (final c in children) {
        _append(rows, c, depth + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final rows = <Widget>[
      _TreeRow(
        label: l10n.navVault,
        icon: Icons.account_tree_rounded,
        color: p.primary,
        depth: 0,
        selected: widget.selectedId == null,
        hasChildren: false,
        expanded: false,
        onTap: () => widget.onSelect(null),
      ),
    ];
    for (final f in _childrenOf(null)) {
      _append(rows, f, 1);
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: rows,
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.depth,
    required this.selected,
    required this.hasChildren,
    required this.expanded,
    required this.onTap,
    this.onToggle,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int depth;
  final bool selected;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? p.primary.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.fromLTRB(6.0 + depth * 14, 8, 10, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: hasChildren
                      ? InkWell(
                          onTap: onToggle,
                          borderRadius: BorderRadius.circular(4),
                          child: Icon(
                            expanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            size: 18,
                            color: p.textMuted,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 2),
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? p.textPrimary : p.textBody,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
