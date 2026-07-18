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
      throw _privateConstructorUsedError; // Auditoria: verificar filtraciones online (HaveIBeenPwned, k-Anonymity).
  // Persistido para que el switch no se resetee al salir de la pantalla.
  bool get hibpCheckEnabled =>
      throw _privateConstructorUsedError; // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
  bool get autostartEnabled =>
      throw _privateConstructorUsedError; // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
  int get scheduledBackupIntervalDays => throw _privateConstructorUsedError;
  String? get backupDirectory =>
      throw _privateConstructorUsedError; // Densidad visual de la UI: 'comfortable' | 'compact'. Se aplica como
  // VisualDensity en el tema (ver UiDensity).
  String get uiDensity =>
      throw _privateConstructorUsedError; // Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
  // valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
  // clave se usa el atajo por defecto de AppShortcut.
  Map<String, String> get shortcutOverrides =>
      throw _privateConstructorUsedError; // Escritorio: barra lateral colapsada (solo iconos) al reabrir.
  bool get desktopSidebarCollapsed =>
      throw _privateConstructorUsedError; // Escritorio: ultima pestana de navegacion seleccionada (indice del sidebar).
  int get desktopLastTab =>
      throw _privateConstructorUsedError; // Escritorio: ultimo tamano/posicion de la ventana (window_manager). null =
  // sin valor persistido todavia -> se centra con el tamano por defecto.
  double? get windowWidth => throw _privateConstructorUsedError;
  double? get windowHeight => throw _privateConstructorUsedError;
  double? get windowX => throw _privateConstructorUsedError;
  double? get windowY => throw _privateConstructorUsedError;

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
    bool hibpCheckEnabled,
    bool autostartEnabled,
    int scheduledBackupIntervalDays,
    String? backupDirectory,
    String uiDensity,
    Map<String, String> shortcutOverrides,
    bool desktopSidebarCollapsed,
    int desktopLastTab,
    double? windowWidth,
    double? windowHeight,
    double? windowX,
    double? windowY,
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
    Object? hibpCheckEnabled = null,
    Object? autostartEnabled = null,
    Object? scheduledBackupIntervalDays = null,
    Object? backupDirectory = freezed,
    Object? uiDensity = null,
    Object? shortcutOverrides = null,
    Object? desktopSidebarCollapsed = null,
    Object? desktopLastTab = null,
    Object? windowWidth = freezed,
    Object? windowHeight = freezed,
    Object? windowX = freezed,
    Object? windowY = freezed,
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
            hibpCheckEnabled: null == hibpCheckEnabled
                ? _value.hibpCheckEnabled
                : hibpCheckEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
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
            uiDensity: null == uiDensity
                ? _value.uiDensity
                : uiDensity // ignore: cast_nullable_to_non_nullable
                      as String,
            shortcutOverrides: null == shortcutOverrides
                ? _value.shortcutOverrides
                : shortcutOverrides // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            desktopSidebarCollapsed: null == desktopSidebarCollapsed
                ? _value.desktopSidebarCollapsed
                : desktopSidebarCollapsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            desktopLastTab: null == desktopLastTab
                ? _value.desktopLastTab
                : desktopLastTab // ignore: cast_nullable_to_non_nullable
                      as int,
            windowWidth: freezed == windowWidth
                ? _value.windowWidth
                : windowWidth // ignore: cast_nullable_to_non_nullable
                      as double?,
            windowHeight: freezed == windowHeight
                ? _value.windowHeight
                : windowHeight // ignore: cast_nullable_to_non_nullable
                      as double?,
            windowX: freezed == windowX
                ? _value.windowX
                : windowX // ignore: cast_nullable_to_non_nullable
                      as double?,
            windowY: freezed == windowY
                ? _value.windowY
                : windowY // ignore: cast_nullable_to_non_nullable
                      as double?,
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
    bool hibpCheckEnabled,
    bool autostartEnabled,
    int scheduledBackupIntervalDays,
    String? backupDirectory,
    String uiDensity,
    Map<String, String> shortcutOverrides,
    bool desktopSidebarCollapsed,
    int desktopLastTab,
    double? windowWidth,
    double? windowHeight,
    double? windowX,
    double? windowY,
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
    Object? hibpCheckEnabled = null,
    Object? autostartEnabled = null,
    Object? scheduledBackupIntervalDays = null,
    Object? backupDirectory = freezed,
    Object? uiDensity = null,
    Object? shortcutOverrides = null,
    Object? desktopSidebarCollapsed = null,
    Object? desktopLastTab = null,
    Object? windowWidth = freezed,
    Object? windowHeight = freezed,
    Object? windowX = freezed,
    Object? windowY = freezed,
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
        hibpCheckEnabled: null == hibpCheckEnabled
            ? _value.hibpCheckEnabled
            : hibpCheckEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
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
        uiDensity: null == uiDensity
            ? _value.uiDensity
            : uiDensity // ignore: cast_nullable_to_non_nullable
                  as String,
        shortcutOverrides: null == shortcutOverrides
            ? _value._shortcutOverrides
            : shortcutOverrides // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        desktopSidebarCollapsed: null == desktopSidebarCollapsed
            ? _value.desktopSidebarCollapsed
            : desktopSidebarCollapsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        desktopLastTab: null == desktopLastTab
            ? _value.desktopLastTab
            : desktopLastTab // ignore: cast_nullable_to_non_nullable
                  as int,
        windowWidth: freezed == windowWidth
            ? _value.windowWidth
            : windowWidth // ignore: cast_nullable_to_non_nullable
                  as double?,
        windowHeight: freezed == windowHeight
            ? _value.windowHeight
            : windowHeight // ignore: cast_nullable_to_non_nullable
                  as double?,
        windowX: freezed == windowX
            ? _value.windowX
            : windowX // ignore: cast_nullable_to_non_nullable
                  as double?,
        windowY: freezed == windowY
            ? _value.windowY
            : windowY // ignore: cast_nullable_to_non_nullable
                  as double?,
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
    this.hibpCheckEnabled = false,
    this.autostartEnabled = false,
    this.scheduledBackupIntervalDays = 0,
    this.backupDirectory,
    this.uiDensity = 'comfortable',
    final Map<String, String> shortcutOverrides = const <String, String>{},
    this.desktopSidebarCollapsed = false,
    this.desktopLastTab = 0,
    this.windowWidth,
    this.windowHeight,
    this.windowX,
    this.windowY,
  }) : _shortcutOverrides = shortcutOverrides;

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
  // Auditoria: verificar filtraciones online (HaveIBeenPwned, k-Anonymity).
  // Persistido para que el switch no se resetee al salir de la pantalla.
  @override
  @JsonKey()
  final bool hibpCheckEnabled;
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
  // Densidad visual de la UI: 'comfortable' | 'compact'. Se aplica como
  // VisualDensity en el tema (ver UiDensity).
  @override
  @JsonKey()
  final String uiDensity;
  // Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
  // valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
  // clave se usa el atajo por defecto de AppShortcut.
  final Map<String, String> _shortcutOverrides;
  // Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
  // valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
  // clave se usa el atajo por defecto de AppShortcut.
  @override
  @JsonKey()
  Map<String, String> get shortcutOverrides {
    if (_shortcutOverrides is EqualUnmodifiableMapView)
      return _shortcutOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_shortcutOverrides);
  }

  // Escritorio: barra lateral colapsada (solo iconos) al reabrir.
  @override
  @JsonKey()
  final bool desktopSidebarCollapsed;
  // Escritorio: ultima pestana de navegacion seleccionada (indice del sidebar).
  @override
  @JsonKey()
  final int desktopLastTab;
  // Escritorio: ultimo tamano/posicion de la ventana (window_manager). null =
  // sin valor persistido todavia -> se centra con el tamano por defecto.
  @override
  final double? windowWidth;
  @override
  final double? windowHeight;
  @override
  final double? windowX;
  @override
  final double? windowY;

  @override
  String toString() {
    return 'AppSecuritySettings(autoLockMinutes: $autoLockMinutes, clearClipboardSeconds: $clearClipboardSeconds, biometricEnabled: $biometricEnabled, obscureOnBackground: $obscureOnBackground, themeMode: $themeMode, locale: $locale, wipeAfterFailedAttempts: $wipeAfterFailedAttempts, hibpCheckEnabled: $hibpCheckEnabled, autostartEnabled: $autostartEnabled, scheduledBackupIntervalDays: $scheduledBackupIntervalDays, backupDirectory: $backupDirectory, uiDensity: $uiDensity, shortcutOverrides: $shortcutOverrides, desktopSidebarCollapsed: $desktopSidebarCollapsed, desktopLastTab: $desktopLastTab, windowWidth: $windowWidth, windowHeight: $windowHeight, windowX: $windowX, windowY: $windowY)';
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
            (identical(other.hibpCheckEnabled, hibpCheckEnabled) ||
                other.hibpCheckEnabled == hibpCheckEnabled) &&
            (identical(other.autostartEnabled, autostartEnabled) ||
                other.autostartEnabled == autostartEnabled) &&
            (identical(
                  other.scheduledBackupIntervalDays,
                  scheduledBackupIntervalDays,
                ) ||
                other.scheduledBackupIntervalDays ==
                    scheduledBackupIntervalDays) &&
            (identical(other.backupDirectory, backupDirectory) ||
                other.backupDirectory == backupDirectory) &&
            (identical(other.uiDensity, uiDensity) ||
                other.uiDensity == uiDensity) &&
            const DeepCollectionEquality().equals(
              other._shortcutOverrides,
              _shortcutOverrides,
            ) &&
            (identical(
                  other.desktopSidebarCollapsed,
                  desktopSidebarCollapsed,
                ) ||
                other.desktopSidebarCollapsed == desktopSidebarCollapsed) &&
            (identical(other.desktopLastTab, desktopLastTab) ||
                other.desktopLastTab == desktopLastTab) &&
            (identical(other.windowWidth, windowWidth) ||
                other.windowWidth == windowWidth) &&
            (identical(other.windowHeight, windowHeight) ||
                other.windowHeight == windowHeight) &&
            (identical(other.windowX, windowX) || other.windowX == windowX) &&
            (identical(other.windowY, windowY) || other.windowY == windowY));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    autoLockMinutes,
    clearClipboardSeconds,
    biometricEnabled,
    obscureOnBackground,
    themeMode,
    locale,
    wipeAfterFailedAttempts,
    hibpCheckEnabled,
    autostartEnabled,
    scheduledBackupIntervalDays,
    backupDirectory,
    uiDensity,
    const DeepCollectionEquality().hash(_shortcutOverrides),
    desktopSidebarCollapsed,
    desktopLastTab,
    windowWidth,
    windowHeight,
    windowX,
    windowY,
  ]);

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
    final bool hibpCheckEnabled,
    final bool autostartEnabled,
    final int scheduledBackupIntervalDays,
    final String? backupDirectory,
    final String uiDensity,
    final Map<String, String> shortcutOverrides,
    final bool desktopSidebarCollapsed,
    final int desktopLastTab,
    final double? windowWidth,
    final double? windowHeight,
    final double? windowX,
    final double? windowY,
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
  int get wipeAfterFailedAttempts; // Auditoria: verificar filtraciones online (HaveIBeenPwned, k-Anonymity).
  // Persistido para que el switch no se resetee al salir de la pantalla.
  @override
  bool get hibpCheckEnabled; // Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
  @override
  bool get autostartEnabled; // Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
  @override
  int get scheduledBackupIntervalDays;
  @override
  String? get backupDirectory; // Densidad visual de la UI: 'comfortable' | 'compact'. Se aplica como
  // VisualDensity en el tema (ver UiDensity).
  @override
  String get uiDensity; // Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
  // valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
  // clave se usa el atajo por defecto de AppShortcut.
  @override
  Map<String, String> get shortcutOverrides; // Escritorio: barra lateral colapsada (solo iconos) al reabrir.
  @override
  bool get desktopSidebarCollapsed; // Escritorio: ultima pestana de navegacion seleccionada (indice del sidebar).
  @override
  int get desktopLastTab; // Escritorio: ultimo tamano/posicion de la ventana (window_manager). null =
  // sin valor persistido todavia -> se centra con el tamano por defecto.
  @override
  double? get windowWidth;
  @override
  double? get windowHeight;
  @override
  double? get windowX;
  @override
  double? get windowY;

  /// Create a copy of AppSecuritySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSecuritySettingsImplCopyWith<_$AppSecuritySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
