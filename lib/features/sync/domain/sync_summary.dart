/// What kind of vault entity a synced change refers to.
enum SyncEntityKind { credential, folder }

/// What happened to a synced entity on THIS device when a delta was applied.
enum SyncChangeAction { added, updated, deleted }

/// A single change applied to the local vault during a sync round. Carries only
/// the plain, already-visible title/name — never a secret — so it is safe to
/// surface in the "what synced" summary and to persist in the history log.
class SyncItemChange {
  const SyncItemChange({
    required this.id,
    required this.name,
    required this.kind,
    required this.action,
  });

  final String id;
  final String name;
  final SyncEntityKind kind;
  final SyncChangeAction action;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'action': action.name,
      };

  factory SyncItemChange.fromJson(Map<String, dynamic> json) => SyncItemChange(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        kind: SyncEntityKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => SyncEntityKind.credential,
        ),
        action: SyncChangeAction.values.firstWhere(
          (a) => a.name == json['action'],
          orElse: () => SyncChangeAction.updated,
        ),
      );
}

/// Immutable result of a single sync round, from the perspective of the device
/// that applied it. Aggregates every [SyncItemChange] plus a timestamp and the
/// peer's name (when known). Serializable so it can live in the persisted sync
/// history and be shown in the UI.
class SyncSummary {
  const SyncSummary({
    required this.timestamp,
    required this.changes,
    this.deviceName,
  });

  /// When the delta finished applying on this device.
  final DateTime timestamp;

  /// Every change applied locally in this round.
  final List<SyncItemChange> changes;

  /// Name of the peer the data came from, when known (null on the mobile side,
  /// where only one desktop is ever paired).
  final String? deviceName;

  factory SyncSummary.empty() =>
      SyncSummary(timestamp: DateTime.now(), changes: const []);

  bool get isEmpty => changes.isEmpty;
  bool get isNotEmpty => changes.isNotEmpty;
  int get total => changes.length;

  Iterable<SyncItemChange> get _creds =>
      changes.where((c) => c.kind == SyncEntityKind.credential);
  Iterable<SyncItemChange> get _folders =>
      changes.where((c) => c.kind == SyncEntityKind.folder);

  int get credentialsAdded =>
      _creds.where((c) => c.action == SyncChangeAction.added).length;
  int get credentialsUpdated =>
      _creds.where((c) => c.action == SyncChangeAction.updated).length;
  int get credentialsDeleted =>
      _creds.where((c) => c.action == SyncChangeAction.deleted).length;
  int get credentialsTotal => _creds.length;

  int get foldersAdded =>
      _folders.where((c) => c.action == SyncChangeAction.added).length;
  int get foldersUpdated =>
      _folders.where((c) => c.action == SyncChangeAction.updated).length;
  int get foldersDeleted =>
      _folders.where((c) => c.action == SyncChangeAction.deleted).length;
  int get foldersTotal => _folders.length;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'device_name': deviceName,
        'changes': changes.map((c) => c.toJson()).toList(),
      };

  factory SyncSummary.fromJson(Map<String, dynamic> json) => SyncSummary(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (json['timestamp'] as num?)?.toInt() ?? 0),
        deviceName: json['device_name'] as String?,
        changes: ((json['changes'] as List?) ?? [])
            .map((e) => SyncItemChange.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
