import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/injection.dart';
import '../../credentials/application/credentials_provider.dart';
import '../../folders/application/folders_provider.dart';
import '../domain/sync_events_source.dart';
import '../domain/sync_summary.dart';
import '../infrastructure/sync_service.dart';

part 'sync_status_provider.g.dart';

/// Coarse phase of the sync engine, surfaced app-wide (e.g. the desktop sidebar
/// badge). Independent from the pairing wizard's own [PairingStatus].
enum SyncPhase { idle, active, connecting, syncing, success, error }

/// Immutable snapshot of the global sync state shared across screens.
class SyncStatusState {
  const SyncStatusState({
    required this.phase,
    this.lastSummary,
    this.errorDetail,
    this.serverRunning = false,
    this.connectedDevices = 0,
    this.history = const [],
  });

  final SyncPhase phase;

  /// Result of the most recent applied round (may be empty).
  final SyncSummary? lastSummary;

  /// Human-readable error detail when [phase] is [SyncPhase.error].
  final String? errorDetail;

  final bool serverRunning;
  final int connectedDevices;

  /// Persisted + live history of recent rounds (most recent first).
  final List<SyncSummary> history;

  bool get isBusy =>
      phase == SyncPhase.connecting || phase == SyncPhase.syncing;

  SyncStatusState copyWith({
    SyncPhase? phase,
    SyncSummary? lastSummary,
    String? errorDetail,
    bool? serverRunning,
    int? connectedDevices,
    List<SyncSummary>? history,
  }) =>
      SyncStatusState(
        phase: phase ?? this.phase,
        lastSummary: lastSummary ?? this.lastSummary,
        errorDetail: errorDetail,
        serverRunning: serverRunning ?? this.serverRunning,
        connectedDevices: connectedDevices ?? this.connectedDevices,
        history: history ?? this.history,
      );
}

/// The sync engine as a narrow, overridable source. Defaults to the get_it
/// [SyncService]; tests override it with a fake.
@Riverpod(keepAlive: true)
SyncEventsSource syncEventsSource(Ref ref) => getIt<SyncService>();

/// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
/// the credential/folder providers whenever a delta is applied** so the vault
/// list updates live without reopening the app (fixes the desktop "stale list
/// after sync" bug). Kept alive so it observes background syncs even when no
/// sync screen is mounted.
@Riverpod(keepAlive: true)
class SyncStatus extends _$SyncStatus {
  @override
  SyncStatusState build() {
    final source = ref.watch(syncEventsSourceProvider);

    final subs = <StreamSubscription<Object?>>[
      source.serverEvents.listen(_onStringEvent),
      source.clientEvents.listen(_onStringEvent),
      source.vaultChanges.listen(_onVaultChanged),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
    });

    // Load the persisted history asynchronously; seed the initial phase from the
    // engine's current connectivity.
    unawaited(_hydrateHistory(source));

    final connected = source.isServerRunning || source.isClientConnected;
    return SyncStatusState(
      phase: connected ? SyncPhase.active : SyncPhase.idle,
      serverRunning: source.isServerRunning,
      connectedDevices: source.connectedDeviceCount,
    );
  }

  Future<void> _hydrateHistory(SyncEventsSource source) async {
    final history = await source.loadHistory();
    if (history.isNotEmpty) {
      state = state.copyWith(history: history);
    }
  }

  /// Called on every applied delta: refreshes the lists and records the summary.
  void _onVaultChanged(SyncSummary summary) {
    final history = summary.isNotEmpty
        ? [summary, ...state.history].take(20).toList()
        : state.history;
    state = state.copyWith(
      phase: SyncPhase.success,
      lastSummary: summary,
      history: history,
    );

    // The heart of the fix: a delta wrote straight to Drift, so invalidate the
    // Riverpod caches to force a re-read. No-op when nothing was watching them.
    if (summary.isNotEmpty) {
      ref.invalidate(credentialsNotifierProvider);
      ref.invalidate(foldersNotifierProvider);
    }
  }

  void _onStringEvent(String event) {
    final source = ref.read(syncEventsSourceProvider);
    final connected = source.isServerRunning || source.isClientConnected;

    if (event.startsWith('error:')) {
      state = state.copyWith(
        phase: SyncPhase.error,
        errorDetail: event.replaceFirst('error:', '').trim(),
        serverRunning: source.isServerRunning,
        connectedDevices: source.connectedDeviceCount,
      );
      return;
    }

    SyncPhase phase = state.phase;
    switch (event) {
      case 'server_started':
      case 'paired':
      case 'client_resumed':
      case 'connected':
      case 'devices_changed':
        phase = connected ? SyncPhase.active : SyncPhase.idle;
      case 'client_connecting':
      case 'connecting':
        phase = SyncPhase.connecting;
      case 'sync_manifest_processed':
      case 'sync_started':
      case 'sync_response_processed':
        phase = SyncPhase.syncing;
      case 'sync_completed':
        phase = SyncPhase.success;
      case 'sync_error':
        phase = SyncPhase.error;
      case 'server_stopped':
      case 'disconnected':
      case 'client_disconnected':
        phase = connected ? SyncPhase.active : SyncPhase.idle;
      default:
        // sync_completed:creds=..,folders=.. and unknown events keep the phase.
        if (event.startsWith('sync_completed')) phase = SyncPhase.success;
    }

    state = state.copyWith(
      phase: phase,
      serverRunning: source.isServerRunning,
      connectedDevices: source.connectedDeviceCount,
    );
  }
}
