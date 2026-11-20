// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SecureFile _$SecureFileFromJson(Map<String, dynamic> json) => _SecureFile(
  id: json['id'] as String,
  name: json['name'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  storedFileName: json['storedFileName'] as String,
  mimeHint: json['mimeHint'] as String?,
  note: json['note'] as String?,
  folderId: json['folderId'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SecureFileToJson(_SecureFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sizeBytes': instance.sizeBytes,
      'storedFileName': instance.storedFileName,
      'mimeHint': instance.mimeHint,
      'note': instance.note,
      'folderId': instance.folderId,
      'isFavorite': instance.isFavorite,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
