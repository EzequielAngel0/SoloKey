import 'package:flutter/material.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

/// The Vault list. Renders as **grouped dense rows** (1Password-style): a single
/// hairline-framed container where each credential is a flat [CredentialCard]
/// (`dense: true`) separated by hairline dividers. Stays virtualized via
/// [ListView.builder] so large vaults scroll cheaply.
///
/// When [onReorder] is provided AND [reorderMode] is on, it switches to a
/// [ReorderableListView] of individually-framed cards with an explicit drag
/// handle — the handle only shows in reorder mode so it never clutters normal
/// browsing.
class CredentialListWidget extends StatelessWidget {
  const CredentialListWidget({
    super.key,
    required this.credentials,
    this.onReorder,
    this.reorderMode = false,
  });

  final List<Credential> credentials;

  /// When provided, the list can be drag-reordered (only while [reorderMode] is
  /// true). [newIndex] is the final index after removal (onReorderItem
  /// semantics — no manual ±1 adjustment needed).
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Whether drag-to-reorder is currently active (shows drag handles).
  final bool reorderMode;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (onReorder != null && reorderMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: credentials.length,
        onReorderItem: onReorder!,
        buildDefaultDragHandles: false,
        itemBuilder: (context, i) => _ReorderRow(
          key: ValueKey(credentials[i].id),
          index: i,
          credential: credentials[i],
        ),
      );
    }

    final hairline = BorderSide(color: p.divider, width: 1);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: credentials.length,
      itemBuilder: (context, i) {
        final isFirst = i == 0;
        final isLast = i == credentials.length - 1;
        final radius = BorderRadius.vertical(
          top: Radius.circular(isFirst ? AppTheme.rCard : 0),
          bottom: Radius.circular(isLast ? AppTheme.rCard : 0),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: radius,
            border: Border(
              left: hairline,
              right: hairline,
              top: isFirst ? hairline : BorderSide.none,
              bottom: hairline,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: CredentialCard(credential: credentials[i], dense: true),
          ),
        );
      },
    );
  }
}

/// A single reorderable row: a framed dense card plus an explicit drag handle
/// on the trailing edge (only rendered in reorder mode).
class _ReorderRow extends StatelessWidget {
  const _ReorderRow({
    super.key,
    required this.index,
    required this.credential,
  });

  final int index;
  final Credential credential;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.rCard),
          side: BorderSide(color: p.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(child: CredentialCard(credential: credential, dense: true)),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Icon(Icons.drag_indicator_rounded, color: p.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
