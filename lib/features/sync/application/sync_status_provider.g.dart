// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sync engine as a narrow, overridable source. Defaults to the get_it
/// [SyncService]; tests override it with a fake.

@ProviderFor(syncEventsSource)
final syncEventsSourceProvider = SyncEventsSourceProvider._();

/// The sync engine as a narrow, overridable source. Defaults to the get_it
/// [SyncService]; tests override it with a fake.

final class SyncEventsSourceProvider
    extends
        $FunctionalProvider<
          SyncEventsSource,
          SyncEventsSource,
          SyncEventsSource
        >
    with $Provider<SyncEventsSource> {
  /// The sync engine as a narrow, overridable source. Defaults to the get_it
  /// [SyncService]; tests override it with a fake.
  SyncEventsSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEventsSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEventsSourceHash();

  @$internal
  @override
  $ProviderElement<SyncEventsSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEventsSource create(Ref ref) {
    return syncEventsSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEventsSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEventsSource>(value),
    );
  }
}

String _$syncEventsSourceHash() => r'36c8d998dd5665ad93361d4182331dddcaf9e8fa';

/// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
/// the credential/folder providers whenever a delta is applied** so the vault
/// list updates live without reopening the app (fixes the desktop "stale list
/// after sync" bug). Kept alive so it observes background syncs even when no
/// sync screen is mounted.

@ProviderFor(SyncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
/// the credential/folder providers whenever a delta is applied** so the vault
/// list updates live without reopening the app (fixes the desktop "stale list
/// after sync" bug). Kept alive so it observes background syncs even when no
/// sync screen is mounted.
final class SyncStatusProvider
    extends $NotifierProvider<SyncStatus, SyncStatusState> {
  /// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
  /// the credential/folder providers whenever a delta is applied** so the vault
  /// list updates live without reopening the app (fixes the desktop "stale list
  /// after sync" bug). Kept alive so it observes background syncs even when no
  /// sync screen is mounted.
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  SyncStatus create() => SyncStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatusState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatusState>(value),
    );
  }
}

String _$syncStatusHash() => r'f0feb92e359285d27ddd97d09303a7b3f1d32687';

/// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
/// the credential/folder providers whenever a delta is applied** so the vault
/// list updates live without reopening the app (fixes the desktop "stale list
/// after sync" bug). Kept alive so it observes background syncs even when no
/// sync screen is mounted.

abstract class _$SyncStatus extends $Notifier<SyncStatusState> {
  SyncStatusState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncStatusState, SyncStatusState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatusState, SyncStatusState>,
              SyncStatusState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
