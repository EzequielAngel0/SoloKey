import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/sync/domain/sync_summary.dart';

void main() {
  SyncItemChange cred(String id, SyncChangeAction a) => SyncItemChange(
        id: id,
        name: 'cred-$id',
        kind: SyncEntityKind.credential,
        action: a,
      );
  SyncItemChange folder(String id, SyncChangeAction a) => SyncItemChange(
        id: id,
        name: 'folder-$id',
        kind: SyncEntityKind.folder,
        action: a,
      );

  group('SyncSummary counters', () {
    test('splits credentials and folders by action', () {
      final s = SyncSummary(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1000),
        changes: [
          cred('a', SyncChangeAction.added),
          cred('b', SyncChangeAction.updated),
          cred('c', SyncChangeAction.deleted),
          folder('f1', SyncChangeAction.added),
          folder('f2', SyncChangeAction.updated),
        ],
      );
      expect(s.total, 5);
      expect(s.isNotEmpty, isTrue);
      expect(s.credentialsAdded, 1);
      expect(s.credentialsUpdated, 1);
      expect(s.credentialsDeleted, 1);
      expect(s.credentialsTotal, 3);
      expect(s.foldersAdded, 1);
      expect(s.foldersUpdated, 1);
      expect(s.foldersTotal, 2);
    });

    test('empty summary reports isEmpty', () {
      final s = SyncSummary.empty();
      expect(s.isEmpty, isTrue);
      expect(s.total, 0);
    });
  });

  group('SyncSummary serialization', () {
    test('round-trips through JSON with all fields', () {
      final s = SyncSummary(
        timestamp: DateTime.fromMillisecondsSinceEpoch(1720000000000),
        deviceName: 'Celular Android',
        changes: [
          cred('a', SyncChangeAction.added),
          folder('f1', SyncChangeAction.deleted),
        ],
      );
      final back = SyncSummary.fromJson(s.toJson());
      expect(back.timestamp, s.timestamp);
      expect(back.deviceName, 'Celular Android');
      expect(back.changes.length, 2);
      expect(back.changes.first.name, 'cred-a');
      expect(back.changes.first.action, SyncChangeAction.added);
      expect(back.changes.first.kind, SyncEntityKind.credential);
      expect(back.changes.last.kind, SyncEntityKind.folder);
      expect(back.changes.last.action, SyncChangeAction.deleted);
    });

    test('tolerates missing/unknown fields with safe defaults', () {
      final back = SyncSummary.fromJson({
        'timestamp': 5,
        'changes': [
          {'id': 'x', 'kind': 'weird', 'action': 'bogus'},
        ],
      });
      expect(back.deviceName, isNull);
      expect(back.changes.single.name, '');
      expect(back.changes.single.kind, SyncEntityKind.credential);
      expect(back.changes.single.action, SyncChangeAction.updated);
    });
  });
}
