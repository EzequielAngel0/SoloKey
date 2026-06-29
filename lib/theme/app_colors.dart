import 'package:flutter/material.dart';

/// Legacy static color constants — **DEPRECATED**.
///
/// Prefer `context.palette.<role>` ([AppPalette]) which is theme-aware
/// (light / dark / dim / oled). These constants mirror the **Graphite Pro dark**
/// values so any remaining direct references stay visually consistent until they
/// are migrated to `context.palette`.
///
/// TODO(ui): migrate remaining references to `context.palette` and delete.
abstract final class AppColors {
  // ── Branding ────────────────────────────────────────────────────────────────
  // Graphite Pro: a single confident blue accent, emerald for success.
  static const primary       = Color(0xFF3B82F6);  // Blue (brand)
  static const accent        = Color(0xFF3B82F6);
  static const secondary     = Color(0xFF10B981);  // Emerald

  // ── Surfaces ────────────────────────────────────────────────────────────────
  static const background    = Color(0xFF0B0B0F);  // Deepest bg (graphite)
  static const surface       = Color(0xFF121218);
  static const card          = Color(0xFF17171F);  // Cards & tiles
  static const cardDark      = Color(0xFF0F0F14);  // Inset panels
  static const drawer        = Color(0xFF121218);  // Modals & drawers
  static const divider       = Color(0xFF262630);

  // ── Text / Labels ───────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF3F4F7);
  static const textBody      = Color(0xFFC7C8D1);
  static const textMuted     = Color(0xFF8A8B97);
  static const textDisabled  = Color(0xFF56575F);
  static const textEmpty     = Color(0xFF262630);  // Placeholder icons

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const danger        = Color(0xFFF26D6D);
  static const error         = Color(0xFFEF4444);
  static const warning       = Color(0xFFF5A524);
  static const success       = Color(0xFF10B981);
  static const info          = Color(0xFF38BDF8);

  // ── Credential types ────────────────────────────────────────────────────────
  static const typePassword  = Color(0xFF3B82F6);
  static const typeApiKey    = Color(0xFF10B981);
  static const typeNote      = Color(0xFFF5A524);
  static const typeTotp      = Color(0xFF8B5CF6);
  static const typePasskey   = Color(0xFF14B8A6);
  static const typeSshKey    = Color(0xFF0EA5E9);
}
