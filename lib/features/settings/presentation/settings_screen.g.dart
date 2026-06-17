// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'03b043f97aa6997dc554bc9cae3c540ab1424e0b';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeProvider<ISettingsRepository>.internal(
      settingsRepository,
      name: r'settingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = AutoDisposeProviderRef<ISettingsRepository>;
String _$settingsNotifierHash() => r'05d6167035d2f064bd6a1e643522f28ed5d0f022';

/// See also [SettingsNotifier].
@ProviderFor(SettingsNotifier)
final settingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SettingsNotifier,
      AppSecuritySettings
    >.internal(
      SettingsNotifier.new,
      name: r'settingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsNotifier = AutoDisposeAsyncNotifier<AppSecuritySettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
