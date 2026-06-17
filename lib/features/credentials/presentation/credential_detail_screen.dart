import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otp/otp.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/copy_feedback_button.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../application/credentials_provider.dart';
import '../domain/entities/credential.dart';
import '../../../core/utils/auth_helper.dart';
import '../../../shared/widgets/clipboard_countdown.dart';

class CredentialDetailScreen extends ConsumerWidget {
  const CredentialDetailScreen({super.key, required this.credentialId});
  final String credentialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialsAsync = ref.watch(credentialsNotifierProvider);

    return credentialsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (creds) {
        final cred = creds.where((c) => c.id == credentialId).firstOrNull;
        if (cred == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Credencial no encontrada')),
          );
        }
        return _DetailView(credential: cred);
      },
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.credential});
  final Credential credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: VaultAppBar(
        title: credential.title,
        actions: [
          IconButton(
            icon: Icon(
              credential.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFFFB74D),
            ),
            tooltip: credential.isFavorite ? 'Quitar de favoritas' : 'Añadir a favoritas',
            onPressed: () {
              ref.read(credentialsNotifierProvider.notifier).updateCredential(
                    credential.copyWith(isFavorite: !credential.isFavorite),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(
              AppRoutes.credentialEdit.replaceFirst(':id', credential.id),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFCF6679)),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TypeBadge(type: credential.type),
          const SizedBox(height: 24),
          if (credential.username != null)
            _SecretTile(
              icon: Icons.person_rounded,
              label: 'Usuario',
              value: credential.username!,
              isSecret: false,
            ),
          if (credential.password != null)
            _SecretTile(
              icon: Icons.lock_rounded,
              label: 'Contraseña',
              value: credential.password!,
              isSecret: true,
            ),
          if (credential.website != null)
            _SecretTile(
              icon: Icons.language_rounded,
              label: 'Sitio web',
              value: credential.website!,
              isSecret: false,
            ),
          if (credential.notes != null && credential.notes!.isNotEmpty)
            _SecretTile(
              icon: Icons.notes_rounded,
              label: 'Notas',
              value: credential.notes!,
              isSecret: false,
              multiline: true,
            ),
          ...credential.customFields.map(
            (f) => _SecretTile(
              icon: Icons.code_rounded,
              label: f.label,
              value: f.value,
              isSecret: f.isSecret,
            ),
          ),
          if (credential.type == CredentialType.totp &&
              credential.password != null)
            _TotpTile(secretId: credential.password!),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(
                AppRoutes.passwordHistory.replaceAll(':id', credential.id),
              ),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text('Ver historial de contraseñas'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Eliminar credencial',
            style: TextStyle(color: Colors.white)),
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
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFCF6679))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!context.mounted) return;
      final auth = await AuthHelper.requireAuth(context, reason: 'Verifica para eliminar esta credencial');
      if (!auth) return;

      await ref
          .read(credentialsNotifierProvider.notifier)
          .delete(credential.id);
      if (context.mounted) context.pop();
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final CredentialType type;

  static const _labels = {
    CredentialType.password:   'Contraseña',
    CredentialType.apiKey:     'API Key',
    CredentialType.secureNote: 'Nota segura',
    CredentialType.totp:       'TOTP / 2FA',
    CredentialType.passkey:    'Passkey',
  };

  static const _colors = {
    CredentialType.password:   Color(0xFF6C63FF),
    CredentialType.apiKey:     Color(0xFF03DAC6),
    CredentialType.secureNote: Color(0xFFFFB74D),
    CredentialType.totp:       Color(0xFFE91E8C),
    CredentialType.passkey:    Color(0xFF4CAF50),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[type] ?? const Color(0xFF6C63FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _labels[type] ?? '',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SecretTile extends StatefulWidget {
  const _SecretTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSecret,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSecret;
  final bool multiline;

  @override
  State<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends State<_SecretTile> {
  bool _revealed = false;

  Future<void> _copy(BuildContext context) async {
    if (widget.isSecret) {
      final auth = await AuthHelper.requireAuth(context);
      if (!auth) return;
    }
    if (!context.mounted) return;

    await showClipboardCountdownSnackBar(
      context: context,
      label: widget.label,
      value: widget.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayValue =
        widget.isSecret && !_revealed ? '••••••••••••' : widget.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, color: const Color(0xFF6C63FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF9E9EBF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: widget.isSecret && !_revealed ? 2 : 0,
                  ),
                  maxLines: widget.multiline ? null : 1,
                  overflow: widget.multiline
                      ? null
                      : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.isSecret)
            IconButton(
              icon: Icon(
                _revealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF9E9EBF),
                size: 18,
              ),
              onPressed: () async {
                if (!_revealed) {
                  final auth = await AuthHelper.requireAuth(context);
                  if (!auth) return;
                }
                setState(() => _revealed = !_revealed);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
          CopyFeedbackButton(onCopy: () => _copy(context)),
        ],
      ),
    );
  }
}

class _TotpTile extends StatefulWidget {
  const _TotpTile({required this.secretId});
  final String secretId;

  @override
  State<_TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<_TotpTile> {
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
    
    // Si acaba de reiniciar, recalcula el código
    if (remaining == 30) {
      _updateCode();
    }
    
    setState(() {
      _progress = remaining / 30.0;
    });
  }

  void _updateCode() {
    try {
      // Limpiar secret de espacios o guiones
      final cleanSecret = widget.secretId.replaceAll(RegExp(r'\s|-'), '').toUpperCase();
      final code = OTP.generateTOTPCodeString(
        cleanSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
      // Poner espacio en medio
      setState(() {
        _code = '${code.substring(0, 3)} ${code.substring(3)}';
      });
    } catch (_) {
      setState(() {
        _code = 'Invalido';
      });
    }
  }

  Future<void> _copy(BuildContext context) async {
    if (_code == 'Invalido' || _code == '--- ---') return;
    
    final auth = await AuthHelper.requireAuth(context);
    if (!auth) return;
    if (!context.mounted) return;

    final cleanCode = _code.replaceAll(' ', '');
    await showClipboardCountdownSnackBar(
      context: context,
      label: 'Código TOTP',
      value: cleanCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E8C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE91E8C).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_rounded, color: Color(0xFFE91E8C), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Código de Verificación (2FA)',
                  style: TextStyle(
                    color: Color(0xFFE91E8C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              CopyFeedbackButton(
                onCopy: () => _copy(context),
                color: const Color(0xFFE91E8C),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: _progress,
                  backgroundColor: const Color(0xFF1A1A2E),
                  color: const Color(0xFFE91E8C),
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
