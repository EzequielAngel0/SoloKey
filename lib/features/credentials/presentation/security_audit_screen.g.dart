// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_audit_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auditResultsHash() => r'77b8e534eb6cc938463f88fdb358f9831f883aac';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [auditResults].
@ProviderFor(auditResults)
const auditResultsProvider = AuditResultsFamily();

/// See also [auditResults].
class AuditResultsFamily extends Family<AsyncValue<List<AuditIssue>>> {
  /// See also [auditResults].
  const AuditResultsFamily();

  /// See also [auditResults].
  AuditResultsProvider call(bool checkBreaches) {
    return AuditResultsProvider(checkBreaches);
  }

  @override
  AuditResultsProvider getProviderOverride(
    covariant AuditResultsProvider provider,
  ) {
    return call(provider.checkBreaches);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'auditResultsProvider';
}

/// See also [auditResults].
class AuditResultsProvider extends AutoDisposeFutureProvider<List<AuditIssue>> {
  /// See also [auditResults].
  AuditResultsProvider(bool checkBreaches)
    : this._internal(
        (ref) => auditResults(ref as AuditResultsRef, checkBreaches),
        from: auditResultsProvider,
        name: r'auditResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$auditResultsHash,
        dependencies: AuditResultsFamily._dependencies,
        allTransitiveDependencies:
            AuditResultsFamily._allTransitiveDependencies,
        checkBreaches: checkBreaches,
      );

  AuditResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.checkBreaches,
  }) : super.internal();

  final bool checkBreaches;

  @override
  Override overrideWith(
    FutureOr<List<AuditIssue>> Function(AuditResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuditResultsProvider._internal(
        (ref) => create(ref as AuditResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        checkBreaches: checkBreaches,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AuditIssue>> createElement() {
    return _AuditResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuditResultsProvider &&
        other.checkBreaches == checkBreaches;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, checkBreaches.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuditResultsRef on AutoDisposeFutureProviderRef<List<AuditIssue>> {
  /// The parameter `checkBreaches` of this provider.
  bool get checkBreaches;
}

class _AuditResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<AuditIssue>>
    with AuditResultsRef {
  _AuditResultsProviderElement(super.provider);

  @override
  bool get checkBreaches => (origin as AuditResultsProvider).checkBreaches;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
