import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solokey/core/infrastructure/vault/data_location.dart';

/// Shared engine for SoloKey E2E flows. See docs/proceso/PRUEBAS_INTEGRACION.md.
///
/// Golden rules baked in here:
///  - **Never** `pumpAndSettle` (TOTP `Timer.periodic`, auto-lock ticker and the
///    desktop sync daemon never "settle"). Wait by CONDITION instead.
///  - Clean state = a BRAND-NEW vault: wipe the isolated data dir (NUC-6) before
///    launching the app.
///  - Zero-Print: never log a revealed secret; assert against known values.

/// Pumps frames until [finder] matches or [timeout] elapses. On timeout it fails
/// with the currently visible texts — a cheap snapshot of where the flow stuck.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Did not appear within $timeout: $finder\n'
      'Visible texts: ${_visibleTexts(tester)}');
}

/// Waits for ANY of [finders] and returns the index of the first that appears.
/// Handy for branching flows (Setup vs Unlock, biometric vs password).
Future<int> waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 25),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    for (var i = 0; i < finders.length; i++) {
      if (finders[i].evaluate().isNotEmpty) return i;
    }
  }
  fail('None of the finders appeared within $timeout: $finders\n'
      'Visible texts: ${_visibleTexts(tester)}');
}

/// Scrolls [finder] into view (best-effort) then taps it — guards against a tap
/// silently landing off the visible area on scrollable sheets/lists.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  try {
    await tester.ensureVisible(finder);
  } catch (_) {
    // Not inside a scrollable, or already visible — fall through and tap.
  }
  await tester.pump(const Duration(milliseconds: 120));
  await tester.tap(finder);
  await tester.pump();
}

/// Enters [text] into the field whose [InputDecoration.labelText] equals [label]
/// — more stable than positional finders across layout tweaks.
Future<void> enterByLabel(
    WidgetTester tester, String label, String text) async {
  final field = fieldByLabel(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Finder fieldByLabel(String label) => find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.labelText == label || w.decoration?.hintText == label),
    );

/// Borra la carpeta de datos AISLADA (NUC-6) para empezar con una boveda nueva. Solo actua con las dos banderas:
/// `--dart-define=E2E_ALLOW_WIPE=1` y `--dart-define=SOLOKEY_DATA_DIR=<carpeta>` (que un release ignora). Nunca toca
/// la boveda real del equipo ni el almacen seguro del sistema: con datos aislados la app usa un almacen en archivo
/// dentro de esa carpeta. `bool.fromEnvironment` solo acepta "true", asi que se aceptan `=1` y `=true`.
const bool e2eWipeAllowed =
    String.fromEnvironment('E2E_ALLOW_WIPE') == '1' ||
        String.fromEnvironment('E2E_ALLOW_WIPE') == 'true';

/// Las E2E que borran solo corren con las dos banderas.
bool get e2eCanWipe => e2eWipeAllowed && isIsolatedDataDir;

Future<void> resetVault() async {
  if (!e2eCanWipe) return;
  final dir = Directory((await resolveDataLocation()).dataDir);
  for (final e in dir.listSync()) {
    e.deleteSync(recursive: true);
  }
}

List<String> _visibleTexts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data)
    .whereType<String>()
    .where((s) => s.trim().isNotEmpty)
    .take(30)
    .toList();
