import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/clipboard_countdown.dart';

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
          const SnackBar(
            content: Text('Contraseña maestra actualizada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
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
      appBar: VaultAppBar(title: 'Recuperar acceso'),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _step == 1 ? _buildStepOne() : _buildStepTwo(),
      ),
    );
  }

  Widget _buildStepOne() {
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
              color: const Color(0xFFFFB74D).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.key_rounded, color: Color(0xFFFFB74D), size: 40),
                SizedBox(height: 12),
                Text(
                  'Código de recuperación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'El código de recuperación fue generado al configurar tu bóveda. '
                  'Si lo guardaste, introdúcelo aquí para restablecer tu contraseña maestra.',
                  style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Code input
          TextFormField(
            controller: _codeCtrl,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
              fontSize: 14,
            ),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Código de recuperación',
              hintText: 'XXXX-XXXX-XXXX-XXXX-…',
              prefixIcon: Icon(Icons.vpn_key_rounded, color: Color(0xFF9E9EBF)),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFCF6679).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFCF6679), fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
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
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Código verificado. Ahora establece tu nueva contraseña maestra.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
                color: const Color(0xFFCF6679).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFCF6679), fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
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
                color: const Color(0xFFCF6679).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCF6679).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Color(0xFFCF6679)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Guarda este código en un lugar seguro! '
                      'Solo se muestra UNA VEZ y no se puede recuperar.',
                      style: TextStyle(color: Color(0xFFCF6679), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(
                  color: Colors.white,
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
