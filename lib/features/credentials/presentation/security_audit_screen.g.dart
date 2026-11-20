// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_audit_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auditResults)
final auditResultsProvider = AuditResultsFamily._();

final class AuditResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditIssue>>,
          List<AuditIssue>,
          FutureOr<List<AuditIssue>>
        >
    with $FutureModifier<List<AuditIssue>>, $FutureProvider<List<AuditIssue>> {
  AuditResultsProvider._({
    required AuditResultsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'auditResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auditResultsHash();

  @override
  String toString() {
    return r'auditResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AuditIssue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuditIssue>> create(Ref ref) {
    final argument = this.argument as bool;
    return auditResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuditResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auditResultsHash() => r'77b8e534eb6cc938463f88fdb358f9831f883aac';

final class AuditResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AuditIssue>>, bool> {
  AuditResultsFamily._()
    : super(
        retry: null,
        name: r'auditResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuditResultsProvider call(bool checkBreaches) =>
      AuditResultsProvider._(argument: checkBreaches, from: this);

  @override
  String toString() => r'auditResultsProvider';
}
