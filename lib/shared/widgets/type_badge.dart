import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// A subtle **category tag** for a credential type: a small colored dot plus a
/// short label in the type color. Deliberately flat and background-less so it
/// reads differently from the filled [StatusChip] used for health (weak/reused)
/// — the two can sit on the same row without competing. UX overhaul kit.
class TypeBadge extends StatelessWidget {
  const TypeBadge({
    super.key,
    required this.label,
    required this.color,
  });

  /// Short, localized type label (e.g. "Password", "TOTP", "SSH key").
  final String label;

  /// The type accent color (from `context.palette.type*`).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
