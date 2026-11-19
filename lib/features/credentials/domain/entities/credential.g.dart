// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomField _$CustomFieldFromJson(Map<String, dynamic> json) => _CustomField(
  label: json['label'] as String,
  value: json['value'] as String,
  isSecret: json['isSecret'] as bool? ?? false,
);

Map<String, dynamic> _$CustomFieldToJson(_CustomField instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'isSecret': instance.isSecret,
    };

_PasskeyMetadata _$PasskeyMetadataFromJson(Map<String, dynamic> json) =>
    _PasskeyMetadata(
      rpId: json['rpId'] as String,
      rpName: json['rpName'] as String?,
      credentialId: json['credentialId'] as String,
      aaguid: json['aaguid'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
      userVerificationRequired:
          json['userVerificationRequired'] as bool? ?? true,
    );

Map<String, dynamic> _$PasskeyMetadataToJson(_PasskeyMetadata instance) =>
    <String, dynamic>{
      'rpId': instance.rpId,
      'rpName': instance.rpName,
      'credentialId': instance.credentialId,
      'aaguid': instance.aaguid,
      'userDisplayName': instance.userDisplayName,
      'userVerificationRequired': instance.userVerificationRequired,
    };

_SshKeyMetadata _$SshKeyMetadataFromJson(Map<String, dynamic> json) =>
    _SshKeyMetadata(
      privateKey: json['privateKey'] as String,
      publicKey: json['publicKey'] as String,
      passphrase: json['passphrase'] as String?,
      keyType: json['keyType'] as String? ?? 'Ed25519',
    );

Map<String, dynamic> _$SshKeyMetadataToJson(_SshKeyMetadata instance) =>
    <String, dynamic>{
      'privateKey': instance.privateKey,
      'publicKey': instance.publicKey,
      'passphrase': instance.passphrase,
      'keyType': instance.keyType,
    };

_Credential _$CredentialFromJson(Map<String, dynamic> json) => _Credential(
  id: json['id'] as String,
  type: $enumDecode(_$CredentialTypeEnumMap, json['type']),
  title: json['title'] as String,
  username: json['username'] as String?,
  password: json['password'] as String?,
  website: json['website'] as String?,
  notes: json['notes'] as String?,
  customFields:
      (json['customFields'] as List<dynamic>?)
          ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categoryId: json['categoryId'] as String?,
  folderId: json['folderId'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  isDoubleEncrypted: json['isDoubleEncrypted'] as bool? ?? false,
  isHidden: json['isHidden'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  passkeyMetadata: json['passkeyMetadata'] == null
      ? null
      : PasskeyMetadata.fromJson(
          json['passkeyMetadata'] as Map<String, dynamic>,
        ),
  sshKeyMetadata: json['sshKeyMetadata'] == null
      ? null
      : SshKeyMetadata.fromJson(json['sshKeyMetadata'] as Map<String, dynamic>),
  rotationInterval: json['rotationInterval'] as String? ?? 'none',
  customRotationDays: (json['customRotationDays'] as num?)?.toInt(),
  lastRotationPromptedAt: json['lastRotationPromptedAt'] == null
      ? null
      : DateTime.parse(json['lastRotationPromptedAt'] as String),
);

Map<String, dynamic> _$CredentialToJson(
  _Credential instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$CredentialTypeEnumMap[instance.type]!,
  'title': instance.title,
  'username': instance.username,
  'password': instance.password,
  'website': instance.website,
  'notes': instance.notes,
  'customFields': instance.customFields,
  'categoryId': instance.categoryId,
  'folderId': instance.folderId,
  'isFavorite': instance.isFavorite,
  'isDoubleEncrypted': instance.isDoubleEncrypted,
  'isHidden': instance.isHidden,
  'sortOrder': instance.sortOrder,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'passkeyMetadata': instance.passkeyMetadata,
  'sshKeyMetadata': instance.sshKeyMetadata,
  'rotationInterval': instance.rotationInterval,
  'customRotationDays': instance.customRotationDays,
  'lastRotationPromptedAt': instance.lastRotationPromptedAt?.toIso8601String(),
};

const _$CredentialTypeEnumMap = {
  CredentialType.password: 'password',
  CredentialType.apiKey: 'apiKey',
  CredentialType.secureNote: 'secureNote',
  CredentialType.totp: 'totp',
  CredentialType.passkey: 'passkey',
  CredentialType.sshKey: 'sshKey',
};
