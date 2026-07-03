import 'package:flutter/material.dart';
import '../../../../shared/widgets/detail_group.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

/// The Vault list. Renders as **grouped dense rows** (1Password-style): a single
/// hairline-framed container where each credential is a flat [CredentialCard]
/// (`dense: true`) separated by hairline dividers. Stays virtualized via
/// [ListView.builder] so large vaults scroll cheaply.
///
/// When [sectioned] is on (used with the A–Z sort), the list is broken into
/// alphabetical groups, each its own rounded container under a letter header.
///
/// When [onReorder] is provided AND [reorderMode] is on, it switches to a
/// [ReorderableListView] of individually-framed cards with an explicit drag
/// handle — the handle only shows in reorder mode so it never clutters normal
/// browsing. Sectioning and reordering are mutually exclusive (reorder only
/// runs under the manual sort, which is never sectioned).
class CredentialListWidget extends StatelessWidget {
  const CredentialListWidget({
    super.key,
    required this.credentials,
    this.onReorder,
    this.reorderMode = false,
    this.sectioned = false,
  });

  final List<Credential> credentials;

  /// When provided, the list can be drag-reordered (only while [reorderMode] is
  /// true). [newIndex] is the final index after removal (onReorderItem
  /// semantics — no manual ±1 adjustment needed).
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Whether drag-to-reorder is currently active (shows drag handles).
  final bool reorderMode;

  /// Whether to break an already A–Z-sorted list into alphabetical sections
  /// with letter headers. Ignored while reordering.
  final bool sectioned;

  static const _padding = EdgeInsets.fromLTRB(16, 12, 16, 100);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (onReorder != null && reorderMode) {
      return ReorderableListView.builder(
        padding: _padding,
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

    if (sectioned) {
      final entries = _buildSectionEntries(credentials);
      return ListView.builder(
        padding: _padding,
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          return e is _HeaderEntry
              ? SectionHeader(text: e.letter)
              : _denseItem(p, (e as _ItemEntry).credential,
                  isFirst: e.isFirst, isLast: e.isLast);
        },
      );
    }

    return ListView.builder(
      padding: _padding,
      itemCount: credentials.length,
      itemBuilder: (context, i) => _denseItem(
        p,
        credentials[i],
        isFirst: i == 0,
        isLast: i == credentials.length - 1,
      ),
    );
  }

  /// One dense credential row framed as part of a rounded hairline group:
  /// [isFirst]/[isLast] control the corner rounding and the top border so a run
  /// of rows reads as a single container.
  Widget _denseItem(AppPalette p, Credential c,
      {required bool isFirst, required bool isLast}) {
    final hairline = BorderSide(color: p.divider, width: 1);
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
        child: CredentialCard(credential: c, dense: true),
      ),
    );
  }

  /// Flattens an already A–Z-sorted [creds] into header + item entries. Each
  /// alphabetical run yields a [_HeaderEntry] followed by its [_ItemEntry]s,
  /// with the first/last flags set so every run renders as its own group.
  static List<_ListEntry> _buildSectionEntries(List<Credential> creds) {
    final out = <_ListEntry>[];
    String? current;
    var runStart = 0;
    for (var i = 0; i < creds.length; i++) {
      final letter = _sectionLetter(creds[i].title);
      if (letter != current) {
        current = letter;
        runStart = i;
        out.add(_HeaderEntry(letter));
      }
      // Peek whether the next credential opens a new section (or the list ends).
      final isLastInRun =
          i == creds.length - 1 || _sectionLetter(creds[i + 1].title) != letter;
      out.add(_ItemEntry(creds[i],
          isFirst: i == runStart, isLast: isLastInRun));
    }
    return out;
  }

  /// Bucket letter for [title]: an uppercase A–Z initial, or '#' for anything
  /// that does not start with a latin letter (digits, symbols, blank).
  static String _sectionLetter(String title) {
    final trimmed = title.trimLeft();
    if (trimmed.isEmpty) return '#';
    final first = trimmed[0].toUpperCase();
    return RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
  }
}

/// An entry in the sectioned list model — either a letter header or a credential.
sealed class _ListEntry {
  const _ListEntry();
}

class _HeaderEntry extends _ListEntry {
  const _HeaderEntry(this.letter);
  final String letter;
}

class _ItemEntry extends _ListEntry {
  const _ItemEntry(this.credential,
      {required this.isFirst, required this.isLast});
  final Credential credential;
  final bool isFirst;
  final bool isLast;
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
