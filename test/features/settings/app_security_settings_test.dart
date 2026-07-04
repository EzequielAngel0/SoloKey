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
  });
}
