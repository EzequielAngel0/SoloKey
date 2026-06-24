// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_files_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureFileRepositoryHash() =>
    r'e49f062d81269bed65337ce3383482331027b6a8';

/// See also [secureFileRepository].
@ProviderFor(secureFileRepository)
final secureFileRepositoryProvider =
    AutoDisposeProvider<ISecureFileRepository>.internal(
      secureFileRepository,
      name: r'secureFileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$secureFileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureFileRepositoryRef = AutoDisposeProviderRef<ISecureFileRepository>;
String _$secureFilesNotifierHash() =>
    r'a7272fb669966a86ccc5b6f8c2ffef2d6214b703';

/// See also [SecureFilesNotifier].
@ProviderFor(SecureFilesNotifier)
final secureFilesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SecureFilesNotifier,
      List<SecureFile>
    >.internal(
      SecureFilesNotifier.new,
      name: r'secureFilesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$secureFilesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SecureFilesNotifier = AutoDisposeAsyncNotifier<List<SecureFile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
