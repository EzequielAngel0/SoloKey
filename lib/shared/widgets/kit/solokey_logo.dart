import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';

/// La marca de SoloKey (DIS-4, elegida por el dueño el 2026-11-20): la S con
/// cerradura de siempre, plana, en un solo color (por defecto, la tinta del
/// tema). La silueta de `assets/logo/solokey_mark.png` sirve de máscara.
class SoloKeyMark extends StatelessWidget {
  const SoloKeyMark({super.key, required this.size, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        'assets/logo/solokey_mark.png',
        width: size,
        height: size,
        color: color ?? context.palette.ink,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// El icono de la app: ficha de tinta de esquinas redondas con la marca en
/// papel. Colores fijos: el lanzador no sigue el tema de la app. De aquí salen
/// los PNG y el `.ico` (`tool/logo/generar_iconos.dart`).
class SoloKeyAppIcon extends StatelessWidget {
  const SoloKeyAppIcon({super.key, required this.size});

  /// Lado de la marca respecto a la ficha.
  static const markRatio = 0.66;

  /// Radio de las esquinas respecto al lado.
  static const cornerRatio = 0.225;

  final double size;

  @override
  Widget build(BuildContext context) {
    const l = AppPalette.light;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: l.ink,
          borderRadius: BorderRadius.circular(size * cornerRatio),
        ),
        child: Center(
          child: SoloKeyMark(size: size * markRatio, color: l.onInk),
        ),
      ),
    );
  }
}
