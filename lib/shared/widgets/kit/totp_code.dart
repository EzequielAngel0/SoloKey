import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_tokens.dart';

/// Código TOTP grande con su anillo de 30 s (REDISENO_V2 §4). El anillo es
/// tinta; en los últimos 5 s pasa a "por vencer" (débil), que sí es un estado.
/// Quien lo usa le pasa el código y los segundos que le quedan.
class TotpCode extends StatelessWidget {
  const TotpCode({
    super.key,
    required this.code,
    required this.secondsLeft,
    this.period = 30,
    this.large = true,
  });

  final String code;
  final int secondsLeft;
  final int period;

  /// Grande en el detalle; chico dentro de una fila.
  final bool large;

  /// "123456" -> "123 456"; "12345678" -> "1234 5678".
  static String group(String code) {
    if (code.length < 6) return code;
    final half = code.length ~/ 2;
    return '${code.substring(0, half)} ${code.substring(half)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final ending = secondsLeft <= 5;
    // El anillo crece con la letra: el número de adentro también crece.
    final ring = MediaQuery.textScalerOf(context).scale(large ? 48.0 : 30.0);
    final fraction = (secondsLeft / period).clamp(0.0, 1.0);

    return Semantics(
      label: code.split('').join(' '),
      value: '$secondsLeft s',
      // Si no cabe en un renglón (celular al 200 %), el anillo baja.
      child: Wrap(
        spacing: large ? AppSpace.lg : AppSpace.sm,
        runSpacing: AppSpace.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ExcludeSemantics(
            child: Text(
              group(code),
              style: AppTheme.mono(
                large ? t.displayMedium : t.titleLarge,
              ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
          SizedBox.square(
            dimension: ring,
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _RingPainter(
                  fraction: fraction,
                  track: p.rule,
                  ink: ending ? p.weak : p.ink,
                  stroke: large ? 4 : 3,
                ),
                child: Center(
                  child: Text(
                    '$secondsLeft',
                    style: (large ? t.labelLarge : t.labelSmall)!.copyWith(
                      color: ending ? p.weak : p.inkSoft,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.ink,
    required this.stroke,
  });

  final double fraction;
  final Color track;
  final Color ink;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawOval(r, base);
    canvas.drawArc(
      r,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      base
        ..color = ink
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.ink != ink || old.track != track;
}
