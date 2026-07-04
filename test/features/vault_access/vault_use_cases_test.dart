import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:password_manager/core/infrastructure/database/app_database.dart';
import 'package:password_manager/core/infrastructure/security/i_security_service.dart';
import 'package:password_manager/core/infrastructure/security/session_manager.dart';
import 'package:password_manager/core/services/brute_force_guard.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/infrastructure/credential_dto.dart';
import 'package:password_manager/features/secure_files/domain/entities/secure_file.dart';
import 'package:password_manager/features/secure_files/domain/repositories/i_secure_file_repository.dart';
import 'package:password_manager/features/settings/domain/entities/app_security_settings.dart';
import 'package:password_manager/features/settings/domain/repositories/i_settings_repository.dart';
import 'package:password_manager/features/vault_access/application/setup_vault_use_case.dart';
import 'package:password_manager/features/vault_access/application/unlock_vault_use_case.dart';
import 'package:password_manager/features/vault_access/application/vault_exceptions.dart';
import 'package:password_manager/features/vault_access/application/wipe_vault_use_case.dart';
import 'package:password_manager/features/vault_access/domain/entities/master_key_config.dart';
import 'package:password_manager/features/vault_access/domain/entities/vault.dart';
import 'package:password_manager/features/vault_access/domain/repositories/i_vault_repository.dart';

import '../../support/fake_secure_storage.dart';

/// Deterministic stand-in for the crypto service. Never runs real Argon2id/AES;
/// it maps a password to a stable 32-byte "key" and models verification as an
/// exact key match, which is all the use-case branching needs.
class _FakeSecurityService implements ISecurityService {
  static const _saltB64 = 'ZmFrZS1zYWx0LTMy';

  static Uint8List keyFor(String password) => Uint8List.fromList(
        List.generate(
          32,
          (i) => password.isEmpty ? 0 : password.codeUnitAt(i % password.length) & 0xFF,
        ),
      );

  @override
  Future<Uint8List> deriveKey({
    required String password,
    required String saltBase64,
    required int memory,
    required int iterations,
    required int parallelism,
  }) async =>
      keyFor(password);

  @override
  Future<String> generateSaltBase64() async => _saltB64;

  @override
  Future<String> createVerificationData(Uint8List keyBytes) async =>
      base64Encode(keyBytes);

  @override
  Future<bool> verifyKey(Uint8List keyBytes, String verificationData) async =>
      base64Encode(keyBytes) == verificationData;

  @override
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List keyBytes) =>
      throw UnimplementedError();

  @override
  Future<Uint8List> decrypt(Uint8List cipherBlob, Uint8List keyBytes) =>
      throw UnimplementedError();

  @override
  Future<Uint8List> sha256(Uint8List data) => throw UnimplementedError();
}

class _FakeVaultRepository implements IVaultRepository {
  _FakeVaultRepository({this.config});

  MasterKeyConfig? config;
  Vault? savedVault;
  MasterKeyConfig? savedConfig;

  @override
  Future<MasterKeyConfig?> getMasterKeyConfig() async => config;

  @override
  Future<void> saveMasterKeyConfig(MasterKeyConfig config) async {
    savedConfig = config;
    this.config = config;
  }

  @override
  Future<void> saveVault(Vault vault) async => savedVault = vault;

  @override
  Future<Vault?> getVault() async => savedVault;

  @override
  Future<bool> isVaultInitialized() async => config != null;
}

class _FakeSettingsRepository implements ISettingsRepository {
  _FakeSettingsRepository(this.settings);
  AppSecuritySettings settings;

  @override
  Future<AppSecuritySettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSecuritySettings settings) async =>
      this.settings = settings;
}

/// Tracks whether the guard-triggered wipe was invoked, without touching a real
/// DB. `implements` (not `extends`) sidesteps the heavyweight constructor.
class _FakeWipeUseCase implements WipeVaultUseCase {
  bool called = false;
  @override
  Future<void> execute() async => called = true;
}

class _FakeSecureFileRepository implements ISecureFileRepository {
  bool deleteAllCalled = false;

  @override
  Future<void> deleteAll() async => deleteAllCalled = true;

