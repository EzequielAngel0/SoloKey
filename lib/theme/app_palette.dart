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

  /// Dark palette (default) — "Graphite Pro": neutral graphite surfaces, a single
  /// confident blue accent (`#3B82F6`) and emerald for success. Flat, no neon, no
  /// glassmorphism: depth comes only from hairline dividers and soft shadows.
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF3B82F6),
    accent: Color(0xFF3B82F6),
    secondary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFF0B0B0F),
    surface: Color(0xFF121218),
    card: Color(0xFF17171F),
    cardDark: Color(0xFF0F0F14),
    drawer: Color(0xFF121218),
    divider: Color(0xFF262630),
    textPrimary: Color(0xFFF3F4F7),
    textBody: Color(0xFFC7C8D1),
    textMuted: Color(0xFF8A8B97),
    textDisabled: Color(0xFF56575F),
    textEmpty: Color(0xFF262630),
    danger: Color(0xFFF26D6D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF5A524),
    success: Color(0xFF10B981),
    info: Color(0xFF38BDF8),
    typePassword: Color(0xFF3B82F6),
    typeApiKey: Color(0xFF10B981),
    typeNote: Color(0xFFF5A524),
    typeTotp: Color(0xFF8B5CF6),
    typePasskey: Color(0xFF14B8A6),
    typeSshKey: Color(0xFF0EA5E9),
    scrim: Color(0x88000000),
    shimmerBase: Color(0xFF17171F),
    shimmerHighlight: Color(0xFF262630),
  );

  /// Light palette — "Graphite Pro" claro: alto contraste, plano, sin neón. Dark
  /// es la referencia de QA; light se mantiene correcto y legible.
  static const AppPalette light = AppPalette(
    primary: Color(0xFF2563EB),
    accent: Color(0xFF2563EB),
    secondary: Color(0xFF059669),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF7F7F9),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardDark: Color(0xFFF1F1F7),
    drawer: Color(0xFFFFFFFF),
    divider: Color(0xFFE6E6EC),
    textPrimary: Color(0xFF15161A),
    textBody: Color(0xFF3A3B42),
    textMuted: Color(0xFF6B6C77),
    textDisabled: Color(0xFFA6A7B0),
    textEmpty: Color(0xFFE6E6EC),
    danger: Color(0xFFE5484D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    success: Color(0xFF059669),
    info: Color(0xFF0284C7),
    typePassword: Color(0xFF2563EB),
    typeApiKey: Color(0xFF059669),
    typeNote: Color(0xFFB45309),
    typeTotp: Color(0xFF7C3AED),
    typePasskey: Color(0xFF0D9488),
    typeSshKey: Color(0xFF0284C7),
    scrim: Color(0x33000000),
    shimmerBase: Color(0xFFE9E9F0),
    shimmerHighlight: Color(0xFFF7F7F9),
  );

  /// Dim palette — un oscuro suave (gris-azulado), menos contraste que dark.
  /// Graphite Pro con un azul algo más claro (`#5B96F8`) para bajar el contraste.
  static const AppPalette dim = AppPalette(
    primary: Color(0xFF5B96F8),
    accent: Color(0xFF5B96F8),
    secondary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFF14151A),
    surface: Color(0xFF1B1C22),
    card: Color(0xFF1F2027),
    cardDark: Color(0xFF15161B),
    drawer: Color(0xFF1B1C22),
    divider: Color(0xFF2C2D36),
    textPrimary: Color(0xFFE7E8EE),
    textBody: Color(0xFFBFC1CB),
    textMuted: Color(0xFF85868F),
    textDisabled: Color(0xFF56575F),
    textEmpty: Color(0xFF2C2D36),
    danger: Color(0xFFF26D6D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF5A524),
    success: Color(0xFF10B981),
    info: Color(0xFF38BDF8),
    typePassword: Color(0xFF5B96F8),
    typeApiKey: Color(0xFF10B981),
    typeNote: Color(0xFFF5A524),
    typeTotp: Color(0xFF8B5CF6),
    typePasskey: Color(0xFF14B8A6),
    typeSshKey: Color(0xFF0EA5E9),
    scrim: Color(0x88000000),
    shimmerBase: Color(0xFF1F2027),
    shimmerHighlight: Color(0xFF2C2D36),
  );

  /// OLED palette — negro puro para ahorro de batería en pantallas OLED.
  /// Graphite Pro sobre negro absoluto, mismo azul `#3B82F6` que dark.
  static const AppPalette oled = AppPalette(
    primary: Color(0xFF3B82F6),
    accent: Color(0xFF3B82F6),
    secondary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFF000000),
    surface: Color(0xFF08080B),
    card: Color(0xFF0C0C10),
    cardDark: Color(0xFF050507),
    drawer: Color(0xFF0C0C10),
    divider: Color(0xFF1C1C24),
    textPrimary: Color(0xFFF3F4F7),
    textBody: Color(0xFFC7C8D1),
    textMuted: Color(0xFF8A8B97),
    textDisabled: Color(0xFF56575F),
    textEmpty: Color(0xFF1C1C24),
    danger: Color(0xFFF26D6D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF5A524),
    success: Color(0xFF10B981),
    info: Color(0xFF38BDF8),
    typePassword: Color(0xFF3B82F6),
    typeApiKey: Color(0xFF10B981),
    typeNote: Color(0xFFF5A524),
    typeTotp: Color(0xFF8B5CF6),
    typePasskey: Color(0xFF14B8A6),
    typeSshKey: Color(0xFF0EA5E9),
    scrim: Color(0x99000000),
    shimmerBase: Color(0xFF0C0C10),
    shimmerHighlight: Color(0xFF1C1C24),
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
