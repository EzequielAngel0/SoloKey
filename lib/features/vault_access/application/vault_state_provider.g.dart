// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VaultNotifier)
final vaultNotifierProvider = VaultNotifierProvider._();

final class VaultNotifierProvider
    extends $NotifierProvider<VaultNotifier, VaultState> {
  VaultNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultNotifierHash();

  @$internal
  @override
  VaultNotifier create() => VaultNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultState>(value),
    );
  }
}

String _$vaultNotifierHash() => r'8e60e3a56051f751df05ca4b598e1b2aa0ddd1d1';

abstract class _$VaultNotifier extends $Notifier<VaultState> {
  VaultState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VaultState, VaultState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultState, VaultState>,
              VaultState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(setupVaultUseCase)
final setupVaultUseCaseProvider = SetupVaultUseCaseProvider._();

final class SetupVaultUseCaseProvider
    extends
        $FunctionalProvider<
          SetupVaultUseCase,
          SetupVaultUseCase,
          SetupVaultUseCase
        >
    with $Provider<SetupVaultUseCase> {
  SetupVaultUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupVaultUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupVaultUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetupVaultUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetupVaultUseCase create(Ref ref) {
    return setupVaultUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetupVaultUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetupVaultUseCase>(value),
    );
  }
}

String _$setupVaultUseCaseHash() => r'd0b5c3dcd39ee018bc5ce61289fe8f6f524536ee';

@ProviderFor(unlockVaultUseCase)
final unlockVaultUseCaseProvider = UnlockVaultUseCaseProvider._();

final class UnlockVaultUseCaseProvider
    extends
        $FunctionalProvider<
          UnlockVaultUseCase,
          UnlockVaultUseCase,
          UnlockVaultUseCase
        >
    with $Provider<UnlockVaultUseCase> {
  UnlockVaultUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockVaultUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockVaultUseCaseHash();

  @$internal
  @override
  $ProviderElement<UnlockVaultUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnlockVaultUseCase create(Ref ref) {
    return unlockVaultUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnlockVaultUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnlockVaultUseCase>(value),
    );
  }
}

String _$unlockVaultUseCaseHash() =>
    r'5908917d3adf5b2611024a81228b3f346f260368';
