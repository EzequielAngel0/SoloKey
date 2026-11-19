// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CredentialsNotifier)
final credentialsNotifierProvider = CredentialsNotifierProvider._();

final class CredentialsNotifierProvider
    extends $AsyncNotifierProvider<CredentialsNotifier, List<Credential>> {
  CredentialsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialsNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialsNotifierHash();

  @$internal
  @override
  CredentialsNotifier create() => CredentialsNotifier();
}

String _$credentialsNotifierHash() =>
    r'81b8a17d69dca2b9019f413e12e1b63ff089892f';

abstract class _$CredentialsNotifier extends $AsyncNotifier<List<Credential>> {
  FutureOr<List<Credential>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Credential>>, List<Credential>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Credential>>, List<Credential>>,
              AsyncValue<List<Credential>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CredentialSearchNotifier)
final credentialSearchNotifierProvider = CredentialSearchNotifierProvider._();

final class CredentialSearchNotifierProvider
    extends $NotifierProvider<CredentialSearchNotifier, String> {
  CredentialSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialSearchNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialSearchNotifierHash();

  @$internal
  @override
  CredentialSearchNotifier create() => CredentialSearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$credentialSearchNotifierHash() =>
    r'1d55355224e12b06375054da8222a32e92946ec8';

abstract class _$CredentialSearchNotifier extends $Notifier<String> {
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

@ProviderFor(filteredCredentials)
final filteredCredentialsProvider = FilteredCredentialsProvider._();

final class FilteredCredentialsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Credential>>,
          List<Credential>,
          FutureOr<List<Credential>>
        >
    with $FutureModifier<List<Credential>>, $FutureProvider<List<Credential>> {
  FilteredCredentialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCredentialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCredentialsHash();

  @$internal
  @override
  $FutureProviderElement<List<Credential>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Credential>> create(Ref ref) {
    return filteredCredentials(ref);
  }
}

String _$filteredCredentialsHash() =>
    r'8527d33c4811ff5a5b1103c0376990f1b4152be1';

@ProviderFor(getCredentialsUseCase)
final getCredentialsUseCaseProvider = GetCredentialsUseCaseProvider._();

final class GetCredentialsUseCaseProvider
    extends
        $FunctionalProvider<
          GetCredentialsUseCase,
          GetCredentialsUseCase,
          GetCredentialsUseCase
        >
    with $Provider<GetCredentialsUseCase> {
  GetCredentialsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCredentialsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCredentialsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCredentialsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCredentialsUseCase create(Ref ref) {
    return getCredentialsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCredentialsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCredentialsUseCase>(value),
    );
  }
}

String _$getCredentialsUseCaseHash() =>
    r'82047d0b2f9c4edcc4b9158bc9c5437d47d21037';

@ProviderFor(saveCredentialUseCase)
final saveCredentialUseCaseProvider = SaveCredentialUseCaseProvider._();

final class SaveCredentialUseCaseProvider
    extends
        $FunctionalProvider<
          SaveCredentialUseCase,
          SaveCredentialUseCase,
          SaveCredentialUseCase
        >
    with $Provider<SaveCredentialUseCase> {
  SaveCredentialUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveCredentialUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveCredentialUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveCredentialUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveCredentialUseCase create(Ref ref) {
    return saveCredentialUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveCredentialUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveCredentialUseCase>(value),
    );
  }
}

String _$saveCredentialUseCaseHash() =>
    r'b74460b90b0db037070008b70c724be53eecb952';

@ProviderFor(deleteCredentialUseCase)
final deleteCredentialUseCaseProvider = DeleteCredentialUseCaseProvider._();

final class DeleteCredentialUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteCredentialUseCase,
          DeleteCredentialUseCase,
          DeleteCredentialUseCase
        >
    with $Provider<DeleteCredentialUseCase> {
  DeleteCredentialUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteCredentialUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteCredentialUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCredentialUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteCredentialUseCase create(Ref ref) {
    return deleteCredentialUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCredentialUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCredentialUseCase>(value),
    );
  }
}

String _$deleteCredentialUseCaseHash() =>
    r'a5a0fc5f70a6af57dd4b34eb6e5e116a327d8a79';
