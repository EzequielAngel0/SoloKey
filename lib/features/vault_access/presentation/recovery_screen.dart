import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/kit/kit.dart';
import 'widgets/access_layout.dart';
import 'widgets/master_password_rules.dart';

/// Recuperar el acceso con el código de recuperación, en dos pasos: escribir el
/// código y elegir una contraseña maestra nueva (con las mismas reglas que al
/// crear la bóveda).
class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = SecretTextController();
  final _confirmCtrl = SecretTextController();

  int _step = 1; // 1 = código, 2 = contraseña nueva
  bool _busy = false;
  String? _error;

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
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await getIt<RecoveryService>().unlockWithRecoveryCode(code);
      if (!mounted) return;
      setState(() {
        if (ok) {
          _codeCtrl.clear();
          _step = 2;
        } else {
          _error = l10n.recoveryWrongCode;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = l10n.commonErrorDetail('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final pwd = _newPasswordCtrl.text;
    if (pwd.isEmpty) {
      setState(() => _error = l10n.recoveryEnterNewPassword);
      return;
    }
    // Las mismas reglas que al crear: nunca bajar a una maestra más débil.
    final policy = masterPasswordError(l10n, pwd);
    if (policy != null) {
      setState(() => _error = policy);
      return;
    }
    if (pwd != _confirmCtrl.text) {
      setState(() => _error = l10n.setupPasswordsMismatch);
      return;
    }
    FocusScope.of(context).unfocus();
    _newPasswordCtrl.clear();
    _confirmCtrl.clear();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await getIt<RecoveryService>().resetMasterPassword(pwd);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recoveryPasswordUpdated)),
      );
      context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = l10n.commonErrorDetail('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AccessLayout(
      appBar: PaperTopBar(
        title: l10n.recoveryTitle,
        textScale: MediaQuery.textScalerOf(context).scale(1),
      ),
      children: [
        ...(_step == 1 ? _codeStep(l10n) : _passwordStep(l10n)),
        if (_error != null) ...[
          const SizedBox(height: AppSpace.lg),
          Notice(title: _error!, tone: SafetyTone.breach),
        ],
        const SizedBox(height: AppSpace.xl),
        _step == 1
            ? PaperButton(
                label: l10n.recoveryVerifyButton,
                icon: Icons.arrow_forward_rounded,
                onPressed: _verifyCode,
                busy: _busy,
                expand: true,
              )
            : PaperButton(
                label: l10n.recoveryResetButton,
                icon: Icons.lock_reset_rounded,
                onPressed: _resetPassword,
                busy: _busy,
                expand: true,
              ),
      ],
    );
  }

  List<Widget> _codeStep(AppLocalizations l10n) {
    final t = Theme.of(context).textTheme;
    return [
      AccessHeader(
        showMark: false,
        step: '${l10n.accessStepOf(1, 2)} · ${l10n.recoveryStepEnterCode}',
        title: l10n.recoveryCodeTitle,
        subtitle: l10n.recoveryCodeDescription,
      ),
      const SizedBox(height: AppSpace.xl),
      TextField(
        controller: _codeCtrl,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 2,
        maxLines: 4,
        style: AppTheme.mono(t.bodyLarge),
        decoration: InputDecoration(
          labelText: l10n.recoveryCodeTitle,
          hintText: 'XXXX-XXXX-XXXX-…',
        ),
      ),
    ];
  }

  List<Widget> _passwordStep(AppLocalizations l10n) {
    return [
      AccessHeader(
        showMark: false,
        step: '${l10n.accessStepOf(2, 2)} · ${l10n.recoveryStepNewPassword}',
        title: l10n.recoveryNewPasswordLabel,
      ),
      const SizedBox(height: AppSpace.lg),
      Notice(title: l10n.recoveryCodeVerified, tone: SafetyTone.sound),
      const SizedBox(height: AppSpace.xl),
      SecretField(
        controller: _newPasswordCtrl,
        label: l10n.recoveryNewPasswordLabel,
        revealTooltip: l10n.commonShowPassword,
        hideTooltip: l10n.commonHidePassword,
        autofocus: true,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: AppSpace.md),
      MasterPasswordRules(password: _newPasswordCtrl.text),
      const SizedBox(height: AppSpace.lg),
      SecretField(
        controller: _confirmCtrl,
        label: l10n.setupConfirmLabel,
        revealTooltip: l10n.commonShowPassword,
        hideTooltip: l10n.commonHidePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _resetPassword(),
      ),
    ];
  }
}
