import 'package:flutter/material.dart';

import '../../features/vault_access/domain/master_password_policy.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_palette.dart';

/// Live checklist of the master-password requirements ([MasterPasswordPolicy]).
/// Each row turns green as its requirement is met. Shared by the Setup and
/// Recovery flows so both enforce (and communicate) the exact same policy.
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final reqs = <({String label, bool met})>[
      (label: l10n.setupReqChars, met: MasterPasswordPolicy.hasMinLength(password)),
      (label: l10n.setupReqUppercase, met: MasterPasswordPolicy.hasUppercase(password)),
      (label: l10n.setupReqNumber, met: MasterPasswordPolicy.hasNumber(password)),
      (label: l10n.setupReqSymbol, met: MasterPasswordPolicy.hasSymbol(password)),
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
