// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_security_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSecuritySettings _$AppSecuritySettingsFromJson(Map<String, dynamic> json) {
  return _AppSecuritySettings.fromJson(json);
}

/// @nodoc
mixin _$AppSecuritySettings {
  int get autoLockMinutes => throw _privateConstructorUsedError;
  int get clearClipboardSeconds => throw _privateConstructorUsedError;
  bool get biometricEnabled => throw _privateConstructorUsedError;
  bool get obscureOnBackground => throw _privateConstructorUsedError;
  String get themeMode =>
      throw _privateConstructorUsedError; // Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
  String get locale =>
      throw _privateConstructorUsedError; // Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
  int get wipeAfterFailedAttempts =>
      throw _privateConstructorUsedError; // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
  bool get autostartEnabled =>
      throw _privateConstructorUsedError; // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
  int get scheduledBackupIntervalDays => throw _privateConstructorUsedError;
  String? get backupDirectory => throw _privateConstructorUsedError;

  /// Serializes this AppSecuritySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSecuritySettingsCopyWith<AppSecuritySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSecuritySettingsCopyWith<$Res> {
  factory $AppSecuritySettingsCopyWith(
    AppSecuritySettings value,
    $Res Function(AppSecuritySettings) then,
  ) = _$AppSecuritySettingsCopyWithImpl<$Res, AppSecuritySettings>;
  @useResult
  $Res call({
    int autoLockMinutes,
    int clearClipboardSeconds,
    bool biometricEnabled,
    bool obscureOnBackground,
    String themeMode,
    String locale,
    int wipeAfterFailedAttempts,
    bool autostartEnabled,
    int scheduledBackupIntervalDays,
    String? backupDirectory,
  });
}

