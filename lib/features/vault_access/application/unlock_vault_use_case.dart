import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/rust/api/error.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../../core/infrastructure/vault/vault_store.dart';
import '../../../core/services/brute_force_guard.dart';
import '../../../core/services/rotation_schedule.dart';
import '../../credentials/infrastructure/credential_dto.dart';
import '../../settings/domain/repositories/i_settings_repository.dart';
import '../domain/entities/vault_session.dart';
import 'setup_vault_use_case.dart';
import 'vault_exceptions.dart';
import 'wipe_vault_use_case.dart';

/// Abre la boveda v2 del nucleo Rust (NUC-2). La primera vez con una v1 en el equipo, la migra antes.
@lazySingleton
class UnlockVaultUseCase {
  const UnlockVaultUseCase(
    this._vault,
    this._settingsRepo,
    this._session,
    this._guard,
    this._wipe,
    this._storage,
    this._rotation,
  );

  final VaultStore _vault;
  final ISettingsRepository _settingsRepo;
  final SessionManager _session;
  final BruteForceGuard _guard;
  final WipeVaultUseCase _wipe;
  final FlutterSecureStorage _storage;
  final RotationSchedule _rotation;

  Future<VaultSession> execute(String masterPassword) async {
    // Anti fuerza bruta: rechazar mientras dura el bloqueo.
    final guardState = await _guard.currentState();
    if (guardState.isLockedOut) {
      throw VaultLockedOutException(guardState.lockoutRemaining);
    }

    final settings = await _settingsRepo.getSettings();
    try {
      await _vault.open(masterPassword);
    } on CoreFailure catch (e) {
      if (e.code != FailureCode.wrongPassword) rethrow;
      final state = await _guard.recordFailure();
      if (BruteForceGuard.shouldWipe(
          state.failedAttempts, settings.wipeAfterFailedAttempts)) {
        await _wipe.execute();
        throw const VaultWipedException();
      }
      throw WrongMasterPasswordException(state.lockoutRemaining);
    }

    await _guard.recordSuccess();
    if (settings.biometricEnabled) {
      await storeBiometricKey(_session, _storage);
    } else {
      await _storage.delete(key: 'bio_master_key');
    }
    await _afterOpen();
    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  Future<VaultSession> executeBiometrics() async {
    final settings = await _settingsRepo.getSettings();
    if (!settings.biometricEnabled) throw StateError('Biometría desactivada');

    final keyBase64 = await _storage.read(key: 'bio_master_key');
    if (keyBase64 == null) throw StateError('Llave biométrica no encontrada');

    final key = base64Decode(keyBase64);
    try {
      await _vault.openWithKey(key);
    } finally {
      key.fillRange(0, key.length, 0);
    }
    await _afterOpen();
    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  /// Abre con la clave de la boveda en bruto (desbloqueo remoto por WiFi, que la desenvuelve con su token).
  /// El nucleo la comprueba contra la cabecera.
  Future<VaultSession> executeWithRawKey(Uint8List keyBytes) async {
    try {
      await _vault.openWithKey(keyBytes);
    } on CoreFailure {
      throw ArgumentError('Invalid master key');
    } finally {
      keyBytes.fillRange(0, keyBytes.length, 0);
    }

    await _guard.recordSuccess();
    await _afterOpen();
    final settings = await _settingsRepo.getSettings();
    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }

  /// Rehace la agenda de rotacion (sin secretos) que lee el aviso de segundo plano.
  Future<void> _afterOpen() async {
    try {
      final rows = await _vault.list(RecordKind.credential);
      await _rotation.rebuild([for (final r in rows) CredentialDto.fromRecord(r)]);
    } catch (_) {
      // La agenda es un aviso: si falla, el desbloqueo sigue.
    }
  }

  void lock() => _vault.lock();
}
