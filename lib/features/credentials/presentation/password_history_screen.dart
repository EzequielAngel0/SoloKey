import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/auth_helper.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../application/password_history_provider.dart';

class PasswordHistoryScreen extends ConsumerWidget {
  const PasswordHistoryScreen({super.key, required this.credentialId});
  final String credentialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(passwordHistoryProvider(credentialId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: const VaultAppBar(
        title: 'Historial',
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No hay contraseñas antiguas.',
                style: TextStyle(color: Color(0xFF5C5C7A)),
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
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2A2A4A),
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
                            style: const TextStyle(
                              color: Color(0xFF5C5C7A),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '••••••••••••',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
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
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Color(0xFFCF6679)),
          ),
        ),
      ),
    );
  }
}
