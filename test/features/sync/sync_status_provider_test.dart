import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/domain/entities/folder.dart';
import 'package:password_manager/features/sync/application/sync_status_provider.dart';
import 'package:password_manager/features/sync/domain/sync_events_source.dart';
import 'package:password_manager/features/sync/domain/sync_summary.dart';

import '../../support/fake_credential_repository.dart';
import '../../support/fake_folder_repository.dart';

/// Controllable [SyncEventsSource] so the test can push a vaultChanges event and
/// assert the status provider reacts (invalidates the lists).
class FakeSyncEventsSource implements SyncEventsSource {
  final _server = StreamController<String>.broadcast();
  final _client = StreamController<String>.broadcast();
  final _vault = StreamController<SyncSummary>.broadcast();

  void emitVaultChange(SyncSummary s) => _vault.add(s);
  void emitServer(String e) => _server.add(e);

  @override
  Stream<String> get serverEvents => _server.stream;
  @override
  Stream<String> get clientEvents => _client.stream;
  @override
  Stream<SyncSummary> get vaultChanges => _vault.stream;
  @override
  bool get isServerRunning => false;
  @override
  bool get isClientConnected => false;
  @override
  int get connectedDeviceCount => 0;
  @override
  Future<List<SyncSummary>> loadHistory() async => [];

  Future<void> dispose() async {
    await _server.close();
    await _client.close();
    await _vault.close();
  }
}

Credential _cred(String id) => Credential(
      id: id,
      type: CredentialType.password,
      title: 'cred-$id',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(1),
    );

Folder _folder(String id) => Folder(
      id: id,
      name: 'folder-$id',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1),
    );

void main() {
  late FakeSyncEventsSource source;
  late List<Credential> creds;
  late List<Folder> folders;
  late ProviderContainer container;

  setUp(() {
    source = FakeSyncEventsSource();
    creds = [_cred('a')];
    folders = [_folder('f1')];
    container = ProviderContainer(overrides: [
      syncEventsSourceProvider.overrideWithValue(source),
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(FakeCredentialRepository(creds))),
      folderRepositoryProvider.overrideWithValue(FakeFolderRepository(folders)),
    ]);
    // Keep the lists alive so an invalidate triggers a rebuild (re-read).
    container.listen(credentialsNotifierProvider, (_, _) {});
    container.listen(foldersNotifierProvider, (_, _) {});
    container.listen(syncStatusProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await source.dispose();
  });

  test('applying a delta invalidates the credential and folder lists', () async {
    // Instantiate the status provider so it subscribes to the source.
    container.read(syncStatusProvider);

    expect((await container.read(credentialsNotifierProvider.future)).length, 1);
    expect((await container.read(foldersNotifierProvider.future)).length, 1);

    // Simulate a delta writing straight to the DB (new rows on both lists).
    creds.add(_cred('b'));
    folders.add(_folder('f2'));

    source.emitVaultChange(SyncSummary(
      timestamp: DateTime.now(),
      deviceName: 'PC',
      changes: const [
        SyncItemChange(
            id: 'b',
            name: 'cred-b',
            kind: SyncEntityKind.credential,
            action: SyncChangeAction.added),
        SyncItemChange(
            id: 'f2',
            name: 'folder-f2',
            kind: SyncEntityKind.folder,
            action: SyncChangeAction.added),
      ],
    ));

    // Let the stream callback + provider rebuild settle.
    await Future<void>.delayed(Duration.zero);

    // The lists must reflect the new rows WITHOUT anyone calling refresh().
    expect((await container.read(credentialsNotifierProvider.future)).length, 2);
    expect((await container.read(foldersNotifierProvider.future)).length, 2);

    // And the status carries the summary of what synced.
    final status = container.read(syncStatusProvider);
    expect(status.phase, SyncPhase.success);
    expect(status.lastSummary?.total, 2);
    expect(status.history.length, 1);
  });

  test('an empty delta does not add a history entry', () async {
    container.read(syncStatusProvider);
    source.emitVaultChange(SyncSummary.empty());
    await Future<void>.delayed(Duration.zero);
    final status = container.read(syncStatusProvider);
    expect(status.lastSummary?.isEmpty, isTrue);
    expect(status.history, isEmpty);
  });
}
