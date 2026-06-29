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
  /// UI font — Inter (bundled offline). Use as the default everywhere.
  static const String fontFamily = 'Inter';

  /// Monospaced font — JetBrains Mono (bundled offline). For secrets, codes,
  /// TOTP digits and SSH key blobs (tabular, aligns digits).
  static const String monoFamily = 'JetBrains Mono';

  // ── Graphite Pro radii (4pt grid) ──────────────────────────────────────────
  static const double rCard = 16;
  static const double rButton = 14;
  static const double rInput = 12;
  static const double rPill = 999;
  static const double rSheet = 24;

  /// Builds a [ThemeData] from a semantic [AppPalette]. The palette is also
  /// registered as a [ThemeExtension] so `context.palette` resolves correctly.
  ///
  /// Graphite Pro: completely flat — no glassmorphism, no M3 elevation tint.
  /// Depth comes from hairline [AppPalette.divider] borders and soft shadows.
  static ThemeData fromPalette(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final focusRing = BorderSide(color: p.primary, width: 1.5);
    final hairline = BorderSide(color: p.divider, width: 1);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: p.onPrimary,
        primaryContainer: p.primary.withValues(alpha: 0.16),
        onPrimaryContainer: p.primary,
        secondary: p.secondary,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: p.error,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
        onSurfaceVariant: p.textMuted,
        outline: p.divider,
        outlineVariant: p.divider,
      ),
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.divider,
      // Kill the M3 surface tint everywhere: it reads as a translucent glass
      // tint, which the design system forbids.
      cardColor: p.card,
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
          side: hairline,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: p.textPrimary),
        actionsIconTheme: IconThemeData(color: p.textBody),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rInput),
          borderSide: hairline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rInput),
          borderSide: hairline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rInput),
          borderSide: focusRing,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rInput),
          borderSide: BorderSide(color: p.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rInput),
          borderSide: BorderSide(color: p.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: p.textMuted),
        floatingLabelStyle: TextStyle(color: p.primary),
        hintStyle: TextStyle(color: p.textDisabled),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.divider,
          disabledForegroundColor: p.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.divider,
          disabledForegroundColor: p.textDisabled,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: hairline,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 1,
        extendedTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rButton),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        height: 68,
        indicatorColor: p.primary.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rPill),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        indicatorColor: p.primary.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rButton),
        ),
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.textMuted),
        selectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textMuted,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.primary,
        disabledColor: p.divider,
        side: hairline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rPill),
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textBody,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textBody,
          fontSize: 15,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(rSheet)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rInput),
          side: hairline,
        ),
        textStyle: TextStyle(fontFamily: fontFamily, color: p.textBody),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.drawer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(rSheet)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.card,
        contentTextStyle: TextStyle(fontFamily: fontFamily, color: p.textPrimary),
        actionTextColor: p.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rInput),
          side: hairline,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textMuted,
        textColor: p.textBody,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: p.textMuted,
          fontSize: 13,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.onPrimary
              : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : p.divider,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.divider,
        thumbColor: p.primary,
        overlayColor: p.primary.withValues(alpha: 0.16),
        valueIndicatorColor: p.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.divider,
        circularTrackColor: p.divider,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.fromBorderSide(hairline),
        ),
        textStyle: TextStyle(fontFamily: fontFamily, color: p.textBody, fontSize: 12),
      ),
      textTheme: _textTheme(p),
      extensions: [p],
    );
  }

  /// Inter-based text theme. Negative letter-spacing on big titles for the
  /// "pro" look; muted body text via [AppPalette].
  static TextTheme _textTheme(AppPalette p) => TextTheme(
        displayLarge: TextStyle(
          color: p.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displayMedium: TextStyle(
          color: p.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: p.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          color: p.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: p.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: p.textBody,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: p.textBody, fontSize: 16),
        bodyMedium: TextStyle(color: p.textBody, fontSize: 15),
        bodySmall: TextStyle(color: p.textMuted, fontSize: 13),
        labelLarge: TextStyle(
          color: p.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: p.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: p.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );

  static ThemeData light() => fromPalette(AppPalette.light, Brightness.light);
  static ThemeData dark() => fromPalette(AppPalette.dark, Brightness.dark);
  static ThemeData dim() => fromPalette(AppPalette.dim, Brightness.dark);
  static ThemeData oled() => fromPalette(AppPalette.oled, Brightness.dark);
}
