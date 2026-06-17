import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/security/double_envelope_service.dart';
import 'package:password_manager/core/infrastructure/security/security_service_impl.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  late SecurityServiceImpl securityService;
  late FakeSecureStorage secureStorage;
  late DoubleEnvelopeService sut;

  setUp(() {
    securityService = SecurityServiceImpl();
    secureStorage = FakeSecureStorage();
    sut = DoubleEnvelopeService(securityService, secureStorage);
  });

  group('DoubleEnvelopeService', () {
    const plaintext = 'my-ultra-secret-password-123';
    const pin = '4321';
    const credentialId = 'test-cred-id-123';

    test('encrypts and decrypts successfully with correct PIN', () async {
      final encrypted = await sut.encryptField(plaintext: plaintext, pin: pin);
      
      expect(encrypted, startsWith('double_enc_v1:'));
      
      final decrypted = await sut.decryptField(encryptedValue: encrypted, pin: pin);
      expect(decrypted, equals(plaintext));
    });

    test('decrypting with wrong PIN throws exception', () async {
      final encrypted = await sut.encryptField(plaintext: plaintext, pin: pin);
      
      expect(
        () => sut.decryptField(encryptedValue: encrypted, pin: 'wrong-pin'),
        throwsA(anything),
      );
    });

    test('saves, reads and deletes PIN in secure storage', () async {
      // 1. Save
      await sut.savePinToSecureStorage(credentialId: credentialId, pin: pin);
      
      // 2. Read
      final readPin = await sut.getPinFromSecureStorage(credentialId);
      expect(readPin, equals(pin));
      
      // 3. Delete
      await sut.deletePinFromSecureStorage(credentialId);
      final readDeleted = await sut.getPinFromSecureStorage(credentialId);
      expect(readDeleted, isNull);
    });
  });
}
