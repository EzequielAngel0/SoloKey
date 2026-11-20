// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_security_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSecuritySettings {

 int get autoLockMinutes; int get clearClipboardSeconds; bool get biometricEnabled; bool get obscureOnBackground; String get themeMode;// Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
 String get locale;// Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
 int get wipeAfterFailedAttempts;// Auditoria: verificar filtraciones online (HaveIBeenPwned, k-Anonymity).
// Persistido para que el switch no se resetee al salir de la pantalla.
 bool get hibpCheckEnabled;// Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
 bool get autostartEnabled;// Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
 int get scheduledBackupIntervalDays; String? get backupDirectory;// Densidad visual de la UI: 'comfortable' | 'compact'. Se aplica como
// VisualDensity en el tema (ver UiDensity).
 String get uiDensity;// Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
// valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
// clave se usa el atajo por defecto de AppShortcut.
 Map<String, String> get shortcutOverrides;// Escritorio: barra lateral colapsada (solo iconos) al reabrir.
 bool get desktopSidebarCollapsed;// Escritorio: ultima pestana de navegacion seleccionada (indice del sidebar).
 int get desktopLastTab;// Escritorio: ultimo tamano/posicion de la ventana (window_manager). null =
// sin valor persistido todavia -> se centra con el tamano por defecto.
 double? get windowWidth; double? get windowHeight; double? get windowX; double? get windowY;
/// Create a copy of AppSecuritySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSecuritySettingsCopyWith<AppSecuritySettings> get copyWith => _$AppSecuritySettingsCopyWithImpl<AppSecuritySettings>(this as AppSecuritySettings, _$identity);

  /// Serializes this AppSecuritySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSecuritySettings&&(identical(other.autoLockMinutes, autoLockMinutes) || other.autoLockMinutes == autoLockMinutes)&&(identical(other.clearClipboardSeconds, clearClipboardSeconds) || other.clearClipboardSeconds == clearClipboardSeconds)&&(identical(other.biometricEnabled, biometricEnabled) || other.biometricEnabled == biometricEnabled)&&(identical(other.obscureOnBackground, obscureOnBackground) || other.obscureOnBackground == obscureOnBackground)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.wipeAfterFailedAttempts, wipeAfterFailedAttempts) || other.wipeAfterFailedAttempts == wipeAfterFailedAttempts)&&(identical(other.hibpCheckEnabled, hibpCheckEnabled) || other.hibpCheckEnabled == hibpCheckEnabled)&&(identical(other.autostartEnabled, autostartEnabled) || other.autostartEnabled == autostartEnabled)&&(identical(other.scheduledBackupIntervalDays, scheduledBackupIntervalDays) || other.scheduledBackupIntervalDays == scheduledBackupIntervalDays)&&(identical(other.backupDirectory, backupDirectory) || other.backupDirectory == backupDirectory)&&(identical(other.uiDensity, uiDensity) || other.uiDensity == uiDensity)&&const DeepCollectionEquality().equals(other.shortcutOverrides, shortcutOverrides)&&(identical(other.desktopSidebarCollapsed, desktopSidebarCollapsed) || other.desktopSidebarCollapsed == desktopSidebarCollapsed)&&(identical(other.desktopLastTab, desktopLastTab) || other.desktopLastTab == desktopLastTab)&&(identical(other.windowWidth, windowWidth) || other.windowWidth == windowWidth)&&(identical(other.windowHeight, windowHeight) || other.windowHeight == windowHeight)&&(identical(other.windowX, windowX) || other.windowX == windowX)&&(identical(other.windowY, windowY) || other.windowY == windowY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,autoLockMinutes,clearClipboardSeconds,biometricEnabled,obscureOnBackground,themeMode,locale,wipeAfterFailedAttempts,hibpCheckEnabled,autostartEnabled,scheduledBackupIntervalDays,backupDirectory,uiDensity,const DeepCollectionEquality().hash(shortcutOverrides),desktopSidebarCollapsed,desktopLastTab,windowWidth,windowHeight,windowX,windowY]);

