import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_security_settings.freezed.dart';
part 'app_security_settings.g.dart';

@freezed
class AppSecuritySettings with _$AppSecuritySettings {
  const factory AppSecuritySettings({
    @Default(5) int autoLockMinutes,
    @Default(30) int clearClipboardSeconds,
    @Default(false) bool biometricEnabled,
    @Default(true) bool obscureOnBackground,
    @Default('system') String themeMode,
  }) = _AppSecuritySettings;

  factory AppSecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$AppSecuritySettingsFromJson(json);

  factory AppSecuritySettings.defaults() => const AppSecuritySettings();
}
