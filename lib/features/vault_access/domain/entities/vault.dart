import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault.freezed.dart';
part 'vault.g.dart';

@freezed
abstract class Vault with _$Vault {
  const factory Vault({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isInitialized,
  }) = _Vault;

  factory Vault.fromJson(Map<String, dynamic> json) => _$VaultFromJson(json);
}