  @override
  Future<List<SecureFile>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

IVaultRepository _repoWithPassword(String password) {
  final key = _FakeSecurityService.keyFor(password);
  return _FakeVaultRepository(
    config: MasterKeyConfig(
      salt: _FakeSecurityService._saltB64,
      kdfAlgorithm: KdfAlgorithm.argon2id,
      kdfParams: KdfParams.argon2idDefaults(),
      verificationData: base64Encode(key),
    ),
  );
}

void main() {
  late Map<String, String> store;
  late FlutterSecureStorage storage;

  setUp(() {
    store = installInMemorySecureStorage();
    storage = const FlutterSecureStorage();
    GetIt.instance.registerSingleton<FlutterSecureStorage>(storage);
  });
  tearDown(() => GetIt.instance.reset());

  UnlockVaultUseCase buildUnlock({
    required IVaultRepository vaultRepo,
    required AppSecuritySettings settings,
    required SessionManager session,
    WipeVaultUseCase? wipe,
  }) =>
      UnlockVaultUseCase(
        vaultRepo,
        _FakeSettingsRepository(settings),
        _FakeSecurityService(),
        session,
        BruteForceGuard(storage),
        wipe ?? _FakeWipeUseCase(),
      );

  group('UnlockVaultUseCase.execute', () {
    test('rejects while in a brute-force lockout window', () async {
      // Pre-seed an active lockout in the persisted guard state.
      final until = DateTime.now()
          .add(const Duration(seconds: 60))
          .millisecondsSinceEpoch;
      store['bf_failed_attempts'] = '5';
      store['bf_lockout_until'] = '$until';

      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(),
        session: SessionManager(),
      );

      await expectLater(
        unlock.execute('correct'),
        throwsA(isA<VaultLockedOutException>()),
      );
    });

    test('correct password stores the derived key in the session', () async {
      final session = SessionManager();
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(autoLockMinutes: 7),
        session: session,
      );

      final result = await unlock.execute('correct');

      expect(result.isUnlocked, isTrue);
      expect(session.hasActiveKey, isTrue);
      expect(session.getKeyCopy(), _FakeSecurityService.keyFor('correct'));
      // Success clears any brute-force counter.
      expect(store['bf_failed_attempts'], isNull);
    });

    test('biometric-enabled unlock persists the wrapped key for reuse',
        () async {
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(biometricEnabled: true),
        session: SessionManager(),
      );

      await unlock.execute('correct');

      expect(
        store['bio_master_key'],
        base64Encode(_FakeSecurityService.keyFor('correct')),
      );
    });

