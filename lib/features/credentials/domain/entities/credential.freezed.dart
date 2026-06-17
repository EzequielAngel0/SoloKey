// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomField _$CustomFieldFromJson(Map<String, dynamic> json) {
  return _CustomField.fromJson(json);
}

/// @nodoc
mixin _$CustomField {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError; // stored encrypted
  bool get isSecret => throw _privateConstructorUsedError;

  /// Serializes this CustomField to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomFieldCopyWith<CustomField> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomFieldCopyWith<$Res> {
  factory $CustomFieldCopyWith(
    CustomField value,
    $Res Function(CustomField) then,
  ) = _$CustomFieldCopyWithImpl<$Res, CustomField>;
  @useResult
  $Res call({String label, String value, bool isSecret});
}

/// @nodoc
class _$CustomFieldCopyWithImpl<$Res, $Val extends CustomField>
    implements $CustomFieldCopyWith<$Res> {
  _$CustomFieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? isSecret = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            isSecret: null == isSecret
                ? _value.isSecret
                : isSecret // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomFieldImplCopyWith<$Res>
    implements $CustomFieldCopyWith<$Res> {
  factory _$$CustomFieldImplCopyWith(
    _$CustomFieldImpl value,
    $Res Function(_$CustomFieldImpl) then,
  ) = __$$CustomFieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String value, bool isSecret});
}

/// @nodoc
class __$$CustomFieldImplCopyWithImpl<$Res>
    extends _$CustomFieldCopyWithImpl<$Res, _$CustomFieldImpl>
    implements _$$CustomFieldImplCopyWith<$Res> {
  __$$CustomFieldImplCopyWithImpl(
    _$CustomFieldImpl _value,
    $Res Function(_$CustomFieldImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? isSecret = null,
  }) {
    return _then(
      _$CustomFieldImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        isSecret: null == isSecret
            ? _value.isSecret
            : isSecret // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomFieldImpl implements _CustomField {
  const _$CustomFieldImpl({
    required this.label,
    required this.value,
    this.isSecret = false,
  });

  factory _$CustomFieldImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomFieldImplFromJson(json);

  @override
  final String label;
  @override
  final String value;
  // stored encrypted
  @override
  @JsonKey()
  final bool isSecret;

  @override
  String toString() {
    return 'CustomField(label: $label, value: $value, isSecret: $isSecret)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomFieldImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.isSecret, isSecret) ||
                other.isSecret == isSecret));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value, isSecret);

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomFieldImplCopyWith<_$CustomFieldImpl> get copyWith =>
      __$$CustomFieldImplCopyWithImpl<_$CustomFieldImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomFieldImplToJson(this);
  }
}

abstract class _CustomField implements CustomField {
  const factory _CustomField({
    required final String label,
    required final String value,
    final bool isSecret,
  }) = _$CustomFieldImpl;

  factory _CustomField.fromJson(Map<String, dynamic> json) =
      _$CustomFieldImpl.fromJson;

