// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_files_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SecureFilesNotifier)
final secureFilesNotifierProvider = SecureFilesNotifierProvider._();

final class SecureFilesNotifierProvider
    extends $AsyncNotifierProvider<SecureFilesNotifier, List<SecureFile>> {
  SecureFilesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureFilesNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureFilesNotifierHash();

  @$internal
  @override
  SecureFilesNotifier create() => SecureFilesNotifier();
}

String _$secureFilesNotifierHash() =>
    r'162cbcc7cc2f997c6e9783bd0bec40b4e7d27d1c';

abstract class _$SecureFilesNotifier extends $AsyncNotifier<List<SecureFile>> {
  FutureOr<List<SecureFile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SecureFile>>, List<SecureFile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SecureFile>>, List<SecureFile>>,
              AsyncValue<List<SecureFile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(secureFileRepository)
final secureFileRepositoryProvider = SecureFileRepositoryProvider._();

final class SecureFileRepositoryProvider
    extends
        $FunctionalProvider<
          ISecureFileRepository,
          ISecureFileRepository,
          ISecureFileRepository
        >
    with $Provider<ISecureFileRepository> {
  SecureFileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureFileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureFileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISecureFileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISecureFileRepository create(Ref ref) {
    return secureFileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISecureFileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISecureFileRepository>(value),
    );
  }
}

String _$secureFileRepositoryHash() =>
    r'e49f062d81269bed65337ce3383482331027b6a8';
