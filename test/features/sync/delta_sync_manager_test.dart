import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/sync/infrastructure/delta_sync_manager.dart';

void main() {
  group('resolveSyncConflict (Last-Write-Wins)', () {
    test('newer remote timestamp wins', () {
      expect(
        resolveSyncConflict(
            localUpdatedAt: 100,
            remoteUpdatedAt: 200,
            localId: 'a',
            remoteId: 'b'),
        SyncConflictWinner.remote,
      );
    });

    test('newer local timestamp wins', () {
      expect(
        resolveSyncConflict(
            localUpdatedAt: 300,
            remoteUpdatedAt: 200,
            localId: 'a',
            remoteId: 'b'),
        SyncConflictWinner.local,
      );
    });

    test('tie breaks toward the lexicographically smaller id', () {
      expect(
        resolveSyncConflict(
            localUpdatedAt: 100,
            remoteUpdatedAt: 100,
            localId: 'aaa',
            remoteId: 'bbb'),
        SyncConflictWinner.local,
      );
      expect(
        resolveSyncConflict(
            localUpdatedAt: 100,
            remoteUpdatedAt: 100,
            localId: 'zzz',
            remoteId: 'bbb'),
        SyncConflictWinner.remote,
      );
    });

    test('equal timestamp and equal id resolves deterministically to local', () {
      expect(
        resolveSyncConflict(
            localUpdatedAt: 100,
            remoteUpdatedAt: 100,
            localId: 'x',
            remoteId: 'x'),
        SyncConflictWinner.local,
      );
    });

    test('both devices independently keep the SAME row on a tie', () {
      // Device A: its local row is cred1, the remote is cred2 (same timestamp).
      final aWinner = resolveSyncConflict(
          localUpdatedAt: 100,
          remoteUpdatedAt: 100,
          localId: 'cred1',
          remoteId: 'cred2');
      // Device B sees the mirror image (its local is cred2).
      final bWinner = resolveSyncConflict(
          localUpdatedAt: 100,
          remoteUpdatedAt: 100,
          localId: 'cred2',
          remoteId: 'cred1');
      // A keeps its local (cred1); B keeps the remote (cred1) → both end on cred1.
      expect(aWinner, SyncConflictWinner.local);
      expect(bWinner, SyncConflictWinner.remote);
    });
  });

  group('SyncManifestItem serialization', () {
    test('round-trips with full row data', () {
      const item = SyncManifestItem(
        id: 'cred1',
        updatedAt: 123,
        isDeleted: false,
        rowData: {'title': 'X'},
      );
      final back = SyncManifestItem.fromJson(item.toJson());
      expect(back.id, 'cred1');
      expect(back.updatedAt, 123);
      expect(back.isDeleted, isFalse);
      expect(back.rowData, {'title': 'X'});
    });

    test('omits row_data when null (manifest-only handshake)', () {
      const item = SyncManifestItem(id: 'c', updatedAt: 1, isDeleted: false);
      expect(item.toJson().containsKey('row_data'), isFalse);
    });

    test('isDeleted defaults to false and rowData to null when absent', () {
      final back = SyncManifestItem.fromJson({'id': 'c', 'updated_at': 1});
      expect(back.isDeleted, isFalse);
      expect(back.rowData, isNull);
    });
  });
}
