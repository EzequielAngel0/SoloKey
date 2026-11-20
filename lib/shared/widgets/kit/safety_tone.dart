import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';

/// El estado de seguridad: **el único color de Tinta y papel** (ADR-0013).
/// [neutral] es tinta, para lo que no es un estado.
enum SafetyTone {
  /// Comprometida, brecha, o lo que no se deshace.
  breach,

  /// Débil, repetida, vieja, por vencer.
  weak,

  /// Sana, sin problemas, sincronizado.
  sound,

  /// Sin estado: tinta.
  neutral;

  /// Color del icono y del texto del estado.
  Color ink(AppPalette p) => switch (this) {
    SafetyTone.breach => p.breach,
    SafetyTone.weak => p.weak,
    SafetyTone.sound => p.sound,
    SafetyTone.neutral => p.ink,
  };

  /// Fondo liso de un aviso o una pastilla.
  Color wash(AppPalette p) => switch (this) {
    SafetyTone.breach => p.breachWash,
    SafetyTone.weak => p.weakWash,
    SafetyTone.sound => p.soundWash,
    SafetyTone.neutral => p.inset,
  };

  /// Icono por defecto del estado (se lee sin color).
  IconData get icon => switch (this) {
    SafetyTone.breach => Icons.error_outline,
    SafetyTone.weak => Icons.warning_amber_outlined,
    SafetyTone.sound => Icons.check_circle_outline,
    SafetyTone.neutral => Icons.info_outline,
  };
}
