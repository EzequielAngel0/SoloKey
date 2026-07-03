import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:password_manager/features/vault_access/presentation/recovery_screen.dart';
import 'package:password_manager/features/vault_access/presentation/setup_screen.dart';

import 'package:password_manager/main.dart' as app;

import 'support/e2e_helpers.dart';

/// Happy-path E2E against the REAL stack (encrypted DB + Keystore/DPAPI): create
/// a brand-new vault with a master password and land, unlocked, in the app.
/// Exercises the crypto-critical setup path end-to-end (Argon2id derivation,
/// salt, vault persistence, session unlock, recovery-code generation) + router.
///
/// ⚠️ DESTRUCTIVE: it needs a CLEAN vault, so it wipes local storage via
/// [resetVault]. Both this test and `resetVault` are hard-gated behind
/// `--dart-define=E2E_ALLOW_WIPE=1` and it **must only run on a throwaway
/// device/emulator**, never on a machine holding a real vault.
///
/// Run it with:
///   flutter test integration_test/vault_e2e_test.dart -d windows \
///     --dart-define=TEST_DISABLE_BIOMETRIC=1 --dart-define=E2E_ALLOW_WIPE=1
///
/// Finders are locale-agnostic (by widget type/icon, not by English text) so it
/// works whatever UI language the device is set to. Zero-Print: no secret logged.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 12+ chars, upper, digit and symbol → passes the setup complexity rules.
  const masterPassword = 'TestVault#2026';

  testWidgets('setup a new vault → recovery code → unlocked app',
      (tester) async {
    await resetVault(); // clean state = brand-new vault (gated + backed up)

    app.main(const <String>[]); // not awaited (desktop main awaits window setup)
    await waitFor(tester, find.byType(SetupScreen));

    // Password + confirmation fields (locale-agnostic: by type, in tree order).
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), masterPassword);
    await tester.enterText(fields.at(1), masterPassword);
    await tester.pump();

    // The only ElevatedButton on Setup is "create vault".
    await tapVisible(tester, find.byType(ElevatedButton));

    // One-time recovery code shown post-setup; the only ElevatedButton continues.
    await waitFor(tester, find.byType(RecoveryCodeDisplay));
    await tapVisible(tester, find.byType(ElevatedButton));

    // We should now be in the unlocked vault: the add-credential affordance
    // (Icons.add_rounded) exists in both mobile and desktop home layouts.
    await waitFor(tester, find.byIcon(Icons.add_rounded));
    expect(find.byType(SetupScreen), findsNothing);
  },
      // Never runs by accident: only on a disposable device with the opt-in.
      skip: !e2eWipeAllowed);
}
