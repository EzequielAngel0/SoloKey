/// Sync status of a connected device, surfaced in the desktop UI.
enum DeviceSyncStatus { connected, syncing, synced }

/// Immutable snapshot of a mobile device currently connected to the desktop
/// sync server. Exposed via `SyncService.connectedDevices`.
class ConnectedDevice {
  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final DeviceSyncStatus status;
}
