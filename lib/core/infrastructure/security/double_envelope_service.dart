import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'i_security_service.dart';

@lazySingleton
class DoubleEnvelopeService {
  const DoubleEnvelopeService(this._securityService, this._secureStorage);

  final ISecurityService _securityService;
  final FlutterSecureStorage _secureStorage;

  // Use slightly lighter but still highly secure Argon2id params for secondary PIN to balance UX
  static const int _kdfMemory = 32768; // 32MB
  static const int _kdfIterations = 2;
  static const int _kdfParallelism = 2;

  /// Derives a 256-bit key from the [pin] and [saltBase64] using Argon2id.
  Future<Uint8List> _deriveKey(String pin, String saltBase64) async {
    return _securityService.deriveKey(
      password: pin,
      saltBase64: saltBase64,
      memory: _kdfMemory,
      iterations: _kdfIterations,
      parallelism: _kdfParallelism,
    );
  }

  /// Encrypts a sensitive field value with a secondary PIN and salt.
  /// Returns a formatted string `double_enc_v1:<saltBase64>:<base64CiphertextBlob>`.
  Future<String> encryptField({
    required String plaintext,
    required String pin,
  }) async {
    final saltBase64 = await _securityService.generateSaltBase64();
    final keyBytes = await _deriveKey(pin, saltBase64);
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final encryptedBytes = await _securityService.encrypt(plaintextBytes, keyBytes);
    final ciphertextBase64 = base64Encode(encryptedBytes);
    return 'double_enc_v1:$saltBase64:$ciphertextBase64';
  }

  /// Decrypts a sensitive field value using the secondary PIN.
  Future<String> decryptField({
    required String encryptedValue,
    required String pin,
  }) async {
    if (!encryptedValue.startsWith('double_enc_v1:')) {
      throw ArgumentError('Invalid double-envelope ciphertext format');
    }
    
    final parts = encryptedValue.split(':');
    if (parts.length != 3) {
      throw ArgumentError('Malformed double-envelope ciphertext');
    }

    final saltBase64 = parts[1];
    final ciphertextBase64 = parts[2];

    final keyBytes = await _deriveKey(pin, saltBase64);
    final cipherBlob = base64Decode(ciphertextBase64);
    final decryptedBytes = await _securityService.decrypt(cipherBlob, keyBytes);
    return utf8.decode(decryptedBytes);
  }

  /// Stores a PIN in secure storage for a specific credential ID (for biometric unlock).
  Future<void> savePinToSecureStorage({
    required String credentialId,
    required String pin,
  }) async {
    await _secureStorage.write(
      key: _storageKey(credentialId),
      value: pin,
    );
  }

  /// Reads a PIN from secure storage for a specific credential ID.
  Future<String?> getPinFromSecureStorage(String credentialId) async {
    return _secureStorage.read(key: _storageKey(credentialId));
  }

  /// Deletes a stored PIN from secure storage.
  Future<void> deletePinFromSecureStorage(String credentialId) async {
    await _secureStorage.delete(key: _storageKey(credentialId));
  }

  String _storageKey(String credentialId) => 'double_pin_$credentialId';
}
