import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../domain/entities/credential.dart';

/// Sensitive fields serialised to JSON before encryption.
/// Only this payload gets AES-256-GCM encrypted.
class CredentialSensitivePayload {
  const CredentialSensitivePayload({
    this.username,
    this.password,
    this.website,
    this.notes,
    required this.customFields,
    this.passkeyMetadata,
    this.sshKeyMetadata,
  });

  final String? username;
  final String? password;
  final String? website;
  final String? notes;
  final List<Map<String, dynamic>> customFields;
  final PasskeyMetadata? passkeyMetadata;
  final SshKeyMetadata? sshKeyMetadata;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'website': website,
        'notes': notes,
        'customFields': customFields,
        'passkeyMetadata': passkeyMetadata?.toJson(),
        'sshKeyMetadata': sshKeyMetadata?.toJson(),
      };

  factory CredentialSensitivePayload.fromJson(Map<String, dynamic> json) =>
      CredentialSensitivePayload(
        username: json['username'] as String?,
        password: json['password'] as String?,
        website: json['website'] as String?,
        notes: json['notes'] as String?,
        customFields: (json['customFields'] as List<dynamic>)
            .cast<Map<String, dynamic>>(),
        passkeyMetadata: json['passkeyMetadata'] != null
            ? PasskeyMetadata.fromJson(json['passkeyMetadata'] as Map<String, dynamic>)
            : null,
        sshKeyMetadata: json['sshKeyMetadata'] != null
            ? SshKeyMetadata.fromJson(json['sshKeyMetadata'] as Map<String, dynamic>)
            : null,
      );

  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  factory CredentialSensitivePayload.fromBytes(Uint8List bytes) =>
      CredentialSensitivePayload.fromJson(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
      );
}

/// Maps between [Credential] domain entity and [CredentialEntriesCompanion] (Drift).
abstract final class CredentialDto {
  static CredentialEntriesCompanion toCompanion({
    required Credential credential,
    required Uint8List encryptedPayload,
  }) =>
      CredentialEntriesCompanion(
        id: Value(credential.id),
        title: Value(credential.title),
        type: Value(credential.type.name),
        categoryId: Value(credential.categoryId),
        isFavorite: Value(credential.isFavorite),
        isDoubleEncrypted: Value(credential.isDoubleEncrypted),
        encryptedPayload: Value(encryptedPayload),
        createdAt: Value(credential.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(credential.updatedAt.millisecondsSinceEpoch),
      );

  static Credential fromEntry({
    required CredentialEntry entry,
    required CredentialSensitivePayload payload,
  }) =>
      Credential(
        id: entry.id,
        type: CredentialType.values.byName(entry.type),
        title: entry.title,
        username: payload.username,
        password: payload.password,
        website: payload.website,
        notes: payload.notes,
        customFields: payload.customFields
            .map(
              (f) => CustomField(
                label: f['label'] as String,
                value: f['value'] as String,
                isSecret: f['isSecret'] as bool? ?? false,
              ),
            )
            .toList(),
        categoryId: entry.categoryId,
        isFavorite: entry.isFavorite,
        isDoubleEncrypted: entry.isDoubleEncrypted,
        createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAt),
        passkeyMetadata: payload.passkeyMetadata,
        sshKeyMetadata: payload.sshKeyMetadata,
      );

  static CredentialSensitivePayload toPayload(Credential c) =>
      CredentialSensitivePayload(
        username: c.username,
        password: c.password,
        website: c.website,
        notes: c.notes,
        customFields: c.customFields
            .map((f) => {
                  'label': f.label,
                  'value': f.value,
                  'isSecret': f.isSecret,
                })
            .toList(),
        passkeyMetadata: c.passkeyMetadata,
        sshKeyMetadata: c.sshKeyMetadata,
      );

  static String newId() => const Uuid().v4();
}