  @override
  String get label;
  @override
  String get value; // stored encrypted
  @override
  bool get isSecret;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomFieldImplCopyWith<_$CustomFieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PasskeyMetadata _$PasskeyMetadataFromJson(Map<String, dynamic> json) {
  return _PasskeyMetadata.fromJson(json);
}

/// @nodoc
mixin _$PasskeyMetadata {
  /// Relying Party identifier, e.g. "example.com"
  String get rpId => throw _privateConstructorUsedError;

  /// Relying Party display name, e.g. "Example Inc."
  String? get rpName => throw _privateConstructorUsedError;

  /// Base64url-encoded credential ID (the public identifier).
  String get credentialId => throw _privateConstructorUsedError;

  /// AAGUID of the authenticator (identifies the passkey provider).
  String? get aaguid => throw _privateConstructorUsedError;

  /// Username / display name used at registration time.
  String? get userDisplayName => throw _privateConstructorUsedError;

  /// Whether the passkey requires user verification (biometric/PIN).
  bool get userVerificationRequired => throw _privateConstructorUsedError;

  /// Serializes this PasskeyMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasskeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasskeyMetadataCopyWith<PasskeyMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasskeyMetadataCopyWith<$Res> {
  factory $PasskeyMetadataCopyWith(
    PasskeyMetadata value,
    $Res Function(PasskeyMetadata) then,
  ) = _$PasskeyMetadataCopyWithImpl<$Res, PasskeyMetadata>;
  @useResult
  $Res call({
    String rpId,
    String? rpName,
    String credentialId,
    String? aaguid,
    String? userDisplayName,
    bool userVerificationRequired,
  });
}

/// @nodoc
class _$PasskeyMetadataCopyWithImpl<$Res, $Val extends PasskeyMetadata>
    implements $PasskeyMetadataCopyWith<$Res> {
  _$PasskeyMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasskeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rpId = null,
    Object? rpName = freezed,
    Object? credentialId = null,
    Object? aaguid = freezed,
    Object? userDisplayName = freezed,
    Object? userVerificationRequired = null,
  }) {
    return _then(
      _value.copyWith(
            rpId: null == rpId
                ? _value.rpId
                : rpId // ignore: cast_nullable_to_non_nullable
                      as String,
            rpName: freezed == rpName
                ? _value.rpName
                : rpName // ignore: cast_nullable_to_non_nullable
                      as String?,
            credentialId: null == credentialId
                ? _value.credentialId
                : credentialId // ignore: cast_nullable_to_non_nullable
                      as String,
            aaguid: freezed == aaguid
                ? _value.aaguid
                : aaguid // ignore: cast_nullable_to_non_nullable
                      as String?,
            userDisplayName: freezed == userDisplayName
                ? _value.userDisplayName
                : userDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userVerificationRequired: null == userVerificationRequired
                ? _value.userVerificationRequired
                : userVerificationRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasskeyMetadataImplCopyWith<$Res>
    implements $PasskeyMetadataCopyWith<$Res> {
  factory _$$PasskeyMetadataImplCopyWith(
    _$PasskeyMetadataImpl value,
    $Res Function(_$PasskeyMetadataImpl) then,
  ) = __$$PasskeyMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rpId,
    String? rpName,
    String credentialId,
    String? aaguid,
    String? userDisplayName,
    bool userVerificationRequired,
  });
}

/// @nodoc
class __$$PasskeyMetadataImplCopyWithImpl<$Res>
    extends _$PasskeyMetadataCopyWithImpl<$Res, _$PasskeyMetadataImpl>
    implements _$$PasskeyMetadataImplCopyWith<$Res> {
  __$$PasskeyMetadataImplCopyWithImpl(
    _$PasskeyMetadataImpl _value,
    $Res Function(_$PasskeyMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasskeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rpId = null,
    Object? rpName = freezed,
    Object? credentialId = null,
    Object? aaguid = freezed,
    Object? userDisplayName = freezed,
    Object? userVerificationRequired = null,
  }) {
    return _then(
      _$PasskeyMetadataImpl(
        rpId: null == rpId
            ? _value.rpId
            : rpId // ignore: cast_nullable_to_non_nullable
                  as String,
        rpName: freezed == rpName
            ? _value.rpName
            : rpName // ignore: cast_nullable_to_non_nullable
                  as String?,
        credentialId: null == credentialId
            ? _value.credentialId
            : credentialId // ignore: cast_nullable_to_non_nullable
                  as String,
        aaguid: freezed == aaguid
            ? _value.aaguid
            : aaguid // ignore: cast_nullable_to_non_nullable
                  as String?,
        userDisplayName: freezed == userDisplayName
            ? _value.userDisplayName
            : userDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userVerificationRequired: null == userVerificationRequired
            ? _value.userVerificationRequired
            : userVerificationRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PasskeyMetadataImpl implements _PasskeyMetadata {
  const _$PasskeyMetadataImpl({
    required this.rpId,
    this.rpName,
    required this.credentialId,
    this.aaguid,
    this.userDisplayName,
    this.userVerificationRequired = true,
  });

  factory _$PasskeyMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PasskeyMetadataImplFromJson(json);

  /// Relying Party identifier, e.g. "example.com"
  @override
  final String rpId;

  /// Relying Party display name, e.g. "Example Inc."
  @override
  final String? rpName;

  /// Base64url-encoded credential ID (the public identifier).
  @override
  final String credentialId;

  /// AAGUID of the authenticator (identifies the passkey provider).
  @override
  final String? aaguid;

  /// Username / display name used at registration time.
  @override
  final String? userDisplayName;

  /// Whether the passkey requires user verification (biometric/PIN).
  @override
  @JsonKey()
  final bool userVerificationRequired;

  @override
  String toString() {
    return 'PasskeyMetadata(rpId: $rpId, rpName: $rpName, credentialId: $credentialId, aaguid: $aaguid, userDisplayName: $userDisplayName, userVerificationRequired: $userVerificationRequired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasskeyMetadataImpl &&
            (identical(other.rpId, rpId) || other.rpId == rpId) &&
            (identical(other.rpName, rpName) || other.rpName == rpName) &&
            (identical(other.credentialId, credentialId) ||
                other.credentialId == credentialId) &&
            (identical(other.aaguid, aaguid) || other.aaguid == aaguid) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(
                  other.userVerificationRequired,
                  userVerificationRequired,
                ) ||
                other.userVerificationRequired == userVerificationRequired));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rpId,
    rpName,
    credentialId,
    aaguid,
    userDisplayName,
    userVerificationRequired,
  );

  /// Create a copy of PasskeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasskeyMetadataImplCopyWith<_$PasskeyMetadataImpl> get copyWith =>
      __$$PasskeyMetadataImplCopyWithImpl<_$PasskeyMetadataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PasskeyMetadataImplToJson(this);
  }
}

abstract class _PasskeyMetadata implements PasskeyMetadata {
  const factory _PasskeyMetadata({
    required final String rpId,
    final String? rpName,
    required final String credentialId,
    final String? aaguid,
    final String? userDisplayName,
    final bool userVerificationRequired,
  }) = _$PasskeyMetadataImpl;

  factory _PasskeyMetadata.fromJson(Map<String, dynamic> json) =
      _$PasskeyMetadataImpl.fromJson;

  /// Relying Party identifier, e.g. "example.com"
  @override
  String get rpId;

  /// Relying Party display name, e.g. "Example Inc."
  @override
  String? get rpName;

  /// Base64url-encoded credential ID (the public identifier).
  @override
  String get credentialId;

  /// AAGUID of the authenticator (identifies the passkey provider).
  @override
  String? get aaguid;

  /// Username / display name used at registration time.
  @override
  String? get userDisplayName;

  /// Whether the passkey requires user verification (biometric/PIN).
  @override
  bool get userVerificationRequired;

  /// Create a copy of PasskeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasskeyMetadataImplCopyWith<_$PasskeyMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SshKeyMetadata _$SshKeyMetadataFromJson(Map<String, dynamic> json) {
  return _SshKeyMetadata.fromJson(json);
}

/// @nodoc
mixin _$SshKeyMetadata {
  String get privateKey =>
      throw _privateConstructorUsedError; // stored encrypted
  String get publicKey =>
      throw _privateConstructorUsedError; // stored encrypted
  String? get passphrase =>
      throw _privateConstructorUsedError; // stored encrypted
  String get keyType => throw _privateConstructorUsedError;

  /// Serializes this SshKeyMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SshKeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SshKeyMetadataCopyWith<SshKeyMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SshKeyMetadataCopyWith<$Res> {
  factory $SshKeyMetadataCopyWith(
    SshKeyMetadata value,
    $Res Function(SshKeyMetadata) then,
  ) = _$SshKeyMetadataCopyWithImpl<$Res, SshKeyMetadata>;
  @useResult
  $Res call({
    String privateKey,
    String publicKey,
    String? passphrase,
    String keyType,
  });
}

/// @nodoc
class _$SshKeyMetadataCopyWithImpl<$Res, $Val extends SshKeyMetadata>
    implements $SshKeyMetadataCopyWith<$Res> {
  _$SshKeyMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SshKeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? privateKey = null,
    Object? publicKey = null,
    Object? passphrase = freezed,
    Object? keyType = null,
  }) {
    return _then(
      _value.copyWith(
            privateKey: null == privateKey
                ? _value.privateKey
                : privateKey // ignore: cast_nullable_to_non_nullable
                      as String,
            publicKey: null == publicKey
                ? _value.publicKey
                : publicKey // ignore: cast_nullable_to_non_nullable
                      as String,
            passphrase: freezed == passphrase
                ? _value.passphrase
                : passphrase // ignore: cast_nullable_to_non_nullable
                      as String?,
            keyType: null == keyType
                ? _value.keyType
                : keyType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SshKeyMetadataImplCopyWith<$Res>
    implements $SshKeyMetadataCopyWith<$Res> {
  factory _$$SshKeyMetadataImplCopyWith(
    _$SshKeyMetadataImpl value,
    $Res Function(_$SshKeyMetadataImpl) then,
  ) = __$$SshKeyMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String privateKey,
    String publicKey,
    String? passphrase,
    String keyType,
  });
}

/// @nodoc
class __$$SshKeyMetadataImplCopyWithImpl<$Res>
    extends _$SshKeyMetadataCopyWithImpl<$Res, _$SshKeyMetadataImpl>
    implements _$$SshKeyMetadataImplCopyWith<$Res> {
  __$$SshKeyMetadataImplCopyWithImpl(
    _$SshKeyMetadataImpl _value,
    $Res Function(_$SshKeyMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SshKeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? privateKey = null,
    Object? publicKey = null,
    Object? passphrase = freezed,
    Object? keyType = null,
  }) {
    return _then(
      _$SshKeyMetadataImpl(
        privateKey: null == privateKey
            ? _value.privateKey
            : privateKey // ignore: cast_nullable_to_non_nullable
                  as String,
        publicKey: null == publicKey
            ? _value.publicKey
            : publicKey // ignore: cast_nullable_to_non_nullable
                  as String,
        passphrase: freezed == passphrase
            ? _value.passphrase
            : passphrase // ignore: cast_nullable_to_non_nullable
                  as String?,
        keyType: null == keyType
            ? _value.keyType
            : keyType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SshKeyMetadataImpl implements _SshKeyMetadata {
  const _$SshKeyMetadataImpl({
    required this.privateKey,
    required this.publicKey,
    this.passphrase,
    this.keyType = 'Ed25519',
  });

  factory _$SshKeyMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SshKeyMetadataImplFromJson(json);

  @override
  final String privateKey;
  // stored encrypted
  @override
  final String publicKey;
  // stored encrypted
  @override
  final String? passphrase;
  // stored encrypted
  @override
  @JsonKey()
  final String keyType;

  @override
  String toString() {
    return 'SshKeyMetadata(privateKey: $privateKey, publicKey: $publicKey, passphrase: $passphrase, keyType: $keyType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SshKeyMetadataImpl &&
            (identical(other.privateKey, privateKey) ||
                other.privateKey == privateKey) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.passphrase, passphrase) ||
                other.passphrase == passphrase) &&
            (identical(other.keyType, keyType) || other.keyType == keyType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, privateKey, publicKey, passphrase, keyType);

  /// Create a copy of SshKeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SshKeyMetadataImplCopyWith<_$SshKeyMetadataImpl> get copyWith =>
      __$$SshKeyMetadataImplCopyWithImpl<_$SshKeyMetadataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SshKeyMetadataImplToJson(this);
  }
}

abstract class _SshKeyMetadata implements SshKeyMetadata {
  const factory _SshKeyMetadata({
    required final String privateKey,
    required final String publicKey,
    final String? passphrase,
    final String keyType,
  }) = _$SshKeyMetadataImpl;

  factory _SshKeyMetadata.fromJson(Map<String, dynamic> json) =
      _$SshKeyMetadataImpl.fromJson;

  @override
  String get privateKey; // stored encrypted
  @override
  String get publicKey; // stored encrypted
  @override
  String? get passphrase; // stored encrypted
  @override
  String get keyType;

  /// Create a copy of SshKeyMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SshKeyMetadataImplCopyWith<_$SshKeyMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Credential _$CredentialFromJson(Map<String, dynamic> json) {
  return _Credential.fromJson(json);
}

/// @nodoc
mixin _$Credential {
  String get id => throw _privateConstructorUsedError;
  CredentialType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get password =>
      throw _privateConstructorUsedError; // stored encrypted; holds passkey private key handle too
  String? get website => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError; // stored encrypted
  List<CustomField> get customFields => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get folderId => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  bool get isDoubleEncrypted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Present only when [type] == [CredentialType.passkey]
  PasskeyMetadata? get passkeyMetadata => throw _privateConstructorUsedError;

  /// Present only when [type] == [CredentialType.sshKey]
  SshKeyMetadata? get sshKeyMetadata => throw _privateConstructorUsedError;

  /// Rotation reminder interval: 'none', 'monthly', 'quarterly',
  /// 'semiAnnually', or 'custom'.
  String get rotationInterval => throw _privateConstructorUsedError;

  /// Custom rotation period in days (used when rotationInterval == 'custom').
  int? get customRotationDays => throw _privateConstructorUsedError;

  /// Last time a rotation notification was shown for this credential.
  DateTime? get lastRotationPromptedAt => throw _privateConstructorUsedError;

  /// Serializes this Credential to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredentialCopyWith<Credential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialCopyWith<$Res> {
  factory $CredentialCopyWith(
    Credential value,
    $Res Function(Credential) then,
  ) = _$CredentialCopyWithImpl<$Res, Credential>;
  @useResult
  $Res call({
    String id,
    CredentialType type,
    String title,
    String? username,
    String? password,
    String? website,
    String? notes,
    List<CustomField> customFields,
    String? categoryId,
    String? folderId,
    bool isFavorite,
    bool isDoubleEncrypted,
    DateTime createdAt,
    DateTime updatedAt,
    PasskeyMetadata? passkeyMetadata,
    SshKeyMetadata? sshKeyMetadata,
    String rotationInterval,
    int? customRotationDays,
    DateTime? lastRotationPromptedAt,
  });

  $PasskeyMetadataCopyWith<$Res>? get passkeyMetadata;
  $SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata;
}

/// @nodoc
class _$CredentialCopyWithImpl<$Res, $Val extends Credential>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? customFields = null,
    Object? categoryId = freezed,
    Object? folderId = freezed,
    Object? isFavorite = null,
    Object? isDoubleEncrypted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? passkeyMetadata = freezed,
    Object? sshKeyMetadata = freezed,
    Object? rotationInterval = null,
    Object? customRotationDays = freezed,
    Object? lastRotationPromptedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CredentialType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            customFields: null == customFields
                ? _value.customFields
                : customFields // ignore: cast_nullable_to_non_nullable
                      as List<CustomField>,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            folderId: freezed == folderId
                ? _value.folderId
                : folderId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDoubleEncrypted: null == isDoubleEncrypted
                ? _value.isDoubleEncrypted
                : isDoubleEncrypted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            passkeyMetadata: freezed == passkeyMetadata
                ? _value.passkeyMetadata
                : passkeyMetadata // ignore: cast_nullable_to_non_nullable
                      as PasskeyMetadata?,
            sshKeyMetadata: freezed == sshKeyMetadata
                ? _value.sshKeyMetadata
                : sshKeyMetadata // ignore: cast_nullable_to_non_nullable
                      as SshKeyMetadata?,
            rotationInterval: null == rotationInterval
                ? _value.rotationInterval
                : rotationInterval // ignore: cast_nullable_to_non_nullable
                      as String,
            customRotationDays: freezed == customRotationDays
                ? _value.customRotationDays
                : customRotationDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            lastRotationPromptedAt: freezed == lastRotationPromptedAt
                ? _value.lastRotationPromptedAt
                : lastRotationPromptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PasskeyMetadataCopyWith<$Res>? get passkeyMetadata {
    if (_value.passkeyMetadata == null) {
      return null;
    }

    return $PasskeyMetadataCopyWith<$Res>(_value.passkeyMetadata!, (value) {
      return _then(_value.copyWith(passkeyMetadata: value) as $Val);
    });
  }

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata {
    if (_value.sshKeyMetadata == null) {
      return null;
    }

    return $SshKeyMetadataCopyWith<$Res>(_value.sshKeyMetadata!, (value) {
      return _then(_value.copyWith(sshKeyMetadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialImplCopyWith<$Res>
    implements $CredentialCopyWith<$Res> {
  factory _$$CredentialImplCopyWith(
    _$CredentialImpl value,
    $Res Function(_$CredentialImpl) then,
  ) = __$$CredentialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    CredentialType type,
    String title,
    String? username,
    String? password,
    String? website,
    String? notes,
    List<CustomField> customFields,
    String? categoryId,
    String? folderId,
    bool isFavorite,
    bool isDoubleEncrypted,
    DateTime createdAt,
    DateTime updatedAt,
    PasskeyMetadata? passkeyMetadata,
    SshKeyMetadata? sshKeyMetadata,
    String rotationInterval,
    int? customRotationDays,
    DateTime? lastRotationPromptedAt,
  });

  @override
  $PasskeyMetadataCopyWith<$Res>? get passkeyMetadata;
  @override
  $SshKeyMetadataCopyWith<$Res>? get sshKeyMetadata;
}

/// @nodoc
class __$$CredentialImplCopyWithImpl<$Res>
    extends _$CredentialCopyWithImpl<$Res, _$CredentialImpl>
    implements _$$CredentialImplCopyWith<$Res> {
  __$$CredentialImplCopyWithImpl(
    _$CredentialImpl _value,
    $Res Function(_$CredentialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? customFields = null,
    Object? categoryId = freezed,
    Object? folderId = freezed,
    Object? isFavorite = null,
    Object? isDoubleEncrypted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? passkeyMetadata = freezed,
    Object? sshKeyMetadata = freezed,
    Object? rotationInterval = null,
    Object? customRotationDays = freezed,
    Object? lastRotationPromptedAt = freezed,
  }) {
    return _then(
      _$CredentialImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CredentialType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        customFields: null == customFields
            ? _value._customFields
            : customFields // ignore: cast_nullable_to_non_nullable
                  as List<CustomField>,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        folderId: freezed == folderId
            ? _value.folderId
            : folderId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDoubleEncrypted: null == isDoubleEncrypted
            ? _value.isDoubleEncrypted
            : isDoubleEncrypted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        passkeyMetadata: freezed == passkeyMetadata
            ? _value.passkeyMetadata
            : passkeyMetadata // ignore: cast_nullable_to_non_nullable
                  as PasskeyMetadata?,
        sshKeyMetadata: freezed == sshKeyMetadata
            ? _value.sshKeyMetadata
            : sshKeyMetadata // ignore: cast_nullable_to_non_nullable
                  as SshKeyMetadata?,
        rotationInterval: null == rotationInterval
            ? _value.rotationInterval
            : rotationInterval // ignore: cast_nullable_to_non_nullable
                  as String,
        customRotationDays: freezed == customRotationDays
            ? _value.customRotationDays
            : customRotationDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        lastRotationPromptedAt: freezed == lastRotationPromptedAt
            ? _value.lastRotationPromptedAt
            : lastRotationPromptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialImpl implements _Credential {
  const _$CredentialImpl({
    required this.id,
    required this.type,
    required this.title,
    this.username,
    this.password,
    this.website,
    this.notes,
    final List<CustomField> customFields = const [],
    this.categoryId,
    this.folderId,
    this.isFavorite = false,
    this.isDoubleEncrypted = false,
    required this.createdAt,
    required this.updatedAt,
    this.passkeyMetadata,
    this.sshKeyMetadata,
    this.rotationInterval = 'none',
    this.customRotationDays,
    this.lastRotationPromptedAt,
  }) : _customFields = customFields;

  factory _$CredentialImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialImplFromJson(json);

  @override
  final String id;
  @override
  final CredentialType type;
  @override
  final String title;
  @override
  final String? username;
  @override
  final String? password;
  // stored encrypted; holds passkey private key handle too
  @override
  final String? website;
  @override
  final String? notes;
  // stored encrypted
  final List<CustomField> _customFields;
  // stored encrypted
  @override
  @JsonKey()
  List<CustomField> get customFields {
    if (_customFields is EqualUnmodifiableListView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customFields);
  }

  @override
  final String? categoryId;
  @override
  final String? folderId;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final bool isDoubleEncrypted;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Present only when [type] == [CredentialType.passkey]
  @override
  final PasskeyMetadata? passkeyMetadata;

  /// Present only when [type] == [CredentialType.sshKey]
  @override
  final SshKeyMetadata? sshKeyMetadata;

  /// Rotation reminder interval: 'none', 'monthly', 'quarterly',
  /// 'semiAnnually', or 'custom'.
  @override
  @JsonKey()
  final String rotationInterval;

  /// Custom rotation period in days (used when rotationInterval == 'custom').
  @override
  final int? customRotationDays;

  /// Last time a rotation notification was shown for this credential.
  @override
  final DateTime? lastRotationPromptedAt;

  @override
  String toString() {
    return 'Credential(id: $id, type: $type, title: $title, username: $username, password: $password, website: $website, notes: $notes, customFields: $customFields, categoryId: $categoryId, folderId: $folderId, isFavorite: $isFavorite, isDoubleEncrypted: $isDoubleEncrypted, createdAt: $createdAt, updatedAt: $updatedAt, passkeyMetadata: $passkeyMetadata, sshKeyMetadata: $sshKeyMetadata, rotationInterval: $rotationInterval, customRotationDays: $customRotationDays, lastRotationPromptedAt: $lastRotationPromptedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._customFields,
              _customFields,
            ) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isDoubleEncrypted, isDoubleEncrypted) ||
                other.isDoubleEncrypted == isDoubleEncrypted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.passkeyMetadata, passkeyMetadata) ||
                other.passkeyMetadata == passkeyMetadata) &&
            (identical(other.sshKeyMetadata, sshKeyMetadata) ||
                other.sshKeyMetadata == sshKeyMetadata) &&
            (identical(other.rotationInterval, rotationInterval) ||
                other.rotationInterval == rotationInterval) &&
            (identical(other.customRotationDays, customRotationDays) ||
                other.customRotationDays == customRotationDays) &&
            (identical(other.lastRotationPromptedAt, lastRotationPromptedAt) ||
                other.lastRotationPromptedAt == lastRotationPromptedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    title,
    username,
    password,
    website,
    notes,
    const DeepCollectionEquality().hash(_customFields),
    categoryId,
    folderId,
    isFavorite,
    isDoubleEncrypted,
    createdAt,
    updatedAt,
    passkeyMetadata,
    sshKeyMetadata,
    rotationInterval,
    customRotationDays,
    lastRotationPromptedAt,
  ]);

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialImplCopyWith<_$CredentialImpl> get copyWith =>
      __$$CredentialImplCopyWithImpl<_$CredentialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialImplToJson(this);
  }
}

abstract class _Credential implements Credential {
  const factory _Credential({
    required final String id,
    required final CredentialType type,
    required final String title,
    final String? username,
    final String? password,
    final String? website,
    final String? notes,
    final List<CustomField> customFields,
    final String? categoryId,
    final String? folderId,
    final bool isFavorite,
    final bool isDoubleEncrypted,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final PasskeyMetadata? passkeyMetadata,
    final SshKeyMetadata? sshKeyMetadata,
    final String rotationInterval,
    final int? customRotationDays,
    final DateTime? lastRotationPromptedAt,
  }) = _$CredentialImpl;

  factory _Credential.fromJson(Map<String, dynamic> json) =
      _$CredentialImpl.fromJson;

  @override
  String get id;
  @override
  CredentialType get type;
  @override
  String get title;
  @override
  String? get username;
  @override
  String? get password; // stored encrypted; holds passkey private key handle too
  @override
  String? get website;
  @override
  String? get notes; // stored encrypted
  @override
  List<CustomField> get customFields;
  @override
  String? get categoryId;
  @override
  String? get folderId;
  @override
  bool get isFavorite;
  @override
  bool get isDoubleEncrypted;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Present only when [type] == [CredentialType.passkey]
  @override
  PasskeyMetadata? get passkeyMetadata;

  /// Present only when [type] == [CredentialType.sshKey]
  @override
  SshKeyMetadata? get sshKeyMetadata;

  /// Rotation reminder interval: 'none', 'monthly', 'quarterly',
  /// 'semiAnnually', or 'custom'.
  @override
  String get rotationInterval;

  /// Custom rotation period in days (used when rotationInterval == 'custom').
  @override
  int? get customRotationDays;

  /// Last time a rotation notification was shown for this credential.
  @override
  DateTime? get lastRotationPromptedAt;

  /// Create a copy of Credential
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialImplCopyWith<_$CredentialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
