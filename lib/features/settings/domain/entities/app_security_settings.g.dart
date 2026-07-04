// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_security_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSecuritySettingsImpl _$$AppSecuritySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$AppSecuritySettingsImpl(
  autoLockMinutes: (json['autoLockMinutes'] as num?)?.toInt() ?? 5,
  clearClipboardSeconds: (json['clearClipboardSeconds'] as num?)?.toInt() ?? 30,
  biometricEnabled: json['biometricEnabled'] as bool? ?? false,
  obscureOnBackground: json['obscureOnBackground'] as bool? ?? true,
  themeMode: json['themeMode'] as String? ?? 'system',
  locale: json['locale'] as String? ?? 'system',
  wipeAfterFailedAttempts:
      (json['wipeAfterFailedAttempts'] as num?)?.toInt() ?? 0,
  autostartEnabled: json['autostartEnabled'] as bool? ?? false,
  scheduledBackupIntervalDays:
      (json['scheduledBackupIntervalDays'] as num?)?.toInt() ?? 0,
  backupDirectory: json['backupDirectory'] as String?,
  uiDensity: json['uiDensity'] as String? ?? 'comfortable',
);

Map<String, dynamic> _$$AppSecuritySettingsImplToJson(
  _$AppSecuritySettingsImpl instance,
) => <String, dynamic>{
  'autoLockMinutes': instance.autoLockMinutes,
  'clearClipboardSeconds': instance.clearClipboardSeconds,
  'biometricEnabled': instance.biometricEnabled,
  'obscureOnBackground': instance.obscureOnBackground,
  'themeMode': instance.themeMode,
  'locale': instance.locale,
  'wipeAfterFailedAttempts': instance.wipeAfterFailedAttempts,
  'autostartEnabled': instance.autostartEnabled,
  'scheduledBackupIntervalDays': instance.scheduledBackupIntervalDays,
  'backupDirectory': instance.backupDirectory,
  'uiDensity': instance.uiDensity,
};
