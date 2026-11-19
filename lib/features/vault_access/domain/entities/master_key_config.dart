import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_key_config.freezed.dart';
part 'master_key_config.g.dart';

enum KdfAlgorithm { argon2id, pbkdf2 }

@freezed
abstract class KdfParams with _$KdfParams {
  const factory KdfParams({
    required int memory,       // KB — Argon2id memory cost
    required int iterations,   // time cost
    required int parallelism,  // degree of parallelism
    required int keyLength,    // derived key length in bytes
  }) = _KdfParams;

  factory KdfParams.fromJson(Map<String, dynamic> json) =>
      _$KdfParamsFromJson(json);

  /// Argon2id secure defaults (OWASP recommended minimums).
  factory KdfParams.argon2idDefaults() => const KdfParams(
        memory: 65536,     // 64 MB
        iterations: 3,
        parallelism: 4,
        keyLength: 32,     // 256-bit key
      );
}

/// Stores cryptographic metadata only — the master key is NEVER persisted.
@freezed
abstract class MasterKeyConfig with _$MasterKeyConfig {
  const factory MasterKeyConfig({
    /// Random salt generated once at vault creation (base64-encoded).
    required String salt,
    required KdfAlgorithm kdfAlgorithm,
    required KdfParams kdfParams,
    /// Encrypted verification token used to confirm the master password
    /// without storing the key. Format: base64(iv + ciphertext + tag).
    required String verificationData,
  }) = _MasterKeyConfig;

  factory MasterKeyConfig.fromJson(Map<String, dynamic> json) =>
      _$MasterKeyConfigFromJson(json);
}
