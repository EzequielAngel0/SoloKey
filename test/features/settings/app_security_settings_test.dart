import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/settings/domain/entities/app_security_settings.dart';

void main() {
  group('AppSecuritySettings', () {
    test('defaults', () {
      const s = AppSecuritySettings();
      expect(s.uiDensity, 'comfortable');
      expect(s.themeMode, 'system');
      expect(s.locale, 'system');
      expect(s.autoLockMinutes, 5);
    });

    test('uiDensity persists through toJson/fromJson round-trip', () {
      const s = AppSecuritySettings(uiDensity: 'compact');
      final restored = AppSecuritySettings.fromJson(s.toJson());
      expect(restored.uiDensity, 'compact');
      expect(restored, s);
    });

    test('fromJson tolerates missing uiDensity (older persisted settings)', () {
      final restored = AppSecuritySettings.fromJson(const {
        'autoLockMinutes': 10,
        'themeMode': 'dark',
      });
      expect(restored.uiDensity, 'comfortable');
      expect(restored.autoLockMinutes, 10);
      expect(restored.themeMode, 'dark');
    });

    test('shortcutOverrides default to empty and persist through JSON', () {
      const s = AppSecuritySettings();
      expect(s.shortcutOverrides, isEmpty);

      final custom =
          s.copyWith(shortcutOverrides: const {'lock': 'ctrl+alt+q'});
      final restored = AppSecuritySettings.fromJson(custom.toJson());
      expect(restored.shortcutOverrides, {'lock': 'ctrl+alt+q'});
    });

    test('desktop layout prefs default to collapsed=false, tab=0, no bounds',
        () {
      const s = AppSecuritySettings();
      expect(s.desktopSidebarCollapsed, isFalse);
      expect(s.desktopLastTab, 0);
      expect(s.windowWidth, isNull);
      expect(s.windowHeight, isNull);
      expect(s.windowX, isNull);
      expect(s.windowY, isNull);
    });

    test('desktop layout prefs persist through a JSON round-trip', () {
      const s = AppSecuritySettings(
        desktopSidebarCollapsed: true,
        desktopLastTab: 3,
        windowWidth: 1200,
        windowHeight: 800,
        windowX: 40,
        windowY: 60,
      );
      final restored = AppSecuritySettings.fromJson(s.toJson());
      expect(restored.desktopSidebarCollapsed, isTrue);
      expect(restored.desktopLastTab, 3);
      expect(restored.windowWidth, 1200);
      expect(restored.windowHeight, 800);
      expect(restored.windowX, 40);
      expect(restored.windowY, 60);
      expect(restored, s);
    });

    test('fromJson tolerates missing desktop prefs (older settings)', () {
      final restored = AppSecuritySettings.fromJson(const {'themeMode': 'dark'});
      expect(restored.desktopSidebarCollapsed, isFalse);
      expect(restored.desktopLastTab, 0);
      expect(restored.windowWidth, isNull);
    });
  });
}
