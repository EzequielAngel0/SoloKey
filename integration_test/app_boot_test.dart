import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solokey/features/settings/presentation/settings_screen.dart';
import 'package:solokey/features/vault_access/presentation/setup_screen.dart';
import 'package:solokey/features/vault_access/presentation/unlock_screen.dart';
import 'package:solokey/l10n/app_localizations.dart';

import 'package:solokey/main.dart' as app;

import 'support/e2e_helpers.dart';

/// Smallest real E2E and the one to keep green: a cold boot of the WHOLE app on
/// the device. Proves `main()` → DI (get_it) → splash → `isVaultInitialized()`
/// (secure storage) → router all wire up against the real stack.
///
/// **Non-destructive on purpose**: it does NOT wipe the vault, so it is safe to
/// run on any machine (including one holding a real vault). It therefore asserts
/// the app reaches the ACCESS flow — Setup (empty vault) OR Unlock (existing
/// vault) — either of which proves the cold boot succeeded.
///
/// Then it checks the language (PAN-10, Spanish is the source): with the system
/// in Spanish the access screen is in Spanish, in English it is in English, and
/// a language the app lacks falls back to English. If the user picked a fixed
/// language in Settings the system one is ignored by design, so only that one
/// is checked.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold boot reaches the access flow in the system language',
      (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('es', 'MX')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    app.main(const <String>[]); // not awaited: desktop main awaits window setup
    final which = await waitForAny(tester, [
      find.byType(SetupScreen),
      find.byType(UnlockScreen),
    ]);
    // 0 = Setup (no vault yet), 1 = Unlock (a vault exists). Both are a pass.
    expect(which, anyOf(0, 1));
    final isSetup = which == 0;
    final screen =
        isSetup ? find.byType(SetupScreen) : find.byType(UnlockScreen);

    final fixed = ProviderScope.containerOf(tester.element(screen),
            listen: false)
        .read(settingsNotifierProvider)
        .value
        ?.locale;
    if (fixed != null && fixed != 'system') {
      await _expectAccessIn(tester, screen, fixed, isSetup: isSetup);
      return;
    }

    await _expectAccessIn(tester, screen, 'es', isSetup: isSetup);

    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    await _expectAccessIn(tester, screen, 'en', isSetup: isSetup);

    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    await _expectAccessIn(tester, screen, 'en', isSetup: isSetup);
  });
}

/// Waits until the access screen shows its texts in [lang] (and none in the
/// other language), and the app's Localizations agree.
Future<void> _expectAccessIn(
  WidgetTester tester,
  Finder screen,
  String lang, {
  required bool isSetup,
}) async {
  List<String> texts(AppLocalizations l) => isSetup
      ? [l.setupTitle, l.setupSubtitle, l.setupCreateButton]
      : [l.unlockSubtitle, l.unlockForgotPassword];
  final want = texts(lookupAppLocalizations(Locale(lang)));
  final other =
      texts(lookupAppLocalizations(Locale(lang == 'es' ? 'en' : 'es')));

  await waitFor(
    tester,
    find.descendant(of: screen, matching: find.text(want.first)),
  );
  expect(Localizations.localeOf(tester.element(screen)).languageCode, lang);
  for (final t in want) {
    expect(find.descendant(of: screen, matching: find.text(t)), findsWidgets,
        reason: 'missing "$t" in $lang');
  }
  for (final t in other) {
    expect(find.descendant(of: screen, matching: find.text(t)), findsNothing,
        reason: '"$t" is still in the other language');
  }
}
