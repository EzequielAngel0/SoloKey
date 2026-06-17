import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Theme variants the user can pick from in Settings. Persisted as a string in
/// `AppSecuritySettings.themeMode` via [key]. `system` follows the OS brightness
/// (light/dark); `dim` and `oled` are explicit dark variants.
enum AppThemeMode {
  system,
  light,
  dark,
  dim,
  oled;

  /// Resolves a stored string back to a mode, defaulting to [system].
  static AppThemeMode fromKey(String? key) => switch (key) {
        'light' => AppThemeMode.light,
        'dark' => AppThemeMode.dark,
        'dim' => AppThemeMode.dim,
        'oled' => AppThemeMode.oled,
        _ => AppThemeMode.system,
      };

  /// Stable string used for persistence.
  String get key => name;

  /// Human label for the Settings selector.
  String get label => switch (this) {
        AppThemeMode.system => 'Seguir el sistema',
        AppThemeMode.light => 'Claro',
        AppThemeMode.dark => 'Oscuro',
        AppThemeMode.dim => 'Tenue',
        AppThemeMode.oled => 'OLED',
      };

  IconData get icon => switch (this) {
        AppThemeMode.system => Icons.brightness_auto_rounded,
        AppThemeMode.light => Icons.light_mode_rounded,
        AppThemeMode.dark => Icons.dark_mode_rounded,
        AppThemeMode.dim => Icons.brightness_4_rounded,
        AppThemeMode.oled => Icons.contrast_rounded,
      };
}

abstract final class AppTheme {
  /// Builds a [ThemeData] from a semantic [AppPalette]. The palette is also
  /// registered as a [ThemeExtension] so `context.palette` resolves correctly.
  static ThemeData fromPalette(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: p.onPrimary,
        secondary: p.secondary,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: p.error,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
      ),
      scaffoldBackgroundColor: p.background,
      cardColor: p.card,
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: p.textMuted),
        hintStyle: TextStyle(color: p.textDisabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600),
        titleMedium:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: p.textBody),
        bodyMedium: TextStyle(color: p.textMuted),
        labelLarge:
            TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600),
      ),
      extensions: [p],
    );
  }

  static ThemeData light() => fromPalette(AppPalette.light, Brightness.light);
  static ThemeData dark() => fromPalette(AppPalette.dark, Brightness.dark);
  static ThemeData dim() => fromPalette(AppPalette.dim, Brightness.dark);
  static ThemeData oled() => fromPalette(AppPalette.oled, Brightness.dark);
}
