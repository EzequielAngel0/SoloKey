import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/password_strength_indicator.dart';
import '../../../shared/widgets/secure_text_field.dart';
import '../../password_generator/domain/password_generator.dart';
import '../../../theme/app_palette.dart';
import '../application/vault_state_provider.dart';
import 'recovery_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  PasswordStrength _strength = PasswordStrength.none;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String v) {
    setState(() => _strength = PasswordGenerator.evaluate(v));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // SEC-003: Capturar y limpiar controladores antes del await para
    // minimizar el tiempo que la contraseña maestra vive en la UI.
    final password = _passCtrl.text;
    _passCtrl.clear();
    _confirmCtrl.clear();
    await ref.read(vaultNotifierProvider.notifier).setup(password);
    final state = ref.read(vaultNotifierProvider);
    if (!mounted) return;
    
    state.maybeWhen(
      unlocked: (_) async {
        final code = await getIt<RecoveryService>().generateRecoveryCode();
        if (!mounted) return;
        // SEC: Pasamos el targetRoute como String y dejamos que RecoveryCodeDisplay
        // use su propio context para navegar, evitando el bug de context desmontado.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RecoveryCodeDisplay(
              code: code,
              targetRoute: AppRoutes.home,
            ),
          ),
        );
      },
      error: (kind, lockout, message) =>
          _showError(message ?? AppLocalizations.of(context).unlockGenericError),
      orElse: () {},
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: context.palette.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final vaultState = ref.watch(vaultNotifierProvider);
    final isLoading = vaultState is _Loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/logo/solokey_mark.png',
                    height: 76,
                    width: 76,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/logo/SoloKey.png',
                      height: 76,
                      width: 76,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.setupTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.setupSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: palette.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  autofocus: true,
                  onChanged: _onPasswordChanged,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  style: TextStyle(color: palette.textPrimary, fontSize: 16, letterSpacing: 1.5),
                  decoration: InputDecoration(
                    labelText: l10n.unlockMasterPasswordHint,
                    hintText: l10n.setupMinChars,
                  ),
                ),
                const SizedBox(height: 8),
                PasswordStrengthIndicator(strength: _strength),
                const SizedBox(height: 20),
                SecureTextField(
                  controller: _confirmCtrl,
                  label: l10n.setupConfirmLabel,
                  textInputAction: TextInputAction.done,
                  validator: (v) => v != _passCtrl.text
                      ? l10n.setupPasswordsMismatch
                      : null,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                _RequirementsList(password: _passCtrl.text),
                const SizedBox(height: 36),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: palette.accent,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(l10n.setupCreateButton),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? v) {
    final l10n = AppLocalizations.of(context);
    if (v == null || v.length < 12) return l10n.setupMinChars;
    if (!v.contains(RegExp(r'[A-Z]'))) return l10n.setupNeedUppercase;
    if (!v.contains(RegExp(r'[0-9]'))) return l10n.setupNeedNumber;
    if (!v.contains(RegExp(r'[!@#$%^&*()\-_=+]'))) {
      return l10n.setupNeedSymbol;
    }
    return null;
  }
}

// ignore: unused_element
class _Loading {}

class _RequirementsList extends StatelessWidget {
  const _RequirementsList({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final reqs = [
      (label: l10n.setupReqChars, met: password.length >= 12),
      (label: l10n.setupReqUppercase, met: password.contains(RegExp(r'[A-Z]'))),
      (label: l10n.setupReqNumber, met: password.contains(RegExp(r'[0-9]'))),
      (
        label: l10n.setupReqSymbol,
        met: password.contains(RegExp(r'[!@#$%^&*()\-_=+]'))
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: reqs
          .map(
            (r) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  r.met
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: r.met ? palette.success : palette.textDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  r.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: r.met ? palette.success : palette.textDisabled,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
