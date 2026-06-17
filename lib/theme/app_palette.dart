import 'package:flutter/material.dart';

/// Single source of truth for every semantic color in SoloKey, exposed as a
/// [ThemeExtension] so the whole UI can switch between light / dark / dim / oled
/// palettes at runtime.
///
/// Read it from a widget with `context.palette.<role>` (see [AppPaletteX]).
/// During the migration phase the values mirror the legacy `AppColors` dark
/// constants exactly, so the look is unchanged until the extra themes are wired.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    // Branding
    required this.primary,
    required this.accent,
    required this.secondary,
    required this.onPrimary,
    // Surfaces
    required this.background,
    required this.surface,
    required this.card,
    required this.cardDark,
    required this.drawer,
    required this.divider,
    // Text
    required this.textPrimary,
    required this.textBody,
    required this.textMuted,
    required this.textDisabled,
    required this.textEmpty,
    // Semantic
    required this.danger,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
    // Credential types
    required this.typePassword,
    required this.typeApiKey,
    required this.typeNote,
    required this.typeTotp,
    required this.typePasskey,
    required this.typeSshKey,
    // Overlays
    required this.scrim,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  // ── Branding ────────────────────────────────────────────────────────────────
  final Color primary;
  final Color accent;
  final Color secondary;
  final Color onPrimary;

  // ── Surfaces ────────────────────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color card;
  final Color cardDark;
  final Color drawer;
  final Color divider;

  // ── Text / Labels ─────────────────────────────────────────────────────────--
  final Color textPrimary;
  final Color textBody;
  final Color textMuted;
  final Color textDisabled;
  final Color textEmpty;

  // ── Semantic ────────────────────────────────────────────────────────────────
  final Color danger;
  final Color error;
  final Color warning;
  final Color success;
  final Color info;

  // ── Credential types ────────────────────────────────────────────────────────
  final Color typePassword;
  final Color typeApiKey;
  final Color typeNote;
  final Color typeTotp;
  final Color typePasskey;
  final Color typeSshKey;

  // ── Overlays ────────────────────────────────────────────────────────────────
  final Color scrim;
  final Color shimmerBase;
  final Color shimmerHighlight;

  /// Dark palette — identical to the legacy `AppColors` values so the current
  /// look is preserved while the codebase migrates onto the palette.
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF39FF14),
    accent: Color(0xFF6C63FF),
    secondary: Color(0xFF03DAC6),
    onPrimary: Colors.white,
    background: Color(0xFF0F0F16),
    surface: Color(0xFF1E1E2C),
    card: Color(0xFF16213E),
    cardDark: Color(0xFF0F0F23),
    drawer: Color(0xFF1A1A2E),
    divider: Color(0xFF2A2A4A),
    textPrimary: Colors.white,
    textBody: Color(0xFFE0E0F0),
    textMuted: Color(0xFF9E9EBF),
    textDisabled: Color(0xFF5C5C7A),
    textEmpty: Color(0xFF2A2A4A),
    danger: Color(0xFFCF6679),
    error: Color(0xFFFF3366),
    warning: Color(0xFFFFB74D),
    success: Color(0xFF4CAF50),
    info: Color(0xFF4FC3F7),
    typePassword: Color(0xFF6C63FF),
    typeApiKey: Color(0xFF03DAC6),
    typeNote: Color(0xFFFFB74D),
    typeTotp: Color(0xFFE91E8C),
    typePasskey: Color(0xFF4CAF50),
    typeSshKey: Color(0xFF00E5FF),
    scrim: Color(0x22000000),
    shimmerBase: Color(0xFF1A1A2E),
    shimmerHighlight: Color(0xFF2A2A4A),
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? accent,
    Color? secondary,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? card,
    Color? cardDark,
    Color? drawer,
    Color? divider,
    Color? textPrimary,
    Color? textBody,
    Color? textMuted,
    Color? textDisabled,
    Color? textEmpty,
    Color? danger,
    Color? error,
    Color? warning,
    Color? success,
    Color? info,
    Color? typePassword,
    Color? typeApiKey,
    Color? typeNote,
    Color? typeTotp,
    Color? typePasskey,
    Color? typeSshKey,
    Color? scrim,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      secondary: secondary ?? this.secondary,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardDark: cardDark ?? this.cardDark,
      drawer: drawer ?? this.drawer,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      textEmpty: textEmpty ?? this.textEmpty,
      danger: danger ?? this.danger,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
      typePassword: typePassword ?? this.typePassword,
      typeApiKey: typeApiKey ?? this.typeApiKey,
      typeNote: typeNote ?? this.typeNote,
      typeTotp: typeTotp ?? this.typeTotp,
      typePasskey: typePasskey ?? this.typePasskey,
      typeSshKey: typeSshKey ?? this.typeSshKey,
      scrim: scrim ?? this.scrim,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardDark: Color.lerp(cardDark, other.cardDark, t)!,
      drawer: Color.lerp(drawer, other.drawer, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textEmpty: Color.lerp(textEmpty, other.textEmpty, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      typePassword: Color.lerp(typePassword, other.typePassword, t)!,
      typeApiKey: Color.lerp(typeApiKey, other.typeApiKey, t)!,
      typeNote: Color.lerp(typeNote, other.typeNote, t)!,
      typeTotp: Color.lerp(typeTotp, other.typeTotp, t)!,
      typePasskey: Color.lerp(typePasskey, other.typePasskey, t)!,
      typeSshKey: Color.lerp(typeSshKey, other.typeSshKey, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// Ergonomic access: `context.palette.card`, `context.palette.textMuted`, etc.
/// Falls back to [AppPalette.dark] if no extension is registered (defensive).
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
