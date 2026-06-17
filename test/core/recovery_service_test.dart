import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/security/security_service_impl.dart';
import 'package:password_manager/core/infrastructure/security/session_manager.dart';
import 'package:password_manager/core/services/recovery_service.dart';
import 'package:password_manager/features/vault_access/domain/entities/master_key_config.dart';
import 'package:password_manager/features/vault_access/domain/entities/vault.dart';
import 'package:password_manager/features/vault_access/domain/repositories/i_vault_repository.dart';

class FakeSecureStorage extends FlutterSecureStorage {
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
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data.containsKey(key);
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

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.clear;
  }
}

class FakeVaultRepository implements IVaultRepository {
  MasterKeyConfig? config;

  @override
  Future<Vault?> getVault() async => null;

  @override
  Future<void> saveVault(Vault vault) async {}

  @override
  Future<MasterKeyConfig?> getMasterKeyConfig() async => config;

  @override
  Future<void> saveMasterKeyConfig(MasterKeyConfig config) async {
    this.config = config;
  }

  @override
  Future<bool> isVaultInitialized() async => config != null;
}

void main() {
  late FakeSecureStorage storage;
  late SecurityServiceImpl security;
  late SessionManager session;
  late FakeVaultRepository vaultRepo;
  late RecoveryService recoveryService;

  setUp(() {
    storage = FakeSecureStorage();
    security = SecurityServiceImpl();
    session = SessionManager();
    vaultRepo = FakeVaultRepository();
    recoveryService = RecoveryService(storage, security, session, vaultRepo);
  });

  group('RecoveryService Tests', () {
    test('generateRecoveryCode fails if vault is locked', () async {
      expect(
        () => recoveryService.generateRecoveryCode(),
        throwsStateError,
      );
    });

    test('generateRecoveryCode creates valid recovery artifacts when unlocked', () async {
      final masterKey = Uint8List.fromList(List.generate(32, (i) => i));
      session.storeKey(masterKey);

      final code = await recoveryService.generateRecoveryCode();
      expect(code, isNotEmpty);
      expect(code.split('-').length, greaterThan(1)); // should be grouped in 4s

      // Should have stored artifacts in storage
      final hasHash = await recoveryService.hasRecoveryCode();
      expect(hasHash, isTrue);

      final hash = await storage.read(key: 'recovery_key_hash');
      expect(hash, isNotNull);

      final encMaster = await storage.read(key: 'recovery_encrypted_master');
      expect(encMaster, isNotNull);
    });

    test('unlockWithRecoveryCode recovers master key and resets password', () async {
      final masterKey = Uint8List.fromList(List.generate(32, (i) => i));
      session.storeKey(masterKey);

      // Generate recovery code
      final code = await recoveryService.generateRecoveryCode();

      // Clear session to simulate lock/loss
      session.lock();
      expect(session.hasActiveKey, isFalse);

      // Try unlocking with incorrect code
      final wrongSuccess = await recoveryService.unlockWithRecoveryCode('A-B-C-D-E');
      expect(wrongSuccess, isFalse);
      expect(session.hasActiveKey, isFalse);

      // Try unlocking with correct code
      final success = await recoveryService.unlockWithRecoveryCode(code);
      expect(success, isTrue);
      expect(session.hasActiveKey, isTrue);
      expect(session.getKeyCopy(), equals(masterKey));

      // Reset password flow
      final salt = await security.generateSaltBase64();
      final initConfig = MasterKeyConfig(
        salt: salt,
        kdfAlgorithm: KdfAlgorithm.argon2id,
        kdfParams: const KdfParams(
          memory: 4096, // low params for fast tests
          iterations: 1,
          parallelism: 1,
          keyLength: 32,
        ),
        verificationData: '',
      );
      vaultRepo.config = initConfig;

      await recoveryService.resetMasterPassword('new-secure-password');

      // The vault configuration should be updated
      expect(vaultRepo.config, isNotNull);
      expect(vaultRepo.config!.verificationData, isNotEmpty);

      // Verify the new master key decrypts verification data
      final newMasterKey = session.getKeyCopy()!;
      final isNewKeyValid = await security.verifyKey(
        newMasterKey,
        vaultRepo.config!.verificationData,
      );
      expect(isNewKeyValid, isTrue);
    });
  });
}
