import 'dart:async';

import 'package:password_manager/features/sync/domain/connected_device.dart';
import 'package:password_manager/features/sync/domain/i_sync_service.dart';
import 'package:password_manager/features/sync/domain/pairing_payload.dart';
import 'package:password_manager/features/sync/domain/sync_summary.dart';

/// Reusable in-memory fake of [ISyncService] for widget/unit tests.
///
/// It exposes broadcast [StreamController]s so a test can PUSH server/client
/// events (`emitServer`/`emitClient`/`emitVaultChange`) to drive the pairing UI
/// and the status provider through idle → connecting → paired → error, plus
/// configurable return values and a small call log for the imperative members.
///
/// No sockets, no mDNS, no crypto — everything runs offline. Register it in
/// get_it as `GetIt.I.registerSingleton<ISyncService>(fake)` (and reset in
/// tearDown), and/or override `syncEventsSourceProvider` with it in a
/// [ProviderScope]. Zero-Print: it never carries real keys or plaintext.
class FakeSyncService implements ISyncService {
  final StreamController<String> _server = StreamController<String>.broadcast();
  final StreamController<String> _client = StreamController<String>.broadcast();
  final StreamController<SyncSummary> _vault =
      StreamController<SyncSummary>.broadcast();

  // ── Configurable results (test knobs) ──────────────────────────────────────
  PairingPayload startServerResult = const PairingPayload(
    ip: '192.168.1.50',
    port: 8283,
    pairingToken: 'test-token',
    desktopPublicKeyHex: 'QUJDRA==',
  );

  /// When non-null, [startServer] throws this (drives the desktop error state).
  Object? startServerThrows;

  bool pairWithDesktopResult = true;
  bool requestSyncResult = true;
  bool canResumeResult = false;
  bool resumeResult = true;
  bool hasRemoteUnlockTokenResult = false;
  bool sendRemoteUnlockResult = true;
  bool hasPairingKeyResult = false;
  int requestApprovalResult = 0;

  bool serverRunning = false;
  bool clientConnected = false;
  List<ConnectedDevice> devices = const [];
  List<SyncSummary> history = const [];

  // ── Call log (assertable) ───────────────────────────────────────────────────
  int startServerCalls = 0;
  int stopServerCalls = 0;
  int removePairingKeyCalls = 0;
  int requestSyncCalls = 0;
  int resumeCalls = 0;
  int sendRemoteUnlockCalls = 0;
  final List<PairingPayload> pairCalls = <PairingPayload>[];

  // ── Emit helpers (the test drives events through these) ──────────────────────
  void emitServer(String event) => _server.add(event);
  void emitClient(String event) => _client.add(event);
  void emitVaultChange(SyncSummary summary) => _vault.add(summary);

  Future<void> dispose() async {
    await _server.close();
    await _client.close();
    await _vault.close();
  }

  // ── SyncEventsSource ────────────────────────────────────────────────────────
  @override
  Stream<String> get serverEvents => _server.stream;
  @override
  Stream<String> get clientEvents => _client.stream;
  @override
  Stream<SyncSummary> get vaultChanges => _vault.stream;
  @override
  bool get isServerRunning => serverRunning;
  @override
  bool get isClientConnected => clientConnected;
  @override
  int get connectedDeviceCount => devices.length;
  @override
  Future<List<SyncSummary>> loadHistory() async => history;

  // ── ISyncService: desktop server ─────────────────────────────────────────────
  @override
  List<ConnectedDevice> get connectedDevices => devices;

  @override
  Future<PairingPayload> startServer() async {
    startServerCalls++;
    final err = startServerThrows;
    if (err != null) throw err;
    serverRunning = true;
    return startServerResult;
  }

  @override
  Future<void> stopServer() async {
    stopServerCalls++;
    serverRunning = false;
  }

  @override
  Future<int> requestApproval() async => requestApprovalResult;

  // ── ISyncService: mobile client ──────────────────────────────────────────────
  @override
  Future<bool> pairWithDesktop(PairingPayload payload) async {
    pairCalls.add(payload);
    return pairWithDesktopResult;
  }

  @override
  Future<bool> requestSync() async {
    requestSyncCalls++;
    return requestSyncResult;
  }

  @override
  Future<bool> canResume() async => canResumeResult;

  @override
  Future<bool> resumeWithDesktop({String? ip, int? port}) async {
    resumeCalls++;
    return resumeResult;
  }

  @override
  Future<bool> hasRemoteUnlockToken() async => hasRemoteUnlockTokenResult;

  @override
  Future<bool> sendRemoteUnlockRequest() async {
    sendRemoteUnlockCalls++;
    return sendRemoteUnlockResult;
  }

  // ── ISyncService: shared pairing state ───────────────────────────────────────
  @override
  Future<bool> hasPairingKey() async => hasPairingKeyResult;

  @override
  Future<void> removePairingKey() async {
    removePairingKeyCalls++;
    hasPairingKeyResult = false;
    serverRunning = false;
  }
}