@override
String toString() {
  return 'AppSecuritySettings(autoLockMinutes: $autoLockMinutes, clearClipboardSeconds: $clearClipboardSeconds, biometricEnabled: $biometricEnabled, obscureOnBackground: $obscureOnBackground, themeMode: $themeMode, locale: $locale, wipeAfterFailedAttempts: $wipeAfterFailedAttempts, hibpCheckEnabled: $hibpCheckEnabled, autostartEnabled: $autostartEnabled, scheduledBackupIntervalDays: $scheduledBackupIntervalDays, backupDirectory: $backupDirectory, uiDensity: $uiDensity, shortcutOverrides: $shortcutOverrides, desktopSidebarCollapsed: $desktopSidebarCollapsed, desktopLastTab: $desktopLastTab, windowWidth: $windowWidth, windowHeight: $windowHeight, windowX: $windowX, windowY: $windowY)';
}


}

/// @nodoc
abstract mixin class $AppSecuritySettingsCopyWith<$Res>  {
  factory $AppSecuritySettingsCopyWith(AppSecuritySettings value, $Res Function(AppSecuritySettings) _then) = _$AppSecuritySettingsCopyWithImpl;
@useResult
$Res call({
 int autoLockMinutes, int clearClipboardSeconds, bool biometricEnabled, bool obscureOnBackground, String themeMode, String locale, int wipeAfterFailedAttempts, bool hibpCheckEnabled, bool autostartEnabled, int scheduledBackupIntervalDays, String? backupDirectory, String uiDensity, Map<String, String> shortcutOverrides, bool desktopSidebarCollapsed, int desktopLastTab, double? windowWidth, double? windowHeight, double? windowX, double? windowY
});




}
/// @nodoc
class _$AppSecuritySettingsCopyWithImpl<$Res>
    implements $AppSecuritySettingsCopyWith<$Res> {
  _$AppSecuritySettingsCopyWithImpl(this._self, this._then);

  final AppSecuritySettings _self;
  final $Res Function(AppSecuritySettings) _then;

/// Create a copy of AppSecuritySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoLockMinutes = null,Object? clearClipboardSeconds = null,Object? biometricEnabled = null,Object? obscureOnBackground = null,Object? themeMode = null,Object? locale = null,Object? wipeAfterFailedAttempts = null,Object? hibpCheckEnabled = null,Object? autostartEnabled = null,Object? scheduledBackupIntervalDays = null,Object? backupDirectory = freezed,Object? uiDensity = null,Object? shortcutOverrides = null,Object? desktopSidebarCollapsed = null,Object? desktopLastTab = null,Object? windowWidth = freezed,Object? windowHeight = freezed,Object? windowX = freezed,Object? windowY = freezed,}) {
  return _then(_self.copyWith(
autoLockMinutes: null == autoLockMinutes ? _self.autoLockMinutes : autoLockMinutes // ignore: cast_nullable_to_non_nullable
as int,clearClipboardSeconds: null == clearClipboardSeconds ? _self.clearClipboardSeconds : clearClipboardSeconds // ignore: cast_nullable_to_non_nullable
as int,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,obscureOnBackground: null == obscureOnBackground ? _self.obscureOnBackground : obscureOnBackground // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,wipeAfterFailedAttempts: null == wipeAfterFailedAttempts ? _self.wipeAfterFailedAttempts : wipeAfterFailedAttempts // ignore: cast_nullable_to_non_nullable
as int,hibpCheckEnabled: null == hibpCheckEnabled ? _self.hibpCheckEnabled : hibpCheckEnabled // ignore: cast_nullable_to_non_nullable
as bool,autostartEnabled: null == autostartEnabled ? _self.autostartEnabled : autostartEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduledBackupIntervalDays: null == scheduledBackupIntervalDays ? _self.scheduledBackupIntervalDays : scheduledBackupIntervalDays // ignore: cast_nullable_to_non_nullable
as int,backupDirectory: freezed == backupDirectory ? _self.backupDirectory : backupDirectory // ignore: cast_nullable_to_non_nullable
as String?,uiDensity: null == uiDensity ? _self.uiDensity : uiDensity // ignore: cast_nullable_to_non_nullable
as String,shortcutOverrides: null == shortcutOverrides ? _self.shortcutOverrides : shortcutOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,desktopSidebarCollapsed: null == desktopSidebarCollapsed ? _self.desktopSidebarCollapsed : desktopSidebarCollapsed // ignore: cast_nullable_to_non_nullable
as bool,desktopLastTab: null == desktopLastTab ? _self.desktopLastTab : desktopLastTab // ignore: cast_nullable_to_non_nullable
as int,windowWidth: freezed == windowWidth ? _self.windowWidth : windowWidth // ignore: cast_nullable_to_non_nullable
as double?,windowHeight: freezed == windowHeight ? _self.windowHeight : windowHeight // ignore: cast_nullable_to_non_nullable
as double?,windowX: freezed == windowX ? _self.windowX : windowX // ignore: cast_nullable_to_non_nullable
as double?,windowY: freezed == windowY ? _self.windowY : windowY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSecuritySettings].
extension AppSecuritySettingsPatterns on AppSecuritySettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSecuritySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSecuritySettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSecuritySettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSecuritySettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSecuritySettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSecuritySettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int autoLockMinutes,  int clearClipboardSeconds,  bool biometricEnabled,  bool obscureOnBackground,  String themeMode,  String locale,  int wipeAfterFailedAttempts,  bool hibpCheckEnabled,  bool autostartEnabled,  int scheduledBackupIntervalDays,  String? backupDirectory,  String uiDensity,  Map<String, String> shortcutOverrides,  bool desktopSidebarCollapsed,  int desktopLastTab,  double? windowWidth,  double? windowHeight,  double? windowX,  double? windowY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSecuritySettings() when $default != null:
return $default(_that.autoLockMinutes,_that.clearClipboardSeconds,_that.biometricEnabled,_that.obscureOnBackground,_that.themeMode,_that.locale,_that.wipeAfterFailedAttempts,_that.hibpCheckEnabled,_that.autostartEnabled,_that.scheduledBackupIntervalDays,_that.backupDirectory,_that.uiDensity,_that.shortcutOverrides,_that.desktopSidebarCollapsed,_that.desktopLastTab,_that.windowWidth,_that.windowHeight,_that.windowX,_that.windowY);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int autoLockMinutes,  int clearClipboardSeconds,  bool biometricEnabled,  bool obscureOnBackground,  String themeMode,  String locale,  int wipeAfterFailedAttempts,  bool hibpCheckEnabled,  bool autostartEnabled,  int scheduledBackupIntervalDays,  String? backupDirectory,  String uiDensity,  Map<String, String> shortcutOverrides,  bool desktopSidebarCollapsed,  int desktopLastTab,  double? windowWidth,  double? windowHeight,  double? windowX,  double? windowY)  $default,) {final _that = this;
switch (_that) {
case _AppSecuritySettings():
return $default(_that.autoLockMinutes,_that.clearClipboardSeconds,_that.biometricEnabled,_that.obscureOnBackground,_that.themeMode,_that.locale,_that.wipeAfterFailedAttempts,_that.hibpCheckEnabled,_that.autostartEnabled,_that.scheduledBackupIntervalDays,_that.backupDirectory,_that.uiDensity,_that.shortcutOverrides,_that.desktopSidebarCollapsed,_that.desktopLastTab,_that.windowWidth,_that.windowHeight,_that.windowX,_that.windowY);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int autoLockMinutes,  int clearClipboardSeconds,  bool biometricEnabled,  bool obscureOnBackground,  String themeMode,  String locale,  int wipeAfterFailedAttempts,  bool hibpCheckEnabled,  bool autostartEnabled,  int scheduledBackupIntervalDays,  String? backupDirectory,  String uiDensity,  Map<String, String> shortcutOverrides,  bool desktopSidebarCollapsed,  int desktopLastTab,  double? windowWidth,  double? windowHeight,  double? windowX,  double? windowY)?  $default,) {final _that = this;
switch (_that) {
case _AppSecuritySettings() when $default != null:
return $default(_that.autoLockMinutes,_that.clearClipboardSeconds,_that.biometricEnabled,_that.obscureOnBackground,_that.themeMode,_that.locale,_that.wipeAfterFailedAttempts,_that.hibpCheckEnabled,_that.autostartEnabled,_that.scheduledBackupIntervalDays,_that.backupDirectory,_that.uiDensity,_that.shortcutOverrides,_that.desktopSidebarCollapsed,_that.desktopLastTab,_that.windowWidth,_that.windowHeight,_that.windowX,_that.windowY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSecuritySettings implements AppSecuritySettings {
  const _AppSecuritySettings({this.autoLockMinutes = 5, this.clearClipboardSeconds = 30, this.biometricEnabled = false, this.obscureOnBackground = true, this.themeMode = 'system', this.locale = 'system', this.wipeAfterFailedAttempts = 0, this.hibpCheckEnabled = false, this.autostartEnabled = false, this.scheduledBackupIntervalDays = 0, this.backupDirectory, this.uiDensity = 'comfortable', final  Map<String, String> shortcutOverrides = const <String, String>{}, this.desktopSidebarCollapsed = false, this.desktopLastTab = 0, this.windowWidth, this.windowHeight, this.windowX, this.windowY}): _shortcutOverrides = shortcutOverrides;
  factory _AppSecuritySettings.fromJson(Map<String, dynamic> json) => _$AppSecuritySettingsFromJson(json);

@override@JsonKey() final  int autoLockMinutes;
@override@JsonKey() final  int clearClipboardSeconds;
@override@JsonKey() final  bool biometricEnabled;
@override@JsonKey() final  bool obscureOnBackground;
@override@JsonKey() final  String themeMode;
// Idioma de la interfaz: 'system' | 'es' | 'en'. 'system' sigue el SO.
@override@JsonKey() final  String locale;
// Anti brute-force: borra la boveda tras N intentos fallidos. 0 = desactivado.
@override@JsonKey() final  int wipeAfterFailedAttempts;
// Auditoria: verificar filtraciones online (HaveIBeenPwned, k-Anonymity).
// Persistido para que el switch no se resetee al salir de la pantalla.
@override@JsonKey() final  bool hibpCheckEnabled;
// Escritorio: iniciar SoloKey con el sistema (minimizado en la bandeja).
@override@JsonKey() final  bool autostartEnabled;
// Backup automatico cifrado: intervalo en dias (0 = desactivado) + carpeta destino.
@override@JsonKey() final  int scheduledBackupIntervalDays;
@override final  String? backupDirectory;
// Densidad visual de la UI: 'comfortable' | 'compact'. Se aplica como
// VisualDensity en el tema (ver UiDensity).
@override@JsonKey() final  String uiDensity;
// Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
// valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
// clave se usa el atajo por defecto de AppShortcut.
 final  Map<String, String> _shortcutOverrides;
// Escritorio: reasignaciones de atajos de teclado. Clave = AppShortcut.id,
// valor = combinacion serializada (p.ej. 'ctrl+shift+k'). Si falta una
// clave se usa el atajo por defecto de AppShortcut.
@override@JsonKey() Map<String, String> get shortcutOverrides {
  if (_shortcutOverrides is EqualUnmodifiableMapView) return _shortcutOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_shortcutOverrides);
}

// Escritorio: barra lateral colapsada (solo iconos) al reabrir.
@override@JsonKey() final  bool desktopSidebarCollapsed;
// Escritorio: ultima pestana de navegacion seleccionada (indice del sidebar).
@override@JsonKey() final  int desktopLastTab;
// Escritorio: ultimo tamano/posicion de la ventana (window_manager). null =
// sin valor persistido todavia -> se centra con el tamano por defecto.
@override final  double? windowWidth;
@override final  double? windowHeight;
@override final  double? windowX;
@override final  double? windowY;

/// Create a copy of AppSecuritySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSecuritySettingsCopyWith<_AppSecuritySettings> get copyWith => __$AppSecuritySettingsCopyWithImpl<_AppSecuritySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSecuritySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSecuritySettings&&(identical(other.autoLockMinutes, autoLockMinutes) || other.autoLockMinutes == autoLockMinutes)&&(identical(other.clearClipboardSeconds, clearClipboardSeconds) || other.clearClipboardSeconds == clearClipboardSeconds)&&(identical(other.biometricEnabled, biometricEnabled) || other.biometricEnabled == biometricEnabled)&&(identical(other.obscureOnBackground, obscureOnBackground) || other.obscureOnBackground == obscureOnBackground)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.wipeAfterFailedAttempts, wipeAfterFailedAttempts) || other.wipeAfterFailedAttempts == wipeAfterFailedAttempts)&&(identical(other.hibpCheckEnabled, hibpCheckEnabled) || other.hibpCheckEnabled == hibpCheckEnabled)&&(identical(other.autostartEnabled, autostartEnabled) || other.autostartEnabled == autostartEnabled)&&(identical(other.scheduledBackupIntervalDays, scheduledBackupIntervalDays) || other.scheduledBackupIntervalDays == scheduledBackupIntervalDays)&&(identical(other.backupDirectory, backupDirectory) || other.backupDirectory == backupDirectory)&&(identical(other.uiDensity, uiDensity) || other.uiDensity == uiDensity)&&const DeepCollectionEquality().equals(other._shortcutOverrides, _shortcutOverrides)&&(identical(other.desktopSidebarCollapsed, desktopSidebarCollapsed) || other.desktopSidebarCollapsed == desktopSidebarCollapsed)&&(identical(other.desktopLastTab, desktopLastTab) || other.desktopLastTab == desktopLastTab)&&(identical(other.windowWidth, windowWidth) || other.windowWidth == windowWidth)&&(identical(other.windowHeight, windowHeight) || other.windowHeight == windowHeight)&&(identical(other.windowX, windowX) || other.windowX == windowX)&&(identical(other.windowY, windowY) || other.windowY == windowY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,autoLockMinutes,clearClipboardSeconds,biometricEnabled,obscureOnBackground,themeMode,locale,wipeAfterFailedAttempts,hibpCheckEnabled,autostartEnabled,scheduledBackupIntervalDays,backupDirectory,uiDensity,const DeepCollectionEquality().hash(_shortcutOverrides),desktopSidebarCollapsed,desktopLastTab,windowWidth,windowHeight,windowX,windowY]);

@override
String toString() {
  return 'AppSecuritySettings(autoLockMinutes: $autoLockMinutes, clearClipboardSeconds: $clearClipboardSeconds, biometricEnabled: $biometricEnabled, obscureOnBackground: $obscureOnBackground, themeMode: $themeMode, locale: $locale, wipeAfterFailedAttempts: $wipeAfterFailedAttempts, hibpCheckEnabled: $hibpCheckEnabled, autostartEnabled: $autostartEnabled, scheduledBackupIntervalDays: $scheduledBackupIntervalDays, backupDirectory: $backupDirectory, uiDensity: $uiDensity, shortcutOverrides: $shortcutOverrides, desktopSidebarCollapsed: $desktopSidebarCollapsed, desktopLastTab: $desktopLastTab, windowWidth: $windowWidth, windowHeight: $windowHeight, windowX: $windowX, windowY: $windowY)';
}


}

/// @nodoc
abstract mixin class _$AppSecuritySettingsCopyWith<$Res> implements $AppSecuritySettingsCopyWith<$Res> {
  factory _$AppSecuritySettingsCopyWith(_AppSecuritySettings value, $Res Function(_AppSecuritySettings) _then) = __$AppSecuritySettingsCopyWithImpl;
@override @useResult
$Res call({
 int autoLockMinutes, int clearClipboardSeconds, bool biometricEnabled, bool obscureOnBackground, String themeMode, String locale, int wipeAfterFailedAttempts, bool hibpCheckEnabled, bool autostartEnabled, int scheduledBackupIntervalDays, String? backupDirectory, String uiDensity, Map<String, String> shortcutOverrides, bool desktopSidebarCollapsed, int desktopLastTab, double? windowWidth, double? windowHeight, double? windowX, double? windowY
});




}
/// @nodoc
class __$AppSecuritySettingsCopyWithImpl<$Res>
    implements _$AppSecuritySettingsCopyWith<$Res> {
  __$AppSecuritySettingsCopyWithImpl(this._self, this._then);

  final _AppSecuritySettings _self;
  final $Res Function(_AppSecuritySettings) _then;

/// Create a copy of AppSecuritySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoLockMinutes = null,Object? clearClipboardSeconds = null,Object? biometricEnabled = null,Object? obscureOnBackground = null,Object? themeMode = null,Object? locale = null,Object? wipeAfterFailedAttempts = null,Object? hibpCheckEnabled = null,Object? autostartEnabled = null,Object? scheduledBackupIntervalDays = null,Object? backupDirectory = freezed,Object? uiDensity = null,Object? shortcutOverrides = null,Object? desktopSidebarCollapsed = null,Object? desktopLastTab = null,Object? windowWidth = freezed,Object? windowHeight = freezed,Object? windowX = freezed,Object? windowY = freezed,}) {
  return _then(_AppSecuritySettings(
autoLockMinutes: null == autoLockMinutes ? _self.autoLockMinutes : autoLockMinutes // ignore: cast_nullable_to_non_nullable
as int,clearClipboardSeconds: null == clearClipboardSeconds ? _self.clearClipboardSeconds : clearClipboardSeconds // ignore: cast_nullable_to_non_nullable
as int,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,obscureOnBackground: null == obscureOnBackground ? _self.obscureOnBackground : obscureOnBackground // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,wipeAfterFailedAttempts: null == wipeAfterFailedAttempts ? _self.wipeAfterFailedAttempts : wipeAfterFailedAttempts // ignore: cast_nullable_to_non_nullable
as int,hibpCheckEnabled: null == hibpCheckEnabled ? _self.hibpCheckEnabled : hibpCheckEnabled // ignore: cast_nullable_to_non_nullable
as bool,autostartEnabled: null == autostartEnabled ? _self.autostartEnabled : autostartEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduledBackupIntervalDays: null == scheduledBackupIntervalDays ? _self.scheduledBackupIntervalDays : scheduledBackupIntervalDays // ignore: cast_nullable_to_non_nullable
as int,backupDirectory: freezed == backupDirectory ? _self.backupDirectory : backupDirectory // ignore: cast_nullable_to_non_nullable
as String?,uiDensity: null == uiDensity ? _self.uiDensity : uiDensity // ignore: cast_nullable_to_non_nullable
as String,shortcutOverrides: null == shortcutOverrides ? _self._shortcutOverrides : shortcutOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,desktopSidebarCollapsed: null == desktopSidebarCollapsed ? _self.desktopSidebarCollapsed : desktopSidebarCollapsed // ignore: cast_nullable_to_non_nullable
as bool,desktopLastTab: null == desktopLastTab ? _self.desktopLastTab : desktopLastTab // ignore: cast_nullable_to_non_nullable
as int,windowWidth: freezed == windowWidth ? _self.windowWidth : windowWidth // ignore: cast_nullable_to_non_nullable
as double?,windowHeight: freezed == windowHeight ? _self.windowHeight : windowHeight // ignore: cast_nullable_to_non_nullable
as double?,windowX: freezed == windowX ? _self.windowX : windowX // ignore: cast_nullable_to_non_nullable
as double?,windowY: freezed == windowY ? _self.windowY : windowY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
