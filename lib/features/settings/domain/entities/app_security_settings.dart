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
    // Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
    @Default('system') String locale,
    // Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
    @Default(0) int wipeAfterFailedAttempts,
    // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
    @Default(false) bool autostartEnabled,
    // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
    @Default(0) int scheduledBackupIntervalDays,
    String? backupDirectory,
  }) = _AppSecuritySettings;

  factory AppSecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$AppSecuritySettingsFromJson(json);

  factory AppSecuritySettings.defaults() => const AppSecuritySettings();
}
