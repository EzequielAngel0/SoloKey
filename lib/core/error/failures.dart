import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.cryptographic({required String message}) =
      CryptographicFailure;
  const factory Failure.storage({required String message}) = StorageFailure;
  const factory Failure.authentication({required String message}) =
      AuthenticationFailure;
  const factory Failure.biometric({required String message}) =
      BiometricFailure;
  const factory Failure.unexpected({required String message}) =
      UnexpectedFailure;
}
