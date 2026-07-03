import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:password_manager/features/vault_access/presentation/setup_screen.dart';
import 'package:password_manager/features/vault_access/presentation/unlock_screen.dart';

import 'package:password_manager/main.dart' as app;

import 'support/e2e_helpers.dart';

/// Smallest real E2E and the one to keep green: a cold boot of the WHOLE app on
/// the device. Proves `main()` → DI (get_it) → splash → `isVaultInitialized()`
/// (secure storage) → router all wire up against the real stack.
///
/// **Non-destructive on purpose**: it does NOT wipe the vault, so it is safe to
/// run on any machine (including one holding a real vault). It therefore asserts
/// the app reaches the ACCESS flow — Setup (empty vault) OR Unlock (existing
/// vault) — either of which proves the cold boot succeeded.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold boot reaches the access flow (Setup or Unlock)',
      (tester) async {
    app.main(const <String>[]); // not awaited: desktop main awaits window setup
    final which = await waitForAny(tester, [
      find.byType(SetupScreen),
      find.byType(UnlockScreen),
    ]);
    // 0 = Setup (no vault yet), 1 = Unlock (a vault exists). Both are a pass.
    expect(which, anyOf(0, 1));
  });
}
