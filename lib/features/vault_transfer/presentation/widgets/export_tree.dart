import 'package:flutter/material.dart';

import '../../../../core/services/vault_export_service.dart' show kNoFolderFilterId;
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../../credentials/domain/entities/credential.dart';
import '../../../folders/domain/entities/folder.dart';

/// Hierarchical selector for the export tab: folders (with nested subfolders)
/// shown as collapsible nodes with tri-state checkboxes, and individual
/// credentials as selectable leaves. Selection is expressed as a set of
/// credential ids owned by the parent.
class ExportTree extends StatefulWidget {
  const ExportTree({
    super.key,
    required this.folders,
    required this.credentials,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.typeIcon,
  });

  final List<Folder> folders;
  final List<Credential> credentials;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final IconData Function(CredentialType) typeIcon;

  @override
  State<ExportTree> createState() => _ExportTreeState();
}

class _ExportTreeState extends State<ExportTree> {
  // parentId (null = root) -> subfolders
  final Map<String?, List<Folder>> _childrenOf = {};
  // folderId (null = "no folder") -> credentials
  final Map<String?, List<Credential>> _credsOf = {};
  // expanded node keys (folder id, or kNoFolderFilterId for the unfiled group)
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _rebuildIndex();
  }

  @override
  void didUpdateWidget(covariant ExportTree old) {
    super.didUpdateWidget(old);
    if (old.folders != widget.folders || old.credentials != widget.credentials) {
      _rebuildIndex();
    }
  }

  void _rebuildIndex() {
    _childrenOf.clear();
    _credsOf.clear();
    final validIds = widget.folders.map((f) => f.id).toSet();
    for (final f in widget.folders) {
      final key = (f.parentId != null && validIds.contains(f.parentId))
          ? f.parentId
          : null;
      (_childrenOf[key] ??= []).add(f);
    }
    for (final list in _childrenOf.values) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    for (final c in widget.credentials) {
      // La carpeta de una credencial se guarda en `categoryId` (asi lo escribe
      // el formulario y lo filtra folder_screen). El campo `folderId` esta en
      // desuso para credenciales, por eso antes el arbol mostraba TODO bajo
      // "Sin carpeta".
      final key = (c.categoryId != null && validIds.contains(c.categoryId))
          ? c.categoryId
          : null;
      (_credsOf[key] ??= []).add(c);
    }
    for (final list in _credsOf.values) {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
  }

  Set<String> _descendantCredIds(String? folderId) {
    final ids = <String>{};
    void walk(String? fid) {
      for (final c in _credsOf[fid] ?? const <Credential>[]) {
        ids.add(c.id);
      }
      for (final sub in _childrenOf[fid] ?? const <Folder>[]) {
        walk(sub.id);
      }
    }

    walk(folderId);
    return ids;
  }

  /// true = all selected, false = none, null = some (partial).
  bool? _triState(Set<String> ids) {
    if (ids.isEmpty) return false;
    final sel = widget.selectedIds;
    var any = false;
    var all = true;
    for (final id in ids) {
      if (sel.contains(id)) {
        any = true;
      } else {
        all = false;
      }
    }
    if (all) return true;
    return any ? null : false;
  }

  void _toggleCred(String id, bool select) {
    final next = {...widget.selectedIds};
    if (select) {
      next.add(id);
    } else {
      next.remove(id);
    }
    widget.onSelectionChanged(next);
  }

  void _toggleFolder(String? folderId, bool? current) {
    final ids = _descendantCredIds(folderId);
    final next = {...widget.selectedIds};
    if (current == true) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    widget.onSelectionChanged(next);
  }

  void _toggleExpand(String key) {
    setState(() {
      if (!_expanded.remove(key)) _expanded.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final allIds = widget.credentials.map((c) => c.id).toSet();
    final selectedCount = widget.selectedIds.where(allIds.contains).length;

    final rootFolders = _childrenOf[null] ?? const <Folder>[];
    final noFolderCreds = _credsOf[null] ?? const <Credential>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectAllHeader(
          state: _triState(allIds),
          label: l10n.transferSelectAll,
          count: selectedCount,
          total: allIds.length,
          onToggle: () => widget.onSelectionChanged(
            _triState(allIds) == true ? <String>{} : {...allIds},
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (final f in rootFolders) _folderNode(f, 0),
              if (noFolderCreds.isNotEmpty) _noFolderNode(0),
              if (rootFolders.isEmpty && noFolderCreds.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.homeEmptyVault,
                    style: TextStyle(color: palette.textMuted, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _folderNode(Folder f, int depth) {
    final palette = context.palette;
    final ids = _descendantCredIds(f.id);
    final expanded = _expanded.contains(f.id);
    final hasChildren = (_childrenOf[f.id]?.isNotEmpty ?? false) ||
        (_credsOf[f.id]?.isNotEmpty ?? false);
    return Column(
      children: [
        _NodeRow(
          depth: depth,
          hasExpand: hasChildren,
          expanded: expanded,
          onExpand: hasChildren ? () => _toggleExpand(f.id) : null,
          checkState: _triState(ids),
          onCheck: ids.isEmpty ? null : () => _toggleFolder(f.id, _triState(ids)),
          icon: Icons.folder_rounded,
          iconColor: palette.accent,
          title: f.name,
          bold: true,
          count: ids.length,
        ),
        if (expanded)
          for (final sub in _childrenOf[f.id] ?? const <Folder>[])
            _folderNode(sub, depth + 1),
        if (expanded)
          for (final c in _credsOf[f.id] ?? const <Credential>[])
            _credRow(c, depth + 1),
      ],
    );
  }

  Widget _noFolderNode(int depth) {
    final palette = context.palette;
    final creds = _credsOf[null] ?? const <Credential>[];
    final ids = creds.map((c) => c.id).toSet();
    final expanded = _expanded.contains(kNoFolderFilterId);
    return Column(
      children: [
        _NodeRow(
          depth: depth,
          hasExpand: creds.isNotEmpty,
          expanded: expanded,
          onExpand: creds.isEmpty ? null : () => _toggleExpand(kNoFolderFilterId),
          checkState: _triState(ids),
          onCheck: ids.isEmpty ? null : () => _toggleFolder(null, _triState(ids)),
          icon: Icons.folder_off_rounded,
          iconColor: palette.textMuted,
          title: AppLocalizations.of(context).transferNoFolder,
          bold: true,
          count: ids.length,
        ),
        if (expanded) for (final c in creds) _credRow(c, depth + 1),
      ],
    );
  }

  Widget _credRow(Credential c, int depth) {
    final palette = context.palette;
    final selected = widget.selectedIds.contains(c.id);
    return _NodeRow(
      depth: depth,
      hasExpand: false,
      expanded: false,
      onExpand: null,
      checkState: selected,
      onCheck: () => _toggleCred(c.id, !selected),
      icon: widget.typeIcon(c.type),
      iconColor: palette.accent.withValues(alpha: 0.75),
      title: c.title,
      subtitle: c.username,
      bold: false,
      count: null,
    );
  }
}

class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.depth,
    required this.hasExpand,
    required this.expanded,
    required this.onExpand,
    required this.checkState,
    required this.onCheck,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.bold,
    this.subtitle,
    this.count,
  });

  final int depth;
  final bool hasExpand;
  final bool expanded;
  final VoidCallback? onExpand;
  final bool? checkState;
  final VoidCallback? onCheck;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool bold;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      // Tocar la fila SELECCIONA (tri-estado en carpetas, marca en credenciales).
      // La expansion para ver/seleccionar credenciales individuales queda en el
      // chevron. Antes la fila expandia y solo el checkbox diminuto seleccionaba,
      // lo que hacia parecer que "la seleccion no funcionaba".
      onTap: onCheck ?? onExpand,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8 + depth * 18.0, 2, 8, 2),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: hasExpand
                  ? IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        expanded
                            ? Icons.expand_more_rounded
                            : Icons.chevron_right_rounded,
                        color: palette.textMuted,
                        size: 20,
                      ),
                      onPressed: onExpand,
                    )
                  : null,
            ),
            Checkbox(
              tristate: true,
              value: checkState,
              activeColor: palette.accent,
              checkColor: palette.onPrimary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onCheck == null ? null : (_) => onCheck!(),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.textMuted, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              _Badge(count: count!),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectAllHeader extends StatelessWidget {
  const _SelectAllHeader({
    required this.state,
    required this.label,
    required this.count,
    required this.total,
    required this.onToggle,
  });

  final bool? state;
  final String label;
  final int count;
  final int total;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Checkbox(
              tristate: true,
              value: state,
              activeColor: palette.accent,
              checkColor: palette.onPrimary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$count / $total',
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: palette.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
