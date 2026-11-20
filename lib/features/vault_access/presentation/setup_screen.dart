import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/recovery_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../shared/widgets/kit/kit.dart';
import '../application/vault_state_provider.dart';
import 'widgets/access_layout.dart';
import 'widgets/master_password_rules.dart';

enum _Step { create, code, import }

/// Primer uso en tres pasos (REDISENO_V2 §4): crear la contraseña maestra,
/// guardar el código de recuperación (hay que confirmarlo) e importar, que es
/// opcional. La bóveda se crea y queda abierta al terminar el paso 1.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  _Step _step = _Step.create;

  // Paso 1
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = SecretTextController();
  final _confirmCtrl = SecretTextController();
  bool _busy = false;
  String? _error;

  // Paso 2
  String? _code;
  int _group = 0; // índice del grupo que se pide para confirmar
  final _groupCtrl = TextEditingController();
  String? _groupError;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    // SEC-003: la maestra sale de los controladores antes del await.
    final password = _passCtrl.text;
    _passCtrl.clear();
    _confirmCtrl.clear();
    setState(() {
      _busy = true;
      _error = null;
    });

    await ref.read(vaultNotifierProvider.notifier).setup(password);
    if (!mounted) return;
    final ok = ref.read(vaultNotifierProvider).maybeWhen(
          unlocked: (_) => true,
          orElse: () => false,
        );
    if (!ok) {
      setState(() {
        _busy = false;
        _error = l10n.unlockGenericError;
      });
      return;
    }

    final code = await getIt<RecoveryService>().generateRecoveryCode();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _code = code;
      _group = Random.secure().nextInt(code.split('-').length);
      _step = _Step.code;
    });
  }

  void _confirmCode() {
    final l10n = AppLocalizations.of(context);
    final want = _code!.split('-')[_group];
    if (_groupCtrl.text.trim() != want) {
      setState(() => _groupError = l10n.setupCodeConfirmWrong(_group + 1));
      return;
    }
    FocusScope.of(context).unfocus();
    _groupCtrl.clear();
    setState(() {
      _groupError = null;
      _code = null; // ya no hace falta en memoria
      _step = _Step.import;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AccessLayout(
      children: switch (_step) {
        _Step.create => _createStep(l10n),
        _Step.code => _codeStep(l10n),
        _Step.import => _importStep(l10n),
      },
    );
  }

  String _stepLabel(AppLocalizations l10n, int n) => l10n.accessStepOf(n, 3);

  List<Widget> _createStep(AppLocalizations l10n) {
    return [
      AccessHeader(
        step: _stepLabel(l10n, 1),
        title: l10n.setupStepCreate,
        subtitle: l10n.setupSubtitle,
      ),
      const SizedBox(height: AppSpace.xl),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SecretField(
              controller: _passCtrl,
              label: l10n.unlockMasterPasswordHint,
              revealTooltip: l10n.commonShowPassword,
              hideTooltip: l10n.commonHidePassword,
              autofocus: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: (_) => setState(() {}),
              validator: (v) => masterPasswordError(l10n, v ?? ''),
            ),
            const SizedBox(height: AppSpace.md),
            MasterPasswordRules(password: _passCtrl.text),
            const SizedBox(height: AppSpace.lg),
            SecretField(
              controller: _confirmCtrl,
              label: l10n.setupConfirmLabel,
              revealTooltip: l10n.commonShowPassword,
              hideTooltip: l10n.commonHidePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) =>
                  v != _passCtrl.text ? l10n.setupPasswordsMismatch : null,
              onSubmitted: (_) => _create(),
            ),
          ],
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpace.lg),
        Notice(title: _error!, tone: SafetyTone.breach),
      ],
      const SizedBox(height: AppSpace.xl),
      PaperButton(
        label: l10n.setupCreateButton,
        onPressed: _create,
        busy: _busy,
        expand: true,
      ),
    ];
  }

  List<Widget> _codeStep(AppLocalizations l10n) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final code = _code!;
    return [
      AccessHeader(
        step: _stepLabel(l10n, 2),
        title: l10n.setupStepSaveCode,
        subtitle: l10n.setupCodeIntro,
      ),
      const SizedBox(height: AppSpace.xl),
      Notice(
        title: l10n.recoveryCodeWarning,
        tone: SafetyTone.weak,
        icon: Icons.priority_high_rounded,
      ),
      const SizedBox(height: AppSpace.lg),
      PaperCard(
        title: l10n.recoveryCodeTitle,
        trailing: CopyButton(
          tooltip: l10n.recoveryCopyCode,
          onCopy: () => showClipboardCountdownSnackBar(
            context: context,
            label: l10n.recoveryCodeTitle,
            value: code,
          ),
        ),
        child: SelectableText(
          code,
          style: AppTheme.mono(t.titleMedium)
              .copyWith(color: p.ink, height: 1.6),
        ),
      ),
      const SizedBox(height: AppSpace.xl),
      TextField(
        controller: _groupCtrl,
        autocorrect: false,
        enableSuggestions: false,
        style: AppTheme.mono(t.bodyLarge),
        textInputAction: TextInputAction.done,
        // Si no coincide, el campo se queda con el foco y el teclado para
        // corregir; _confirmCode lo suelta al acertar.
        onEditingComplete: () {},
        onSubmitted: (_) => _confirmCode(),
        decoration: InputDecoration(
          labelText: l10n.setupCodeConfirmLabel(_group + 1),
          helperText: l10n.setupCodeConfirmHelp,
          helperMaxLines: 3,
          errorText: _groupError,
          errorMaxLines: 3,
        ),
      ),
      const SizedBox(height: AppSpace.xl),
      PaperButton(
        label: l10n.setupCodeConfirmButton,
        onPressed: _confirmCode,
        expand: true,
      ),
    ];
  }

  List<Widget> _importStep(AppLocalizations l10n) {
    return [
      AccessHeader(
        step: _stepLabel(l10n, 3),
        title: l10n.setupStepImport,
        subtitle: l10n.setupImportBody,
      ),
      const SizedBox(height: AppSpace.xl),
      PaperButton.secondary(
        label: l10n.setupImportButton,
        icon: Icons.file_download_outlined,
        // La bóveda ya está abierta: Transferir se apila sobre este paso y al
        // volver se entra con el botón principal.
        onPressed: () => context.push(AppRoutes.transfer),
        expand: true,
      ),
      const SizedBox(height: AppSpace.md),
      PaperButton(
        label: l10n.setupImportDone,
        icon: Icons.arrow_forward_rounded,
        onPressed: () => context.go(AppRoutes.home),
        expand: true,
      ),
    ];
  }

}
