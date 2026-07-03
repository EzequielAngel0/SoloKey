import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/extensions/color_extensions.dart';
import '../../../../theme/app_palette.dart';
import '../../../credentials/application/credentials_provider.dart';
import '../../application/folders_provider.dart';
import '../../domain/entities/folder.dart';
import '../../domain/folder_tree.dart';
import '../folder_actions.dart';

/// Contextual actions available on a folder node.
enum _FolderMenuAction { addSubfolder, rename, toggleFavorite, delete }

/// Expandable folder tree for the desktop master-detail. Lets the user jump to
/// ANY folder/level in one click (no "go back to root"), with the full
/// hierarchy always visible. Selecting a node calls [onSelect]; `null` = the
/// vault root (unfiled credentials).
///
/// Each folder row exposes management actions (new subfolder / rename /
/// favourite / delete) through a "⋯" button and a right-click context menu, and
/// shows how many credentials live directly in it. The tree is keyboard
/// navigable: ↑/↓ move the selection, →/← expand/collapse (or step in/out).
class FolderTree extends ConsumerStatefulWidget {
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
  ConsumerState<FolderTree> createState() => _FolderTreeState();
}

class _FolderTreeState extends ConsumerState<FolderTree> {
  final Set<String> _expanded = {};
  final FocusNode _focusNode = FocusNode(debugLabel: 'FolderTree');

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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _expandAncestors() {
    _expanded.addAll(folderAncestorIds(widget.folders, widget.selectedId));
  }

  List<Folder> _childrenOf(String? parentId) =>
      folderChildren(widget.folders, parentId);

  /// Direct-credential count per folder id (`null` key = unfiled), excluding
  /// hidden entries so it matches the list shown below the tree.
  Map<String?, int> _counts() {
    final creds =
        ref.watch(credentialsNotifierProvider).valueOrNull ?? const [];
    final map = <String?, int>{};
    for (final c in creds) {
      if (c.isHidden) continue;
      map[c.categoryId] = (map[c.categoryId] ?? 0) + 1;
    }
    return map;
  }

