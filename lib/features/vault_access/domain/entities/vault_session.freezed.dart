// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VaultSession {

 bool get isUnlocked; DateTime get unlockedAt; DateTime get expiresAt;
/// Create a copy of VaultSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaultSessionCopyWith<VaultSession> get copyWith => _$VaultSessionCopyWithImpl<VaultSession>(this as VaultSession, _$identity);

  /// Serializes this VaultSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultSession&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isUnlocked,unlockedAt,expiresAt);

@override
String toString() {
  return 'VaultSession(isUnlocked: $isUnlocked, unlockedAt: $unlockedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $VaultSessionCopyWith<$Res>  {
  factory $VaultSessionCopyWith(VaultSession value, $Res Function(VaultSession) _then) = _$VaultSessionCopyWithImpl;
@useResult
$Res call({
 bool isUnlocked, DateTime unlockedAt, DateTime expiresAt
});




}
/// @nodoc
class _$VaultSessionCopyWithImpl<$Res>
    implements $VaultSessionCopyWith<$Res> {
  _$VaultSessionCopyWithImpl(this._self, this._then);

  final VaultSession _self;
  final $Res Function(VaultSession) _then;

/// Create a copy of VaultSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isUnlocked = null,Object? unlockedAt = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VaultSession].
extension VaultSessionPatterns on VaultSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VaultSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VaultSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VaultSession value)  $default,){
final _that = this;
switch (_that) {
case _VaultSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VaultSession value)?  $default,){
final _that = this;
switch (_that) {
case _VaultSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isUnlocked,  DateTime unlockedAt,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VaultSession() when $default != null:
return $default(_that.isUnlocked,_that.unlockedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isUnlocked,  DateTime unlockedAt,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _VaultSession():
return $default(_that.isUnlocked,_that.unlockedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isUnlocked,  DateTime unlockedAt,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _VaultSession() when $default != null:
return $default(_that.isUnlocked,_that.unlockedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VaultSession extends VaultSession {
  const _VaultSession({required this.isUnlocked, required this.unlockedAt, required this.expiresAt}): super._();
  factory _VaultSession.fromJson(Map<String, dynamic> json) => _$VaultSessionFromJson(json);

@override final  bool isUnlocked;
@override final  DateTime unlockedAt;
@override final  DateTime expiresAt;

/// Create a copy of VaultSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaultSessionCopyWith<_VaultSession> get copyWith => __$VaultSessionCopyWithImpl<_VaultSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VaultSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VaultSession&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isUnlocked,unlockedAt,expiresAt);

@override
String toString() {
  return 'VaultSession(isUnlocked: $isUnlocked, unlockedAt: $unlockedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$VaultSessionCopyWith<$Res> implements $VaultSessionCopyWith<$Res> {
  factory _$VaultSessionCopyWith(_VaultSession value, $Res Function(_VaultSession) _then) = __$VaultSessionCopyWithImpl;
@override @useResult
$Res call({
 bool isUnlocked, DateTime unlockedAt, DateTime expiresAt
});




}
/// @nodoc
class __$VaultSessionCopyWithImpl<$Res>
    implements _$VaultSessionCopyWith<$Res> {
  __$VaultSessionCopyWithImpl(this._self, this._then);

  final _VaultSession _self;
  final $Res Function(_VaultSession) _then;

/// Create a copy of VaultSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isUnlocked = null,Object? unlockedAt = null,Object? expiresAt = null,}) {
  return _then(_VaultSession(
isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
