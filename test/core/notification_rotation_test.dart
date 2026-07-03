import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/database/app_database.dart';
import 'package:password_manager/core/services/notification_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/infrastructure/credential_dto.dart';

/// `findDueRotations` reads ONLY plain columns and takes an injected [now], so
/// it's fully deterministic here — no wall clock, no decryption.
void main() {
  group('rotationDaysForInterval', () {
    test('maps named intervals to day thresholds', () {
      expect(rotationDaysForInterval('monthly', null), 30);
      expect(rotationDaysForInterval('quarterly', null), 90);
      expect(rotationDaysForInterval('semiAnnually', null), 180);
    });

    test('custom uses customDays, defaulting to 30 when null', () {
      expect(rotationDaysForInterval('custom', 7), 7);
      expect(rotationDaysForInterval('custom', null), 30);
    });

    test('unknown / none interval yields 0 (never due)', () {
      expect(rotationDaysForInterval('none', null), 0);
      expect(rotationDaysForInterval('weekly', null), 0);
    });
  });

  group('findDueRotations', () {
    late AppDatabase db;
    final now = DateTime(2026, 6, 1, 12);

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() async => db.close());

    Future<void> putCred({
      required String id,
      required String interval,
      int? customDays,
      required DateTime updatedAt,
      DateTime? lastPrompted,
    }) {
      final c = Credential(
        id: id,
        type: CredentialType.password,
        title: 'cred-$id',
        createdAt: DateTime(2020),
        updatedAt: updatedAt,
        rotationInterval: interval,
        customRotationDays: customDays,
        lastRotationPromptedAt: lastPrompted,
      );
      return db.credentialDao.upsert(
        CredentialDto.toCompanion(credential: c, encryptedPayload: Uint8List(0)),
      );
    }

    test('interval "none" is never due', () async {
      await putCred(
        id: 'a',
        interval: 'none',
        updatedAt: now.subtract(const Duration(days: 999)),
      );
      expect(await findDueRotations(db, now: now), isEmpty);
    });

    test('overdue credential is reported with correct daysOverdue', () async {
      await putCred(
        id: 'a',
        interval: 'monthly', // 30d
        updatedAt: now.subtract(const Duration(days: 40)),
      );
      final due = await findDueRotations(db, now: now);
      expect(due.map((d) => d.id), ['a']);
      expect(due.single.daysOverdue, 10); // 40 - 30
    });

    test('credential still inside its window is not due', () async {
      await putCred(
        id: 'a',
        interval: 'monthly',
        updatedAt: now.subtract(const Duration(days: 20)),
      );
      expect(await findDueRotations(db, now: now), isEmpty);
    });

    test('recently prompted (<24h) is suppressed by the cooldown', () async {
      await putCred(
        id: 'a',
        interval: 'monthly',
        updatedAt: now.subtract(const Duration(days: 40)),
        lastPrompted: now.subtract(const Duration(hours: 12)),
      );
      expect(await findDueRotations(db, now: now), isEmpty);
    });

    test('prompted more than 24h ago is due again', () async {
      await putCred(
        id: 'a',
        interval: 'monthly',
        updatedAt: now.subtract(const Duration(days: 40)),
        lastPrompted: now.subtract(const Duration(hours: 48)),
      );
      expect((await findDueRotations(db, now: now)).map((d) => d.id), ['a']);
    });

    test('custom interval honours customRotationDays', () async {
      await putCred(
        id: 'a',
        interval: 'custom',
        customDays: 7,
        updatedAt: now.subtract(const Duration(days: 10)),
      );
      expect((await findDueRotations(db, now: now)).map((d) => d.id), ['a']);
    });

    test('mixes due and not-due across several credentials', () async {
      await putCred(
        id: 'due',
        interval: 'quarterly', // 90d
        updatedAt: now.subtract(const Duration(days: 100)),
      );
      await putCred(
        id: 'fresh',
        interval: 'quarterly',
        updatedAt: now.subtract(const Duration(days: 80)),
      );
      await putCred(
        id: 'ignored',
        interval: 'none',
        updatedAt: now.subtract(const Duration(days: 500)),
      );
      final ids = (await findDueRotations(db, now: now)).map((d) => d.id);
      expect(ids, ['due']);
    });
  });

  group('showSyncCompleted', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() async => db.close());

    test('no-op for a non-positive change count (never hits the platform)',
        () async {
      final service = NotificationService(db);
      // count <= 0 returns before initialize()/plugin, so this must not throw
      // even without any platform notification channel registered.
      await expectLater(service.showSyncCompleted(0), completes);
      await expectLater(service.showSyncCompleted(-3), completes);
    });
  });
}
