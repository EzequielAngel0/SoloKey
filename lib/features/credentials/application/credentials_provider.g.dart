// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCredentialsHash() =>
    r'8527d33c4811ff5a5b1103c0376990f1b4152be1';

/// See also [filteredCredentials].
@ProviderFor(filteredCredentials)
final filteredCredentialsProvider =
    AutoDisposeFutureProvider<List<Credential>>.internal(
      filteredCredentials,
      name: r'filteredCredentialsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredCredentialsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCredentialsRef = AutoDisposeFutureProviderRef<List<Credential>>;
String _$getCredentialsUseCaseHash() =>
    r'82047d0b2f9c4edcc4b9158bc9c5437d47d21037';

/// See also [getCredentialsUseCase].
@ProviderFor(getCredentialsUseCase)
final getCredentialsUseCaseProvider =
    AutoDisposeProvider<GetCredentialsUseCase>.internal(
      getCredentialsUseCase,
      name: r'getCredentialsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getCredentialsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCredentialsUseCaseRef =
    AutoDisposeProviderRef<GetCredentialsUseCase>;
String _$saveCredentialUseCaseHash() =>
    r'b74460b90b0db037070008b70c724be53eecb952';

/// See also [saveCredentialUseCase].
@ProviderFor(saveCredentialUseCase)
final saveCredentialUseCaseProvider =
    AutoDisposeProvider<SaveCredentialUseCase>.internal(
      saveCredentialUseCase,
      name: r'saveCredentialUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$saveCredentialUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveCredentialUseCaseRef =
    AutoDisposeProviderRef<SaveCredentialUseCase>;
String _$deleteCredentialUseCaseHash() =>
    r'a5a0fc5f70a6af57dd4b34eb6e5e116a327d8a79';

/// See also [deleteCredentialUseCase].
@ProviderFor(deleteCredentialUseCase)
final deleteCredentialUseCaseProvider =
    AutoDisposeProvider<DeleteCredentialUseCase>.internal(
      deleteCredentialUseCase,
      name: r'deleteCredentialUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteCredentialUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteCredentialUseCaseRef =
    AutoDisposeProviderRef<DeleteCredentialUseCase>;
String _$credentialsNotifierHash() =>
    r'6b1ee823569b050ba47f254ced549a60c9e17acc';

/// See also [CredentialsNotifier].
@ProviderFor(CredentialsNotifier)
final credentialsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CredentialsNotifier,
      List<Credential>
    >.internal(
      CredentialsNotifier.new,
      name: r'credentialsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$credentialsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CredentialsNotifier = AutoDisposeAsyncNotifier<List<Credential>>;
String _$credentialSearchNotifierHash() =>
    r'1d55355224e12b06375054da8222a32e92946ec8';

/// See also [CredentialSearchNotifier].
@ProviderFor(CredentialSearchNotifier)
final credentialSearchNotifierProvider =
    AutoDisposeNotifierProvider<CredentialSearchNotifier, String>.internal(
      CredentialSearchNotifier.new,
      name: r'credentialSearchNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$credentialSearchNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CredentialSearchNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
