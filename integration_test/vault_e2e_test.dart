import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solokey/features/vault_access/application/vault_state_provider.dart';
import 'package:solokey/features/vault_access/presentation/setup_screen.dart';
import 'package:solokey/features/vault_access/presentation/unlock_screen.dart';
import 'package:solokey/l10n/app_localizations.dart';

import 'package:solokey/main.dart' as app;

import 'support/e2e_helpers.dart';

/// Happy-path E2E against the REAL stack (encrypted DB + Keystore/DPAPI), PAN-1:
/// first use in three steps (master password → confirm one group of the
/// recovery code → import, skipped), land in the vault, lock it, and unlock it
/// again with the master password field.
///
/// ⚠️ DESTRUCTIVE: it needs a CLEAN vault, so it wipes local storage via
/// [resetVault]. Both this test and `resetVault` are hard-gated behind
/// `--dart-define=E2E_ALLOW_WIPE=1` and it **must only run on a throwaway
/// device/emulator** or through `run_integration_tests.ps1` (backs up and
/// restores the real vault).
///
/// Texts come from the app's own [AppLocalizations], so it works in any UI
/// language. Before each tap the soft keyboard is closed: on Android it can
/// cover the button. Zero-Print: no secret logged.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 12+ chars, upper, digit and symbol → passes the master password rules.
  const masterPassword = 'TestVault#2026';

  testWidgets('first use in 3 steps → vault → lock → unlock with the field',
      (tester) async {
    await resetVault(); // clean state = brand-new vault (gated + backed up)

    // main() installs the app's own error handlers; give the test its handler
    // back once the app is up, or a failure only shows as an opaque
    // "_pendingExceptionDetails != null" and tearDownAll hangs.
    final testOnError = FlutterError.onError;
    app.main(const <String>[]); // not awaited (desktop main awaits window setup)
    await waitFor(tester, find.byType(SetupScreen));
    FlutterError.onError = testOnError;
    final l = AppLocalizations.of(tester.element(find.byType(SetupScreen)));

    // Step 1: master password + confirmation.
    await enterByLabel(tester, l.unlockMasterPasswordHint, masterPassword);
    await enterByLabel(tester, l.setupConfirmLabel, masterPassword);
    await _tapButton(tester, l.setupCreateButton);

    // Step 2: the code is shown once; a wrong group is refused, the right one
    // moves on. The group asked for is random, so read it from the label.
    await waitFor(tester, find.text(l.setupStepSaveCode),
        timeout: const Duration(seconds: 60)); // Argon2id on a slow emulator
    final code =
        tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    final groups = code.split('-');
    final asked = List.generate(groups.length, (i) => i + 1).firstWhere(
          (n) => fieldByLabel(l.setupCodeConfirmLabel(n)).evaluate().isNotEmpty,
        );
    final groupField = l.setupCodeConfirmLabel(asked);

    await _typeAndSubmit(tester, groupField, 'NOPE');
    await waitFor(tester, find.text(l.setupCodeConfirmWrong(asked)));

    await _typeAndSubmit(tester, groupField, groups[asked - 1]);

    // Step 3: import is optional; go straight into the vault.
    await waitFor(tester, find.text(l.setupStepImport));
    await _tapButton(tester, l.setupImportDone);

    // Unlocked vault: the add-credential affordance (Icons.add_rounded) exists
    // in both mobile and desktop home layouts.
    await waitFor(tester, find.byIcon(Icons.add_rounded));
    expect(find.byType(SetupScreen), findsNothing);

    // Lock it the way the app does (auto-lock, tray, shortcut), then unlock with
    // the master password field.
    ProviderScope.containerOf(
      tester.element(find.byIcon(Icons.add_rounded).first),
    ).read(vaultNotifierProvider.notifier).lock();
    await waitFor(tester, find.byType(UnlockScreen));
    await enterByLabel(tester, l.unlockMasterPasswordHint, masterPassword);
    await _tapButton(tester, l.unlockButton);

    await waitFor(tester, find.byIcon(Icons.add_rounded),
        timeout: const Duration(seconds: 60));
    expect(find.byType(UnlockScreen), findsNothing);
  },
      // Never runs by accident: only on a disposable device with the opt-in.
      skip: !e2eCanWipe);
}

/// Types [text] in the field labelled [label] and presses the keyboard's Done
/// key while it still has focus, as a person does. Submitting from the field
/// avoids the real Android IME pushing its stale text back when the field
/// loses focus.
Future<void> _typeAndSubmit(
    WidgetTester tester, String label, String text) async {
  await enterByLabel(tester, label, text);
  expect(tester.widget<TextField>(fieldByLabel(label)).controller?.text, text,
      reason: 'the field "$label" does not hold what was typed');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump(const Duration(milliseconds: 200));
}

/// Closes the soft keyboard (it can cover the button on Android) and taps the
/// button that shows [label].
Future<void> _tapButton(WidgetTester tester, String label) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 400));
  await tapVisible(tester, find.text(label).last);
}
