// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_generator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$passwordStrengthHash() => r'ccbdb71a8c844e1b2a253954020c9a49dc37c340';

/// See also [passwordStrength].
@ProviderFor(passwordStrength)
final passwordStrengthProvider = AutoDisposeProvider<PasswordStrength>.internal(
  passwordStrength,
  name: r'passwordStrengthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$passwordStrengthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PasswordStrengthRef = AutoDisposeProviderRef<PasswordStrength>;
String _$passwordConfigNotifierHash() =>
    r'3d582f8b79f51715853499620537660ac8a965c0';

/// Kept alive so the user's last generation preferences (length, charsets)
/// persist across opening the generator again during the session, instead of
/// resetting to defaults each time.
///
/// Copied from [PasswordConfigNotifier].
@ProviderFor(PasswordConfigNotifier)
final passwordConfigNotifierProvider =
    NotifierProvider<PasswordConfigNotifier, PasswordConfig>.internal(
      PasswordConfigNotifier.new,
      name: r'passwordConfigNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$passwordConfigNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PasswordConfigNotifier = Notifier<PasswordConfig>;
String _$generatedPasswordNotifierHash() =>
    r'87cd3199d2b8bc7313ef74d1f4d5f9103e8a88c5';

/// See also [GeneratedPasswordNotifier].
@ProviderFor(GeneratedPasswordNotifier)
final generatedPasswordNotifierProvider =
    AutoDisposeNotifierProvider<GeneratedPasswordNotifier, String>.internal(
      GeneratedPasswordNotifier.new,
      name: r'generatedPasswordNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generatedPasswordNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GeneratedPasswordNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
