import 'package:flutter/material.dart';

/// Tokens de color de **Tinta y papel** (ADR-0013, DIS-1).
///
/// La interfaz es neutra, como una libreta: tinta casi negra sobre papel
/// cálido. **El único color es el estado de seguridad**: comprometida (y lo que
/// no se deshace), débil y sana. Los tipos de credencial se distinguen por
/// icono, nunca por color.
///
/// Se lee con `context.palette.<rol>` (ver [AppPaletteX]). Los nombres son
/// roles del mundo de la app, no grados de gris.
///
/// Los contrastes de texto cumplen AA (4.5:1) sobre `paper`, `sheet` e `inset`
/// en los dos temas; `inkGhost` es solo para deshabilitado y marcadores.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.paper,
    required this.sheet,
    required this.raised,
    required this.inset,
    required this.ink,
    required this.onInk,
    required this.inkSoft,
    required this.inkFaint,
    required this.inkGhost,
    required this.rule,
    required this.ruleSoft,
    required this.ruleStrong,
    required this.focus,
    required this.breach,
    required this.onBreach,
    required this.breachWash,
    required this.weak,
    required this.onWeak,
    required this.weakWash,
    required this.sound,
    required this.onSound,
    required this.soundWash,
    required this.scrim,
    required this.shadow,
  });

  // ── Superficies (de abajo hacia arriba) ───────────────────────────────────
  /// El papel: fondo de cada pantalla.
  final Color paper;

  /// Una hoja sobre el papel: tarjetas, paneles, barras.
  final Color sheet;

  /// Lo que flota sobre una hoja: diálogos, menús, hojas inferiores.
  final Color raised;

  /// Hundido: campos de texto y controles que reciben algo.
  final Color inset;

  // ── Tinta (cuatro niveles de texto) ───────────────────────────────────────
  /// Texto principal **y botón principal**.
  final Color ink;

  /// Letra sobre tinta (la del botón principal).
  final Color onInk;

  /// Texto secundario: subtítulos, usuario de una credencial.
  final Color inkSoft;

  /// Texto terciario: metadatos, fechas, ayudas.
  final Color inkFaint;

  /// Deshabilitado y marcadores de posición (no pasa AA a propósito).
  final Color inkGhost;

  // ── Bordes ────────────────────────────────────────────────────────────────
  /// Borde fino estándar: contorno de tarjetas y separadores.
  final Color rule;

  /// Separación suave entre filas de una misma lista.
  final Color ruleSoft;

  /// Contorno de controles (campos, casillas, botón con borde).
  final Color ruleStrong;

  /// Anillo de foco del teclado.
  final Color focus;

  // ── Estado de seguridad (el único color) ──────────────────────────────────
  /// Comprometida, brecha, y lo que no se deshace (borrar, cerrar sesión).
  final Color breach;

  /// Letra sobre [breach].
  final Color onBreach;

  /// Fondo liso de un aviso de [breach].
  final Color breachWash;

  /// Débil, repetida, vieja, por vencer.
  final Color weak;

  /// Letra sobre [weak].
  final Color onWeak;

  /// Fondo liso de un aviso de [weak].
  final Color weakWash;

  /// Sana: auditoría sin problemas, sincronizado.
  final Color sound;

  /// Letra sobre [sound].
  final Color onSound;

  /// Fondo liso de un aviso de [sound].
  final Color soundWash;

  // ── Capas ─────────────────────────────────────────────────────────────────
  /// Velo detrás de diálogos y hojas.
  final Color scrim;

  /// Color de la sombra suave de las tarjetas.
  final Color shadow;

  /// Claro: papel cálido, tinta casi negra.
  static const AppPalette light = AppPalette(
    paper: Color(0xFFF7F6F2),
    sheet: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    inset: Color(0xFFF1EFEA),
    ink: Color(0xFF15171A),
    onInk: Color(0xFFFBFAF7),
    inkSoft: Color(0xFF5B6068),
    inkFaint: Color(0xFF6B7078),
    inkGhost: Color(0xFFA3A7AD),
    rule: Color(0xFFE4E2DC),
    ruleSoft: Color(0xFFEEECE7),
    ruleStrong: Color(0xFFCFCCC4),
    focus: Color(0xFF15171A),
    breach: Color(0xFFB4322A),
    onBreach: Color(0xFFFFFFFF),
    breachWash: Color(0xFFFBECEA),
    weak: Color(0xFF94600F),
    onWeak: Color(0xFFFFFFFF),
    weakWash: Color(0xFFFAF0DF),
    sound: Color(0xFF2A7449),
    onSound: Color(0xFFFFFFFF),
    soundWash: Color(0xFFE9F3ED),
    scrim: Color(0x5215171A),
    shadow: Color(0x1415171A),
  );

  /// Oscuro: papel de noche, tinta clara. Los estados, algo más claros para
  /// que se lean sobre el fondo oscuro.
  static const AppPalette dark = AppPalette(
    paper: Color(0xFF121316),
    sheet: Color(0xFF1A1C20),
    raised: Color(0xFF22252A),
    inset: Color(0xFF0E0F12),
    ink: Color(0xFFECEDEF),
    onInk: Color(0xFF121316),
    inkSoft: Color(0xFFA2A6AD),
    inkFaint: Color(0xFF8A8E96),
    inkGhost: Color(0xFF4F535A),
    rule: Color(0xFF2A2D33),
    ruleSoft: Color(0xFF222429),
    ruleStrong: Color(0xFF3A3E45),
    focus: Color(0xFFECEDEF),
    breach: Color(0xFFF0625A),
    onBreach: Color(0xFF121316),
    breachWash: Color(0xFF2C1917),
    weak: Color(0xFFE8B14A),
    onWeak: Color(0xFF121316),
    weakWash: Color(0xFF2A2317),
    sound: Color(0xFF5CBF85),
    onSound: Color(0xFF121316),
    soundWash: Color(0xFF16261D),
    scrim: Color(0x99000000),
    shadow: Color(0x66000000),
  );

  // ── Alias de la v1 ────────────────────────────────────────────────────────
  // Las pantallas de la v1 (carril C) todavía leen estos nombres. Apuntan a los
  // tokens de Tinta y papel para que la v1 se vea con el sistema nuevo mientras
  // C la reescribe; cada PAN deja de usarlos. No usar en código nuevo.

  /// v1: usar [ink].
  Color get primary => ink;

  /// v1: usar [ink].
  Color get accent => ink;

  /// v1: usar [ink].
  Color get secondary => ink;

  /// v1: usar [onInk].
  Color get onPrimary => onInk;

  /// v1: usar [paper].
  Color get background => paper;

  /// v1: usar [sheet].
  Color get surface => sheet;

  /// v1: usar [sheet].
  Color get card => sheet;

  /// v1: usar [inset].
  Color get cardDark => inset;

  /// v1: usar [raised].
  Color get drawer => raised;

  /// v1: usar [rule].
  Color get divider => rule;

  /// v1: usar [ink].
  Color get textPrimary => ink;

  /// v1: usar [ink].
  Color get textBody => ink;

  /// v1: usar [inkSoft].
  Color get textMuted => inkSoft;

  /// v1: usar [inkGhost].
  Color get textDisabled => inkGhost;

  /// v1: usar [rule].
  Color get textEmpty => rule;

  /// v1: usar [breach].
  Color get danger => breach;

  /// v1: usar [breach].
  Color get error => breach;

  /// v1: usar [weak].
  Color get warning => weak;

  /// v1: usar [sound].
  Color get success => sound;

  /// v1: informativo no es un estado de seguridad; usar [inkSoft].
  Color get info => inkSoft;

  /// v1: los tipos van por icono, no por color; usar [inkSoft].
  Color get typePassword => inkSoft;

  /// v1: usar [inkSoft].
  Color get typeApiKey => inkSoft;

  /// v1: usar [inkSoft].
  Color get typeNote => inkSoft;

  /// v1: usar [inkSoft].
  Color get typeTotp => inkSoft;

  /// v1: usar [inkSoft].
  Color get typePasskey => inkSoft;

  /// v1: usar [inkSoft].
  Color get typeSshKey => inkSoft;

  @override
  AppPalette copyWith({
    Color? paper,
    Color? sheet,
    Color? raised,
    Color? inset,
    Color? ink,
    Color? onInk,
    Color? inkSoft,
    Color? inkFaint,
    Color? inkGhost,
    Color? rule,
    Color? ruleSoft,
    Color? ruleStrong,
    Color? focus,
    Color? breach,
    Color? onBreach,
    Color? breachWash,
    Color? weak,
    Color? onWeak,
    Color? weakWash,
    Color? sound,
    Color? onSound,
    Color? soundWash,
    Color? scrim,
    Color? shadow,
  }) {
    return AppPalette(
      paper: paper ?? this.paper,
      sheet: sheet ?? this.sheet,
      raised: raised ?? this.raised,
      inset: inset ?? this.inset,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      inkGhost: inkGhost ?? this.inkGhost,
      rule: rule ?? this.rule,
      ruleSoft: ruleSoft ?? this.ruleSoft,
      ruleStrong: ruleStrong ?? this.ruleStrong,
      focus: focus ?? this.focus,
      breach: breach ?? this.breach,
      onBreach: onBreach ?? this.onBreach,
      breachWash: breachWash ?? this.breachWash,
      weak: weak ?? this.weak,
      onWeak: onWeak ?? this.onWeak,
      weakWash: weakWash ?? this.weakWash,
      sound: sound ?? this.sound,
      onSound: onSound ?? this.onSound,
      soundWash: soundWash ?? this.soundWash,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      paper: m(paper, other.paper),
      sheet: m(sheet, other.sheet),
      raised: m(raised, other.raised),
      inset: m(inset, other.inset),
      ink: m(ink, other.ink),
      onInk: m(onInk, other.onInk),
      inkSoft: m(inkSoft, other.inkSoft),
      inkFaint: m(inkFaint, other.inkFaint),
      inkGhost: m(inkGhost, other.inkGhost),
      rule: m(rule, other.rule),
      ruleSoft: m(ruleSoft, other.ruleSoft),
      ruleStrong: m(ruleStrong, other.ruleStrong),
      focus: m(focus, other.focus),
      breach: m(breach, other.breach),
      onBreach: m(onBreach, other.onBreach),
      breachWash: m(breachWash, other.breachWash),
      weak: m(weak, other.weak),
      onWeak: m(onWeak, other.onWeak),
      weakWash: m(weakWash, other.weakWash),
      sound: m(sound, other.sound),
      onSound: m(onSound, other.onSound),
      soundWash: m(soundWash, other.soundWash),
      scrim: m(scrim, other.scrim),
      shadow: m(shadow, other.shadow),
    );
  }
}

/// Acceso corto: `context.palette.ink`, `context.palette.breach`...
/// Si no hay extensión registrada (no debería pasar), usa la clara.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
