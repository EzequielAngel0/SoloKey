import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Extension to parse hex color strings (e.g. "#6C63FF" or "6C63FF") into
/// Flutter [Color] objects. Falls back to [AppColors.accent] on invalid input.
extension HexColorParsing on String {
  Color toColor() {
    try {
      return Color(int.parse('FF${replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }
}
