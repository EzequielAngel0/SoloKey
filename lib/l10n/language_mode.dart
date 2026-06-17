import 'package:flutter/material.dart';

/// UI language selection, persisted in `AppSecuritySettings.locale`.
///
/// Mirrors the `AppThemeMode` pattern: a stable string `key` for storage plus a
/// resolved [Locale] for `MaterialApp`. `system` returns a null locale so Flutter
/// follows the OS language.
enum LanguageMode {
  system('system'),
  spanish('es'),
  english('en');

  const LanguageMode(this.key);

  final String key;

  static LanguageMode fromKey(String key) => LanguageMode.values.firstWhere(
        (m) => m.key == key,
        orElse: () => LanguageMode.system,
      );

  /// Locale handed to `MaterialApp`; `null` means "follow the system".
  Locale? get locale => switch (this) {
        LanguageMode.system => null,
        LanguageMode.spanish => const Locale('es'),
        LanguageMode.english => const Locale('en'),
      };
}
