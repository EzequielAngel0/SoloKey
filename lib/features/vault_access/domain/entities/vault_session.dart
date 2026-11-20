import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault_session.freezed.dart';
part 'vault_session.g.dart';

@freezed
abstract class VaultSession with _$VaultSession {
  const factory VaultSession({
    required bool isUnlocked,
    required DateTime unlockedAt,
    required DateTime expiresAt,
  }) = _VaultSession;

  const VaultSession._();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isActive => isUnlocked && !isExpired;

  factory VaultSession.fromJson(Map<String, dynamic> json) =>
      _$VaultSessionFromJson(json);

  factory VaultSession.locked() => VaultSession(
        isUnlocked: false,
        unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  factory VaultSession.unlocked({required int autoLockMinutes}) {
    final now = DateTime.now();
    return VaultSession(
      isUnlocked: true,
      unlockedAt: now,
      expiresAt: now.add(Duration(minutes: autoLockMinutes)),
    );
  }
}
