import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/security_audit_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/domain/entities/app_security_settings.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';

part 'security_audit_screen.g.dart';

@riverpod
Future<List<AuditIssue>> auditResults(Ref ref, bool checkBreaches) =>
    getIt<SecurityAuditService>().runAudit(checkBreaches: checkBreaches);

class SecurityAuditScreen extends ConsumerWidget {
  const SecurityAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    // El switch HIBP vive en AppSecuritySettings (no en estado local) para que
    // sobreviva al salir de la pantalla o cambiar de modulo.
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final checkBreaches = settings?.hibpCheckEnabled ?? false;
    final auditAsync = ref.watch(auditResultsProvider(checkBreaches));
    final issues = auditAsync.valueOrNull;

    return Scaffold(
      appBar: VaultAppBar(title: l10n.auditTitle),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Security Score — at-a-glance vault health.
          if (issues != null)
            SliverToBoxAdapter(child: _ScoreCard(issues: issues)),
          // Header card with statistics & description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.surface, palette.card],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.divider),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.auditAnalysisTitle,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.auditAnalysisDesc,
                      style: TextStyle(color: palette.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: palette.divider),
                    const SizedBox(height: 8),
                    // Breach check option
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cloud_sync_rounded, color: palette.accent, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.auditBreachCheck,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: palette.accent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.auditPrivateBadge,
                                      style: TextStyle(
                                        color: palette.accent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.auditBreachDesc,
                                style: TextStyle(color: palette.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: checkBreaches,
                          activeThumbColor: palette.accent,
                          activeTrackColor: palette.accent.withValues(alpha: 0.3),
                          inactiveThumbColor: palette.textDisabled,
                          inactiveTrackColor: palette.surface,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            final current =
                                settings ?? AppSecuritySettings.defaults();
                            ref
                                .read(settingsNotifierProvider.notifier)
                                .save(current.copyWith(hibpCheckEnabled: val));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Audit Results List
          auditAsync.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: palette.accent),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.commonErrorDetail('$e'),
                    style: TextStyle(color: palette.danger),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            data: (issues) {
              if (issues.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _AllGood(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _IssueCard(issue: issues[i]),
                    ),
                    childCount: issues.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Vault Security Score header: a ring gauge + per-severity counts. The score
/// starts at 100 and drops by weighted penalties per finding.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.issues});
  final List<AuditIssue> issues;

  int get _critical =>
      issues.where((i) => i.severity == AuditSeverity.critical).length;
  int get _warning =>
      issues.where((i) => i.severity == AuditSeverity.warning).length;
  int get _info => issues.where((i) => i.severity == AuditSeverity.info).length;

  int get _score {
    final raw = 100 - (_critical * 15 + _warning * 8 + _info * 3);
    return raw.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.divider),
        ),
        child: Row(
          children: [
            ScoreRing(score: _score, size: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.auditScoreTitle,
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    issues.isEmpty
                        ? l10n.auditAllGoodTitle
                        : l10n.auditScoreIssues(issues.length),
                    style: TextStyle(color: p.textMuted, fontSize: 13),
                  ),
                  if (issues.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (_critical > 0)
                          StatusChip(
                            label: '$_critical ${l10n.auditSeverityCritical}',
                            color: p.danger,
                            icon: Icons.error_rounded,
                            dense: true,
                          ),
                        if (_warning > 0)
                          StatusChip(
                            label: '$_warning ${l10n.auditSeverityWarning}',
                            color: p.warning,
                            icon: Icons.warning_rounded,
                            dense: true,
                          ),
                        if (_info > 0)
                          StatusChip(
                            label: '$_info ${l10n.auditSeverityInfo}',
                            color: p.info,
                            icon: Icons.info_rounded,
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGood extends StatelessWidget {
  const _AllGood();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_rounded, color: palette.success, size: 60),
          ),
          const SizedBox(height: 20),
          Text(l10n.auditAllGoodTitle,
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            l10n.auditAllGoodDesc,
            style: TextStyle(color: palette.textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});
  final AuditIssue issue;

  static IconData _severityIcon(AuditSeverity s) => switch (s) {
        AuditSeverity.critical => Icons.error_rounded,
        AuditSeverity.warning => Icons.warning_rounded,
        AuditSeverity.info => Icons.info_rounded,
      };

  static String _severityLabel(AppLocalizations l10n, AuditSeverity s) =>
      switch (s) {
        AuditSeverity.critical => l10n.auditSeverityCritical,
        AuditSeverity.warning => l10n.auditSeverityWarning,
        AuditSeverity.info => l10n.auditSeverityInfo,
      };

  Color _severityColor(AuditSeverity severity, AppPalette p) => switch (severity) {
        AuditSeverity.critical => p.danger,
        AuditSeverity.warning => p.warning,
        AuditSeverity.info => p.accent,
      };

  /// Localized title for an audit finding (the service returns a [type], not text).
  static String _title(AppLocalizations l10n, AuditIssue i) => switch (i.type) {
        AuditIssueType.tooShort => l10n.auditIssueTooShortTitle,
        AuditIssueType.weakLettersOnly ||
        AuditIssueType.weakNumbersOnly =>
          l10n.auditIssueWeakTitle,
        AuditIssueType.reused => l10n.auditIssueReusedTitle,
        AuditIssueType.breached => l10n.auditIssueBreachedTitle,
        AuditIssueType.noPassword => l10n.auditIssueNoPasswordTitle,
        AuditIssueType.rotationDue => l10n.auditIssueRotationTitle,
        AuditIssueType.stale => l10n.auditIssueStaleTitle,
      };

  /// Localized description (with the finding's numeric params interpolated).
  static String _description(AppLocalizations l10n, AuditIssue i) =>
      switch (i.type) {
        AuditIssueType.tooShort => l10n.auditIssueTooShortDesc,
        AuditIssueType.weakLettersOnly => l10n.auditIssueWeakLettersDesc,
        AuditIssueType.weakNumbersOnly => l10n.auditIssueWeakNumbersDesc,
        AuditIssueType.reused => l10n.auditIssueReusedDesc,
        AuditIssueType.breached => l10n.auditIssueBreachedDesc(i.breachCount),
        AuditIssueType.noPassword => l10n.auditIssueNoPasswordDesc,
        AuditIssueType.rotationDue =>
          l10n.auditIssueRotationDesc(i.daysOverdue, i.intervalDays),
        AuditIssueType.stale => l10n.auditIssueStaleDesc(i.daysSinceUpdate),
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final color = _severityColor(issue.severity, palette);
    return InkWell(
      onTap: () => context.push(AppRoutes.credentialEdit.replaceFirst(':id', issue.credential.id)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon(issue.severity), color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _severityLabel(l10n, issue.severity),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue.credential.title,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _title(l10n, issue),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _description(l10n, issue),
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
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
