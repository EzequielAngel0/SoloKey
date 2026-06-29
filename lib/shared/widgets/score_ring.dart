import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';

/// Circular 0–100 score gauge (e.g. vault Security Score). Colour follows the
/// value: green ≥80, amber ≥50, red below. UX overhaul L0 kit.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 56});

  final int score;
  final double size;

  Color _color(AppPalette p) {
    if (score >= 80) return p.success;
    if (score >= 50) return p.warning;
    return p.danger;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = _color(p);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100.0,
              backgroundColor: p.divider,
              color: color,
              strokeWidth: size > 40 ? 5 : 3,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: p.textPrimary,
              fontSize: size * 0.3,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.monoFamily,
            ),
          ),
        ],
      ),
    );
  }
}
