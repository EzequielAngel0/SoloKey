// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VaultSession _$VaultSessionFromJson(Map<String, dynamic> json) =>
    _VaultSession(
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$VaultSessionToJson(_VaultSession instance) =>
    <String, dynamic>{
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
