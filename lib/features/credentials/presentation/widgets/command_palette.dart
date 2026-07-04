import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_router.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../../folders/presentation/folder_actions.dart';
import '../../../vault_access/application/vault_state_provider.dart';
import '../../application/credentials_provider.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

/// Global command palette (Ctrl+K) for the desktop layout: fuzzy-search the
/// whole vault, jump to a credential in-place, and run quick actions. Results
/// are grouped (actions / credentials), fully keyboard-driven (↑/↓ to move,
/// Enter to run, Esc to close) and matches are highlighted. Flat Graphite Pro:
/// a single elevated surface with a hairline border.
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  /// Shows the palette as a top-aligned dialog.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

/// A runnable action row in the palette (New credential, Go to Audit, Lock, …).
class _PaletteAction {
  const _PaletteAction({
    required this.icon,
    required this.label,
    required this.onSelect,
    this.keywords = '',
    this.danger = false,
  });

  final IconData icon;
  final String label;

  /// Full effect of choosing this action (including closing the palette).
  final VoidCallback onSelect;

  /// Extra searchable text so an action matches on synonyms, not just its label.
  final String keywords;
  final bool danger;
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  /// Key attached to the currently-highlighted row so we can keep it in view
  /// while navigating with the arrow keys.
  final _selectedKey = GlobalKey();

  String _query = '';

  /// Index into the flat list of selectable entries ([_selectableCount]).
  int _selected = 0;

  /// Number of selectable rows in the last build — the arrow-key clamp bound.
  int _selectableCount = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openCredential(String id) {
    ref.read(desktopSelectedNavigationProvider.notifier).state = 0;
    ref.read(desktopSelectedCredentialIdProvider.notifier).state = id;
    ref.read(desktopRightPaneModeProvider.notifier).state =
        RightPaneMode.details;
    Navigator.of(context).pop();
  }

  /// Runs [effect] then closes the palette.
  void _runAction(VoidCallback effect) {
    effect();
    Navigator.of(context).pop();
  }

  /// Create-folder flow: jumps to the Folders tab and opens the shared creator
  /// dialog on top of the palette, closing the palette once it resolves.
  Future<void> _newFolder() async {
    ref.read(desktopSelectedNavigationProvider.notifier).state = 1;
    await promptCreateFolder(context, ref);
    if (mounted) Navigator.of(context).pop();
  }

  /// The full action set, in display order. Filtered by the query at build time.
  List<_PaletteAction> _actions(AppLocalizations l10n) {
    void goTab(int index) => ref
        .read(desktopSelectedNavigationProvider.notifier)
        .state = index;
    return [
      _PaletteAction(
        icon: Icons.add_rounded,
        label: l10n.desktopNewCredentialTooltip,
        keywords: 'new create credential add',
        onSelect: () => _runAction(() {
          goTab(0);
          ref.read(desktopRightPaneModeProvider.notifier).state =
              RightPaneMode.create;
          ref.read(desktopSelectedCredentialIdProvider.notifier).state = null;
        }),
      ),
      _PaletteAction(
        icon: Icons.create_new_folder_rounded,
        label: l10n.desktopNewFolderTooltip,
        keywords: 'new create folder add',
        onSelect: _newFolder,
      ),
      _PaletteAction(
        icon: Icons.inventory_2_rounded,
        label: l10n.navVault,
        keywords: 'vault go',
        onSelect: () => _runAction(() => goTab(0)),
      ),
      _PaletteAction(
        icon: Icons.folder_rounded,
        label: l10n.navFolders,
        keywords: 'folders go',
        onSelect: () => _runAction(() => goTab(1)),
      ),
      _PaletteAction(
        icon: Icons.star_rounded,
        label: l10n.navFavorites,
        keywords: 'favorites favourites go',
        onSelect: () => _runAction(() => goTab(2)),
      ),
      _PaletteAction(
        icon: Icons.shield_rounded,
        label: l10n.navAudit,
        keywords: 'audit security watchtower go',
        onSelect: () => _runAction(() => goTab(3)),
      ),
      _PaletteAction(
        icon: Icons.folder_shared_rounded,
        label: l10n.navSecureFiles,
        keywords: 'secure files go',
        onSelect: () => _runAction(() => goTab(6)),
      ),
      _PaletteAction(
        icon: Icons.sync_rounded,
        label: l10n.navSync,
        keywords: 'sync devices pair go',
        onSelect: () => _runAction(() => goTab(5)),
      ),
      _PaletteAction(
        icon: Icons.settings_rounded,
        label: l10n.navSettings,
        keywords: 'settings preferences go',
        onSelect: () => _runAction(() => goTab(4)),
      ),
      _PaletteAction(
        icon: Icons.lock_rounded,
        label: l10n.homeLockTooltip,
        keywords: 'lock logout',
        danger: true,
        onSelect: () => _runAction(() {
          ref.read(vaultNotifierProvider.notifier).lock();
          context.go(AppRoutes.unlock);
        }),
      ),
    ];
  }

  bool _matchesCredential(Credential c, String q) =>
      c.title.toLowerCase().contains(q) ||
      (c.username?.toLowerCase().contains(q) ?? false) ||
      (c.website?.toLowerCase().contains(q) ?? false);

