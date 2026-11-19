// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsNotifier)
final settingsNotifierProvider = SettingsNotifierProvider._();

final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, AppSecuritySettings> {
  SettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();
}

String _$settingsNotifierHash() => r'05d6167035d2f064bd6a1e643522f28ed5d0f022';

abstract class _$SettingsNotifier extends $AsyncNotifier<AppSecuritySettings> {
  FutureOr<AppSecuritySettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AppSecuritySettings>, AppSecuritySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSecuritySettings>, AppSecuritySettings>,
              AsyncValue<AppSecuritySettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          ISettingsRepository,
          ISettingsRepository,
          ISettingsRepository
        >
    with $Provider<ISettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'03b043f97aa6997dc554bc9cae3c540ab1424e0b';
