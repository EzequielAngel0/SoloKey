import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Medidas de Tinta y papel (DIS-1): espacio, esquinas, sombra y movimiento.
/// Las pantallas y el kit solo usan estos valores, nunca números sueltos.

/// Espacio en múltiplos de 4.
abstract final class AppSpace {
  /// Entre un icono y su texto.
  static const double xs = 4;

  /// Dentro de un componente pequeño (pastilla, chip).
  static const double sm = 8;

  /// Entre elementos de una fila.
  static const double md = 12;

  /// Relleno de tarjetas y margen lateral de pantalla.
  static const double lg = 16;

  /// Entre grupos de una pantalla.
  static const double xl = 24;

  /// Entre secciones distintas.
  static const double xxl = 32;

  /// Aire grande (primer uso, pantallas vacías).
  static const double xxxl = 48;

  /// Toque mínimo (accesibilidad): 48 en cualquier control.
  static const double touch = 48;
}

/// Esquinas: 12 en todo (decidido, ADR-0013); pastilla para datos cortos.
abstract final class AppRadius {
  static const double card = 12;
  static const double control = 12;
  static const double sheet = 12;
  static const double tooltip = 8;
  static const double pill = 999;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius controlAll =
      BorderRadius.all(Radius.circular(control));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Profundidad = borde fino + sombra suave. Nada más (sin brillos ni capas).
abstract final class AppDepth {
  /// Grosor del borde fino.
  static const double hairline = 1;

  /// Grosor del anillo de foco.
  static const double focusRing = 2;

  /// Sombra suave de una tarjeta o panel.
  static List<BoxShadow> soft(AppPalette p) => [
        BoxShadow(
          color: p.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Sombra de lo que flota (diálogo, menú).
  static List<BoxShadow> floating(AppPalette p) => [
        BoxShadow(
          color: p.shadow,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Caja de una tarjeta: hoja, borde fino, esquinas de 12 y sombra suave.
  static BoxDecoration card(AppPalette p) => BoxDecoration(
        color: p.sheet,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: p.rule, width: hairline),
        boxShadow: soft(p),
      );
}

/// Movimiento corto y sin adornos: 200 ms o menos, desaceleración, nada de
/// rebotes. Con "reducir movimiento" del sistema, sin animación.
abstract final class AppMotion {
  /// Cambios de estado de un control (hover, foco, selección).
  static const Duration quick = Duration(milliseconds: 120);

  /// Transiciones de pantalla, hojas y paneles.
  static const Duration standard = Duration(milliseconds: 200);

  static const Curve curve = Curves.easeOutCubic;

  /// [standard], o cero si el sistema pide reducir movimiento.
  static Duration of(BuildContext context, [Duration d = standard]) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
          ? Duration.zero
          : d;
}
