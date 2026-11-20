// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(passwordHistory)
final passwordHistoryProvider = PasswordHistoryFamily._();

final class PasswordHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PasswordHistory>>,
          List<PasswordHistory>,
          FutureOr<List<PasswordHistory>>
        >
    with
        $FutureModifier<List<PasswordHistory>>,
        $FutureProvider<List<PasswordHistory>> {
  PasswordHistoryProvider._({
    required PasswordHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'passwordHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$passwordHistoryHash();

  @override
  String toString() {
    return r'passwordHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PasswordHistory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PasswordHistory>> create(Ref ref) {
    final argument = this.argument as String;
    return passwordHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PasswordHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$passwordHistoryHash() => r'491464f5da831256f7733261835a60cd114745cb';

final class PasswordHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PasswordHistory>>, String> {
  PasswordHistoryFamily._()
    : super(
        retry: null,
        name: r'passwordHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PasswordHistoryProvider call(String credentialId) =>
      PasswordHistoryProvider._(argument: credentialId, from: this);

  @override
  String toString() => r'passwordHistoryProvider';
}
