import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/l10n/app_localizations.dart';

/// The desktop tray context menu is built from these localized strings (see
/// `App._setTrayMenu`), resolved via `lookupAppLocalizations` because that
/// widget sits above `MaterialApp` and has no `Localizations` in context.
void main() {
  test('tray menu labels resolve in English', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.trayShowVault, 'Show vault');
    expect(en.trayExit, 'Exit');
    // Reused labels for the quick actions.
    expect(en.desktopNewCredentialTooltip, isNotEmpty);
    expect(en.navSync, isNotEmpty);
    expect(en.homeLockTooltip, isNotEmpty);
  });

  test('tray menu labels resolve in Spanish', () {
    final es = lookupAppLocalizations(const Locale('es'));
    expect(es.trayShowVault, 'Mostrar bóveda');
    expect(es.trayExit, 'Salir');
  });
}
