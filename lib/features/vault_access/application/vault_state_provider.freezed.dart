// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VaultState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VaultState()';
}


}

/// @nodoc
class $VaultStateCopyWith<$Res>  {
$VaultStateCopyWith(VaultState _, $Res Function(VaultState) __);
}


/// Adds pattern-matching-related methods to [VaultState].
extension VaultStatePatterns on VaultState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Unlocked value)?  unlocked,TResult Function( _Locked value)?  locked,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Unlocked() when unlocked != null:
return unlocked(_that);case _Locked() when locked != null:
return locked(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Unlocked value)  unlocked,required TResult Function( _Locked value)  locked,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Unlocked():
return unlocked(_that);case _Locked():
return locked(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Unlocked value)?  unlocked,TResult? Function( _Locked value)?  locked,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Unlocked() when unlocked != null:
return unlocked(_that);case _Locked() when locked != null:
return locked(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( VaultSession session)?  unlocked,TResult Function()?  locked,TResult Function( VaultErrorKind kind,  Duration? lockout,  String? message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Unlocked() when unlocked != null:
return unlocked(_that.session);case _Locked() when locked != null:
return locked();case _Error() when error != null:
return error(_that.kind,_that.lockout,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( VaultSession session)  unlocked,required TResult Function()  locked,required TResult Function( VaultErrorKind kind,  Duration? lockout,  String? message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Unlocked():
return unlocked(_that.session);case _Locked():
return locked();case _Error():
return error(_that.kind,_that.lockout,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( VaultSession session)?  unlocked,TResult? Function()?  locked,TResult? Function( VaultErrorKind kind,  Duration? lockout,  String? message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Unlocked() when unlocked != null:
return unlocked(_that.session);case _Locked() when locked != null:
return locked();case _Error() when error != null:
return error(_that.kind,_that.lockout,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements VaultState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VaultState.initial()';
}


}




/// @nodoc


class _Loading implements VaultState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VaultState.loading()';
}


}




/// @nodoc


class _Unlocked implements VaultState {
  const _Unlocked(this.session);
  

 final  VaultSession session;

/// Create a copy of VaultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnlockedCopyWith<_Unlocked> get copyWith => __$UnlockedCopyWithImpl<_Unlocked>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unlocked&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'VaultState.unlocked(session: $session)';
}


}

/// @nodoc
abstract mixin class _$UnlockedCopyWith<$Res> implements $VaultStateCopyWith<$Res> {
  factory _$UnlockedCopyWith(_Unlocked value, $Res Function(_Unlocked) _then) = __$UnlockedCopyWithImpl;
@useResult
$Res call({
 VaultSession session
});


$VaultSessionCopyWith<$Res> get session;

}
/// @nodoc
class __$UnlockedCopyWithImpl<$Res>
    implements _$UnlockedCopyWith<$Res> {
  __$UnlockedCopyWithImpl(this._self, this._then);

  final _Unlocked _self;
  final $Res Function(_Unlocked) _then;

/// Create a copy of VaultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(_Unlocked(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as VaultSession,
  ));
}

/// Create a copy of VaultState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VaultSessionCopyWith<$Res> get session {
  
  return $VaultSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class _Locked implements VaultState {
  const _Locked();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Locked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VaultState.locked()';
}


}




/// @nodoc


class _Error implements VaultState {
  const _Error({this.kind = VaultErrorKind.generic, this.lockout, this.message});
  

@JsonKey() final  VaultErrorKind kind;
 final  Duration? lockout;
 final  String? message;

/// Create a copy of VaultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.lockout, lockout) || other.lockout == lockout)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,kind,lockout,message);

@override
String toString() {
  return 'VaultState.error(kind: $kind, lockout: $lockout, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $VaultStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 VaultErrorKind kind, Duration? lockout, String? message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of VaultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? lockout = freezed,Object? message = freezed,}) {
  return _then(_Error(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as VaultErrorKind,lockout: freezed == lockout ? _self.lockout : lockout // ignore: cast_nullable_to_non_nullable
as Duration?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
