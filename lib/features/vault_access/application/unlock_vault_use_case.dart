import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../app/di/injection.dart';

import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../../core/services/brute_force_guard.dart';
import '../domain/entities/vault_session.dart';
import '../domain/repositories/i_vault_repository.dart';
import '../../settings/domain/repositories/i_settings_repository.dart';
import 'vault_exceptions.dart';
import 'wipe_vault_use_case.dart';

@lazySingleton
class UnlockVaultUseCase {
  const UnlockVaultUseCase(
    this._vaultRepo,
    this._settingsRepo,
    this._security,
    this._session,
    this._guard,
    this._wipe,
  );

  final IVaultRepository _vaultRepo;
  final ISettingsRepository _settingsRepo;
  final ISecurityService _security;
  final SessionManager _session;
  final BruteForceGuard _guard;
  final WipeVaultUseCase _wipe;

  Future<VaultSession> execute(String masterPassword) async {
    // Anti brute-force: reject attempts while in a lockout window.
    final guardState = await _guard.currentState();
    if (guardState.isLockedOut) {
      throw VaultLockedOutException(guardState.lockoutRemaining);
    }

    final config = await _vaultRepo.getMasterKeyConfig();
    if (config == null) throw StateError('Vault not initialized');

    // SEC-003: Convertir a bytes inmediatamente y borrar el buffer tras el KDF
    // para minimizar el tiempo que la contraseña en texto plano ocupa el heap.
    // Nota: el String original en el call-stack no se puede borrar por ser
    // inmutable en Dart (limitación documentada del runtime).
    final passwordBytes = Uint8List.fromList(utf8.encode(masterPassword));

    late final Uint8List keyBytes;
    try {
      keyBytes = await _security.deriveKey(
        password: String.fromCharCodes(passwordBytes), // KDF recibe String
        saltBase64: config.salt,
        memory: config.kdfParams.memory,
        iterations: config.kdfParams.iterations,
        parallelism: config.kdfParams.parallelism,
      );
    } finally {
      // Borrar el buffer de bytes de la contraseña, aunque el String original
      // puede seguir vivo hasta el próximo GC.
      passwordBytes.fillRange(0, passwordBytes.length, 0);
    }

    final isValid = await _security.verifyKey(keyBytes, config.verificationData);
    final settings = await _settingsRepo.getSettings();

    if (!isValid) {
      // Zero the derived (wrong) key before bailing out.
      keyBytes.fillRange(0, keyBytes.length, 0);
      final state = await _guard.recordFailure();
      if (BruteForceGuard.shouldWipe(
          state.failedAttempts, settings.wipeAfterFailedAttempts)) {
        await _wipe.execute();
        throw const VaultWipedException();
      }
      throw WrongMasterPasswordException(state.lockoutRemaining);
    }

    // Correct password: clear the brute-force counter.
    await _guard.recordSuccess();
    _session.storeKey(keyBytes);

    if (settings.biometricEnabled) {
      await getIt<FlutterSecureStorage>()
          .write(key: 'bio_master_key', value: base64Encode(keyBytes));
    } else {
      await getIt<FlutterSecureStorage>().delete(key: 'bio_master_key');
    }
    // El WiFi-unlock ya NO usa la contrasena en texto plano (usa un token DUK);
    // limpiamos cualquier 'master_password' heredado de versiones anteriores.
    await getIt<FlutterSecureStorage>().delete(key: 'master_password');

    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  Future<VaultSession> executeBiometrics() async {
    final settings = await _settingsRepo.getSettings();
    if (!settings.biometricEnabled) throw StateError('Biometría desactivada');

    final keyBase64 =
        await getIt<FlutterSecureStorage>().read(key: 'bio_master_key');
    if (keyBase64 == null) throw StateError('Llave biométrica no encontrada');

    final keyBytes = base64Decode(keyBase64);
    _session.storeKey(keyBytes);

    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  /// Unlocks the vault with a raw master key (e.g. from a WiFi remote-unlock DUK
  /// that decrypted the locally-wrapped key). Verifies the key against the
  /// stored verification data before storing it in the session.
  Future<VaultSession> executeWithRawKey(Uint8List keyBytes) async {
    final config = await _vaultRepo.getMasterKeyConfig();
    if (config == null) throw StateError('Vault not initialized');

    final isValid = await _security.verifyKey(keyBytes, config.verificationData);
    if (!isValid) {
      keyBytes.fillRange(0, keyBytes.length, 0);
      throw ArgumentError('Invalid master key');
    }

    await _guard.recordSuccess();
    _session.storeKey(keyBytes);

    final settings = await _settingsRepo.getSettings();
    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  void lock() => _session.lock();
}
