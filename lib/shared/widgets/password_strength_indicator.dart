import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_palette.dart';
import '../../features/password_generator/domain/password_generator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    this.showLabel = true,
  });

  final PasswordStrength strength;
  final bool showLabel;

  static double _fill(PasswordStrength s) => switch (s) {
        PasswordStrength.none => 0.0,
        PasswordStrength.weak => 0.25,
        PasswordStrength.fair => 0.5,
        PasswordStrength.good => 0.75,
        PasswordStrength.strong => 1.0,
      };

  static String _label(AppLocalizations l10n, PasswordStrength s) => switch (s) {
        PasswordStrength.none => '',
        PasswordStrength.weak => l10n.strengthWeak,
        PasswordStrength.fair => l10n.strengthFair,
        PasswordStrength.good => l10n.strengthGood,
        PasswordStrength.strong => l10n.strengthStrong,
      };

  Color _colorFor(AppPalette palette) => switch (strength) {
        PasswordStrength.none => palette.divider,
        PasswordStrength.weak => palette.danger,
        PasswordStrength.fair => palette.warning,
        PasswordStrength.good => palette.info,
        PasswordStrength.strong => palette.success,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final color = _colorFor(palette);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _fill(strength),
            minHeight: 6,
            backgroundColor: palette.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (showLabel && strength != PasswordStrength.none) ...[
          const SizedBox(height: 4),
          Text(
            _label(l10n, strength),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
