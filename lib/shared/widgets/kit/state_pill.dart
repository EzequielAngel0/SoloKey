import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';
import 'safety_tone.dart';

/// Pastilla de estado para datos cortos ("Comprometida", "Débil", "Sana",
/// "Sincronizado"). Lleva icono además del color: se entiende sin distinguir
/// colores.
class StatePill extends StatelessWidget {
  const StatePill({
    super.key,
    required this.label,
    this.tone = SafetyTone.neutral,
    this.icon,
  });

  final String label;
  final SafetyTone tone;

  /// Si es `null`, el icono del estado.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = tone.ink(p);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm + 2,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: tone.wash(p),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? tone.icon, size: 16, color: c),
          const SizedBox(width: AppSpace.xs + 2),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: c,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
