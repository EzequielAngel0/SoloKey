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
  wipeAfterFailedAttempts:
      (json['wipeAfterFailedAttempts'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$AppSecuritySettingsImplToJson(
  _$AppSecuritySettingsImpl instance,
) => <String, dynamic>{
  'autoLockMinutes': instance.autoLockMinutes,
  'clearClipboardSeconds': instance.clearClipboardSeconds,
  'biometricEnabled': instance.biometricEnabled,
  'obscureOnBackground': instance.obscureOnBackground,
  'themeMode': instance.themeMode,
  'wipeAfterFailedAttempts': instance.wipeAfterFailedAttempts,
};
