import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layouts/desktop_layout_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_router.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import '../../../vault_access/application/vault_state_provider.dart';
import '../../application/credentials_provider.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

/// Global command palette (Ctrl+K) for the desktop layout: fuzzy-search the
/// whole vault and jump to a credential in-place, plus quick actions. Flat
/// Graphite Pro: a single elevated surface with a hairline border.
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

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openCredential(String id) {
    ref.read(desktopSelectedNavigationProvider.notifier).state = 0;
    ref.read(desktopSelectedCredentialIdProvider.notifier).state = id;
    ref.read(desktopRightPaneModeProvider.notifier).state =
        RightPaneMode.details;
    Navigator.of(context).pop();
  }

  void _runAction(VoidCallback action) {
    action();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(credentialsNotifierProvider).valueOrNull ?? [];
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? <Credential>[]
        : all
            .where((c) =>
                c.title.toLowerCase().contains(q) ||
                (c.username?.toLowerCase().contains(q) ?? false) ||
                (c.website?.toLowerCase().contains(q) ?? false))
            .take(8)
            .toList();

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
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 460),
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
                      onChanged: (v) => setState(() => _query = v),
                      style: TextStyle(color: p.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: l10n.homeSearchHint,
                        hintStyle: TextStyle(color: p.textDisabled),
                      ),
                    ),
                  ),
                  _KbdHint(label: 'Ctrl K', color: p.textDisabled, border: p.divider),
                ],
              ),
            ),
            Divider(height: 1, color: p.divider),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  if (q.isEmpty) ...[
                    _ActionRow(
                      icon: Icons.add_rounded,
                      label: l10n.desktopNewCredentialTooltip,
                      onTap: () => _runAction(() {
                        ref
                            .read(desktopSelectedNavigationProvider.notifier)
                            .state = 0;
                        ref
                            .read(desktopRightPaneModeProvider.notifier)
                            .state = RightPaneMode.create;
                        ref
                            .read(desktopSelectedCredentialIdProvider.notifier)
                            .state = null;
                      }),
                    ),
                    _ActionRow(
                      icon: Icons.shield_rounded,
                      label: l10n.navAudit,
                      onTap: () => _runAction(() => ref
                          .read(desktopSelectedNavigationProvider.notifier)
                          .state = 3),
                    ),
                    _ActionRow(
                      icon: Icons.sync_rounded,
                      label: l10n.navSync,
                      onTap: () => _runAction(() => ref
                          .read(desktopSelectedNavigationProvider.notifier)
                          .state = 5),
                    ),
                    _ActionRow(
                      icon: Icons.settings_rounded,
                      label: l10n.navSettings,
                      onTap: () => _runAction(() => ref
                          .read(desktopSelectedNavigationProvider.notifier)
                          .state = 4),
                    ),
                    _ActionRow(
                      icon: Icons.lock_rounded,
                      label: l10n.homeLockTooltip,
                      danger: true,
                      onTap: () => _runAction(() {
                        ref.read(vaultNotifierProvider.notifier).lock();
                        context.go(AppRoutes.unlock);
                      }),
                    ),
                  ] else if (matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 24),
                      child: Text(
                        l10n.commandNoResults,
                        style: TextStyle(color: p.textMuted),
                      ),
                    )
                  else
                    ...matches.map(
                      (c) => _CredentialRow(
                        credential: c,
                        onTap: () => _openCredential(c.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({required this.credential, required this.onTap});

  final Credential credential;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = credentialTypeColor(credential.type, p);
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  Text(
                    credential.title,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (credential.username != null)
                    Text(
                      credential.username!,
                      style: TextStyle(color: p.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = danger ? p.danger : p.textBody;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: danger ? p.danger : p.textMuted, size: 19),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
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
