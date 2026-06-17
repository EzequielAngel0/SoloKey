import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/infrastructure/clipboard/clipboard_service.dart';
import '../../../../core/utils/auth_helper.dart';
import '../../../../router/app_router.dart';
import '../../domain/entities/credential.dart';
import '../../application/credentials_provider.dart';
import '../../../folders/application/folders_provider.dart';

class CredentialCard extends ConsumerWidget {
  const CredentialCard({super.key, required this.credential});

  final Credential credential;

  static const _typeIcons = {
    CredentialType.password:   Icons.lock_rounded,
    CredentialType.apiKey:     Icons.key_rounded,
    CredentialType.secureNote: Icons.note_rounded,
    CredentialType.totp:       Icons.access_time_rounded,
    CredentialType.passkey:    Icons.fingerprint_rounded,
  };

  static const _typeColors = {
    CredentialType.password:   Color(0xFF6C63FF),
    CredentialType.apiKey:     Color(0xFF03DAC6),
    CredentialType.secureNote: Color(0xFFFFB74D),
    CredentialType.totp:       Color(0xFFE91E8C),
    CredentialType.passkey:    Color(0xFF4CAF50),
  };

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              credential.title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(
              credential.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
              color: const Color(0xFFFFB74D),
            ),
            title: Text(
              credential.isFavorite ? 'Quitar de favoritas' : 'Añadir a favoritas',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(credentialsNotifierProvider.notifier).updateCredential(
                    credential.copyWith(isFavorite: !credential.isFavorite),
                  );
            },
          ),
          if (credential.username != null)
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white),
              title: const Text('Copiar Usuario', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final seconds = await getIt<ClipboardService>().copySecure(credential.username!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Usuario copiado · se limpia en ${seconds}s'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF6C63FF),
                  ));
                }
              },
            ),
          if (credential.password != null && credential.type != CredentialType.totp)
            ListTile(
              leading: const Icon(Icons.password_rounded, color: Colors.white),
              title: const Text('Copiar Contraseña', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final auth = await AuthHelper.requireAuth(
                  context,
                  reason: 'Autentícate para copiar la contraseña',
                );
                if (!auth) return;

                final seconds = await getIt<ClipboardService>().copySecure(credential.password!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Contraseña copiada · se limpia en ${seconds}s'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF6C63FF),
                  ));
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_rounded, color: Colors.white),
            title: const Text('Mover a carpeta', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _moveFolder(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: Colors.white),
            title: const Text('Editar', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.credentialEdit.replaceFirst(':id', credential.id));
            },
          ),
          const Divider(color: Color(0xFF2A2A4A)),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Color(0xFFCF6679)),
            title: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Eliminar credencial', style: TextStyle(color: Colors.white)),
                  content: Text('¿Eliminar "${credential.title}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Color(0xFF9E9EBF))),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(credentialsNotifierProvider.notifier).delete(credential.id);
              }
            },
          ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveFolder(BuildContext context, WidgetRef ref) async {
    final folders = ref.read(foldersNotifierProvider).valueOrNull ?? [];
    
    final newCategoryId = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Mover a carpeta', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.all_inbox_rounded, color: Colors.white),
            title: const Text('Sin carpeta', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ''), // empty means null
          ),
          const Divider(color: Color(0xFF2A2A4A)),
          Expanded(
            child: ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, i) {
                final f = folders[i];
                final color = Color(int.tryParse('FF${f.colorHex.replaceFirst('#', '')}', radix: 16) ?? 0xFF6C63FF);
                return ListTile(
                  leading: Icon(Icons.folder_rounded, color: color),
                  title: Text(f.name, style: const TextStyle(color: Colors.white)),
                  trailing: credential.categoryId == f.id ? const Icon(Icons.check_rounded, color: Color(0xFF6C63FF)) : null,
                  onTap: () => Navigator.pop(context, f.id),
                );
              },
            ),
          )
        ],
      ),
    );

    if (newCategoryId != null) {
      final updated = credential.copyWith(categoryId: newCategoryId.isEmpty ? null : newCategoryId);
      await ref.read(credentialsNotifierProvider.notifier).save(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Credencial movida con éxito'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon  = _typeIcons[credential.type]  ?? Icons.lock_rounded;
    final color = _typeColors[credential.type] ?? const Color(0xFF6C63FF);

    return Dismissible(
      key: Key(credential.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.warningImpact();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Eliminar credencial', style: TextStyle(color: Colors.white)),
            content: Text(
              '¿Eliminar "${credential.title}"? Esta acción no se puede deshacer.',
              style: const TextStyle(color: Color(0xFF9E9EBF)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar', style: TextStyle(color: Color(0xFFCF6679))),
              ),
            ],
          ),
        );
        if (confirm == true) {
          HapticFeedback.heavyImpact();
          await ref.read(credentialsNotifierProvider.notifier).delete(credential.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${credential.title}" eliminada'),
                backgroundColor: const Color(0xFFCF6679),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return true;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFFCF6679),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Material(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(
            AppRoutes.credentialDetail.replaceFirst(':id', credential.id),
          ),
          onLongPress: () => _showOptionsSheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (credential.username != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          credential.username!,
                          style: const TextStyle(
                            color: Color(0xFF9E9EBF),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (credential.isFavorite)
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB74D), size: 18),
                if (credential.type == CredentialType.totp)
                  _TotpVisualizer(credential: credential),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TotpVisualizer extends StatefulWidget {
  const _TotpVisualizer({required this.credential});
  final Credential credential;

  @override
  State<_TotpVisualizer> createState() => _TotpVisualizerState();
}

class _TotpVisualizerState extends State<_TotpVisualizer> {
  late Timer _timer;
  String _code = '--- ---';
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateProgress());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateProgress() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = 30 - ((now / 1000).round() % 30);
    if (remaining == 30) _updateCode();
    if (mounted) setState(() => _progress = remaining / 30.0);
  }

  void _updateCode() {
    final secret = widget.credential.password;
    if (secret == null || secret.isEmpty) return;
    try {
      final cleanSecret = secret.replaceAll(RegExp(r'\s|-'), '').toUpperCase();
      final code = OTP.generateTOTPCodeString(
        cleanSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      if (mounted) {
        setState(() {
          _code = '${code.substring(0, 3)} ${code.substring(3)}';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _code = 'Error');
    }
  }

  Future<void> _quickCopy(BuildContext context) async {
    if (_code == 'Error' || _code == '--- ---') return;
    final cleanCode = _code.replaceAll(' ', '');
    final seconds = await getIt<ClipboardService>().copySecure(cleanCode);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('TOTP copiado · se limpia en ${seconds}s'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFE91E8C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 2,
              backgroundColor: const Color(0xFF0F0E17),
              color: const Color(0xFFE91E8C),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Color(0xFFE91E8C), size: 16),
            onPressed: () => _quickCopy(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
