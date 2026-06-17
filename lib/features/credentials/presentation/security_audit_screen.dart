import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/security_audit_service.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/vault_app_bar.dart';

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
    final auditAsync = ref.watch(auditResultsProvider(_checkBreaches));

    return Scaffold(
      appBar: VaultAppBar(title: 'Auditoría de Seguridad'),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header card with statistics & description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E38), Color(0xFF16162A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E2E4A)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Análisis de Seguridad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SoloKey analiza tus credenciales localmente para identificar contraseñas débiles, cortas, reutilizadas o antiguas.',
                      style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2E2E4A)),
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
                                  const Icon(Icons.cloud_sync_rounded, color: Color(0xFF6C63FF), size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Verificar filtraciones (online)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRIVADO',
                                      style: TextStyle(
                                        color: Color(0xFF8C84FF),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Usa k-Anonymity (HaveIBeenPwned) para buscar contraseñas expuestas sin revelar tu contraseña real.',
                                style: TextStyle(color: Color(0xFF8C8C9E), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _checkBreaches,
                          activeColor: const Color(0xFF6C63FF),
                          activeTrackColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          inactiveThumbColor: const Color(0xFF5C5C7A),
                          inactiveTrackColor: const Color(0xFF1E1E30),
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
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(color: Color(0xFFCF6679)),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded,
                color: Color(0xFF4CAF50), size: 60),
          ),
          const SizedBox(height: 20),
          const Text('¡Todo en orden!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'No se encontraron problemas en tu bóveda.',
            style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14),
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

  static const _severityData = {
    AuditSeverity.critical: (
      color: Color(0xFFCF6679),
      icon: Icons.error_rounded,
      label: 'Crítico',
    ),
    AuditSeverity.warning: (
      color: Color(0xFFFFB74D),
      icon: Icons.warning_rounded,
      label: 'Advertencia',
    ),
    AuditSeverity.info: (
      color: Color(0xFF6C63FF),
      icon: Icons.info_rounded,
      label: 'Info',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final data = _severityData[issue.severity]!;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.credentialEdit.replaceFirst(':id', issue.credential.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, color: data.color, size: 22),
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
                          color: data.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data.label,
                          style: TextStyle(
                            color: data.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue.credential.title,
                          style: const TextStyle(
                            color: Colors.white,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.description,
                    style: const TextStyle(
                      color: Color(0xFF9E9EBF),
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
