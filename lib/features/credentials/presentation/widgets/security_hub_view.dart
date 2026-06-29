import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../router/app_router.dart';
import '../../../../shared/widgets/clipboard_countdown.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import 'password_generator_widget.dart';

/// Unified "Security" hub (mobile destination). Consolidates tools that used to
/// be scattered across the overflow menu and settings: audit, generator,
/// import/export, secure files, passkeys, sync and recovery.
class SecurityHubView extends StatelessWidget {
  const SecurityHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          l10n.securityHubSubtitle,
          style: TextStyle(color: p.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Hero: full security audit.
        _HubCard(
          icon: Icons.verified_user_rounded,
          accent: p.success,
          title: l10n.navAudit,
          subtitle: l10n.securityHubAuditDesc,
          hero: true,
          onTap: () => context.push(AppRoutes.securityAudit),
        ),
        const SizedBox(height: 12),

        _HubCard(
          icon: Icons.casino_rounded,
          accent: p.primary,
          title: l10n.securityHubGenerator,
          subtitle: l10n.securityHubGeneratorDesc,
          onTap: () => _openGenerator(context, l10n),
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.import_export_rounded,
          accent: p.info,
          title: l10n.transferTitle,
          subtitle: l10n.securityHubTransferDesc,
          onTap: () => context.push(AppRoutes.transfer),
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.folder_shared_rounded,
          accent: p.warning,
          title: l10n.navSecureFiles,
          subtitle: l10n.securityHubSecureFilesDesc,
          onTap: () => context.push(AppRoutes.secureFiles),
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.fingerprint_rounded,
          accent: p.typePasskey,
          title: l10n.passkeysTitle,
          subtitle: l10n.securityHubPasskeysDesc,
          onTap: () => context.push(AppRoutes.passkeys),
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.sync_rounded,
          accent: p.secondary,
          title: l10n.navSync,
          subtitle: l10n.securityHubSyncDesc,
          onTap: () => context.push(AppRoutes.sync),
        ),
        const SizedBox(height: 12),
        _HubCard(
          icon: Icons.restore_rounded,
          accent: p.danger,
          title: l10n.recoveryTitle,
          subtitle: l10n.securityHubRecoveryDesc,
          onTap: () => context.push(AppRoutes.recovery),
        ),
      ],
    );
  }

  Future<void> _openGenerator(
      BuildContext context, AppLocalizations l10n) async {
    final p = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: p.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.generatorSheetTitle,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              PasswordGeneratorWidget(
                onApplyPassword: (value) async {
                  Navigator.of(sheetContext).pop();
                  await showClipboardCountdownSnackBar(
                    context: context,
                    label: l10n.generatorSheetTitle,
                    value: value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat tile used in the security hub: hairline border, accent-tinted icon
/// square, title + subtitle and a chevron. No glow, no gradient.
class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hero = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double box = hero ? 52 : 44;
    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        side: BorderSide(color: p.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: box,
                height: box,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: hero ? 26 : 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: hero ? 17 : 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: p.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}