  void _move(int delta) {
    if (_selectableCount == 0) return;
    setState(() {
      _selected = (_selected + delta).clamp(0, _selectableCount - 1);
    });
    // Keep the highlighted row visible after the frame that repaints it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _selectedKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            alignment: 0.5, duration: const Duration(milliseconds: 120));
      }
    });
  }

  /// Runs whatever the highlighted row points at (Enter / row tap).
  void _activateSelected(
      List<_PaletteAction> actions, List<Credential> creds) {
    if (_selected < actions.length) {
      actions[_selected].onSelect();
    } else {
      final credIndex = _selected - actions.length;
      if (credIndex >= 0 && credIndex < creds.length) {
        _openCredential(creds[credIndex].id);
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    // Enter is handled via the TextField's onSubmitted; Esc falls through to the
    // default dialog dismiss.
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(credentialsNotifierProvider).valueOrNull ?? [];
    final q = _query.trim().toLowerCase();

    final actions = _actions(l10n);
    final visibleActions = q.isEmpty
        ? actions
        : actions
            .where((a) =>
                a.label.toLowerCase().contains(q) || a.keywords.contains(q))
            .toList();
    final credMatches = q.isEmpty
        ? <Credential>[]
        : all.where((c) => _matchesCredential(c, q)).take(8).toList();

    _selectableCount = visibleActions.length + credMatches.length;
    if (_selected >= _selectableCount) {
      _selected = _selectableCount == 0 ? 0 : _selectableCount - 1;
    }
    if (_selected < 0) _selected = 0;

    // Build the row list (headers + selectable entries), tracking a flat index
    // so the highlight and keyboard selection line up with [_selectableCount].
    final rows = <Widget>[];
    var flatIndex = 0;
    if (visibleActions.isNotEmpty) {
      rows.add(_GroupHeader(label: l10n.commandActionsGroup));
      for (final a in visibleActions) {
        final i = flatIndex++;
        rows.add(_ActionRow(
          key: i == _selected ? _selectedKey : null,
          action: a,
          selected: i == _selected,
          query: q,
          onTap: a.onSelect,
        ));
      }
    }
    if (credMatches.isNotEmpty) {
      rows.add(_GroupHeader(label: l10n.commandCredentialsGroup));
      for (final c in credMatches) {
        final i = flatIndex++;
        rows.add(_CredentialRow(
          key: i == _selected ? _selectedKey : null,
          credential: c,
          selected: i == _selected,
          query: q,
          onTap: () => _openCredential(c.id),
        ));
      }
    }
    if (_selectableCount == 0) {
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Text(l10n.commandNoResults, style: TextStyle(color: p.textMuted)),
      ));
    }

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 96, left: 24, right: 24),
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        side: BorderSide(color: p.divider),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Focus(
          onKeyEvent: _onKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: p.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: (v) => setState(() {
                          _query = v;
                          _selected = 0;
                        }),
                        onSubmitted: (_) =>
                            _activateSelected(visibleActions, credMatches),
                        style: TextStyle(color: p.textPrimary, fontSize: 16),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: l10n.homeSearchHint,
                          hintStyle: TextStyle(color: p.textDisabled),
                        ),
                      ),
                    ),
                    _KbdHint(
                        label: 'Ctrl K',
                        color: p.textDisabled,
                        border: p.divider),
                  ],
                ),
              ),
              Divider(height: 1, color: p.divider),
              Flexible(
                child: ListView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: rows,
                ),
              ),
              Divider(height: 1, color: p.divider),
              _PaletteFooter(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [text] with the matched [query] substring emphasized.
Widget _highlighted(
  String text,
  String query,
  TextStyle base,
  Color highlight,
) {
  if (query.isEmpty) {
    return Text(text, style: base, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
  final idx = text.toLowerCase().indexOf(query);
  if (idx < 0) {
    return Text(text, style: base, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
  return Text.rich(
    TextSpan(style: base, children: [
      TextSpan(text: text.substring(0, idx)),
      TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(color: highlight, fontWeight: FontWeight.w700),
      ),
      TextSpan(text: text.substring(idx + query.length)),
    ]),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

/// Uppercase group label separating actions from credential matches.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: p.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    super.key,
    required this.credential,
    required this.onTap,
    required this.selected,
    required this.query,
  });

  final Credential credential;
  final VoidCallback onTap;
  final bool selected;
  final String query;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = credentialTypeColor(credential.type, p);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? p.primary.withValues(alpha: 0.12) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.lock_rounded, color: color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlighted(
                    credential.title,
                    query,
                    TextStyle(
                      color: p.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    p.primary,
                  ),
                  if (credential.username != null)
                    _highlighted(
                      credential.username!,
                      query,
                      TextStyle(color: p.textMuted, fontSize: 12),
                      p.primary,
                    ),
                ],
              ),
            ),
            Icon(Icons.north_east_rounded, color: p.textDisabled, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.action,
    required this.onTap,
    required this.selected,
    required this.query,
  });

  final _PaletteAction action;
  final VoidCallback onTap;
  final bool selected;
  final String query;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = action.danger ? p.danger : p.textBody;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? p.primary.withValues(alpha: 0.12) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(action.icon,
                color: action.danger ? p.danger : p.textMuted, size: 19),
            const SizedBox(width: 14),
            Expanded(
              child: _highlighted(
                action.label,
                query,
                TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w500),
                action.danger ? p.danger : p.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom hint bar: keyboard affordances (↑↓ navigate · ↵ open · esc close).
class _PaletteFooter extends StatelessWidget {
  const _PaletteFooter({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _hint('↑↓', l10n.commandHintNavigate, p),
          const SizedBox(width: 16),
          _hint('↵', l10n.commandHintSelect, p),
          const SizedBox(width: 16),
          _hint('esc', l10n.commandHintClose, p),
        ],
      ),
    );
  }

  Widget _hint(String keycap, String label, AppPalette p) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KbdHint(label: keycap, color: p.textDisabled, border: p.divider),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: p.textDisabled, fontSize: 11)),
        ],
      );
}

class _KbdHint extends StatelessWidget {
  const _KbdHint({
    required this.label,
    required this.color,
    required this.border,
  });

  final String label;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontFamily: AppTheme.monoFamily,
        ),
      ),
    );
  }
}
