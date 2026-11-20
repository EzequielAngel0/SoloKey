import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../domain/entities/credential.dart';

/// Campos sensibles de una credencial (los mismos nombres que el payload cifrado de la v1).
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
        customFields: ((json['customFields'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>(),
        passkeyMetadata: json['passkeyMetadata'] != null
            ? PasskeyMetadata.fromJson(
                json['passkeyMetadata'] as Map<String, dynamic>)
            : null,
        sshKeyMetadata: json['sshKeyMetadata'] != null
            ? SshKeyMetadata.fromJson(
                json['sshKeyMetadata'] as Map<String, dynamic>)
            : null,
      );

  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  factory CredentialSensitivePayload.fromBytes(Uint8List bytes) =>
      CredentialSensitivePayload.fromJson(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
      );
}

/// [Credential] <-> registro `credential` de la boveda v2: un solo objeto JSON con el payload y los metadatos, con
/// las claves que deja la migracion de la v1 (`migrate_v1.rs`). El nucleo lo cifra entero.
abstract final class CredentialDto {
  static Map<String, dynamic> toRecord(Credential c) => {
        ...toPayload(c).toJson(),
        'id': c.id,
        'type': c.type.name,
        'title': c.title,
        'categoryId': c.categoryId,
        'folderId': c.folderId,
        'isFavorite': c.isFavorite,
        'isDoubleEncrypted': c.isDoubleEncrypted,
        'isHidden': c.isHidden,
        'sortOrder': c.sortOrder,
        'createdAt': c.createdAt.millisecondsSinceEpoch,
        'updatedAt': c.updatedAt.millisecondsSinceEpoch,
        'rotationInterval': c.rotationInterval,
        'customRotationDays': c.customRotationDays,
        'lastRotationPromptedAt': c.lastRotationPromptedAt?.millisecondsSinceEpoch,
      };

  static Credential fromRecord(Map<String, dynamic> m) {
    final payload = CredentialSensitivePayload.fromJson(m);
    DateTime? date(String k) => m[k] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((m[k] as num).toInt());
    return Credential(
      id: m['id'] as String,
      type: CredentialType.values.byName(m['type'] as String),
      title: m['title'] as String? ?? '',
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
      categoryId: m['categoryId'] as String?,
      folderId: m['folderId'] as String?,
      isFavorite: m['isFavorite'] as bool? ?? false,
      isDoubleEncrypted: m['isDoubleEncrypted'] as bool? ?? false,
      isHidden: m['isHidden'] as bool? ?? false,
      sortOrder: (m['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: date('createdAt')!,
      updatedAt: date('updatedAt')!,
      passkeyMetadata: payload.passkeyMetadata,
      sshKeyMetadata: payload.sshKeyMetadata,
      rotationInterval: m['rotationInterval'] as String? ?? 'none',
      customRotationDays: (m['customRotationDays'] as num?)?.toInt(),
      lastRotationPromptedAt: date('lastRotationPromptedAt'),
    );
  }

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
