import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solokey/core/infrastructure/security/security_service_impl.dart';
import 'package:solokey/core/infrastructure/security/session_manager.dart';

void main() {
  late SecurityServiceImpl sut;
  late SessionManager sessionManager;

  setUp(() {
    sut = SecurityServiceImpl();
    sessionManager = SessionManager();
  });

  group('Salt generation', () {
    test('generates a valid base64 salt of 32 bytes', () async {
      final salt = await sut.generateSaltBase64();
      final bytes = base64Decode(salt);
      expect(bytes.length, 32);
    });

    test('two consecutive salts are different', () async {
      final a = await sut.generateSaltBase64();
      final b = await sut.generateSaltBase64();
      expect(a, isNot(equals(b)));
    });
  });

  group('AES-256-GCM encrypt / decrypt', () {
    late Uint8List key;

    setUp(() async {
      // Derive a test key — fast params for unit tests only.
      final salt = await sut.generateSaltBase64();
      key = await sut.deriveKey(
        password: 'test-password',
        saltBase64: salt,
        memory: 4096,   // minimal for test speed
        iterations: 1,
        parallelism: 1,
      );
    });

    test('encrypt returns nonce(12) + ciphertext + tag(16)', () async {
      final plaintext = Uint8List.fromList(utf8.encode('hello vault'));
      final blob = await sut.encrypt(plaintext, key);
      // Minimum blob size: 12 (nonce) + 0 (empty ct) + 16 (tag) = 28
      expect(blob.length, greaterThanOrEqualTo(28));
    });

    test('decrypt restores original plaintext', () async {
      final original = Uint8List.fromList(utf8.encode('super secret 1234'));
      final blob = await sut.encrypt(original, key);
      final recovered = await sut.decrypt(blob, key);
      expect(utf8.decode(recovered), utf8.decode(original));
    });

    test('each encryption of same plaintext produces a unique blob (random IV)',
        () async {
      final plaintext = Uint8List.fromList(utf8.encode('same plaintext'));
      final blob1 = await sut.encrypt(plaintext, key);
      final blob2 = await sut.encrypt(plaintext, key);
      expect(blob1, isNot(equals(blob2)));
    });

    test('decrypt throws on tampered ciphertext (GCM authentication)', () async {
      final plaintext = Uint8List.fromList(utf8.encode('tamper me'));
      final blob = await sut.encrypt(plaintext, key);
      // Flip a byte in the ciphertext section
      final tampered = Uint8List.fromList(blob);
      tampered[15] ^= 0xFF;
      expect(
        () => sut.decrypt(tampered, key),
        throwsA(anything),
      );
    });

    test('decrypt throws with wrong key', () async {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final blob = await sut.encrypt(plaintext, key);
      final wrongKey = Uint8List(32); // all zeros
      expect(
        () => sut.decrypt(blob, wrongKey),
        throwsA(anything),
      );
    });
  });

  group('Key derivation (Argon2id)', () {
    test('same password + salt produces same key (deterministic)', () async {
      final salt = await sut.generateSaltBase64();
      final key1 = await sut.deriveKey(
        password: 'my-master-pass',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      final key2 = await sut.deriveKey(
        password: 'my-master-pass',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      expect(key1, equals(key2));
    });

    test('different password produces different key', () async {
      final salt = await sut.generateSaltBase64();
      final params = (
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      final key1 = await sut.deriveKey(
        password: 'correct-password',
        saltBase64: params.saltBase64,
        memory: params.memory,
        iterations: params.iterations,
        parallelism: params.parallelism,
      );
      final key2 = await sut.deriveKey(
        password: 'wrong-password',
        saltBase64: params.saltBase64,
        memory: params.memory,
        iterations: params.iterations,
        parallelism: params.parallelism,
      );
      expect(key1, isNot(equals(key2)));
    });

    test('derived key is 32 bytes (256-bit)', () async {
      final salt = await sut.generateSaltBase64();
      final key = await sut.deriveKey(
        password: 'password',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      expect(key.length, 32);
    });
  });

  group('Verification data (vault unlock flow)', () {
    test('createVerificationData + verifyKey returns true for correct key',
        () async {
      final salt = await sut.generateSaltBase64();
      final key = await sut.deriveKey(
        password: 'master',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      final verificationData = await sut.createVerificationData(key);
      final isValid = await sut.verifyKey(key, verificationData);
      expect(isValid, isTrue);
    });

    test('verifyKey returns false for wrong key', () async {
      final salt = await sut.generateSaltBase64();
      final correctKey = await sut.deriveKey(
        password: 'master',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      final wrongKey = await sut.deriveKey(
        password: 'wrong-master',
        saltBase64: salt,
        memory: 4096,
        iterations: 1,
        parallelism: 1,
      );
      final verificationData = await sut.createVerificationData(correctKey);
      final isValid = await sut.verifyKey(wrongKey, verificationData);
      expect(isValid, isFalse);
    });
  });

  group('SessionManager', () {
    test('hasActiveKey is false initially', () {
      expect(sessionManager.hasActiveKey, isFalse);
    });

    test('getKeyCopy returns null when locked', () {
      expect(sessionManager.getKeyCopy(), isNull);
    });

    test('stores key and returns a copy', () {
      final key = Uint8List.fromList(List.generate(32, (i) => i));
      sessionManager.storeKey(key);
      expect(sessionManager.hasActiveKey, isTrue);
      expect(sessionManager.getKeyCopy(), equals(key));
    });

    test('lock zeros and clears the key', () {
      final key = Uint8List.fromList(List.generate(32, (i) => i));
      sessionManager.storeKey(key);
      sessionManager.lock();
      expect(sessionManager.hasActiveKey, isFalse);
      expect(sessionManager.getKeyCopy(), isNull);
    });

    test('getKeyCopy returns an independent copy (not the internal buffer)', () {
      final key = Uint8List.fromList(List.generate(32, (i) => i));
      sessionManager.storeKey(key);
      final copy = sessionManager.getKeyCopy()!;
      copy[0] = 0xFF; // mutate copy
      // Internal buffer should be unaffected
      expect(sessionManager.getKeyCopy()![0], equals(0));
    });
  });
}
