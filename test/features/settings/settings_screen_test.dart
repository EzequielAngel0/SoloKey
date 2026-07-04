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

  testWidgets('tapping the Compact density pill persists uiDensity',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    final repo = _FakeSettingsRepo(AppSecuritySettings.defaults());
    await pumpApp(
      tester,
      scaffolded(const SettingsView()),
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      surfaceSize: const Size(820, 2400),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The compact pill is uniquely identified by its density_small icon
    // (locale-independent). Default is 'comfortable'.
    expect(repo.settings.uiDensity, 'comfortable');
    await tester.tap(find.byIcon(Icons.density_small_rounded));
    await tester.pump();

    expect(repo.settings.uiDensity, 'compact');
  });

  testWidgets('dragging the auto-lock slider persists a lower value',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    final repo = _FakeSettingsRepo(AppSecuritySettings.defaults());
    await pumpApp(
      tester,
      scaffolded(const SettingsView()),
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      surfaceSize: const Size(820, 2400),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repo.settings.autoLockMinutes, 5); // AppSecuritySettings default.

    // The auto-lock slider is the first Slider (Security section). Dragging it
    // toward the minimum must flow through onUpdate → save → the fake repo.
    final slider = find.byType(Slider).first;
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(-400, 0));
    await tester.pump();

    expect(repo.settings.autoLockMinutes, lessThan(5));
    expect(repo.settings.autoLockMinutes, greaterThanOrEqualTo(1));
  });

  testWidgets('desktop shortcuts section shows the default key combinations',
      (tester) async {
    tolerateInkHiddenPaintWarnings();
    await pumpApp(
      tester,
      scaffolded(const SettingsView()),
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(_FakeSettingsRepo(AppSecuritySettings.defaults())),
      ],
      surfaceSize: const Size(820, 2600),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // `flutter test` runs on a desktop host, so the desktop-only shortcuts
    // section is present with its default Ctrl+K/N/L combinations.
    expect(find.text('Ctrl + K'), findsOneWidget);
    expect(find.text('Ctrl + N'), findsOneWidget);
    expect(find.text('Ctrl + L'), findsOneWidget);
  });
}
