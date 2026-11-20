// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_key_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KdfParams {

 int get memory;// KB — Argon2id memory cost
 int get iterations;// time cost
 int get parallelism;// degree of parallelism
 int get keyLength;
/// Create a copy of KdfParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KdfParamsCopyWith<KdfParams> get copyWith => _$KdfParamsCopyWithImpl<KdfParams>(this as KdfParams, _$identity);

  /// Serializes this KdfParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KdfParams&&(identical(other.memory, memory) || other.memory == memory)&&(identical(other.iterations, iterations) || other.iterations == iterations)&&(identical(other.parallelism, parallelism) || other.parallelism == parallelism)&&(identical(other.keyLength, keyLength) || other.keyLength == keyLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memory,iterations,parallelism,keyLength);

@override
String toString() {
  return 'KdfParams(memory: $memory, iterations: $iterations, parallelism: $parallelism, keyLength: $keyLength)';
}


}

/// @nodoc
abstract mixin class $KdfParamsCopyWith<$Res>  {
  factory $KdfParamsCopyWith(KdfParams value, $Res Function(KdfParams) _then) = _$KdfParamsCopyWithImpl;
@useResult
$Res call({
 int memory, int iterations, int parallelism, int keyLength
});




}
/// @nodoc
class _$KdfParamsCopyWithImpl<$Res>
    implements $KdfParamsCopyWith<$Res> {
  _$KdfParamsCopyWithImpl(this._self, this._then);

  final KdfParams _self;
  final $Res Function(KdfParams) _then;

/// Create a copy of KdfParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memory = null,Object? iterations = null,Object? parallelism = null,Object? keyLength = null,}) {
  return _then(_self.copyWith(
memory: null == memory ? _self.memory : memory // ignore: cast_nullable_to_non_nullable
as int,iterations: null == iterations ? _self.iterations : iterations // ignore: cast_nullable_to_non_nullable
as int,parallelism: null == parallelism ? _self.parallelism : parallelism // ignore: cast_nullable_to_non_nullable
as int,keyLength: null == keyLength ? _self.keyLength : keyLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KdfParams].
extension KdfParamsPatterns on KdfParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KdfParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KdfParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KdfParams value)  $default,){
final _that = this;
switch (_that) {
case _KdfParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KdfParams value)?  $default,){
final _that = this;
switch (_that) {
case _KdfParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int memory,  int iterations,  int parallelism,  int keyLength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KdfParams() when $default != null:
return $default(_that.memory,_that.iterations,_that.parallelism,_that.keyLength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int memory,  int iterations,  int parallelism,  int keyLength)  $default,) {final _that = this;
switch (_that) {
case _KdfParams():
return $default(_that.memory,_that.iterations,_that.parallelism,_that.keyLength);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int memory,  int iterations,  int parallelism,  int keyLength)?  $default,) {final _that = this;
switch (_that) {
case _KdfParams() when $default != null:
return $default(_that.memory,_that.iterations,_that.parallelism,_that.keyLength);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KdfParams implements KdfParams {
  const _KdfParams({required this.memory, required this.iterations, required this.parallelism, required this.keyLength});
  factory _KdfParams.fromJson(Map<String, dynamic> json) => _$KdfParamsFromJson(json);

@override final  int memory;
// KB — Argon2id memory cost
@override final  int iterations;
// time cost
@override final  int parallelism;
// degree of parallelism
@override final  int keyLength;

/// Create a copy of KdfParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KdfParamsCopyWith<_KdfParams> get copyWith => __$KdfParamsCopyWithImpl<_KdfParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KdfParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KdfParams&&(identical(other.memory, memory) || other.memory == memory)&&(identical(other.iterations, iterations) || other.iterations == iterations)&&(identical(other.parallelism, parallelism) || other.parallelism == parallelism)&&(identical(other.keyLength, keyLength) || other.keyLength == keyLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memory,iterations,parallelism,keyLength);

@override
String toString() {
  return 'KdfParams(memory: $memory, iterations: $iterations, parallelism: $parallelism, keyLength: $keyLength)';
}


}

/// @nodoc
abstract mixin class _$KdfParamsCopyWith<$Res> implements $KdfParamsCopyWith<$Res> {
  factory _$KdfParamsCopyWith(_KdfParams value, $Res Function(_KdfParams) _then) = __$KdfParamsCopyWithImpl;
@override @useResult
$Res call({
 int memory, int iterations, int parallelism, int keyLength
});




}
/// @nodoc
class __$KdfParamsCopyWithImpl<$Res>
    implements _$KdfParamsCopyWith<$Res> {
  __$KdfParamsCopyWithImpl(this._self, this._then);

  final _KdfParams _self;
  final $Res Function(_KdfParams) _then;

/// Create a copy of KdfParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memory = null,Object? iterations = null,Object? parallelism = null,Object? keyLength = null,}) {
  return _then(_KdfParams(
memory: null == memory ? _self.memory : memory // ignore: cast_nullable_to_non_nullable
as int,iterations: null == iterations ? _self.iterations : iterations // ignore: cast_nullable_to_non_nullable
as int,parallelism: null == parallelism ? _self.parallelism : parallelism // ignore: cast_nullable_to_non_nullable
as int,keyLength: null == keyLength ? _self.keyLength : keyLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MasterKeyConfig {

/// Random salt generated once at vault creation (base64-encoded).
 String get salt; KdfAlgorithm get kdfAlgorithm; KdfParams get kdfParams;/// Encrypted verification token used to confirm the master password
/// without storing the key. Format: base64(iv + ciphertext + tag).
 String get verificationData;
/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasterKeyConfigCopyWith<MasterKeyConfig> get copyWith => _$MasterKeyConfigCopyWithImpl<MasterKeyConfig>(this as MasterKeyConfig, _$identity);

  /// Serializes this MasterKeyConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MasterKeyConfig&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.kdfAlgorithm, kdfAlgorithm) || other.kdfAlgorithm == kdfAlgorithm)&&(identical(other.kdfParams, kdfParams) || other.kdfParams == kdfParams)&&(identical(other.verificationData, verificationData) || other.verificationData == verificationData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salt,kdfAlgorithm,kdfParams,verificationData);

@override
String toString() {
  return 'MasterKeyConfig(salt: $salt, kdfAlgorithm: $kdfAlgorithm, kdfParams: $kdfParams, verificationData: $verificationData)';
}


}

/// @nodoc
abstract mixin class $MasterKeyConfigCopyWith<$Res>  {
  factory $MasterKeyConfigCopyWith(MasterKeyConfig value, $Res Function(MasterKeyConfig) _then) = _$MasterKeyConfigCopyWithImpl;
@useResult
$Res call({
 String salt, KdfAlgorithm kdfAlgorithm, KdfParams kdfParams, String verificationData
});


$KdfParamsCopyWith<$Res> get kdfParams;

}
/// @nodoc
class _$MasterKeyConfigCopyWithImpl<$Res>
    implements $MasterKeyConfigCopyWith<$Res> {
  _$MasterKeyConfigCopyWithImpl(this._self, this._then);

  final MasterKeyConfig _self;
  final $Res Function(MasterKeyConfig) _then;

/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salt = null,Object? kdfAlgorithm = null,Object? kdfParams = null,Object? verificationData = null,}) {
  return _then(_self.copyWith(
salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String,kdfAlgorithm: null == kdfAlgorithm ? _self.kdfAlgorithm : kdfAlgorithm // ignore: cast_nullable_to_non_nullable
as KdfAlgorithm,kdfParams: null == kdfParams ? _self.kdfParams : kdfParams // ignore: cast_nullable_to_non_nullable
as KdfParams,verificationData: null == verificationData ? _self.verificationData : verificationData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KdfParamsCopyWith<$Res> get kdfParams {
  
  return $KdfParamsCopyWith<$Res>(_self.kdfParams, (value) {
    return _then(_self.copyWith(kdfParams: value));
  });
}
}


/// Adds pattern-matching-related methods to [MasterKeyConfig].
extension MasterKeyConfigPatterns on MasterKeyConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MasterKeyConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MasterKeyConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MasterKeyConfig value)  $default,){
final _that = this;
switch (_that) {
case _MasterKeyConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MasterKeyConfig value)?  $default,){
final _that = this;
switch (_that) {
case _MasterKeyConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String salt,  KdfAlgorithm kdfAlgorithm,  KdfParams kdfParams,  String verificationData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MasterKeyConfig() when $default != null:
return $default(_that.salt,_that.kdfAlgorithm,_that.kdfParams,_that.verificationData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String salt,  KdfAlgorithm kdfAlgorithm,  KdfParams kdfParams,  String verificationData)  $default,) {final _that = this;
switch (_that) {
case _MasterKeyConfig():
return $default(_that.salt,_that.kdfAlgorithm,_that.kdfParams,_that.verificationData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String salt,  KdfAlgorithm kdfAlgorithm,  KdfParams kdfParams,  String verificationData)?  $default,) {final _that = this;
switch (_that) {
case _MasterKeyConfig() when $default != null:
return $default(_that.salt,_that.kdfAlgorithm,_that.kdfParams,_that.verificationData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MasterKeyConfig implements MasterKeyConfig {
  const _MasterKeyConfig({required this.salt, required this.kdfAlgorithm, required this.kdfParams, required this.verificationData});
  factory _MasterKeyConfig.fromJson(Map<String, dynamic> json) => _$MasterKeyConfigFromJson(json);

/// Random salt generated once at vault creation (base64-encoded).
@override final  String salt;
@override final  KdfAlgorithm kdfAlgorithm;
@override final  KdfParams kdfParams;
/// Encrypted verification token used to confirm the master password
/// without storing the key. Format: base64(iv + ciphertext + tag).
@override final  String verificationData;

/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasterKeyConfigCopyWith<_MasterKeyConfig> get copyWith => __$MasterKeyConfigCopyWithImpl<_MasterKeyConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MasterKeyConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MasterKeyConfig&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.kdfAlgorithm, kdfAlgorithm) || other.kdfAlgorithm == kdfAlgorithm)&&(identical(other.kdfParams, kdfParams) || other.kdfParams == kdfParams)&&(identical(other.verificationData, verificationData) || other.verificationData == verificationData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salt,kdfAlgorithm,kdfParams,verificationData);

@override
String toString() {
  return 'MasterKeyConfig(salt: $salt, kdfAlgorithm: $kdfAlgorithm, kdfParams: $kdfParams, verificationData: $verificationData)';
}


}

/// @nodoc
abstract mixin class _$MasterKeyConfigCopyWith<$Res> implements $MasterKeyConfigCopyWith<$Res> {
  factory _$MasterKeyConfigCopyWith(_MasterKeyConfig value, $Res Function(_MasterKeyConfig) _then) = __$MasterKeyConfigCopyWithImpl;
@override @useResult
$Res call({
 String salt, KdfAlgorithm kdfAlgorithm, KdfParams kdfParams, String verificationData
});


@override $KdfParamsCopyWith<$Res> get kdfParams;

}
/// @nodoc
class __$MasterKeyConfigCopyWithImpl<$Res>
    implements _$MasterKeyConfigCopyWith<$Res> {
  __$MasterKeyConfigCopyWithImpl(this._self, this._then);

  final _MasterKeyConfig _self;
  final $Res Function(_MasterKeyConfig) _then;

/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salt = null,Object? kdfAlgorithm = null,Object? kdfParams = null,Object? verificationData = null,}) {
  return _then(_MasterKeyConfig(
salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String,kdfAlgorithm: null == kdfAlgorithm ? _self.kdfAlgorithm : kdfAlgorithm // ignore: cast_nullable_to_non_nullable
as KdfAlgorithm,kdfParams: null == kdfParams ? _self.kdfParams : kdfParams // ignore: cast_nullable_to_non_nullable
as KdfParams,verificationData: null == verificationData ? _self.verificationData : verificationData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of MasterKeyConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KdfParamsCopyWith<$Res> get kdfParams {
  
  return $KdfParamsCopyWith<$Res>(_self.kdfParams, (value) {
    return _then(_self.copyWith(kdfParams: value));
  });
}
}

// dart format on
