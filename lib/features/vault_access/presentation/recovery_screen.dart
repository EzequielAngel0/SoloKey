import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/password_requirements_checklist.dart';
import '../../../shared/widgets/password_strength_indicator.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../password_generator/domain/password_generator.dart';
import '../domain/master_password_policy.dart';

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
  PasswordStrength _strength = PasswordStrength.none;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = l10n.recoveryEnterCode);
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
          () => _error = l10n.recoveryWrongCode,
        );
      }
    } catch (e) {
      setState(() => _error = l10n.commonErrorDetail('$e'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final pwd = _newPasswordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pwd.isEmpty) {
      setState(() => _error = l10n.recoveryEnterNewPassword);
      return;
    }
    // A reset must enforce the SAME complexity as the initial setup — never let
    // the user downgrade to a weaker master password (MasterPasswordPolicy).
    final policyError = _policyError(l10n, pwd);
    if (policyError != null) {
      setState(() => _error = policyError);
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = l10n.setupPasswordsMismatch);
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
            content: Text(l10n.recoveryPasswordUpdated),
            backgroundColor: context.palette.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = l10n.commonErrorDetail('$e'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// First unmet requirement of [MasterPasswordPolicy], as a localized message,
  /// or null when [value] satisfies the policy. Mirrors the Setup validator so
  /// both flows speak the same language.
  String? _policyError(AppLocalizations l10n, String value) {
    if (!MasterPasswordPolicy.hasMinLength(value)) return l10n.setupMinChars;
    if (!MasterPasswordPolicy.hasUppercase(value)) return l10n.setupNeedUppercase;
    if (!MasterPasswordPolicy.hasNumber(value)) return l10n.setupNeedNumber;
    if (!MasterPasswordPolicy.hasSymbol(value)) return l10n.setupNeedSymbol;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VaultAppBar(title: AppLocalizations.of(context).recoveryTitle),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _step == 1 ? _buildStepOne() : _buildStepTwo(),
      ),
    );
  }

  Widget _buildStepOne() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepIndicator(
            currentStep: 1,
            totalSteps: 2,
            label:
                '${l10n.accessStepOf(1, 2)} · ${l10n.recoveryStepEnterCode}',
          ),
          const SizedBox(height: 24),
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
                  l10n.recoveryCodeTitle,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.recoveryCodeDescription,
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
              fontFamily: AppTheme.monoFamily,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.recoveryCodeTitle,
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
                  label: Text(l10n.recoveryVerifyButton),
                ),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepIndicator(
            currentStep: 2,
            totalSteps: 2,
            label:
                '${l10n.accessStepOf(2, 2)} · ${l10n.recoveryStepNewPassword}',
          ),
          const SizedBox(height: 24),
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
                    l10n.recoveryCodeVerified,
                    style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SecureTextField(
            controller: _newPasswordCtrl,
            label: l10n.recoveryNewPasswordLabel,
            onChanged: (v) =>
                setState(() => _strength = PasswordGenerator.evaluate(v)),
            validator: (_) => null,
          ),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(strength: _strength),
          const SizedBox(height: 12),
          PasswordRequirementsChecklist(password: _newPasswordCtrl.text),
          const SizedBox(height: 16),
          SecureTextField(
            controller: _confirmCtrl,
            label: l10n.setupConfirmLabel,
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
                  label: Text(l10n.recoveryResetButton),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoveryCodeTitle),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepIndicator(
              currentStep: 2,
              totalSteps: 2,
              label: '${l10n.accessStepOf(2, 2)} · ${l10n.setupStepSaveCode}',
            ),
            const SizedBox(height: 24),
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
                      l10n.recoveryCodeWarning,
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
                  fontFamily: AppTheme.monoFamily,
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
                  label: l10n.recoveryCodeTitle,
                  value: code,
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.recoveryCopyCode),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go(targetRoute),
              child: Text(l10n.recoveryCodeSavedContinue),
            ),
          ],
        ),
      ),
    );
  }
}
