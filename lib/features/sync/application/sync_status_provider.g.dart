// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncEventsSourceHash() => r'36c8d998dd5665ad93361d4182331dddcaf9e8fa';

/// The sync engine as a narrow, overridable source. Defaults to the get_it
/// [SyncService]; tests override it with a fake.
///
/// Copied from [syncEventsSource].
@ProviderFor(syncEventsSource)
final syncEventsSourceProvider = Provider<SyncEventsSource>.internal(
  syncEventsSource,
  name: r'syncEventsSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncEventsSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncEventsSourceRef = ProviderRef<SyncEventsSource>;
String _$syncStatusHash() => r'f0feb92e359285d27ddd97d09303a7b3f1d32687';

/// App-wide sync status. Listens to the sync engine and, crucially, **refreshes
/// the credential/folder providers whenever a delta is applied** so the vault
/// list updates live without reopening the app (fixes the desktop "stale list
/// after sync" bug). Kept alive so it observes background syncs even when no
/// sync screen is mounted.
///
/// Copied from [SyncStatus].
@ProviderFor(SyncStatus)
final syncStatusProvider =
    NotifierProvider<SyncStatus, SyncStatusState>.internal(
      SyncStatus.new,
      name: r'syncStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncStatus = Notifier<SyncStatusState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
