import 'dart:convert';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../rust/api/crypto.dart' as core;
import 'i_security_service.dart';

/// Cripto de la boveda en el nucleo Rust (NUC-1, ADR-0008): Argon2id y AES-256-GCM de RustCrypto, mismo formato
/// que la v1. Corre en el pool de hilos del puente, asi que no bloquea la interfaz.
@LazySingleton(as: ISecurityService)
class SecurityServiceImpl implements ISecurityService {
  @override
  Future<Uint8List> deriveKey({
    required String password,
    required String saltBase64,
    required int memory,
    required int iterations,
    required int parallelism,
  }) =>
      // utf8.encode: los mismos bytes que pasaba la libreria `cryptography` de la v1.
      core.deriveKey(
        password: utf8.encode(password),
        salt: base64Decode(saltBase64),
        memoryKib: memory,
        iterations: iterations,
        parallelism: parallelism,
      );

  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List keyBytes) =>
      core.encrypt(plaintext: plaintext, key: keyBytes);

  @override
  Future<Uint8List> decrypt(Uint8List cipherBlob, Uint8List keyBytes) =>
      core.decrypt(blob: cipherBlob, key: keyBytes);

  @override
  Future<String> generateSaltBase64() async =>
      base64Encode(await core.generateSalt());

  @override
  Future<String> createVerificationData(Uint8List keyBytes) async =>
      base64Encode(await core.createVerificationData(key: keyBytes));

  @override
  Future<bool> verifyKey(Uint8List keyBytes, String verificationData) async {
    final Uint8List blob;
    try {
      blob = base64Decode(verificationData);
    } on FormatException {
      return false;
    }
    return core.verifyKey(key: keyBytes, verification: blob);
  }

  @override
  Future<Uint8List> sha256(Uint8List data) => core.sha256(data: data);
}
