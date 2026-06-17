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

  /// Dark palette (default) — de-neon'd: the indigo `#6C63FF` becomes the brand
  /// color, replacing the legacy neon green. Surfaces consolidated per roadmap.
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF6C63FF),
    accent: Color(0xFF6C63FF),
    secondary: Color(0xFF03DAC6),
    onPrimary: Colors.white,
    background: Color(0xFF14141C),
    surface: Color(0xFF1E1E2C),
    card: Color(0xFF1A1A2E),
    cardDark: Color(0xFF13131F),
    drawer: Color(0xFF1A1A2E),
    divider: Color(0xFF2A2A4A),
    textPrimary: Color(0xFFECECF5),
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
    typeSshKey: Color(0xFF00B8D4),
    scrim: Color(0x22000000),
    shimmerBase: Color(0xFF1A1A2E),
    shimmerHighlight: Color(0xFF2A2A4A),
  );

  /// Light palette — sencilla, alto contraste, sin neón.
  static const AppPalette light = AppPalette(
    primary: Color(0xFF5B54E0),
    accent: Color(0xFF5B54E0),
    secondary: Color(0xFF00897B),
    onPrimary: Colors.white,
    background: Color(0xFFF6F6FB),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF1F1F7),
    cardDark: Color(0xFFE8E8F0),
    drawer: Color(0xFFFFFFFF),
    divider: Color(0xFFE2E2EC),
    textPrimary: Color(0xFF13131F),
    textBody: Color(0xFF2A2A3A),
    textMuted: Color(0xFF5C5C7A),
    textDisabled: Color(0xFF9A9AB5),
    textEmpty: Color(0xFFE2E2EC),
    danger: Color(0xFFB3261E),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFB26A00),
    success: Color(0xFF2E7D32),
    info: Color(0xFF0277BD),
    typePassword: Color(0xFF5B54E0),
    typeApiKey: Color(0xFF00897B),
    typeNote: Color(0xFFB26A00),
    typeTotp: Color(0xFFC2185B),
    typePasskey: Color(0xFF2E7D32),
    typeSshKey: Color(0xFF00838F),
    scrim: Color(0x22000000),
    shimmerBase: Color(0xFFE8E8F0),
    shimmerHighlight: Color(0xFFF4F4F9),
  );

  /// Dim palette — un oscuro más suave (gris-azulado), menos contraste que dark.
  static const AppPalette dim = AppPalette(
    primary: Color(0xFF8C84FF),
    accent: Color(0xFF8C84FF),
    secondary: Color(0xFF03DAC6),
    onPrimary: Colors.white,
    background: Color(0xFF1B1B24),
    surface: Color(0xFF24242F),
    card: Color(0xFF20202B),
    cardDark: Color(0xFF181820),
    drawer: Color(0xFF20202B),
    divider: Color(0xFF30303E),
    textPrimary: Color(0xFFE0E0EC),
    textBody: Color(0xFFD0D0DE),
    textMuted: Color(0xFF9A9AB5),
    textDisabled: Color(0xFF6A6A80),
    textEmpty: Color(0xFF30303E),
    danger: Color(0xFFCF6679),
    error: Color(0xFFFF5277),
    warning: Color(0xFFFFB74D),
    success: Color(0xFF4CAF50),
    info: Color(0xFF4FC3F7),
    typePassword: Color(0xFF8C84FF),
    typeApiKey: Color(0xFF03DAC6),
    typeNote: Color(0xFFFFB74D),
    typeTotp: Color(0xFFE91E8C),
    typePasskey: Color(0xFF4CAF50),
    typeSshKey: Color(0xFF00B8D4),
    scrim: Color(0x22000000),
    shimmerBase: Color(0xFF20202B),
    shimmerHighlight: Color(0xFF30303E),
  );

  /// OLED palette — negro puro para ahorro de batería en pantallas OLED.
  static const AppPalette oled = AppPalette(
    primary: Color(0xFF6C63FF),
    accent: Color(0xFF6C63FF),
    secondary: Color(0xFF03DAC6),
    onPrimary: Colors.white,
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0F),
    card: Color(0xFF0D0D14),
    cardDark: Color(0xFF060609),
    drawer: Color(0xFF0D0D14),
    divider: Color(0xFF1A1A22),
    textPrimary: Color(0xFFF2F2F8),
    textBody: Color(0xFFE0E0F0),
    textMuted: Color(0xFF9A9AB5),
    textDisabled: Color(0xFF5C5C7A),
    textEmpty: Color(0xFF1A1A22),
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
    typeSshKey: Color(0xFF00B8D4),
    scrim: Color(0x33000000),
    shimmerBase: Color(0xFF0D0D14),
    shimmerHighlight: Color(0xFF1A1A22),
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