/// @nodoc
class _$AppSecuritySettingsCopyWithImpl<$Res, $Val extends AppSecuritySettings>
    implements $AppSecuritySettingsCopyWith<$Res> {
  _$AppSecuritySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoLockMinutes = null,
    Object? clearClipboardSeconds = null,
    Object? biometricEnabled = null,
    Object? obscureOnBackground = null,
    Object? themeMode = null,
    Object? locale = null,
    Object? wipeAfterFailedAttempts = null,
    Object? autostartEnabled = null,
    Object? scheduledBackupIntervalDays = null,
    Object? backupDirectory = freezed,
  }) {
    return _then(
      _value.copyWith(
            autoLockMinutes: null == autoLockMinutes
                ? _value.autoLockMinutes
                : autoLockMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            clearClipboardSeconds: null == clearClipboardSeconds
                ? _value.clearClipboardSeconds
                : clearClipboardSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            biometricEnabled: null == biometricEnabled
                ? _value.biometricEnabled
                : biometricEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            obscureOnBackground: null == obscureOnBackground
                ? _value.obscureOnBackground
                : obscureOnBackground // ignore: cast_nullable_to_non_nullable
                      as bool,
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as String,
            locale: null == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String,
            wipeAfterFailedAttempts: null == wipeAfterFailedAttempts
                ? _value.wipeAfterFailedAttempts
                : wipeAfterFailedAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            autostartEnabled: null == autostartEnabled
                ? _value.autostartEnabled
                : autostartEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            scheduledBackupIntervalDays: null == scheduledBackupIntervalDays
                ? _value.scheduledBackupIntervalDays
                : scheduledBackupIntervalDays // ignore: cast_nullable_to_non_nullable
                      as int,
            backupDirectory: freezed == backupDirectory
                ? _value.backupDirectory
                : backupDirectory // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSecuritySettingsImplCopyWith<$Res>
    implements $AppSecuritySettingsCopyWith<$Res> {
  factory _$$AppSecuritySettingsImplCopyWith(
    _$AppSecuritySettingsImpl value,
    $Res Function(_$AppSecuritySettingsImpl) then,
  ) = __$$AppSecuritySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int autoLockMinutes,
    int clearClipboardSeconds,
    bool biometricEnabled,
    bool obscureOnBackground,
    String themeMode,
    String locale,
    int wipeAfterFailedAttempts,
    bool autostartEnabled,
    int scheduledBackupIntervalDays,
    String? backupDirectory,
  });
}

/// @nodoc
class __$$AppSecuritySettingsImplCopyWithImpl<$Res>
    extends _$AppSecuritySettingsCopyWithImpl<$Res, _$AppSecuritySettingsImpl>
    implements _$$AppSecuritySettingsImplCopyWith<$Res> {
  __$$AppSecuritySettingsImplCopyWithImpl(
    _$AppSecuritySettingsImpl _value,
    $Res Function(_$AppSecuritySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoLockMinutes = null,
    Object? clearClipboardSeconds = null,
    Object? biometricEnabled = null,
    Object? obscureOnBackground = null,
    Object? themeMode = null,
    Object? locale = null,
    Object? wipeAfterFailedAttempts = null,
    Object? autostartEnabled = null,
    Object? scheduledBackupIntervalDays = null,
    Object? backupDirectory = freezed,
  }) {
    return _then(
      _$AppSecuritySettingsImpl(
        autoLockMinutes: null == autoLockMinutes
            ? _value.autoLockMinutes
            : autoLockMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        clearClipboardSeconds: null == clearClipboardSeconds
            ? _value.clearClipboardSeconds
            : clearClipboardSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        biometricEnabled: null == biometricEnabled
            ? _value.biometricEnabled
            : biometricEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        obscureOnBackground: null == obscureOnBackground
            ? _value.obscureOnBackground
            : obscureOnBackground // ignore: cast_nullable_to_non_nullable
                  as bool,
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as String,
        locale: null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String,
        wipeAfterFailedAttempts: null == wipeAfterFailedAttempts
            ? _value.wipeAfterFailedAttempts
            : wipeAfterFailedAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        autostartEnabled: null == autostartEnabled
            ? _value.autostartEnabled
            : autostartEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        scheduledBackupIntervalDays: null == scheduledBackupIntervalDays
            ? _value.scheduledBackupIntervalDays
            : scheduledBackupIntervalDays // ignore: cast_nullable_to_non_nullable
                  as int,
        backupDirectory: freezed == backupDirectory
            ? _value.backupDirectory
            : backupDirectory // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSecuritySettingsImpl implements _AppSecuritySettings {
  const _$AppSecuritySettingsImpl({
    this.autoLockMinutes = 5,
    this.clearClipboardSeconds = 30,
    this.biometricEnabled = false,
    this.obscureOnBackground = true,
    this.themeMode = 'system',
    this.locale = 'system',
    this.wipeAfterFailedAttempts = 0,
    this.autostartEnabled = false,
    this.scheduledBackupIntervalDays = 0,
    this.backupDirectory,
  });

  factory _$AppSecuritySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSecuritySettingsImplFromJson(json);

  @override
  @JsonKey()
  final int autoLockMinutes;
  @override
  @JsonKey()
  final int clearClipboardSeconds;
  @override
  @JsonKey()
  final bool biometricEnabled;
  @override
  @JsonKey()
  final bool obscureOnBackground;
  @override
  @JsonKey()
  final String themeMode;
  // Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
  @override
  @JsonKey()
  final String locale;
  // Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
  @override
  @JsonKey()
  final int wipeAfterFailedAttempts;
  // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
  @override
  @JsonKey()
  final bool autostartEnabled;
  // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
  @override
  @JsonKey()
  final int scheduledBackupIntervalDays;
  @override
  final String? backupDirectory;

  @override
  String toString() {
    return 'AppSecuritySettings(autoLockMinutes: $autoLockMinutes, clearClipboardSeconds: $clearClipboardSeconds, biometricEnabled: $biometricEnabled, obscureOnBackground: $obscureOnBackground, themeMode: $themeMode, locale: $locale, wipeAfterFailedAttempts: $wipeAfterFailedAttempts, autostartEnabled: $autostartEnabled, scheduledBackupIntervalDays: $scheduledBackupIntervalDays, backupDirectory: $backupDirectory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSecuritySettingsImpl &&
            (identical(other.autoLockMinutes, autoLockMinutes) ||
                other.autoLockMinutes == autoLockMinutes) &&
            (identical(other.clearClipboardSeconds, clearClipboardSeconds) ||
                other.clearClipboardSeconds == clearClipboardSeconds) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.obscureOnBackground, obscureOnBackground) ||
                other.obscureOnBackground == obscureOnBackground) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(
                  other.wipeAfterFailedAttempts,
                  wipeAfterFailedAttempts,
                ) ||
                other.wipeAfterFailedAttempts == wipeAfterFailedAttempts) &&
            (identical(other.autostartEnabled, autostartEnabled) ||
                other.autostartEnabled == autostartEnabled) &&
            (identical(
                  other.scheduledBackupIntervalDays,
                  scheduledBackupIntervalDays,
                ) ||
                other.scheduledBackupIntervalDays ==
                    scheduledBackupIntervalDays) &&
            (identical(other.backupDirectory, backupDirectory) ||
                other.backupDirectory == backupDirectory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    autoLockMinutes,
    clearClipboardSeconds,
    biometricEnabled,
    obscureOnBackground,
    themeMode,
    locale,
    wipeAfterFailedAttempts,
    autostartEnabled,
    scheduledBackupIntervalDays,
    backupDirectory,
  );

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSecuritySettingsImplCopyWith<_$AppSecuritySettingsImpl> get copyWith =>
      __$$AppSecuritySettingsImplCopyWithImpl<_$AppSecuritySettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSecuritySettingsImplToJson(this);
  }
}

abstract class _AppSecuritySettings implements AppSecuritySettings {
  const factory _AppSecuritySettings({
    final int autoLockMinutes,
    final int clearClipboardSeconds,
    final bool biometricEnabled,
    final bool obscureOnBackground,
    final String themeMode,
    final String locale,
    final int wipeAfterFailedAttempts,
    final bool autostartEnabled,
    final int scheduledBackupIntervalDays,
    final String? backupDirectory,
  }) = _$AppSecuritySettingsImpl;

  factory _AppSecuritySettings.fromJson(Map<String, dynamic> json) =
      _$AppSecuritySettingsImpl.fromJson;

  @override
  int get autoLockMinutes;
  @override
  int get clearClipboardSeconds;
  @override
  bool get biometricEnabled;
  @override
  bool get obscureOnBackground;
  @override
  String get themeMode; // Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
  @override
  String get locale; // Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
  @override
  int get wipeAfterFailedAttempts; // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
  @override
  bool get autostartEnabled; // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
  @override
  int get scheduledBackupIntervalDays;
  @override
  String? get backupDirectory;

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSecuritySettingsImplCopyWith<_$AppSecuritySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
