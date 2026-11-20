// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_generator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive so the user's last generation preferences (length, charsets)
/// persist across opening the generator again during the session, instead of
/// resetting to defaults each time.

@ProviderFor(PasswordConfigNotifier)
final passwordConfigNotifierProvider = PasswordConfigNotifierProvider._();

/// Kept alive so the user's last generation preferences (length, charsets)
/// persist across opening the generator again during the session, instead of
/// resetting to defaults each time.
final class PasswordConfigNotifierProvider
    extends $NotifierProvider<PasswordConfigNotifier, PasswordConfig> {
  /// Kept alive so the user's last generation preferences (length, charsets)
  /// persist across opening the generator again during the session, instead of
  /// resetting to defaults each time.
  PasswordConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordConfigNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordConfigNotifierHash();

  @$internal
  @override
  PasswordConfigNotifier create() => PasswordConfigNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordConfig>(value),
    );
  }
}

String _$passwordConfigNotifierHash() =>
    r'3d582f8b79f51715853499620537660ac8a965c0';

/// Kept alive so the user's last generation preferences (length, charsets)
/// persist across opening the generator again during the session, instead of
/// resetting to defaults each time.

abstract class _$PasswordConfigNotifier extends $Notifier<PasswordConfig> {
  PasswordConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PasswordConfig, PasswordConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PasswordConfig, PasswordConfig>,
              PasswordConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GeneratedPasswordNotifier)
final generatedPasswordNotifierProvider = GeneratedPasswordNotifierProvider._();

final class GeneratedPasswordNotifierProvider
    extends $NotifierProvider<GeneratedPasswordNotifier, String> {
  GeneratedPasswordNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedPasswordNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedPasswordNotifierHash();

  @$internal
  @override
  GeneratedPasswordNotifier create() => GeneratedPasswordNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$generatedPasswordNotifierHash() =>
    r'87cd3199d2b8bc7313ef74d1f4d5f9103e8a88c5';

abstract class _$GeneratedPasswordNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(passwordStrength)
final passwordStrengthProvider = PasswordStrengthProvider._();

final class PasswordStrengthProvider
    extends
        $FunctionalProvider<
          PasswordStrength,
          PasswordStrength,
          PasswordStrength
        >
    with $Provider<PasswordStrength> {
  PasswordStrengthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordStrengthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordStrengthHash();

  @$internal
  @override
  $ProviderElement<PasswordStrength> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PasswordStrength create(Ref ref) {
    return passwordStrength(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordStrength value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordStrength>(value),
    );
  }
}

String _$passwordStrengthHash() => r'ccbdb71a8c844e1b2a253954020c9a49dc37c340';
