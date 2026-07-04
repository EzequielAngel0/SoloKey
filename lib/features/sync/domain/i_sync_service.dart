import 'connected_device.dart';
import 'pairing_payload.dart';
import 'sync_events_source.dart';

/// UI-facing contract of the sync engine. `SyncService` (the concrete
/// `@lazySingleton`) implements it; the DI layer also registers the same
/// instance under this interface so the pairing UI resolves it via
/// `getIt<ISyncService>()`.
///
/// Extracting it is a TEST SEAM only — it does not change the P2P E2EE protocol
/// or the pairing behavior. Its sole purpose is to let widget/unit tests inject
/// a lightweight fake (see `test/support/fake_sync_service.dart`) instead of the
/// real socket/mDNS/crypto stack that the concrete class carries.
///
/// Extends [SyncEventsSource] (the narrow read-only view the Riverpod status
/// layer already consumes) and adds the imperative members the pairing screen
/// and notifier drive.
abstract interface class ISyncService implements SyncEventsSource {
  // ── Desktop server ────────────────────────────────────────────────────────
  Future<PairingPayload> startServer();
  Future<void> stopServer();

  /// Snapshot of the mobile devices currently connected to the desktop server.
  List<ConnectedDevice> get connectedDevices;

  /// Asks every connected phone to approve unlocking this desktop. Returns how
  /// many phones the request reached.
  Future<int> requestApproval();

  // ── Mobile client ─────────────────────────────────────────────────────────
  Future<bool> pairWithDesktop(PairingPayload payload);
  Future<bool> requestSync();

  /// True once this phone has resume data (endpoint + K_sync) to reconnect.
  Future<bool> canResume();

  /// Reconnects to the paired desktop without re-scanning the QR. Returns true
  /// when the link is up.
  Future<bool> resumeWithDesktop({String? ip, int? port});

  /// True if this phone holds a WiFi-unlock token (DUK) for the paired desktop.
  Future<bool> hasRemoteUnlockToken();

  /// Sends a remote-unlock request (the stored DUK) over the E2EE channel.
  Future<bool> sendRemoteUnlockRequest();

  // ── Shared pairing state ──────────────────────────────────────────────────
  /// Whether this device has paired before (mobile K_sync or desktop devices).
  Future<bool> hasPairingKey();

  /// Removes all pairing state, effectively "un-pairing" the devices.
  Future<void> removePairingKey();
}
