import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/security_audit_service.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';

part 'security_audit_screen.g.dart';

@riverpod
Future<List<AuditIssue>> auditResults(Ref ref, bool checkBreaches) =>
    getIt<SecurityAuditService>().runAudit(checkBreaches: checkBreaches);

class SecurityAuditScreen extends ConsumerStatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  ConsumerState<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends ConsumerState<SecurityAuditScreen> {
  bool _checkBreaches = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final auditAsync = ref.watch(auditResultsProvider(_checkBreaches));

    return Scaffold(
      appBar: const VaultAppBar(title: 'Auditoría de Seguridad'),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
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
                      'Análisis de Seguridad',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SoloKey analiza tus credenciales localmente para identificar contraseñas débiles, cortas, reutilizadas o antiguas.',
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
                                      'Verificar filtraciones (online)',
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
                                      'PRIVADO',
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
                                'Usa k-Anonymity (HaveIBeenPwned) para buscar contraseñas expuestas sin revelar tu contraseña real.',
                                style: TextStyle(color: palette.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _checkBreaches,
                          activeThumbColor: palette.accent,
                          activeTrackColor: palette.accent.withValues(alpha: 0.3),
                          inactiveThumbColor: palette.textDisabled,
                          inactiveTrackColor: palette.surface,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _checkBreaches = val;
                            });
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
                    'Error: $e',
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

class _AllGood extends StatelessWidget {
  const _AllGood();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
          Text('¡Todo en orden!',
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'No se encontraron problemas en tu bóveda.',
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

  static const _severityMeta = {
    AuditSeverity.critical: (icon: Icons.error_rounded, label: 'Crítico'),
    AuditSeverity.warning: (icon: Icons.warning_rounded, label: 'Advertencia'),
    AuditSeverity.info: (icon: Icons.info_rounded, label: 'Info'),
  };

  Color _severityColor(AuditSeverity severity, AppPalette p) => switch (severity) {
        AuditSeverity.critical => p.danger,
        AuditSeverity.warning => p.warning,
        AuditSeverity.info => p.accent,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = _severityMeta[issue.severity]!;
    final color = _severityColor(issue.severity, palette);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.credentialEdit.replaceFirst(':id', issue.credential.id)),
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
            Icon(meta.icon, color: color, size: 22),
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
                          meta.label,
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
                    issue.title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.description,
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
