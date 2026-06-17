import 'package:flutter/material.dart';

/// Centralized color palette for the SoloKey design system.
///
/// Use these semantic names instead of hardcoding hex values throughout
/// the codebase. This makes theme maintenance and potential light-mode
/// support trivial in the future.
abstract final class AppColors {
  // ── Branding ────────────────────────────────────────────────────────────────
  // De-neon'd: indigo is now the brand color, replacing the legacy neon green.
  static const primary       = Color(0xFF6C63FF);  // Indigo (brand)
  static const accent        = Color(0xFF6C63FF);  // Indigo/Violet
  static const secondary     = Color(0xFF03DAC6);  // Teal

  // ── Surfaces ────────────────────────────────────────────────────────────────
  static const background    = Color(0xFF0F0F16);  // Deepest bg
  static const surface       = Color(0xFF1E1E2C);
  static const card          = Color(0xFF16213E);  // Cards & tiles
  static const cardDark      = Color(0xFF0F0F23);  // Inset panels
  static const drawer        = Color(0xFF1A1A2E);  // Modals & drawers
  static const divider       = Color(0xFF2A2A4A);

  // ── Text / Labels ───────────────────────────────────────────────────────────
  static const textPrimary   = Colors.white;
  static const textBody      = Color(0xFFE0E0F0);
  static const textMuted     = Color(0xFF9E9EBF);
  static const textDisabled  = Color(0xFF5C5C7A);
  static const textEmpty     = Color(0xFF2A2A4A);  // Placeholder icons

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const danger        = Color(0xFFCF6679);
  static const error         = Color(0xFFFF3366);
  static const warning       = Color(0xFFFFB74D);
  static const success       = Color(0xFF4CAF50);
  static const info          = Color(0xFF4FC3F7);

  // ── Credential types ────────────────────────────────────────────────────────
  static const typePassword  = accent;
  static const typeApiKey    = secondary;
  static const typeNote      = warning;
  static const typeTotp      = Color(0xFFE91E8C);
  static const typePasskey   = Color(0xFF4CAF50);
  static const typeSshKey    = Color(0xFF00B8D4);  // Softened cyan
}
