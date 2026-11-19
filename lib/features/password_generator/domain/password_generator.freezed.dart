// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_generator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordConfig {

 int get length; bool get useUppercase; bool get useLowercase; bool get useNumbers; bool get useSymbols; String get symbolSet;
/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordConfigCopyWith<PasswordConfig> get copyWith => _$PasswordConfigCopyWithImpl<PasswordConfig>(this as PasswordConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordConfig&&(identical(other.length, length) || other.length == length)&&(identical(other.useUppercase, useUppercase) || other.useUppercase == useUppercase)&&(identical(other.useLowercase, useLowercase) || other.useLowercase == useLowercase)&&(identical(other.useNumbers, useNumbers) || other.useNumbers == useNumbers)&&(identical(other.useSymbols, useSymbols) || other.useSymbols == useSymbols)&&(identical(other.symbolSet, symbolSet) || other.symbolSet == symbolSet));
}


@override
int get hashCode => Object.hash(runtimeType,length,useUppercase,useLowercase,useNumbers,useSymbols,symbolSet);

@override
String toString() {
  return 'PasswordConfig(length: $length, useUppercase: $useUppercase, useLowercase: $useLowercase, useNumbers: $useNumbers, useSymbols: $useSymbols, symbolSet: $symbolSet)';
}


}

/// @nodoc
abstract mixin class $PasswordConfigCopyWith<$Res>  {
  factory $PasswordConfigCopyWith(PasswordConfig value, $Res Function(PasswordConfig) _then) = _$PasswordConfigCopyWithImpl;
@useResult
$Res call({
 int length, bool useUppercase, bool useLowercase, bool useNumbers, bool useSymbols, String symbolSet
});




}
/// @nodoc
class _$PasswordConfigCopyWithImpl<$Res>
    implements $PasswordConfigCopyWith<$Res> {
  _$PasswordConfigCopyWithImpl(this._self, this._then);

  final PasswordConfig _self;
  final $Res Function(PasswordConfig) _then;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? length = null,Object? useUppercase = null,Object? useLowercase = null,Object? useNumbers = null,Object? useSymbols = null,Object? symbolSet = null,}) {
  return _then(_self.copyWith(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,useUppercase: null == useUppercase ? _self.useUppercase : useUppercase // ignore: cast_nullable_to_non_nullable
as bool,useLowercase: null == useLowercase ? _self.useLowercase : useLowercase // ignore: cast_nullable_to_non_nullable
as bool,useNumbers: null == useNumbers ? _self.useNumbers : useNumbers // ignore: cast_nullable_to_non_nullable
as bool,useSymbols: null == useSymbols ? _self.useSymbols : useSymbols // ignore: cast_nullable_to_non_nullable
as bool,symbolSet: null == symbolSet ? _self.symbolSet : symbolSet // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordConfig].
extension PasswordConfigPatterns on PasswordConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordConfig value)  $default,){
final _that = this;
switch (_that) {
case _PasswordConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int length,  bool useUppercase,  bool useLowercase,  bool useNumbers,  bool useSymbols,  String symbolSet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
return $default(_that.length,_that.useUppercase,_that.useLowercase,_that.useNumbers,_that.useSymbols,_that.symbolSet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int length,  bool useUppercase,  bool useLowercase,  bool useNumbers,  bool useSymbols,  String symbolSet)  $default,) {final _that = this;
switch (_that) {
case _PasswordConfig():
return $default(_that.length,_that.useUppercase,_that.useLowercase,_that.useNumbers,_that.useSymbols,_that.symbolSet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int length,  bool useUppercase,  bool useLowercase,  bool useNumbers,  bool useSymbols,  String symbolSet)?  $default,) {final _that = this;
switch (_that) {
case _PasswordConfig() when $default != null:
return $default(_that.length,_that.useUppercase,_that.useLowercase,_that.useNumbers,_that.useSymbols,_that.symbolSet);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordConfig implements PasswordConfig {
  const _PasswordConfig({this.length = 16, this.useUppercase = true, this.useLowercase = true, this.useNumbers = true, this.useSymbols = true, this.symbolSet = '!@#\$%^&*()-_=+[]{}|;:,.<>?'});
  

@override@JsonKey() final  int length;
@override@JsonKey() final  bool useUppercase;
@override@JsonKey() final  bool useLowercase;
@override@JsonKey() final  bool useNumbers;
@override@JsonKey() final  bool useSymbols;
@override@JsonKey() final  String symbolSet;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordConfigCopyWith<_PasswordConfig> get copyWith => __$PasswordConfigCopyWithImpl<_PasswordConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordConfig&&(identical(other.length, length) || other.length == length)&&(identical(other.useUppercase, useUppercase) || other.useUppercase == useUppercase)&&(identical(other.useLowercase, useLowercase) || other.useLowercase == useLowercase)&&(identical(other.useNumbers, useNumbers) || other.useNumbers == useNumbers)&&(identical(other.useSymbols, useSymbols) || other.useSymbols == useSymbols)&&(identical(other.symbolSet, symbolSet) || other.symbolSet == symbolSet));
}


@override
int get hashCode => Object.hash(runtimeType,length,useUppercase,useLowercase,useNumbers,useSymbols,symbolSet);

@override
String toString() {
  return 'PasswordConfig(length: $length, useUppercase: $useUppercase, useLowercase: $useLowercase, useNumbers: $useNumbers, useSymbols: $useSymbols, symbolSet: $symbolSet)';
}


}

/// @nodoc
abstract mixin class _$PasswordConfigCopyWith<$Res> implements $PasswordConfigCopyWith<$Res> {
  factory _$PasswordConfigCopyWith(_PasswordConfig value, $Res Function(_PasswordConfig) _then) = __$PasswordConfigCopyWithImpl;
@override @useResult
$Res call({
 int length, bool useUppercase, bool useLowercase, bool useNumbers, bool useSymbols, String symbolSet
});




}
/// @nodoc
class __$PasswordConfigCopyWithImpl<$Res>
    implements _$PasswordConfigCopyWith<$Res> {
  __$PasswordConfigCopyWithImpl(this._self, this._then);

  final _PasswordConfig _self;
  final $Res Function(_PasswordConfig) _then;

/// Create a copy of PasswordConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? length = null,Object? useUppercase = null,Object? useLowercase = null,Object? useNumbers = null,Object? useSymbols = null,Object? symbolSet = null,}) {
  return _then(_PasswordConfig(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,useUppercase: null == useUppercase ? _self.useUppercase : useUppercase // ignore: cast_nullable_to_non_nullable
as bool,useLowercase: null == useLowercase ? _self.useLowercase : useLowercase // ignore: cast_nullable_to_non_nullable
as bool,useNumbers: null == useNumbers ? _self.useNumbers : useNumbers // ignore: cast_nullable_to_non_nullable
as bool,useSymbols: null == useSymbols ? _self.useSymbols : useSymbols // ignore: cast_nullable_to_non_nullable
as bool,symbolSet: null == symbolSet ? _self.symbolSet : symbolSet // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
