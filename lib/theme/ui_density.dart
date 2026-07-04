import 'package:flutter/material.dart';

/// UI density the user can pick in Settings, persisted as a string in
/// `AppSecuritySettings.uiDensity` via [key].
///
/// Mirrors the `AppThemeMode` / `LanguageMode` pattern: a stable string [key]
/// for storage plus a resolved [VisualDensity] applied to the [ThemeData] in
/// `app.dart`. `comfortable` is the default spacing; `compact` tightens rows
/// for the dense, 1Password-like desktop feel.
enum UiDensity {
  comfortable('comfortable'),
  compact('compact');

  const UiDensity(this.key);

  final String key;

  /// Resolves a stored string back to a density, defaulting to [comfortable].
  static UiDensity fromKey(String? key) => UiDensity.values.firstWhere(
        (d) => d.key == key,
        orElse: () => UiDensity.comfortable,
      );

  /// [VisualDensity] handed to `ThemeData`.
  VisualDensity get visualDensity => switch (this) {
        UiDensity.comfortable => VisualDensity.standard,
        UiDensity.compact => VisualDensity.compact,
      };

  IconData get icon => switch (this) {
        UiDensity.comfortable => Icons.density_medium_rounded,
        UiDensity.compact => Icons.density_small_rounded,
      };
}
