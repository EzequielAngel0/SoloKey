import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/settings/domain/entities/app_security_settings.dart';
import 'package:password_manager/features/settings/domain/repositories/i_settings_repository.dart';
import 'package:password_manager/features/settings/presentation/settings_screen.dart';

import '../../support/widget_harness.dart';

class _FakeSettingsRepo implements ISettingsRepository {
  _FakeSettingsRepo(this.settings);
  AppSecuritySettings settings;

  @override
  Future<AppSecuritySettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSecuritySettings s) async => settings = s;
}

void main() {
  testWidgets('SettingsView builds with default settings', (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      scaffolded(const SettingsView()), // SettingsView expects a Scaffold ancestor
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(_FakeSettingsRepo(AppSecuritySettings.defaults())),
      ],
      surfaceSize: const Size(820, 2000),
    );
    // Resolve the async settings load, then let the body build.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    // The settings body renders switches/sliders once loaded.
    expect(find.byType(Switch), findsWidgets);
  });
}
