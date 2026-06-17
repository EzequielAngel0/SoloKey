import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../theme/app_palette.dart';

/// Recovery Step 1: Enter recovery code → unlock.
/// Recovery Step 2: Set new master password.
class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _step = 1; // 1 = enter code, 2 = set new password
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Ingresa el código de recuperación');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final success = await getIt<RecoveryService>().unlockWithRecoveryCode(
        code,
      );
      if (success) {
        setState(() => _step = 2);
      } else {
        setState(
          () => _error = 'Código incorrecto. Verifica e intenta de nuevo.',
        );
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final pwd = _newPasswordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pwd.isEmpty) {
      setState(() => _error = 'Ingresa la nueva contraseña maestra');
      return;
    }
    if (pwd.length < 8) {
      setState(() => _error = 'La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await getIt<RecoveryService>().resetMasterPassword(pwd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contraseña maestra actualizada exitosamente'),
            backgroundColor: context.palette.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VaultAppBar(title: 'Recuperar acceso'),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _step == 1 ? _buildStepOne() : _buildStepTwo(),
      ),
    );
  }

  Widget _buildStepOne() {
    final palette = context.palette;
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: palette.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.key_rounded, color: palette.warning, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Código de recuperación',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El código de recuperación fue generado al configurar tu bóveda. '
                  'Si lo guardaste, introdúcelo aquí para restablecer tu contraseña maestra.',
                  style: TextStyle(color: palette.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Code input
          TextFormField(
            controller: _codeCtrl,
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
              fontSize: 14,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Código de recuperación',
              hintText: 'XXXX-XXXX-XXXX-XXXX-…',
              prefixIcon: Icon(Icons.vpn_key_rounded, color: palette.textMuted),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: palette.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: palette.danger, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),

          _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: palette.accent),
                )
              : ElevatedButton.icon(
                  onPressed: _verifyCode,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Verificar código'),
                ),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    final palette = context.palette;
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: palette.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: palette.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Código verificado. Ahora establece tu nueva contraseña maestra.',
                    style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SecureTextField(
            controller: _newPasswordCtrl,
            label: 'Nueva contraseña maestra',
            validator: (_) => null,
          ),
          const SizedBox(height: 16),
          SecureTextField(
            controller: _confirmCtrl,
            label: 'Confirmar contraseña',
            validator: (_) => null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: palette.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: palette.danger, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: palette.accent),
                )
              : ElevatedButton.icon(
                  onPressed: _resetPassword,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text('Restablecer contraseña maestra'),
                ),
        ],
      ),
    );
  }
}

/// Widget to show the recovery code to the user at setup time.
class RecoveryCodeDisplay extends StatelessWidget {
  const RecoveryCodeDisplay({
    super.key,
    required this.code,
    required this.targetRoute,
  });
  final String code;
  final String targetRoute;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código de recuperación'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: palette.danger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: palette.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Guarda este código en un lugar seguro! '
                      'Solo se muestra UNA VEZ y no se puede recuperar.',
                      style: TextStyle(color: palette.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                code,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                // SEC-001: Usar ClipboardService para que el código de
                // recuperación se limpie automáticamente del portapapeles.
                await showClipboardCountdownSnackBar(
                  context: context,
                  label: 'Código de recuperación',
                  value: code,
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar código'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go(targetRoute),
              child: const Text('Ya lo guardé, continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