  // ── Keyboard navigation ──────────────────────────────────────────────────
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final order = <String?>[
      null,
      ...flattenVisibleFolders(widget.folders, _expanded).map((r) => r.folder.id),
    ];
    final idx = order.indexOf(widget.selectedId);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      if (idx < order.length - 1) widget.onSelect(order[idx + 1]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      if (idx > 0) widget.onSelect(order[idx - 1]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      final id = widget.selectedId;
      if (id != null &&
          _childrenOf(id).isNotEmpty &&
          !_expanded.contains(id)) {
        setState(() => _expanded.add(id));
      } else if (idx < order.length - 1) {
        widget.onSelect(order[idx + 1]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      final id = widget.selectedId;
      if (id != null && _expanded.contains(id)) {
        setState(() => _expanded.remove(id));
      } else if (id != null) {
        final parent =
            widget.folders.where((f) => f.id == id).firstOrNull?.parentId;
        widget.onSelect(parent);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── Contextual actions ───────────────────────────────────────────────────
  Future<void> _runAction(_FolderMenuAction action, Folder folder) async {
    switch (action) {
      case _FolderMenuAction.addSubfolder:
        final created =
            await promptCreateFolder(context, ref, parentId: folder.id);
        if (created != null && mounted) {
          setState(() => _expanded.add(folder.id));
        }
      case _FolderMenuAction.rename:
        await promptRenameFolder(context, ref, folder);
      case _FolderMenuAction.toggleFavorite:
        await ref
            .read(foldersNotifierProvider.notifier)
            .toggleFavorite(folder.id);
      case _FolderMenuAction.delete:
        await confirmDeleteFolder(
          context,
          ref,
          folder,
          onDeleted: () {
            final affected = folderDescendantIds(widget.folders, folder.id);
            if (widget.selectedId != null &&
                affected.contains(widget.selectedId)) {
              widget.onSelect(null);
            }
          },
        );
    }
  }

  List<PopupMenuEntry<_FolderMenuAction>> _menuItems(
      AppLocalizations l10n, Folder folder) {
    final p = context.palette;
    return [
      PopupMenuItem(
        value: _FolderMenuAction.addSubfolder,
        child: _menuRow(Icons.create_new_folder_outlined, l10n.folderNewSubfolder,
            p.textPrimary),
      ),
      PopupMenuItem(
        value: _FolderMenuAction.rename,
        child: _menuRow(Icons.edit_rounded, l10n.commonEdit, p.textPrimary),
      ),
      PopupMenuItem(
        value: _FolderMenuAction.toggleFavorite,
        child: _menuRow(
          folder.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
          folder.isFavorite ? l10n.detailRemoveFavorite : l10n.detailAddFavorite,
          p.warning,
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: _FolderMenuAction.delete,
        child: _menuRow(Icons.delete_outline_rounded, l10n.commonDelete, p.danger),
      ),
    ];
  }

  Widget _menuRow(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Flexible(
            child: Text(label,
                style: TextStyle(color: color), overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  /// Drop handler: a credential dragged onto a node is moved into that folder
  /// (`null` = vault root). Plain-column move, so it syncs without re-encrypting.
  Future<void> _moveCredentialHere(String credentialId, String? folderId) async {
    await ref
        .read(credentialsNotifierProvider.notifier)
        .moveToFolder(credentialId, folderId);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.cardMovedSuccess),
      backgroundColor: context.palette.success,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _showContextMenu(Folder folder, Offset globalPosition) async {
    final l10n = AppLocalizations.of(context);
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<_FolderMenuAction>(
      context: context,
      color: context.palette.drawer,
      position: RelativeRect.fromRect(
        globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: _menuItems(l10n, folder),
    );
    if (action != null) await _runAction(action, folder);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final counts = _counts();

    final rows = <Widget>[
      _TreeRow(
        label: l10n.navVault,
        icon: Icons.account_tree_rounded,
        color: p.primary,
        depth: 0,
        selected: widget.selectedId == null,
        hasChildren: false,
        expanded: false,
        count: counts[null] ?? 0,
        onTap: () {
          _focusNode.requestFocus();
          widget.onSelect(null);
        },
        onAcceptCredential: (id) => _moveCredentialHere(id, null),
      ),
    ];
    for (final f in _childrenOf(null)) {
      _append(rows, f, 1, counts, l10n);
    }

    return Semantics(
      hint: l10n.folderTreeHint,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: rows,
        ),
      ),
    );
  }

  void _append(List<Widget> rows, Folder f, int depth,
      Map<String?, int> counts, AppLocalizations l10n) {
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
      count: counts[f.id] ?? 0,
      onTap: () {
        _focusNode.requestFocus();
        widget.onSelect(f.id);
      },
      onToggle: hasChildren
          ? () => setState(
              () => expanded ? _expanded.remove(f.id) : _expanded.add(f.id))
          : null,
      menu: PopupMenuButton<_FolderMenuAction>(
        icon: Icon(Icons.more_horiz_rounded, color: context.palette.textMuted),
        iconSize: 18,
        padding: EdgeInsets.zero,
        tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        color: context.palette.drawer,
        itemBuilder: (_) => _menuItems(l10n, f),
        onSelected: (a) => _runAction(a, f),
      ),
      onSecondaryTap: (pos) => _showContextMenu(f, pos),
      onAcceptCredential: (id) => _moveCredentialHere(id, f.id),
    ));
    if (expanded) {
      for (final c in children) {
        _append(rows, c, depth + 1, counts, l10n);
      }
    }
  }

}

class _TreeRow extends StatefulWidget {
  const _TreeRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.depth,
    required this.selected,
    required this.hasChildren,
    required this.expanded,
    required this.count,
    required this.onTap,
    this.onToggle,
    this.menu,
    this.onSecondaryTap,
    this.onAcceptCredential,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int depth;
  final bool selected;
  final bool hasChildren;
  final bool expanded;
  final int count;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final Widget? menu;
  final ValueChanged<Offset>? onSecondaryTap;

  /// Called with a dropped credential id when one is dragged onto this node.
  final ValueChanged<String>? onAcceptCredential;

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onAcceptCredential == null) return _row(context, false);
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => widget.onAcceptCredential!(d.data),
      builder: (context, candidate, rejected) =>
          _row(context, candidate.isNotEmpty),
    );
  }

  Widget _row(BuildContext context, bool dragOver) {
    final p = context.palette;
    final showMenuBtn = widget.menu != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: dragOver
              ? p.primary.withValues(alpha: 0.28)
              : widget.selected
                  ? p.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onSecondaryTapDown: widget.onSecondaryTap == null
                ? null
                : (d) => widget.onSecondaryTap!(d.globalPosition),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.fromLTRB(6.0 + widget.depth * 14, 6, 4, 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: widget.hasChildren
                          ? InkWell(
                              onTap: widget.onToggle,
                              borderRadius: BorderRadius.circular(4),
                              child: Icon(
                                widget.expanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_right_rounded,
                                size: 18,
                                color: p.textMuted,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 2),
                    Icon(widget.icon, color: widget.color, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.selected ? p.textPrimary : p.textBody,
                          fontSize: 13.5,
                          fontWeight:
                              widget.selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (widget.count > 0 && !(showMenuBtn && _hovered)) ...[
                      const SizedBox(width: 6),
                      _CountPill(count: widget.count),
                    ],
                    if (showMenuBtn && (_hovered || widget.selected))
                      SizedBox(width: 28, height: 28, child: widget.menu)
                    else if (showMenuBtn)
                      const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.divider),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: p.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
