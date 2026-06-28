import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';
part 'credential.g.dart';

enum CredentialType {
  password,
  apiKey,
  secureNote,
  totp,
  /// FIDO2 / WebAuthn Passkey
  passkey,
  /// SSH Key Pair
  sshKey,
}

@freezed
class CustomField with _$CustomField {
  const factory CustomField({
    required String label,
    required String value, // stored encrypted
    @Default(false) bool isSecret,
  }) = _CustomField;

  factory CustomField.fromJson(Map<String, dynamic> json) =>
      _$CustomFieldFromJson(json);
}

/// Non-secret metadata for a FIDO2 Passkey.
///
/// The actual private key handle is stored encrypted inside the standard
/// [Credential.password] field to reuse the existing AES-256-GCM pipeline.
@freezed
class PasskeyMetadata with _$PasskeyMetadata {
  const factory PasskeyMetadata({
    /// Relying Party identifier, e.g. "example.com"
    required String rpId,

    /// Relying Party display name, e.g. "Example Inc."
    String? rpName,

    /// Base64url-encoded credential ID (the public identifier).
    required String credentialId,

    /// AAGUID of the authenticator (identifies the passkey provider).
    String? aaguid,

    /// Username / display name used at registration time.
    String? userDisplayName,

    /// Whether the passkey requires user verification (biometric/PIN).
    @Default(true) bool userVerificationRequired,
  }) = _PasskeyMetadata;

  factory PasskeyMetadata.fromJson(Map<String, dynamic> json) =>
      _$PasskeyMetadataFromJson(json);
}

/// Metadata and keys for an SSH Key.
@freezed
class SshKeyMetadata with _$SshKeyMetadata {
  const factory SshKeyMetadata({
    required String privateKey, // stored encrypted
    required String publicKey,  // stored encrypted
    String? passphrase,         // stored encrypted
    @Default('Ed25519') String keyType,
  }) = _SshKeyMetadata;

  factory SshKeyMetadata.fromJson(Map<String, dynamic> json) =>
      _$SshKeyMetadataFromJson(json);
}

@freezed
class Credential with _$Credential {
  const factory Credential({
    required String id,
    required CredentialType type,
    required String title,
    String? username,
    String? password, // stored encrypted; holds passkey private key handle too
    String? website,
    String? notes, // stored encrypted
    @Default([]) List<CustomField> customFields,
    String? categoryId,
    String? folderId,
    @Default(false) bool isFavorite,
    @Default(false) bool isDoubleEncrypted,
    /// Hidden/archived: kept out of the main list (shown in the "Ocultas" view).
    @Default(false) bool isHidden,
    /// Manual sort order for the main list (ascending; lower = higher up).
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    /// Present only when [type] == [CredentialType.passkey]
    PasskeyMetadata? passkeyMetadata,
    /// Present only when [type] == [CredentialType.sshKey]
    SshKeyMetadata? sshKeyMetadata,
    /// Rotation reminder interval: 'none', 'monthly', 'quarterly',
    /// 'semiAnnually', or 'custom'.
    @Default('none') String rotationInterval,
    /// Custom rotation period in days (used when rotationInterval == 'custom').
    int? customRotationDays,
    /// Last time a rotation notification was shown for this credential.
    DateTime? lastRotationPromptedAt,
  }) = _Credential;

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);
}
