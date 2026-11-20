import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_tokens.dart';

/// Temas que el usuario elige en Ajustes, guardados como texto en
/// `AppSecuritySettings.themeMode` con [key]. Por defecto se sigue al sistema.
/// Dim y OLED salieron en la v2 (DEC-3): un valor guardado viejo cae en oscuro.
enum AppThemeMode {
  system,
  light,
  dark;

  /// Lee el valor guardado; 'dim' y 'oled' de la v1 pasan a [dark].
  static AppThemeMode fromKey(String? key) => switch (key) {
        'light' => AppThemeMode.light,
        'dark' || 'dim' || 'oled' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };

  /// Texto estable para guardar.
  String get key => name;

  IconData get icon => switch (this) {
        AppThemeMode.system => Icons.brightness_auto_outlined,
        AppThemeMode.light => Icons.light_mode_outlined,
        AppThemeMode.dark => Icons.dark_mode_outlined,
      };
}

/// Tema de **Tinta y papel** (ADR-0013, DIS-1): liso, borde fino y sombra
/// suave, esquinas de 12, el botón principal es tinta y el único color es el
/// estado de seguridad. Letra Atkinson Hyperlegible Next (interfaz) y Mono
/// (secretos y códigos), empaquetadas sin red.
abstract final class AppTheme {
  /// Letra de la interfaz.
  static const String fontFamily = 'Atkinson Hyperlegible Next';

  /// Letra de secretos, códigos TOTP y llaves SSH: distingue l, I y 1, y 0 y O.
  static const String monoFamily = 'Atkinson Hyperlegible Mono';

  /// v1: usar [AppRadius]. Se quitan cuando C deje de usarlos.
  static const double rCard = AppRadius.card;
  static const double rInput = AppRadius.control;
  static const double rPill = AppRadius.pill;

  /// En escritorio el cuerpo baja de 16 a 14 (REDISENO_V2 §3).
  static bool get _isDesktop => switch (defaultTargetPlatform) {
        TargetPlatform.windows ||
        TargetPlatform.linux ||
        TargetPlatform.macOS =>
          true,
        _ => false,
      };

  static ThemeData light({bool? desktop}) =>
      fromPalette(AppPalette.light, Brightness.light, desktop: desktop);

  static ThemeData dark({bool? desktop}) =>
      fromPalette(AppPalette.dark, Brightness.dark, desktop: desktop);

