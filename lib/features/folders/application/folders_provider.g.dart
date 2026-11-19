// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FoldersNotifier)
final foldersNotifierProvider = FoldersNotifierProvider._();

final class FoldersNotifierProvider
    extends $AsyncNotifierProvider<FoldersNotifier, List<Folder>> {
  FoldersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersNotifierHash();

  @$internal
  @override
  FoldersNotifier create() => FoldersNotifier();
}

String _$foldersNotifierHash() => r'd564caff304fb269d88e0f1df1abac859d8f2c4e';

abstract class _$FoldersNotifier extends $AsyncNotifier<List<Folder>> {
  FutureOr<List<Folder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Folder>>, List<Folder>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Folder>>, List<Folder>>,
              AsyncValue<List<Folder>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(folderRepository)
final folderRepositoryProvider = FolderRepositoryProvider._();

final class FolderRepositoryProvider
    extends
        $FunctionalProvider<
          IFolderRepository,
          IFolderRepository,
          IFolderRepository
        >
    with $Provider<IFolderRepository> {
  FolderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderRepositoryHash();

  @$internal
  @override
  $ProviderElement<IFolderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IFolderRepository create(Ref ref) {
    return folderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IFolderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IFolderRepository>(value),
    );
  }
}

String _$folderRepositoryHash() => r'cf86f11dc36087cb3a46052c9d68fc88d199f0e1';
