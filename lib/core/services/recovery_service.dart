import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../infrastructure/security/i_security_service.dart';
import '../infrastructure/security/session_manager.dart';
import '../../features/vault_access/domain/repositories/i_vault_repository.dart';

/// Manages the recovery key lifecycle.
///
/// Security design:
/// - At vault setup, a 32-byte random recovery key is generated.
/// - SHA-256 hash of the key is stored in SecureStorage (not the key itself).
/// - The raw AES master key is encrypted WITH the recovery key and stored.
/// - To recover: user provides raw recovery key → decrypt master key → re-encrypt with new password.
@lazySingleton
class RecoveryService {
  RecoveryService(this._storage, this._security, this._session, this._vaultRepo);

  final FlutterSecureStorage _storage;
  final ISecurityService _security;
  final SessionManager _session;
  final IVaultRepository _vaultRepo;

  static const _recoveryKeyHashKey = 'recovery_key_hash';
  static const _recoveryEncryptedMasterKey = 'recovery_encrypted_master';

  /// Generates a new recovery code (call after vault setup, while key is in session).
  /// Returns the base64 recovery code to show ONCE to the user.
  Future<String> generateRecoveryCode() async {
    final key = _session.getKeyCopy();
    if (key == null) throw StateError('Vault must be unlocked');

    // Generate 32 random bytes as recovery key
    final rng = Random.secure();
    final recoveryKeyBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));

    // Hash the recovery key for verification later
    final hash = await _security.sha256(recoveryKeyBytes);
    await _storage.write(
      key: _recoveryKeyHashKey,
      value: base64Encode(hash),
    );

    // Encrypt the master AES key WITH the recovery key
    final encryptedMaster =
        await _security.encrypt(key, recoveryKeyBytes);
    await _storage.write(
      key: _recoveryEncryptedMasterKey,
      value: base64Encode(encryptedMaster),
    );

    // Return human-friendly grouped code
    final raw = base64.encode(recoveryKeyBytes);
    return _groupCode(raw);
  }

  /// Returns true if a recovery code has been generated.
  Future<bool> hasRecoveryCode() async {
    final hash = await _storage.read(key: _recoveryKeyHashKey);
    return hash != null;
  }

  /// Attempts to unlock the vault using a recovery code.
  /// On success, the master key is in session and ready to re-encrypt with new password.
  Future<bool> unlockWithRecoveryCode(String code) async {
    final cleanCode = code.replaceAll(RegExp(r'[\s-]'), '');
    var normalized = cleanCode;
    final mod = normalized.length % 4;
    if (mod == 2) {
      normalized += '==';
    } else if (mod == 3) {
      normalized += '=';
    }

    late Uint8List recoveryKeyBytes;
    try {
      recoveryKeyBytes = Uint8List.fromList(base64.decode(normalized));
    } catch (_) {
      return false;
    }

    // Verify hash
    final storedHash = await _storage.read(key: _recoveryKeyHashKey);
    if (storedHash == null) return false;

    final hash = await _security.sha256(recoveryKeyBytes);
    if (base64Encode(hash) != storedHash) return false;

    // Decrypt master key
    final encryptedMasterB64 =
        await _storage.read(key: _recoveryEncryptedMasterKey);
    if (encryptedMasterB64 == null) return false;

    final masterKey = await _security.decrypt(
      base64Decode(encryptedMasterB64),
      recoveryKeyBytes,
    );

    _session.storeKey(masterKey);
    return true;
  }

  /// After recovery, re-encrypts the vault under a new master password.
  Future<void> resetMasterPassword(String newPassword) async {
    final config = await _vaultRepo.getMasterKeyConfig();
    if (config == null) throw StateError('No vault config');

    final newKey = await _security.deriveKey(
      password: newPassword,
      saltBase64: config.salt,
      memory: config.kdfParams.memory,
      iterations: config.kdfParams.iterations,
      parallelism: config.kdfParams.parallelism,
    );
    final verification = await _security.createVerificationData(newKey);

    await _vaultRepo.saveMasterKeyConfig(
      config.copyWith(verificationData: verification),
    );
    _session.storeKey(newKey);

    // Re-encrypt the stored recovery master key with the new key
    final rng = Random.secure();
    final recoveryKeyBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    final hash = await _security.sha256(recoveryKeyBytes);
    await _storage.write(
        key: _recoveryKeyHashKey, value: base64Encode(hash));
    final encryptedMaster = await _security.encrypt(newKey, recoveryKeyBytes);
    await _storage.write(
        key: _recoveryEncryptedMasterKey,
        value: base64Encode(encryptedMaster));
  }

  /// Groups a base64 string into blocks of 4 for readability.
  String _groupCode(String raw) {
    final cleaned = raw.replaceAll('=', '');
    final chunks = <String>[];
    for (var i = 0; i < cleaned.length; i += 4) {
      chunks.add(cleaned.substring(i, min(i + 4, cleaned.length)));
    }
    return chunks.join('-');
  }
}
