import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/features/sync/application/pairing_notifier.dart';
import 'package:password_manager/features/sync/domain/i_sync_service.dart';
import 'package:password_manager/features/sync/domain/pairing_payload.dart';

import '../../support/fake_sync_service.dart';

/// Drives [PairingNotifier] against [FakeSyncService] registered in get_it (the
/// notifier grabs `getIt<ISyncService>()` in its constructor and subscribes to
/// the event streams), so its imperative flows and its stream→state mapping are
/// exercised without any sockets/crypto.
void main() {
  late FakeSyncService fake;
  late ProviderContainer container;

  setUp(() {
    fake = FakeSyncService();
    GetIt.I.registerSingleton<ISyncService>(fake);
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await GetIt.I.reset();
    await fake.dispose();
  });

  PairingNotifier notifier() =>
      container.read(pairingNotifierProvider.notifier);
  PairingState state() => container.read(pairingNotifierProvider);

  const validPayload = PairingPayload(
    ip: '192.168.1.9',
    port: 8283,
    pairingToken: 'tok',
    desktopPublicKeyHex: 'QQ==',
  );

  test('starts idle', () {
    expect(state().status, PairingStatus.idle);
  });

  group('desktop server', () {
    test('startDesktopServer moves to serverReady carrying the payload',
        () async {
      await notifier().startDesktopServer();
      expect(fake.startServerCalls, 1);
      expect(state().status, PairingStatus.serverReady);
      expect(state().payload, isNotNull);
      expect(state().payload!.pairingToken, 'test-token');
    });

    test('startDesktopServer surfaces a failure', () async {
      fake.startServerThrows = Exception('no port');
      await notifier().startDesktopServer();
      expect(state().status, PairingStatus.failed);
      expect(state().errorMessage, isNotNull);
    });

    test('stopDesktopServer returns to idle', () async {
      await notifier().startDesktopServer();
      await notifier().stopDesktopServer();
      expect(fake.stopServerCalls, 1);
      expect(state().status, PairingStatus.idle);
    });
  });

  group('mobile pairing', () {
    test('pairWithPc succeeds with a valid QR payload', () async {
      await notifier().pairWithPc(validPayload.toQrString());
      expect(fake.pairCalls, hasLength(1));
      expect(fake.pairCalls.single.ip, '192.168.1.9');
      expect(state().status, PairingStatus.paired);
    });

    test('pairWithPc fails when the key agreement fails', () async {
      fake.pairWithDesktopResult = false;
      await notifier().pairWithPc(validPayload.toQrString());
      expect(state().status, PairingStatus.failed);
    });

    test('pairWithPc fails on a malformed QR string (never hits the service)',
        () async {
      await notifier().pairWithPc('not-json');
      expect(state().status, PairingStatus.failed);
      expect(fake.pairCalls, isEmpty);
    });
  });

  group('event stream → state', () {
    test('a server "paired" event flips to paired', () async {
      notifier(); // instantiate so it subscribes
      fake.emitServer('paired');
      await Future<void>.delayed(Duration.zero);
      expect(state().status, PairingStatus.paired);
    });

    test('a server "pairing_failed" event flips to failed', () async {
      notifier();
      fake.emitServer('pairing_failed');
      await Future<void>.delayed(Duration.zero);
      expect(state().status, PairingStatus.failed);
    });

    test('a client "paired" event flips to paired', () async {
      notifier();
      fake.emitClient('paired');
      await Future<void>.delayed(Duration.zero);
      expect(state().status, PairingStatus.paired);
    });

    test('a client "error:" event flips to failed with the trimmed message',
        () async {
      notifier();
      fake.emitClient('error: boom detail');
      await Future<void>.delayed(Duration.zero);
      expect(state().status, PairingStatus.failed);
      expect(state().errorMessage, 'boom detail');
    });
  });

  test('reset returns to idle', () async {
    fake.startServerThrows = Exception('x');
    await notifier().startDesktopServer();
    expect(state().status, PairingStatus.failed);
    notifier().reset();
    expect(state().status, PairingStatus.idle);
  });
}
