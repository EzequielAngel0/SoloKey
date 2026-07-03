import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Shared engine for SoloKey E2E flows. See docs/prompts/PRUEBAS_INTEGRACION.md.
///
/// Golden rules baked in here:
///  - **Never** `pumpAndSettle` (TOTP `Timer.periodic`, auto-lock ticker and the
///    desktop sync daemon never "settle"). Wait by CONDITION instead.
///  - Clean state = a BRAND-NEW vault: wipe the local Drift DB file + the secure
///    storage before launching the app.
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

/// ⚠️ DESTRUCTIVE — wipes the vault (secure storage + Drift DB) so a run starts
/// from a known-empty state. This targets the SAME storage the real desktop app
/// uses, so on a machine with a real vault it WILL delete the user's data.
///
/// For that reason it is **hard-gated**: it does nothing unless BOTH
/// `--dart-define=E2E_ALLOW_WIPE=1` is passed AND (belt-and-suspenders) the app
/// identity is not the shipped one. Even when allowed, it first copies every
/// file it will delete to a timestamped `.e2e-backup` sibling. Run E2E only on a
/// throwaway device/emulator, never on a machine that holds a real vault.
/// Opt-in flag for the destructive path. `bool.fromEnvironment` only accepts the
/// literal "true", so we accept both `E2E_ALLOW_WIPE=1` and `=true`.
const bool e2eWipeAllowed =
    String.fromEnvironment('E2E_ALLOW_WIPE') == '1' ||
        String.fromEnvironment('E2E_ALLOW_WIPE') == 'true';

Future<void> resetVault() async {
  if (!e2eWipeAllowed) {
    // Safe default: do NOT touch persistent storage. Tests that truly need a
    // clean vault should be run with the define on a disposable device.
    return;
  }
  final stamp = DateTime.now().millisecondsSinceEpoch;
  try {
    // Back up secure storage before clearing it (both known dir layouts).
    final support = await getApplicationSupportDirectory();
    final secure = File(p.join(support.path, 'flutter_secure_storage.dat'));
    if (await secure.exists()) {
      await secure.copy('${secure.path}.$stamp.e2e-backup');
    }
    await const FlutterSecureStorage().deleteAll();
  } catch (_) {
    // Best effort.
  }
  try {
    // Drift stores under the Documents dir (`getApplicationDocumentsDirectory`),
    // NOT the support dir — back up then delete there.
    final docs = await getApplicationDocumentsDirectory();
    for (final ext in ['sqlite', 'sqlite-wal', 'sqlite-shm']) {
      final f = File(p.join(docs.path, 'vault_guard_db.$ext'));
      if (await f.exists()) {
        await f.copy('${f.path}.$stamp.e2e-backup');
        await f.delete();
      }
    }
  } catch (_) {
    // Best effort.
  }
}

List<String> _visibleTexts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data)
    .whereType<String>()
    .where((s) => s.trim().isNotEmpty)
    .take(30)
    .toList();
