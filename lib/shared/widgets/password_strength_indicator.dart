import 'package:flutter/material.dart';

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

  static const _meta = {
    PasswordStrength.none: (label: '', fill: 0.0),
    PasswordStrength.weak: (label: 'Débil', fill: 0.25),
    PasswordStrength.fair: (label: 'Regular', fill: 0.5),
    PasswordStrength.good: (label: 'Buena', fill: 0.75),
    PasswordStrength.strong: (label: 'Fuerte', fill: 1.0),
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
    final meta = _meta[strength]!;
    final color = _colorFor(palette);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: meta.fill,
            minHeight: 6,
            backgroundColor: palette.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (showLabel && strength != PasswordStrength.none) ...[
          const SizedBox(height: 4),
          Text(
            meta.label,
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
