import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_tokens.dart';
import 'safety_tone.dart';

/// Aviso en línea: fondo liso del estado, icono y texto. El color solo dice el
/// estado; el texto va en tinta para que se lea igual en los dos temas.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.title,
    this.message,
    this.tone = SafetyTone.neutral,
    this.icon,
    this.action,
  });

  final String title;
  final String? message;
  final SafetyTone tone;

  /// Si es `null`, el icono del estado.
  final IconData? icon;

  /// Un [PaperButton] discreto, por ejemplo "Cambiar contraseña".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final c = tone.ink(p);

    return Semantics(
      container: true,
      liveRegion: tone == SafetyTone.breach,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: tone.wash(p),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: c.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? tone.icon, color: c, size: 22),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: text.titleSmall),
                  if (message != null) ...[
                    const SizedBox(height: AppSpace.xs),
                    Text(message!, style: text.bodyMedium),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: AppSpace.sm),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
