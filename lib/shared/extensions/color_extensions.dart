import 'package:flutter/material.dart';

/// Convierte un color hexadecimal ("#6C63FF" o "6C63FF") en [Color]. Con un
/// valor inválido devuelve la tinta suave de Tinta y papel.
extension HexColorParsing on String {
  Color toColor() {
    try {
      return Color(int.parse('FF${replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF5B6068);
    }
  }
}
