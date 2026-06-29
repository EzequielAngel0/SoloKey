import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../core/presentation/layouts/responsive_layout.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_palette.dart';
import '../../domain/entities/folder.dart';

/// Breadcrumb trail (Bóveda › Trabajo › Cloud) so the user always knows where
/// they are and can jump to ANY ancestor in one tap — no more "go back to the
/// root to reach the previous folder".
///
/// - **Desktop:** a tap sets [desktopSelectedFolderIdProvider] (jumps in-place).
/// - **Mobile:** each level is a pushed route, so a tap pops the right number of
///   routes to land on the chosen ancestor.
class FolderBreadcrumbs extends ConsumerWidget {
  const FolderBreadcrumbs({
    super.key,
    required this.folders,
    required this.currentId,
  });

  final List<Folder> folders;
  final String currentId;

  /// Top-most ancestor → current folder (inclusive). Guards against cycles.
  List<Folder> _path() {
    final byId = {for (final f in folders) f.id: f};
    final path = <Folder>[];
    final seen = <String>{};
    Folder? cur = byId[currentId];
    while (cur != null && !seen.contains(cur.id)) {
      seen.add(cur.id);
      path.insert(0, cur);
      final pid = cur.parentId;
      cur = pid == null ? null : byId[pid];
    }
    return path;
  }

  void _goTo(BuildContext context, WidgetRef ref, List<Folder> path, int index) {
    if (ResponsiveLayout.isDesktop(context)) {
      ref.read(desktopSelectedFolderIdProvider.notifier).state =
          index < 0 ? null : path[index].id;
    } else {
      // Mobile: pop (currentDepth - target) routes; root crumb pops them all.
      final pops = index < 0 ? path.length : (path.length - 1 - index);
      final nav = Navigator.of(context);
      for (var i = 0; i < pops; i++) {
        if (nav.canPop()) nav.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final path = _path();

    final crumbs = <Widget>[
      _crumb(
        label: l10n.navVault,
        isCurrent: path.isEmpty,
        palette: p,
        onTap: () => _goTo(context, ref, path, -1),
      ),
    ];
    for (var i = 0; i < path.length; i++) {
      final isLast = i == path.length - 1;
      crumbs
        ..add(_sep(p))
        ..add(_crumb(
          label: path[i].name,
          isCurrent: isLast,
          palette: p,
          onTap: isLast ? null : () => _goTo(context, ref, path, i),
        ));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: crumbs),
      ),
    );
  }

  Widget _sep(AppPalette p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.chevron_right_rounded, size: 16, color: p.textDisabled),
      );

  Widget _crumb({
    required String label,
    required bool isCurrent,
    required AppPalette palette,
    VoidCallback? onTap,
  }) {
    final text = Text(
      label,
      style: TextStyle(
        color: isCurrent ? palette.textPrimary : palette.info,
        fontSize: 13,
        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    if (onTap == null || isCurrent) return text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: text,
      ),
    );
  }
}