    test('biometric-disabled unlock clears any stale biometric/legacy keys',
        () async {
      store['bio_master_key'] = 'stale';
      store['master_password'] = 'legacy-plaintext';

      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(biometricEnabled: false),
        session: SessionManager(),
      );

      await unlock.execute('correct');

      expect(store.containsKey('bio_master_key'), isFalse);
      expect(store.containsKey('master_password'), isFalse);
    });

    test('wrong password within free attempts records a failure, no lockout',
        () async {
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(),
        session: SessionManager(),
      );

      await expectLater(
        unlock.execute('wrong'),
        throwsA(isA<WrongMasterPasswordException>().having(
          (e) => e.lockoutAfter,
          'lockoutAfter',
          Duration.zero,
        )),
      );
      expect(store['bf_failed_attempts'], '1');
    });

    test('reaching the wipe threshold across attempts wipes the vault',
        () async {
      final wipe = _FakeWipeUseCase();
      UnlockVaultUseCase build() => buildUnlock(
            vaultRepo: _repoWithPassword('correct'),
            settings: const AppSecuritySettings(wipeAfterFailedAttempts: 2),
            session: SessionManager(),
            wipe: wipe,
          );

      // First wrong attempt: below threshold -> plain wrong-password error.
      await expectLater(
        build().execute('wrong'),
        throwsA(isA<WrongMasterPasswordException>()),
      );
      expect(wipe.called, isFalse);

      // Second wrong attempt: hits the threshold -> wipe + VaultWipedException.
      await expectLater(
        build().execute('wrong'),
        throwsA(isA<VaultWipedException>()),
      );
      expect(wipe.called, isTrue);
    });

    test('throws when the vault is not initialized', () async {
      final unlock = buildUnlock(
        vaultRepo: _FakeVaultRepository(config: null),
        settings: const AppSecuritySettings(),
        session: SessionManager(),
      );

      await expectLater(
        unlock.execute('whatever'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('UnlockVaultUseCase.executeBiometrics', () {
    test('reads back the stored key and unlocks', () async {
      final key = _FakeSecurityService.keyFor('correct');
      store['bio_master_key'] = base64Encode(key);
      final session = SessionManager();
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(biometricEnabled: true),
        session: session,
      );

      final result = await unlock.executeBiometrics();

      expect(result.isUnlocked, isTrue);
      expect(session.getKeyCopy(), key);
    });

    test('throws when biometrics are disabled', () async {
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(biometricEnabled: false),
        session: SessionManager(),
      );

      await expectLater(
        unlock.executeBiometrics(),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when no biometric key is stored', () async {
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(biometricEnabled: true),
        session: SessionManager(),
      );

      await expectLater(
        unlock.executeBiometrics(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('UnlockVaultUseCase.executeWithRawKey', () {
    test('a valid raw key unlocks the session', () async {
      final key = _FakeSecurityService.keyFor('correct');
      final session = SessionManager();
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(),
        session: session,
      );

      final result = await unlock.executeWithRawKey(Uint8List.fromList(key));

      expect(result.isUnlocked, isTrue);
      expect(session.getKeyCopy(), key);
    });

    test('an invalid raw key throws and is zeroed', () async {
      final wrong = Uint8List.fromList(List.filled(32, 9));
      final session = SessionManager();
      final unlock = buildUnlock(
        vaultRepo: _repoWithPassword('correct'),
        settings: const AppSecuritySettings(),
        session: session,
      );

      await expectLater(
        unlock.executeWithRawKey(wrong),
        throwsA(isA<ArgumentError>()),
      );
      expect(session.hasActiveKey, isFalse);
      expect(wrong.every((b) => b == 0), isTrue);
    });
  });

  group('SetupVaultUseCase', () {
    SetupVaultUseCase buildSetup({
      required _FakeVaultRepository vaultRepo,
      required AppSecuritySettings settings,
      required SessionManager session,
    }) =>
        SetupVaultUseCase(
          vaultRepo,
          _FakeSettingsRepository(settings),
          _FakeSecurityService(),
          session,
        );

    test('creates the vault + master-key config and unlocks the session',
        () async {
      final repo = _FakeVaultRepository();
      final session = SessionManager();
      final setup = buildSetup(
        vaultRepo: repo,
        settings: const AppSecuritySettings(autoLockMinutes: 3),
        session: session,
      );

      final result = await setup.execute('brand-new');

      expect(result.isUnlocked, isTrue);
      expect(session.getKeyCopy(), _FakeSecurityService.keyFor('brand-new'));
      expect(repo.savedVault?.isInitialized, isTrue);
      final config = repo.savedConfig;
      expect(config, isNotNull);
      expect(config!.salt, isNotEmpty);
      expect(config.kdfAlgorithm, KdfAlgorithm.argon2id);
      // Verification data must round-trip against the derived key.
      expect(
        config.verificationData,
        base64Encode(_FakeSecurityService.keyFor('brand-new')),
      );
    });

    test('persists the biometric key only when biometrics are enabled',
        () async {
      final withBio = _FakeVaultRepository();
      await buildSetup(
        vaultRepo: withBio,
        settings: const AppSecuritySettings(biometricEnabled: true),
        session: SessionManager(),
      ).execute('pw');
      expect(
        store['bio_master_key'],
        base64Encode(_FakeSecurityService.keyFor('pw')),
      );

      store.remove('bio_master_key');

      await buildSetup(
        vaultRepo: _FakeVaultRepository(),
        settings: const AppSecuritySettings(biometricEnabled: false),
        session: SessionManager(),
      ).execute('pw');
      expect(store.containsKey('bio_master_key'), isFalse);
    });
  });

  group('WipeVaultUseCase', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() async => db.close());

    test('locks the session, clears the DB, secure storage and files',
        () async {
      // Seed everything the wipe should destroy.
      store['x'] = 'y';
      final session = SessionManager()
        ..storeKey(Uint8List.fromList(List.filled(32, 1)));
      final secureFiles = _FakeSecureFileRepository();
      await db.credentialDao.upsert(
        CredentialDto.toCompanion(
          credential: Credential(
            id: 'seed',
            type: CredentialType.password,
            title: 'seed',
            createdAt: DateTime(2020),
            updatedAt: DateTime(2020),
          ),
          encryptedPayload: Uint8List(0),
        ),
      );
      expect((await db.select(db.credentialEntries).get()), isNotEmpty);

      await WipeVaultUseCase(storage, db, session, secureFiles).execute();

      expect(secureFiles.deleteAllCalled, isTrue);
      expect(session.hasActiveKey, isFalse);
      expect((await db.select(db.credentialEntries).get()), isEmpty);
      expect(store, isEmpty);
    });
  });
}
