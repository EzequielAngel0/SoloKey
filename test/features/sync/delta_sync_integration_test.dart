import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/database/app_database.dart';
import 'package:password_manager/core/infrastructure/security/i_security_service.dart';
import 'package:password_manager/core/infrastructure/security/session_manager.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/infrastructure/credential_dto.dart';
import 'package:password_manager/features/sync/domain/sync_summary.dart';
import 'package:password_manager/features/sync/infrastructure/delta_sync_manager.dart';

/// Identity "crypto": exercises the sync data path deterministically without the
/// real Argon2id/AES isolates. encrypt/decrypt are pass-through.
class _IdentitySecurity implements ISecurityService {
  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List keyBytes) async =>
      Uint8List.fromList(plaintext);
  @override
  Future<Uint8List> decrypt(Uint8List cipherBlob, Uint8List keyBytes) async =>
      Uint8List.fromList(cipherBlob);
  @override
  Future<Uint8List> sha256(Uint8List data) async => Uint8List.fromList(data);
  @override
  Future<Uint8List> deriveKey(
          {required String password,
          required String saltBase64,
          required int memory,
          required int iterations,
          required int parallelism}) =>
      throw UnimplementedError();
  @override
  Future<String> generateSaltBase64() => throw UnimplementedError();
  @override
  Future<String> createVerificationData(Uint8List keyBytes) =>
      throw UnimplementedError();
  @override
  Future<bool> verifyKey(Uint8List keyBytes, String verificationData) =>
      throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late DeltaSyncManager mgr;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final session = SessionManager()..storeKey(Uint8List(32));
    mgr = DeltaSyncManager(db, _IdentitySecurity(), session);
  });

  tearDown(() async => db.close());

  Future<void> putFolder(String id, int createdAt, {String name = 'F'}) =>
      db.folderDao.upsert(FolderEntriesCompanion.insert(
        id: id,
        name: name,
        createdAt: createdAt,
      ));

  Future<void> putCredential(String id, int updatedAt,
      {String? categoryId}) async {
    final c = Credential(
      id: id,
      type: CredentialType.password,
      title: 'cred-$id',
      password: 'secret-$id',
      categoryId: categoryId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
    final payload = CredentialDto.toPayload(c);
    await db.credentialDao.upsert(
      CredentialDto.toCompanion(credential: c, encryptedPayload: payload.toBytes()),
    );
  }

  group('DeltaSyncManager folder deltas (real in-memory DB)', () {
    test('requests newer/remote-only folders and pushes local-only ones',
        () async {
      await putFolder('A', 100); // remote will be newer
      await putFolder('C', 300); // only local → push

      final remote = [
        const SyncManifestItem(id: 'A', updatedAt: 200, isDeleted: false),
        const SyncManifestItem(id: 'B', updatedAt: 50, isDeleted: false),
      ];

      final delta = await mgr.computeFolderDeltas(remote);

      expect(delta.toRequest, containsAll(<String>['A', 'B']));
      expect(delta.toRequest, isNot(contains('C')));
      expect(delta.toPush.map((i) => i.id), contains('C'));
    });

    test('applyRemoteFolders upserts received rows', () async {
      const item = SyncManifestItem(
        id: 'X',
        updatedAt: 10,
        isDeleted: false,
        rowData: {
          'id': 'X',
          'parent_id': null,
          'name': 'Imported',
          'icon': 'folder',
          'color_hex': '#6C63FF',
          'is_favorite': false,
          'created_at': 10,
        },
      );
      final applied = await mgr.applyRemoteFolders([item]);
      expect(applied.length, 1);
      expect(applied.single.action, SyncChangeAction.added);
      expect(applied.single.name, 'Imported');
      expect(applied.single.kind, SyncEntityKind.folder);
      final row = await db.folderDao.getById('X');
      expect(row, isNotNull);
      expect(row!.name, 'Imported');
    });

    test('re-applying an existing folder reports it as updated', () async {
      await putFolder('Y', 5, name: 'Original');
      const item = SyncManifestItem(
        id: 'Y',
        updatedAt: 20,
        isDeleted: false,
        rowData: {
          'id': 'Y',
          'parent_id': null,
          'name': 'Renamed',
          'icon': 'folder',
          'color_hex': '#6C63FF',
          'is_favorite': false,
          'created_at': 20,
        },
      );
      final applied = await mgr.applyRemoteFolders([item]);
      expect(applied.single.action, SyncChangeAction.updated);
      expect(applied.single.name, 'Renamed');
    });
  });

  group('DeltaSyncManager credential deltas (real in-memory DB)', () {
    test('LWW: newer remote is requested, newer local is pushed', () async {
      await putCredential('older', 100); // remote newer → request
      await putCredential('newer', 500); // local newer → push

      final remote = [
        const SyncManifestItem(id: 'older', updatedAt: 200, isDeleted: false),
        const SyncManifestItem(id: 'newer', updatedAt: 200, isDeleted: false),
      ];

      final delta = await mgr.computeCredentialDeltas(remote);
      expect(delta.toRequest, contains('older'));
      expect(delta.toPush.map((i) => i.id), contains('newer'));
    });

    test('round-trips a pushed credential back through apply', () async {
      await putCredential('c1', 100, categoryId: 'folderA');
      final pushItem = await mgr.buildCredentialPushItem('c1');
      expect(pushItem, isNotNull);
      expect(pushItem!.rowData!['category_id'], 'folderA');

      // Wipe and re-apply as if received from a peer.
      await db.credentialDao.deleteById('c1');
      final applied = await mgr.applyRemoteCredentials([pushItem]);
      expect(applied.length, 1);
      expect(applied.single.action, SyncChangeAction.added);
      expect(applied.single.name, 'cred-c1');
      expect(applied.single.kind, SyncEntityKind.credential);
      final row = await db.credentialDao.getById('c1');
      expect(row, isNotNull);
      expect(row!.categoryId, 'folderA');
    });

    test('applying an update over an existing credential reports updated',
        () async {
      await putCredential('c2', 100);
      final pushItem = await mgr.buildCredentialPushItem('c2');
      // Row still present → applying again is an update, not an add.
      final applied = await mgr.applyRemoteCredentials([pushItem!]);
      expect(applied.single.action, SyncChangeAction.updated);
    });
  });
}
