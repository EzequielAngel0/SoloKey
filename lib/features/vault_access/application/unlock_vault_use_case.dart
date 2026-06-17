import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../app/di/injection.dart';

import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../domain/entities/vault_session.dart';
import '../domain/repositories/i_vault_repository.dart';
import '../../settings/domain/repositories/i_settings_repository.dart';

@lazySingleton
class UnlockVaultUseCase {
  const UnlockVaultUseCase(
    this._vaultRepo,
    this._settingsRepo,
    this._security,
    this._session,
  );

  final IVaultRepository _vaultRepo;
  final ISettingsRepository _settingsRepo;
  final ISecurityService _security;
  final SessionManager _session;

  Future<VaultSession> execute(String masterPassword) async {
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
    if (!isValid) throw ArgumentError('Invalid master password');

    final settings = await _settingsRepo.getSettings();
    _session.storeKey(keyBytes);

    if (settings.biometricEnabled) {
      await getIt<FlutterSecureStorage>()
          .write(key: 'bio_master_key', value: base64Encode(keyBytes));
      await getIt<FlutterSecureStorage>()
          .write(key: 'master_password', value: masterPassword);
    } else {
      await getIt<FlutterSecureStorage>().delete(key: 'bio_master_key');
      await getIt<FlutterSecureStorage>().delete(key: 'master_password');
    }

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

  void lock() => _session.lock();
}