  /// Estilo monoespaciado para un secreto o un código, con cifras de ancho fijo.
  static TextStyle mono(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(
        fontFamily: monoFamily,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 0,
      );

  /// Construye el [ThemeData] desde una [AppPalette], que también queda
  /// registrada como extensión para `context.palette`.
  static ThemeData fromPalette(
    AppPalette p,
    Brightness brightness, {
    bool? desktop,
  }) {
    final isDesktop = desktop ?? _isDesktop;
    final text = _textTheme(p, desktop: isDesktop);
    final hairline = BorderSide(color: p.rule, width: AppDepth.hairline);
    final controlEdge =
        BorderSide(color: p.ruleStrong, width: AppDepth.hairline);
    final focusRing = BorderSide(color: p.focus, width: AppDepth.focusRing);
    const controlShape = RoundedRectangleBorder(
      borderRadius: AppRadius.controlAll,
    );
    final hover = p.ink.withValues(alpha: 0.06);
    final press = p.ink.withValues(alpha: 0.10);
    final buttonText = text.labelLarge!;

    // Superposición plana de la tinta para hover, foco y presionado.
    WidgetStateProperty<Color?> overlay(Color base) =>
        WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) {
            return base.withValues(alpha: 0.10);
          }
          if (s.contains(WidgetState.hovered) ||
              s.contains(WidgetState.focused)) {
            return base.withValues(alpha: 0.06);
          }
          return null;
        });

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      // Liso: sin onda de tinta al tocar, solo el resaltado plano.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: press,
      hoverColor: hover,
      focusColor: press,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.ink,
        onPrimary: p.onInk,
        primaryContainer: p.inset,
        onPrimaryContainer: p.ink,
        secondary: p.inkSoft,
        onSecondary: p.onInk,
        secondaryContainer: p.inset,
        onSecondaryContainer: p.ink,
        tertiary: p.inkSoft,
        onTertiary: p.onInk,
        error: p.breach,
        onError: p.onBreach,
        errorContainer: p.breachWash,
        onErrorContainer: p.breach,
        surface: p.sheet,
        onSurface: p.ink,
        onSurfaceVariant: p.inkSoft,
        surfaceDim: p.paper,
        surfaceBright: p.sheet,
        surfaceContainerLowest: p.paper,
        surfaceContainerLow: p.sheet,
        surfaceContainer: p.sheet,
        surfaceContainerHigh: p.raised,
        surfaceContainerHighest: p.inset,
        outline: p.ruleStrong,
        outlineVariant: p.rule,
        shadow: p.shadow,
        scrim: p.scrim,
        inverseSurface: p.ink,
        onInverseSurface: p.onInk,
        inversePrimary: p.onInk,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: p.paper,
      canvasColor: p.paper,
      cardColor: p.sheet,
      dividerColor: p.rule,
      disabledColor: p.inkGhost,
      textTheme: text,
      iconTheme: IconThemeData(color: p.ink, size: 24),
      dividerTheme: DividerThemeData(color: p.rule, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: p.sheet,
        elevation: 1,
        shadowColor: p.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: hairline,
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: p.paper,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: AppSpace.lg,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: p.ink),
        actionsIconTheme: IconThemeData(color: p.ink),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: p.inset,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: controlEdge,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: controlEdge,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: focusRing,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: hairline,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: BorderSide(color: p.breach),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlAll,
          borderSide: BorderSide(color: p.breach, width: AppDepth.focusRing),
        ),
        labelStyle: text.bodyMedium!.copyWith(color: p.inkSoft),
        floatingLabelStyle: text.bodyMedium!.copyWith(color: p.ink),
        hintStyle: text.bodyMedium!.copyWith(color: p.inkFaint),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: p.breach),
        helperMaxLines: 3,
        errorMaxLines: 3,
        prefixIconColor: p.inkSoft,
        suffixIconColor: p.inkSoft,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.ink,
        selectionColor: p.ink.withValues(alpha: 0.18),
        selectionHandleColor: p.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.rule : p.ink,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.onInk,
          ),
          overlayColor: overlay(p.onInk),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size(64, AppSpace.touch)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpace.xl),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      // ElevatedButton de la v1 = botón principal liso (sin elevación).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.rule : p.ink,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.onInk,
          ),
          overlayColor: overlay(p.onInk),
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          minimumSize: const WidgetStatePropertyAll(Size(64, AppSpace.touch)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpace.xl),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.ink,
          ),
          backgroundColor: WidgetStatePropertyAll(p.sheet),
          overlayColor: overlay(p.ink),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused)
                ? focusRing
                : (s.contains(WidgetState.disabled) ? hairline : controlEdge),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(64, AppSpace.touch)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpace.xl),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.ink,
          ),
          overlayColor: overlay(p.ink),
          minimumSize: const WidgetStatePropertyAll(Size(48, AppSpace.touch)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpace.md),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(
            buttonText.copyWith(decoration: TextDecoration.none),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? p.inkGhost : p.ink,
          ),
          overlayColor: overlay(p.ink),
          minimumSize:
              const WidgetStatePropertyAll(Size(AppSpace.touch, AppSpace.touch)),
          shape: const WidgetStatePropertyAll(controlShape),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.ink,
        foregroundColor: p.onInk,
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 2,
        highlightElevation: 1,
        splashColor: Colors.transparent,
        extendedTextStyle: buttonText,
        shape: controlShape,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.ink : p.sheet,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.onInk : p.ink,
          ),
          side: WidgetStatePropertyAll(controlEdge),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(buttonText),
          minimumSize: const WidgetStatePropertyAll(Size(48, AppSpace.touch)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.sheet,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        height: 72,
        indicatorColor: p.inset,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? p.ink : p.inkSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium!.copyWith(
            color: s.contains(WidgetState.selected) ? p.ink : p.inkSoft,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.paper,
        elevation: 0,
        indicatorColor: p.inset,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlAll,
        ),
        selectedIconTheme: IconThemeData(color: p.ink),
        unselectedIconTheme: IconThemeData(color: p.inkSoft),
        selectedLabelTextStyle:
            text.labelMedium!.copyWith(color: p.ink, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: text.labelMedium!.copyWith(color: p.inkSoft),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.sheet,
        selectedColor: p.ink,
        disabledColor: p.inset,
        side: controlEdge,
        shape: const StadiumBorder(),
        labelStyle: text.labelMedium!.copyWith(color: p.ink),
        secondaryLabelStyle: text.labelMedium!.copyWith(color: p.onInk),
        checkmarkColor: p.onInk,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: p.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: hairline,
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: p.scrim,
        showDragHandle: true,
        dragHandleColor: p.ruleStrong,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: p.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.controlAll,
          side: hairline,
        ),
        textStyle: text.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(p.raised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          shadowColor: WidgetStatePropertyAll(p.shadow),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: AppRadius.controlAll,
              side: hairline,
            ),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: p.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: text.bodyMedium!.copyWith(color: p.onInk),
        actionTextColor: p.onInk,
        closeIconColor: p.onInk,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlAll,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        textColor: p.ink,
        minVerticalPadding: AppSpace.md,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.controlAll),
        titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: text.bodyMedium!.copyWith(color: p.inkSoft),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return p.inkGhost;
          return s.contains(WidgetState.selected) ? p.onInk : p.inkSoft;
        }),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.ink : p.inset,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.ink : p.ruleStrong,
        ),
        overlayColor: overlay(p.ink),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.ink : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(p.onInk),
        side: BorderSide(color: p.ruleStrong, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.ink : p.ruleStrong,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.ink,
        inactiveTrackColor: p.rule,
        thumbColor: p.ink,
        overlayColor: p.ink.withValues(alpha: 0.10),
        valueIndicatorColor: p.ink,
        valueIndicatorTextStyle: text.labelMedium!.copyWith(color: p.onInk),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.ink,
        linearTrackColor: p.rule,
        circularTrackColor: p.rule,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.tooltip),
          ),
        ),
        textStyle: text.labelMedium!.copyWith(color: p.onInk),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(p.ruleStrong),
        radius: const Radius.circular(AppRadius.pill),
        thumbVisibility: WidgetStatePropertyAll(isDesktop),
      ),
      extensions: [p],
    );
  }

  /// Escala de letra. Móvil: cuerpo 16; escritorio: cuerpo 14. Atkinson ya es
  /// ancha, así que los títulos solo se aprietan un poco.
  static TextTheme _textTheme(AppPalette p, {required bool desktop}) {
    final d = desktop ? 2.0 : 0.0;
    TextStyle s(
      double size,
      FontWeight w,
      Color c, {
      double height = 1.4,
      double tracking = 0,
    }) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          color: c,
          height: height,
          letterSpacing: tracking,
        );

    return TextTheme(
      displayLarge: s(34 - d, FontWeight.w700, p.ink,
          height: 1.15, tracking: -0.5),
      displayMedium: s(30 - d, FontWeight.w700, p.ink,
          height: 1.15, tracking: -0.4),
      displaySmall: s(26 - d, FontWeight.w700, p.ink,
          height: 1.2, tracking: -0.3),
      headlineLarge: s(24 - d, FontWeight.w700, p.ink,
          height: 1.25, tracking: -0.3),
      headlineMedium: s(22 - d, FontWeight.w700, p.ink,
          height: 1.25, tracking: -0.2),
      headlineSmall: s(20 - d, FontWeight.w600, p.ink,
          height: 1.3, tracking: -0.2),
      titleLarge: s(20 - d, FontWeight.w700, p.ink, height: 1.3),
      titleMedium: s(17 - d, FontWeight.w600, p.ink, height: 1.35),
      titleSmall: s(15 - d, FontWeight.w600, p.ink, height: 1.35),
      bodyLarge: s(17 - d, FontWeight.w400, p.ink),
      bodyMedium: s(16 - d, FontWeight.w400, p.ink),
      bodySmall: s(14 - d, FontWeight.w400, p.inkSoft),
      labelLarge: s(16 - d, FontWeight.w600, p.ink, height: 1.25),
      labelMedium: s(14 - d, FontWeight.w500, p.inkSoft, height: 1.3),
      labelSmall: s(13 - d / 2, FontWeight.w500, p.inkFaint, height: 1.3),
    );
  }
}
