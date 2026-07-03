import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/l10n/app_localizations.dart';
import 'package:password_manager/theme/app_theme.dart';

/// Minimal shell every SoloKey widget test needs, in one place:
///  - a [ProviderScope] with the given [overrides] (use-case providers throw
///    `UnimplementedError` by design — always override what the widget reads);
///  - the Graphite Pro theme, which registers the `AppPalette` ThemeExtension
///    so `context.palette` resolves;
///  - the i18n delegates so `AppLocalizations.of(context)` works.
///
/// Reminders (see docs/prompts/95_pruebas.md):
///  - Do NOT `pumpAndSettle` when a `Timer.periodic` is alive (e.g. the TOTP
///    card) — bump frames with `tester.pump(Duration(...))` instead.
///  - After typing in the search field, advance > 250 ms to fire the debounce.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Size? surfaceSize,
}) async {
  if (surfaceSize != null) {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme ?? AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

/// Wraps [child] in a [Scaffold] body — handy for isolated components that
/// expect Material ancestors (ink, text directionality, etc.).
Widget scaffolded(Widget child) => Scaffold(body: child);

/// Tolerates ONLY Flutter's debug ink warning "…will hide those effects",
/// emitted when a `ListTile`/`SwitchListTile` sits inside an opaque colored
/// container (e.g. `FormSection`). It's a paint-only cosmetic check unrelated to
/// the behavior under test; every other error still surfaces and fails the test.
/// Call this at the very start of a test (before pumping), so it is active for
/// the first paint too.
void tolerateInkHiddenPaintWarnings() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('hide those effects')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}
