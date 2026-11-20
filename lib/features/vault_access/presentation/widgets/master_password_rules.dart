import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/kit/kit.dart';
import '../../domain/master_password_policy.dart';

/// Las reglas de la contraseña maestra como pastillas: verde con palomita la
/// que ya se cumple, tinta la que falta. Se leen sin distinguir colores.
class MasterPasswordRules extends StatelessWidget {
  const MasterPasswordRules({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = [
      (l10n.setupReqChars, MasterPasswordPolicy.hasMinLength(password)),
      (l10n.setupReqUppercase, MasterPasswordPolicy.hasUppercase(password)),
      (l10n.setupReqNumber, MasterPasswordPolicy.hasNumber(password)),
      (l10n.setupReqSymbol, MasterPasswordPolicy.hasSymbol(password)),
    ];
    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: [
        for (final (label, met) in rules)
          StatePill(
            label: label,
            tone: met ? SafetyTone.sound : SafetyTone.neutral,
            icon: met
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
          ),
      ],
    );
  }
}

/// La primera regla que [value] no cumple, ya traducida, o `null` si las cumple
/// todas. La usan el primer uso y la recuperación.
String? masterPasswordError(AppLocalizations l10n, String value) {
  if (!MasterPasswordPolicy.hasMinLength(value)) return l10n.setupMinChars;
  if (!MasterPasswordPolicy.hasUppercase(value)) return l10n.setupNeedUppercase;
  if (!MasterPasswordPolicy.hasNumber(value)) return l10n.setupNeedNumber;
  if (!MasterPasswordPolicy.hasSymbol(value)) return l10n.setupNeedSymbol;
  return null;
}
