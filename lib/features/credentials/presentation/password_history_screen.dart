import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/auth_helper.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../application/password_history_provider.dart';
import '../../../theme/app_palette.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';

class PasswordHistoryScreen extends ConsumerWidget {
  const PasswordHistoryScreen({super.key, required this.credentialId});
  final String credentialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final historyAsync = ref.watch(passwordHistoryProvider(credentialId));

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const VaultAppBar(
        title: 'Historial',
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Text(
                'No hay contraseñas antiguas.',
                style: TextStyle(color: palette.textDisabled),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final date = '${entry.createdAt.day.toString().padLeft(2, '0')}/'
                  '${entry.createdAt.month.toString().padLeft(2, '0')}/'
                  '${entry.createdAt.year}';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.drawer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: palette.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: palette.textDisabled,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '••••••••••••',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: palette.accent,
                        size: 20,
                      ),
                      tooltip: 'Copiar contraseña',
                      onPressed: () async {
                        final auth = await AuthHelper.requireAuth(context);
                        if (!auth) return;
                        if (!context.mounted) return;

                        await showClipboardCountdownSnackBar(
                          context: context,
                          label: 'Contraseña histórica',
                          value: entry.password,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.restore_rounded,
                        color: palette.secondary,
                        size: 20,
                      ),
                      tooltip: 'Restaurar contraseña',
                      onPressed: () async {
                        final auth = await AuthHelper.requireAuth(context);
                        if (!auth) return;
                        if (!context.mounted) return;

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: palette.drawer,
                            title: Text('¿Restaurar contraseña?', style: TextStyle(color: palette.textPrimary)),
                            content: Text(
                              'Esta acción reemplazará la contraseña actual de la credencial con esta contraseña histórica. ¿Deseas continuar?',
                              style: TextStyle(color: palette.textMuted),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar', style: TextStyle(color: palette.textDisabled)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: palette.accent,
                                  foregroundColor: palette.onPrimary,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Restaurar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await _restorePassword(context, ref, entry.password);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.accent),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: palette.danger),
          ),
        ),
      ),
    );
  }

  Future<void> _restorePassword(
    BuildContext context,
    WidgetRef ref,
    String historicalPassword,
  ) async {
    final palette = context.palette;
    try {
      final creds = ref.read(credentialsNotifierProvider).valueOrNull;
      final existing = creds?.firstWhere((c) => c.id == credentialId);
      if (existing == null) throw Exception('Credencial no encontrada');

      var updated = existing.copyWith(
        password: historicalPassword,
        updatedAt: DateTime.now(),
      );

      if (existing.type == CredentialType.sshKey && existing.sshKeyMetadata != null) {
        updated = updated.copyWith(
          sshKeyMetadata: existing.sshKeyMetadata!.copyWith(
            privateKey: historicalPassword,
          ),
        );
      }

      await ref.read(credentialsNotifierProvider.notifier).updateCredential(updated);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contraseña restaurada con éxito'),
            backgroundColor: palette.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Volver a la pantalla de detalle
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar la contraseña: $e'),
            backgroundColor: palette.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
