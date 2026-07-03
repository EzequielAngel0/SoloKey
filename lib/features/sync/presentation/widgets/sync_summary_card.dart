import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/detail_group.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../theme/app_palette.dart';
import '../../application/sync_status_provider.dart';
import '../../domain/sync_summary.dart';

/// "What synced" panel: shows the most recent applied round (added / updated /
/// removed, with the item names) plus a collapsible history of recent rounds.
/// Purely a consumer of [syncStatusProvider] — drop it into either the mobile or
/// desktop pairing view. Renders nothing until there is something to show.
class SyncSummaryCard extends ConsumerStatefulWidget {
  const SyncSummaryCard({super.key});

  @override
  ConsumerState<SyncSummaryCard> createState() => _SyncSummaryCardState();
}

class _SyncSummaryCardState extends ConsumerState<SyncSummaryCard> {
  bool _itemsOpen = false;
  bool _historyOpen = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(syncStatusProvider);

    // After a fresh launch lastSummary is null but the persisted history holds
    // the previous round — fall back to it so the card survives reopening.
    final last = status.lastSummary ??
        (status.history.isNotEmpty ? status.history.first : null);

    if (last == null && status.history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (last != null)
          _LastSyncSection(
            summary: last,
            itemsOpen: _itemsOpen,
            onToggleItems: () => setState(() => _itemsOpen = !_itemsOpen),
          ),
        if (status.history.isNotEmpty)
          _HistorySection(
            history: status.history,
            open: _historyOpen,
            onToggle: () => setState(() => _historyOpen = !_historyOpen),
          ),
      ],
    );
  }
}

// ── Last sync ────────────────────────────────────────────────────────────────
class _LastSyncSection extends StatelessWidget {
  const _LastSyncSection({
    required this.summary,
    required this.itemsOpen,
    required this.onToggleItems,
  });

  final SyncSummary summary;
  final bool itemsOpen;
  final VoidCallback onToggleItems;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 15, color: p.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.syncSummaryTitle.toUpperCase(),
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                relativeSyncTime(l10n, summary.timestamp),
                style: TextStyle(
                    color: p.textDisabled,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (summary.isEmpty)
          DetailGroup(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: p.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.syncSummaryNoChanges,
                      style: TextStyle(color: p.textMuted, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ])
        else ...[
          DetailGroup(children: [
            _CountRow(
              icon: Icons.vpn_key_rounded,
              label: l10n.syncCredentialsLabel,
              added: summary.credentialsAdded,
              updated: summary.credentialsUpdated,
              removed: summary.credentialsDeleted,
            ),
            _CountRow(
              icon: Icons.folder_rounded,
              label: l10n.syncFoldersLabel,
              added: summary.foldersAdded,
              updated: summary.foldersUpdated,
              removed: summary.foldersDeleted,
            ),
            InkWell(
              onTap: onToggleItems,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
                child: Row(
                  children: [
                    Icon(
                      itemsOpen
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: p.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      itemsOpen ? l10n.syncItemsHide : l10n.syncItemsShow,
                      style: TextStyle(
                          color: p.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          if (itemsOpen) ...[
            const SizedBox(height: 6),
            DetailGroup(
              children: [
                for (final c in summary.changes) _ItemRow(change: c),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.label,
    required this.added,
    required this.updated,
    required this.removed,
  });

  final IconData icon;
  final String label;
  final int added;
  final int updated;
  final int removed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[
      if (added > 0)
        StatusChip(
            label: l10n.syncCountAdded(added),
            color: p.success,
            icon: Icons.add_rounded,
            dense: true),
      if (updated > 0)
        StatusChip(
            label: l10n.syncCountUpdated(updated),
            color: p.accent,
            icon: Icons.sync_alt_rounded,
            dense: true),
      if (removed > 0)
        StatusChip(
            label: l10n.syncCountRemoved(removed),
            color: p.danger,
            icon: Icons.remove_rounded,
            dense: true),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: p.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
                color: p.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (chips.isEmpty)
            Text('—', style: TextStyle(color: p.textDisabled, fontSize: 13))
          else
            Wrap(spacing: 6, runSpacing: 6, children: chips),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.change});

  final SyncItemChange change;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final (IconData actionIcon, Color color, String actionLabel) =
        switch (change.action) {
      SyncChangeAction.added => (
          Icons.add_circle_outline_rounded,
          p.success,
          l10n.syncActionAdded
        ),
      SyncChangeAction.updated => (
          Icons.sync_alt_rounded,
          p.accent,
          l10n.syncActionUpdated
        ),
      SyncChangeAction.deleted => (
          Icons.remove_circle_outline_rounded,
          p.danger,
          l10n.syncActionRemoved
        ),
    };
    final kindIcon = change.kind == SyncEntityKind.folder
        ? Icons.folder_rounded
        : Icons.vpn_key_rounded;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 12, 9),
      child: Row(
        children: [
          Icon(kindIcon, size: 15, color: p.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              change.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textPrimary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Icon(actionIcon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            actionLabel,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── History ──────────────────────────────────────────────────────────────────
class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.history,
    required this.open,
    required this.onToggle,
  });

  final List<SyncSummary> history;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.syncHistoryTitle.toUpperCase(),
                    style: TextStyle(
                      color: p.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Icon(
                  open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: p.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (open)
          DetailGroup(
            children: [
              for (final s in history.take(8)) _HistoryRow(summary: s),
            ],
          ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.summary});

  final SyncSummary summary;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final parts = <String>[
      if (summary.credentialsTotal > 0)
        '${summary.credentialsTotal} ${l10n.syncCredentialsLabel.toLowerCase()}',
      if (summary.foldersTotal > 0)
        '${summary.foldersTotal} ${l10n.syncFoldersLabel.toLowerCase()}',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 9, 12, 9),
      child: Row(
        children: [
          Icon(Icons.sync_rounded, size: 14, color: p.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parts.isEmpty ? l10n.syncSummaryNoChanges : parts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textPrimary, fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            relativeSyncTime(l10n, summary.timestamp),
            style: TextStyle(color: p.textDisabled, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Localized coarse "x ago" label for a sync timestamp.
String relativeSyncTime(AppLocalizations l10n, DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return l10n.syncRelativeNow;
  if (diff.inMinutes < 60) return l10n.syncRelativeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.syncRelativeHours(diff.inHours);
  return l10n.syncRelativeDays(diff.inDays);
}
