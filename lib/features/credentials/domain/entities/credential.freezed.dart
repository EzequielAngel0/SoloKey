// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomField {

 String get label; String get value;// stored encrypted
 bool get isSecret;
/// Create a copy of CustomField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomFieldCopyWith<CustomField> get copyWith => _$CustomFieldCopyWithImpl<CustomField>(this as CustomField, _$identity);

  /// Serializes this CustomField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomField&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.isSecret, isSecret) || other.isSecret == isSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value,isSecret);

@override
String toString() {
  return 'CustomField(label: $label, value: $value, isSecret: $isSecret)';
}


}

/// @nodoc
abstract mixin class $CustomFieldCopyWith<$Res>  {
  factory $CustomFieldCopyWith(CustomField value, $Res Function(CustomField) _then) = _$CustomFieldCopyWithImpl;
@useResult
$Res call({
 String label, String value, bool isSecret
});




}
/// @nodoc
class _$CustomFieldCopyWithImpl<$Res>
    implements $CustomFieldCopyWith<$Res> {
  _$CustomFieldCopyWithImpl(this._self, this._then);

  final CustomField _self;
  final $Res Function(CustomField) _then;

/// Create a copy of CustomField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? isSecret = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isSecret: null == isSecret ? _self.isSecret : isSecret // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomField].
extension CustomFieldPatterns on CustomField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomField value)  $default,){
final _that = this;
switch (_that) {
case _CustomField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomField value)?  $default,){
final _that = this;
switch (_that) {
case _CustomField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value,  bool isSecret)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomField() when $default != null:
return $default(_that.label,_that.value,_that.isSecret);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value,  bool isSecret)  $default,) {final _that = this;
switch (_that) {
case _CustomField():
return $default(_that.label,_that.value,_that.isSecret);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value,  bool isSecret)?  $default,) {final _that = this;
switch (_that) {
case _CustomField() when $default != null:
return $default(_that.label,_that.value,_that.isSecret);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomField implements CustomField {
  const _CustomField({required this.label, required this.value, this.isSecret = false});
  factory _CustomField.fromJson(Map<String, dynamic> json) => _$CustomFieldFromJson(json);

@override final  String label;
@override final  String value;
// stored encrypted
@override@JsonKey() final  bool isSecret;

/// Create a copy of CustomField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomFieldCopyWith<_CustomField> get copyWith => __$CustomFieldCopyWithImpl<_CustomField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomField&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.isSecret, isSecret) || other.isSecret == isSecret));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value,isSecret);

@override
String toString() {
  return 'CustomField(label: $label, value: $value, isSecret: $isSecret)';
}


}

/// @nodoc
abstract mixin class _$CustomFieldCopyWith<$Res> implements $CustomFieldCopyWith<$Res> {
  factory _$CustomFieldCopyWith(_CustomField value, $Res Function(_CustomField) _then) = __$CustomFieldCopyWithImpl;
@override @useResult
$Res call({
 String label, String value, bool isSecret
});




}
/// @nodoc
class __$CustomFieldCopyWithImpl<$Res>
    implements _$CustomFieldCopyWith<$Res> {
  __$CustomFieldCopyWithImpl(this._self, this._then);

  final _CustomField _self;
  final $Res Function(_CustomField) _then;

/// Create a copy of CustomField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? isSecret = null,}) {
  return _then(_CustomField(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isSecret: null == isSecret ? _self.isSecret : isSecret // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PasskeyMetadata {

/// Relying Party identifier, e.g. "example.com"
 String get rpId;/// Relying Party display name, e.g. "Example Inc."
 String? get rpName;/// Base64url-encoded credential ID (the public identifier).
 String get credentialId;/// AAGUID of the authenticator (identifies the passkey provider).
 String? get aaguid;/// Username / display name used at registration time.
 String? get userDisplayName;/// Whether the passkey requires user verification (biometric/PIN).
 bool get userVerificationRequired;
/// Create a copy of PasskeyMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasskeyMetadataCopyWith<PasskeyMetadata> get copyWith => _$PasskeyMetadataCopyWithImpl<PasskeyMetadata>(this as PasskeyMetadata, _$identity);

  /// Serializes this PasskeyMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasskeyMetadata&&(identical(other.rpId, rpId) || other.rpId == rpId)&&(identical(other.rpName, rpName) || other.rpName == rpName)&&(identical(other.credentialId, credentialId) || other.credentialId == credentialId)&&(identical(other.aaguid, aaguid) || other.aaguid == aaguid)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName)&&(identical(other.userVerificationRequired, userVerificationRequired) || other.userVerificationRequired == userVerificationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rpId,rpName,credentialId,aaguid,userDisplayName,userVerificationRequired);

@override
String toString() {
  return 'PasskeyMetadata(rpId: $rpId, rpName: $rpName, credentialId: $credentialId, aaguid: $aaguid, userDisplayName: $userDisplayName, userVerificationRequired: $userVerificationRequired)';
}


}

/// @nodoc
abstract mixin class $PasskeyMetadataCopyWith<$Res>  {
  factory $PasskeyMetadataCopyWith(PasskeyMetadata value, $Res Function(PasskeyMetadata) _then) = _$PasskeyMetadataCopyWithImpl;
@useResult
$Res call({
 String rpId, String? rpName, String credentialId, String? aaguid, String? userDisplayName, bool userVerificationRequired
});




}
/// @nodoc
class _$PasskeyMetadataCopyWithImpl<$Res>
    implements $PasskeyMetadataCopyWith<$Res> {
  _$PasskeyMetadataCopyWithImpl(this._self, this._then);

  final PasskeyMetadata _self;
  final $Res Function(PasskeyMetadata) _then;

/// Create a copy of PasskeyMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rpId = null,Object? rpName = freezed,Object? credentialId = null,Object? aaguid = freezed,Object? userDisplayName = freezed,Object? userVerificationRequired = null,}) {
  return _then(_self.copyWith(
rpId: null == rpId ? _self.rpId : rpId // ignore: cast_nullable_to_non_nullable
as String,rpName: freezed == rpName ? _self.rpName : rpName // ignore: cast_nullable_to_non_nullable
as String?,credentialId: null == credentialId ? _self.credentialId : credentialId // ignore: cast_nullable_to_non_nullable
as String,aaguid: freezed == aaguid ? _self.aaguid : aaguid // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,userVerificationRequired: null == userVerificationRequired ? _self.userVerificationRequired : userVerificationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PasskeyMetadata].
extension PasskeyMetadataPatterns on PasskeyMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasskeyMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasskeyMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasskeyMetadata value)  $default,){
final _that = this;
switch (_that) {
case _PasskeyMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasskeyMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _PasskeyMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rpId,  String? rpName,  String credentialId,  String? aaguid,  String? userDisplayName,  bool userVerificationRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasskeyMetadata() when $default != null:
return $default(_that.rpId,_that.rpName,_that.credentialId,_that.aaguid,_that.userDisplayName,_that.userVerificationRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rpId,  String? rpName,  String credentialId,  String? aaguid,  String? userDisplayName,  bool userVerificationRequired)  $default,) {final _that = this;
switch (_that) {
case _PasskeyMetadata():
return $default(_that.rpId,_that.rpName,_that.credentialId,_that.aaguid,_that.userDisplayName,_that.userVerificationRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rpId,  String? rpName,  String credentialId,  String? aaguid,  String? userDisplayName,  bool userVerificationRequired)?  $default,) {final _that = this;
switch (_that) {
case _PasskeyMetadata() when $default != null:
return $default(_that.rpId,_that.rpName,_that.credentialId,_that.aaguid,_that.userDisplayName,_that.userVerificationRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasskeyMetadata implements PasskeyMetadata {
  const _PasskeyMetadata({required this.rpId, this.rpName, required this.credentialId, this.aaguid, this.userDisplayName, this.userVerificationRequired = true});
  factory _PasskeyMetadata.fromJson(Map<String, dynamic> json) => _$PasskeyMetadataFromJson(json);

/// Relying Party identifier, e.g. "example.com"
@override final  String rpId;
/// Relying Party display name, e.g. "Example Inc."
@override final  String? rpName;
/// Base64url-encoded credential ID (the public identifier).
@override final  String credentialId;
/// AAGUID of the authenticator (identifies the passkey provider).
@override final  String? aaguid;
/// Username / display name used at registration time.
@override final  String? userDisplayName;
/// Whether the passkey requires user verification (biometric/PIN).
@override@JsonKey() final  bool userVerificationRequired;

/// Create a copy of PasskeyMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasskeyMetadataCopyWith<_PasskeyMetadata> get copyWith => __$PasskeyMetadataCopyWithImpl<_PasskeyMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasskeyMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasskeyMetadata&&(identical(other.rpId, rpId) || other.rpId == rpId)&&(identical(other.rpName, rpName) || other.rpName == rpName)&&(identical(other.credentialId, credentialId) || other.credentialId == credentialId)&&(identical(other.aaguid, aaguid) || other.aaguid == aaguid)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName)&&(identical(other.userVerificationRequired, userVerificationRequired) || other.userVerificationRequired == userVerificationRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rpId,rpName,credentialId,aaguid,userDisplayName,userVerificationRequired);

@override
String toString() {
  return 'PasskeyMetadata(rpId: $rpId, rpName: $rpName, credentialId: $credentialId, aaguid: $aaguid, userDisplayName: $userDisplayName, userVerificationRequired: $userVerificationRequired)';
}


}

/// @nodoc
abstract mixin class _$PasskeyMetadataCopyWith<$Res> implements $PasskeyMetadataCopyWith<$Res> {
  factory _$PasskeyMetadataCopyWith(_PasskeyMetadata value, $Res Function(_PasskeyMetadata) _then) = __$PasskeyMetadataCopyWithImpl;
@override @useResult
$Res call({
 String rpId, String? rpName, String credentialId, String? aaguid, String? userDisplayName, bool userVerificationRequired
});




}
/// @nodoc
class __$PasskeyMetadataCopyWithImpl<$Res>
    implements _$PasskeyMetadataCopyWith<$Res> {
  __$PasskeyMetadataCopyWithImpl(this._self, this._then);

  final _PasskeyMetadata _self;
  final $Res Function(_PasskeyMetadata) _then;

/// Create a copy of PasskeyMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rpId = null,Object? rpName = freezed,Object? credentialId = null,Object? aaguid = freezed,Object? userDisplayName = freezed,Object? userVerificationRequired = null,}) {
  return _then(_PasskeyMetadata(
rpId: null == rpId ? _self.rpId : rpId // ignore: cast_nullable_to_non_nullable
as String,rpName: freezed == rpName ? _self.rpName : rpName // ignore: cast_nullable_to_non_nullable
as String?,credentialId: null == credentialId ? _self.credentialId : credentialId // ignore: cast_nullable_to_non_nullable
as String,aaguid: freezed == aaguid ? _self.aaguid : aaguid // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,userVerificationRequired: null == userVerificationRequired ? _self.userVerificationRequired : userVerificationRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SshKeyMetadata {

 String get privateKey;// stored encrypted
 String get publicKey;// stored encrypted
 String? get passphrase;// stored encrypted
 String get keyType;
/// Create a copy of SshKeyMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SshKeyMetadataCopyWith<SshKeyMetadata> get copyWith => _$SshKeyMetadataCopyWithImpl<SshKeyMetadata>(this as SshKeyMetadata, _$identity);

  /// Serializes this SshKeyMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SshKeyMetadata&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.passphrase, passphrase) || other.passphrase == passphrase)&&(identical(other.keyType, keyType) || other.keyType == keyType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,privateKey,publicKey,passphrase,keyType);

@override
String toString() {
  return 'SshKeyMetadata(privateKey: $privateKey, publicKey: $publicKey, passphrase: $passphrase, keyType: $keyType)';
}


}

/// @nodoc
abstract mixin class $SshKeyMetadataCopyWith<$Res>  {
  factory $SshKeyMetadataCopyWith(SshKeyMetadata value, $Res Function(SshKeyMetadata) _then) = _$SshKeyMetadataCopyWithImpl;
@useResult
$Res call({
 String privateKey, String publicKey, String? passphrase, String keyType
});




}
/// @nodoc
class _$SshKeyMetadataCopyWithImpl<$Res>
    implements $SshKeyMetadataCopyWith<$Res> {
  _$SshKeyMetadataCopyWithImpl(this._self, this._then);

  final SshKeyMetadata _self;
  final $Res Function(SshKeyMetadata) _then;

/// Create a copy of SshKeyMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? privateKey = null,Object? publicKey = null,Object? passphrase = freezed,Object? keyType = null,}) {
  return _then(_self.copyWith(
privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,passphrase: freezed == passphrase ? _self.passphrase : passphrase // ignore: cast_nullable_to_non_nullable
as String?,keyType: null == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SshKeyMetadata].
extension SshKeyMetadataPatterns on SshKeyMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SshKeyMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SshKeyMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SshKeyMetadata value)  $default,){
final _that = this;
switch (_that) {
case _SshKeyMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SshKeyMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _SshKeyMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String privateKey,  String publicKey,  String? passphrase,  String keyType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SshKeyMetadata() when $default != null:
return $default(_that.privateKey,_that.publicKey,_that.passphrase,_that.keyType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String privateKey,  String publicKey,  String? passphrase,  String keyType)  $default,) {final _that = this;
switch (_that) {
case _SshKeyMetadata():
return $default(_that.privateKey,_that.publicKey,_that.passphrase,_that.keyType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String privateKey,  String publicKey,  String? passphrase,  String keyType)?  $default,) {final _that = this;
switch (_that) {
case _SshKeyMetadata() when $default != null:
return $default(_that.privateKey,_that.publicKey,_that.passphrase,_that.keyType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SshKeyMetadata implements SshKeyMetadata {
  const _SshKeyMetadata({required this.privateKey, required this.publicKey, this.passphrase, this.keyType = 'Ed25519'});
  factory _SshKeyMetadata.fromJson(Map<String, dynamic> json) => _$SshKeyMetadataFromJson(json);

@override final  String privateKey;
// stored encrypted
@override final  String publicKey;
// stored encrypted
@override final  String? passphrase;
// stored encrypted
@override@JsonKey() final  String keyType;

/// Create a copy of SshKeyMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SshKeyMetadataCopyWith<_SshKeyMetadata> get copyWith => __$SshKeyMetadataCopyWithImpl<_SshKeyMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SshKeyMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SshKeyMetadata&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.passphrase, passphrase) || other.passphrase == passphrase)&&(identical(other.keyType, keyType) || other.keyType == keyType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,privateKey,publicKey,passphrase,keyType);

@override
String toString() {
  return 'SshKeyMetadata(privateKey: $privateKey, publicKey: $publicKey, passphrase: $passphrase, keyType: $keyType)';
}


}

/// @nodoc
abstract mixin class _$SshKeyMetadataCopyWith<$Res> implements $SshKeyMetadataCopyWith<$Res> {
  factory _$SshKeyMetadataCopyWith(_SshKeyMetadata value, $Res Function(_SshKeyMetadata) _then) = __$SshKeyMetadataCopyWithImpl;
@override @useResult
$Res call({
 String privateKey, String publicKey, String? passphrase, String keyType
});




}
/// @nodoc
class __$SshKeyMetadataCopyWithImpl<$Res>
    implements _$SshKeyMetadataCopyWith<$Res> {
  __$SshKeyMetadataCopyWithImpl(this._self, this._then);

  final _SshKeyMetadata _self;
  final $Res Function(_SshKeyMetadata) _then;

/// Create a copy of SshKeyMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? privateKey = null,Object? publicKey = null,Object? passphrase = freezed,Object? keyType = null,}) {
  return _then(_SshKeyMetadata(
privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String,publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String,passphrase: freezed == passphrase ? _self.passphrase : passphrase // ignore: cast_nullable_to_non_nullable
as String?,keyType: null == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Credential {

 String get id; CredentialType get type; String get title; String? get username; String? get password;// stored encrypted; holds passkey private key handle too
 String? get website; String? get notes;// stored encrypted
 List<CustomField> get customFields; String? get categoryId; String? get folderId; bool get isFavorite; bool get isDoubleEncrypted;/// Hidden/archived: kept out of the main list (shown in the "Ocultas" view).
 bool get isHidden;/// Manual sort order for the main list (ascending; lower = higher up).
 int get sortOrder; DateTime get createdAt; DateTime get updatedAt;/// Present only when [type] == [CredentialType.passkey]
 PasskeyMetadata? get passkeyMetadata;/// Present only when [type] == [CredentialType.sshKey]
 SshKeyMetadata? get sshKeyMetadata;/// Rotation reminder interval: 'none', 'monthly', 'quarterly',
/// 'semiAnnually', or 'custom'.
 String get rotationInterval;/// Custom rotation period in days (used when rotationInterval == 'custom').
 int? get customRotationDays;/// Last time a rotation notification was shown for this credential.
 DateTime? get lastRotationPromptedAt;
/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialCopyWith<Credential> get copyWith => _$CredentialCopyWithImpl<Credential>(this as Credential, _$identity);

  /// Serializes this Credential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credential&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.website, website) || other.website == website)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.customFields, customFields)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDoubleEncrypted, isDoubleEncrypted) || other.isDoubleEncrypted == isDoubleEncrypted)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.passkeyMetadata, passkeyMetadata) || other.passkeyMetadata == passkeyMetadata)&&(identical(other.sshKeyMetadata, sshKeyMetadata) || other.sshKeyMetadata == sshKeyMetadata)&&(identical(other.rotationInterval, rotationInterval) || other.rotationInterval == rotationInterval)&&(identical(other.customRotationDays, customRotationDays) || other.customRotationDays == customRotationDays)&&(identical(other.lastRotationPromptedAt, lastRotationPromptedAt) || other.lastRotationPromptedAt == lastRotationPromptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,title,username,password,website,notes,const DeepCollectionEquality().hash(customFields),categoryId,folderId,isFavorite,isDoubleEncrypted,isHidden,sortOrder,createdAt,updatedAt,passkeyMetadata,sshKeyMetadata,rotationInterval,customRotationDays,lastRotationPromptedAt]);

@override
String toString() {
  return 'Credential(id: $id, type: $type, title: $title, username: $username, password: $password, website: $website, notes: $notes, customFields: $customFields, categoryId: $categoryId, folderId: $folderId, isFavorite: $isFavorite, isDoubleEncrypted: $isDoubleEncrypted, isHidden: $isHidden, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, passkeyMetadata: $passkeyMetadata, sshKeyMetadata: $sshKeyMetadata, rotationInterval: $rotationInterval, customRotationDays: $customRotationDays, lastRotationPromptedAt: $lastRotationPromptedAt)';
}


}

/// @nodoc
abstract mixin class $CredentialCopyWith<$Res>  {
  factory $CredentialCopyWith(Credential value, $Res Function(Credential) _then) = _$CredentialCopyWithImpl;
@useResult
$Res call({
 String id, CredentialType type, String title, String? username, String? password, String? website, String? notes, List<CustomField> customFields, String? categoryId, String? folderId, bool isFavorite, bool isDoubleEncrypted, bool isHidden, int sortOrder, DateTime createdAt, DateTime updatedAt, PasskeyMetadata? passkeyMetadata, SshKeyMetadata? sshKeyMetadata, String rotationInterval, int? customRotationDays, DateTime? lastRotationPromptedAt
});


$PasskeyMetadataCopyWith<$Res>? get passkeyMetadata;$SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata;

}
/// @nodoc
class _$CredentialCopyWithImpl<$Res>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._self, this._then);

  final Credential _self;
  final $Res Function(Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? username = freezed,Object? password = freezed,Object? website = freezed,Object? notes = freezed,Object? customFields = null,Object? categoryId = freezed,Object? folderId = freezed,Object? isFavorite = null,Object? isDoubleEncrypted = null,Object? isHidden = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? passkeyMetadata = freezed,Object? sshKeyMetadata = freezed,Object? rotationInterval = null,Object? customRotationDays = freezed,Object? lastRotationPromptedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CredentialType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customFields: null == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as List<CustomField>,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDoubleEncrypted: null == isDoubleEncrypted ? _self.isDoubleEncrypted : isDoubleEncrypted // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,passkeyMetadata: freezed == passkeyMetadata ? _self.passkeyMetadata : passkeyMetadata // ignore: cast_nullable_to_non_nullable
as PasskeyMetadata?,sshKeyMetadata: freezed == sshKeyMetadata ? _self.sshKeyMetadata : sshKeyMetadata // ignore: cast_nullable_to_non_nullable
as SshKeyMetadata?,rotationInterval: null == rotationInterval ? _self.rotationInterval : rotationInterval // ignore: cast_nullable_to_non_nullable
as String,customRotationDays: freezed == customRotationDays ? _self.customRotationDays : customRotationDays // ignore: cast_nullable_to_non_nullable
as int?,lastRotationPromptedAt: freezed == lastRotationPromptedAt ? _self.lastRotationPromptedAt : lastRotationPromptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PasskeyMetadataCopyWith<$Res>? get passkeyMetadata {
    if (_self.passkeyMetadata == null) {
    return null;
  }

  return $PasskeyMetadataCopyWith<$Res>(_self.passkeyMetadata!, (value) {
    return _then(_self.copyWith(passkeyMetadata: value));
  });
}/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata {
    if (_self.sshKeyMetadata == null) {
    return null;
  }

  return $SshKeyMetadataCopyWith<$Res>(_self.sshKeyMetadata!, (value) {
    return _then(_self.copyWith(sshKeyMetadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [Credential].
extension CredentialPatterns on Credential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Credential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Credential value)  $default,){
final _that = this;
switch (_that) {
case _Credential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Credential value)?  $default,){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CredentialType type,  String title,  String? username,  String? password,  String? website,  String? notes,  List<CustomField> customFields,  String? categoryId,  String? folderId,  bool isFavorite,  bool isDoubleEncrypted,  bool isHidden,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  PasskeyMetadata? passkeyMetadata,  SshKeyMetadata? sshKeyMetadata,  String rotationInterval,  int? customRotationDays,  DateTime? lastRotationPromptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.username,_that.password,_that.website,_that.notes,_that.customFields,_that.categoryId,_that.folderId,_that.isFavorite,_that.isDoubleEncrypted,_that.isHidden,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.passkeyMetadata,_that.sshKeyMetadata,_that.rotationInterval,_that.customRotationDays,_that.lastRotationPromptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CredentialType type,  String title,  String? username,  String? password,  String? website,  String? notes,  List<CustomField> customFields,  String? categoryId,  String? folderId,  bool isFavorite,  bool isDoubleEncrypted,  bool isHidden,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  PasskeyMetadata? passkeyMetadata,  SshKeyMetadata? sshKeyMetadata,  String rotationInterval,  int? customRotationDays,  DateTime? lastRotationPromptedAt)  $default,) {final _that = this;
switch (_that) {
case _Credential():
return $default(_that.id,_that.type,_that.title,_that.username,_that.password,_that.website,_that.notes,_that.customFields,_that.categoryId,_that.folderId,_that.isFavorite,_that.isDoubleEncrypted,_that.isHidden,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.passkeyMetadata,_that.sshKeyMetadata,_that.rotationInterval,_that.customRotationDays,_that.lastRotationPromptedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CredentialType type,  String title,  String? username,  String? password,  String? website,  String? notes,  List<CustomField> customFields,  String? categoryId,  String? folderId,  bool isFavorite,  bool isDoubleEncrypted,  bool isHidden,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  PasskeyMetadata? passkeyMetadata,  SshKeyMetadata? sshKeyMetadata,  String rotationInterval,  int? customRotationDays,  DateTime? lastRotationPromptedAt)?  $default,) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.username,_that.password,_that.website,_that.notes,_that.customFields,_that.categoryId,_that.folderId,_that.isFavorite,_that.isDoubleEncrypted,_that.isHidden,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.passkeyMetadata,_that.sshKeyMetadata,_that.rotationInterval,_that.customRotationDays,_that.lastRotationPromptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Credential implements Credential {
  const _Credential({required this.id, required this.type, required this.title, this.username, this.password, this.website, this.notes, final  List<CustomField> customFields = const [], this.categoryId, this.folderId, this.isFavorite = false, this.isDoubleEncrypted = false, this.isHidden = false, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.passkeyMetadata, this.sshKeyMetadata, this.rotationInterval = 'none', this.customRotationDays, this.lastRotationPromptedAt}): _customFields = customFields;
  factory _Credential.fromJson(Map<String, dynamic> json) => _$CredentialFromJson(json);

@override final  String id;
@override final  CredentialType type;
@override final  String title;
@override final  String? username;
@override final  String? password;
// stored encrypted; holds passkey private key handle too
@override final  String? website;
@override final  String? notes;
// stored encrypted
 final  List<CustomField> _customFields;
// stored encrypted
@override@JsonKey() List<CustomField> get customFields {
  if (_customFields is EqualUnmodifiableListView) return _customFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customFields);
}

@override final  String? categoryId;
@override final  String? folderId;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isDoubleEncrypted;
/// Hidden/archived: kept out of the main list (shown in the "Ocultas" view).
@override@JsonKey() final  bool isHidden;
/// Manual sort order for the main list (ascending; lower = higher up).
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Present only when [type] == [CredentialType.passkey]
@override final  PasskeyMetadata? passkeyMetadata;
/// Present only when [type] == [CredentialType.sshKey]
@override final  SshKeyMetadata? sshKeyMetadata;
/// Rotation reminder interval: 'none', 'monthly', 'quarterly',
/// 'semiAnnually', or 'custom'.
@override@JsonKey() final  String rotationInterval;
/// Custom rotation period in days (used when rotationInterval == 'custom').
@override final  int? customRotationDays;
/// Last time a rotation notification was shown for this credential.
@override final  DateTime? lastRotationPromptedAt;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialCopyWith<_Credential> get copyWith => __$CredentialCopyWithImpl<_Credential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Credential&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.website, website) || other.website == website)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._customFields, _customFields)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDoubleEncrypted, isDoubleEncrypted) || other.isDoubleEncrypted == isDoubleEncrypted)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.passkeyMetadata, passkeyMetadata) || other.passkeyMetadata == passkeyMetadata)&&(identical(other.sshKeyMetadata, sshKeyMetadata) || other.sshKeyMetadata == sshKeyMetadata)&&(identical(other.rotationInterval, rotationInterval) || other.rotationInterval == rotationInterval)&&(identical(other.customRotationDays, customRotationDays) || other.customRotationDays == customRotationDays)&&(identical(other.lastRotationPromptedAt, lastRotationPromptedAt) || other.lastRotationPromptedAt == lastRotationPromptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,title,username,password,website,notes,const DeepCollectionEquality().hash(_customFields),categoryId,folderId,isFavorite,isDoubleEncrypted,isHidden,sortOrder,createdAt,updatedAt,passkeyMetadata,sshKeyMetadata,rotationInterval,customRotationDays,lastRotationPromptedAt]);

@override
String toString() {
  return 'Credential(id: $id, type: $type, title: $title, username: $username, password: $password, website: $website, notes: $notes, customFields: $customFields, categoryId: $categoryId, folderId: $folderId, isFavorite: $isFavorite, isDoubleEncrypted: $isDoubleEncrypted, isHidden: $isHidden, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, passkeyMetadata: $passkeyMetadata, sshKeyMetadata: $sshKeyMetadata, rotationInterval: $rotationInterval, customRotationDays: $customRotationDays, lastRotationPromptedAt: $lastRotationPromptedAt)';
}


}

/// @nodoc
abstract mixin class _$CredentialCopyWith<$Res> implements $CredentialCopyWith<$Res> {
  factory _$CredentialCopyWith(_Credential value, $Res Function(_Credential) _then) = __$CredentialCopyWithImpl;
@override @useResult
$Res call({
 String id, CredentialType type, String title, String? username, String? password, String? website, String? notes, List<CustomField> customFields, String? categoryId, String? folderId, bool isFavorite, bool isDoubleEncrypted, bool isHidden, int sortOrder, DateTime createdAt, DateTime updatedAt, PasskeyMetadata? passkeyMetadata, SshKeyMetadata? sshKeyMetadata, String rotationInterval, int? customRotationDays, DateTime? lastRotationPromptedAt
});


@override $PasskeyMetadataCopyWith<$Res>? get passkeyMetadata;@override $SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata;

}
/// @nodoc
class __$CredentialCopyWithImpl<$Res>
    implements _$CredentialCopyWith<$Res> {
  __$CredentialCopyWithImpl(this._self, this._then);

  final _Credential _self;
  final $Res Function(_Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? username = freezed,Object? password = freezed,Object? website = freezed,Object? notes = freezed,Object? customFields = null,Object? categoryId = freezed,Object? folderId = freezed,Object? isFavorite = null,Object? isDoubleEncrypted = null,Object? isHidden = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? passkeyMetadata = freezed,Object? sshKeyMetadata = freezed,Object? rotationInterval = null,Object? customRotationDays = freezed,Object? lastRotationPromptedAt = freezed,}) {
  return _then(_Credential(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CredentialType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customFields: null == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as List<CustomField>,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDoubleEncrypted: null == isDoubleEncrypted ? _self.isDoubleEncrypted : isDoubleEncrypted // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,passkeyMetadata: freezed == passkeyMetadata ? _self.passkeyMetadata : passkeyMetadata // ignore: cast_nullable_to_non_nullable
as PasskeyMetadata?,sshKeyMetadata: freezed == sshKeyMetadata ? _self.sshKeyMetadata : sshKeyMetadata // ignore: cast_nullable_to_non_nullable
as SshKeyMetadata?,rotationInterval: null == rotationInterval ? _self.rotationInterval : rotationInterval // ignore: cast_nullable_to_non_nullable
as String,customRotationDays: freezed == customRotationDays ? _self.customRotationDays : customRotationDays // ignore: cast_nullable_to_non_nullable
as int?,lastRotationPromptedAt: freezed == lastRotationPromptedAt ? _self.lastRotationPromptedAt : lastRotationPromptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PasskeyMetadataCopyWith<$Res>? get passkeyMetadata {
    if (_self.passkeyMetadata == null) {
    return null;
  }

  return $PasskeyMetadataCopyWith<$Res>(_self.passkeyMetadata!, (value) {
    return _then(_self.copyWith(passkeyMetadata: value));
  });
}/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata {
    if (_self.sshKeyMetadata == null) {
    return null;
  }

  return $SshKeyMetadataCopyWith<$Res>(_self.sshKeyMetadata!, (value) {
    return _then(_self.copyWith(sshKeyMetadata: value));
  });
}
}

// dart format on
