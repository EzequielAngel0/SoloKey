import 'sync_summary.dart';

/// Narrow read-only view of the sync engine that the Riverpod status layer
/// consumes. Implemented by `SyncService`; kept as a small interface so the
/// `syncStatusProvider` can be unit-tested against a fake without standing up
/// the whole WebSocket/crypto stack.
abstract interface class SyncEventsSource {
  /// String status events from the desktop server side (pairing, per-round).
  Stream<String> get serverEvents;

  /// String status events from the mobile client side.
  Stream<String> get clientEvents;

  /// Typed stream fired once per applied delta with what changed locally.
  Stream<SyncSummary> get vaultChanges;

  bool get isServerRunning;
  bool get isClientConnected;

  /// Number of mobile devices currently connected to the desktop server.
  int get connectedDeviceCount;

  /// Persisted history of recent sync rounds (most recent first).
  Future<List<SyncSummary>> loadHistory();
}
