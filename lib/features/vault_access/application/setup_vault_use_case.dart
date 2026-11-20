import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/security/session_manager.dart';
import '../../../core/infrastructure/vault/vault_store.dart';
import '../../../features/settings/domain/repositories/i_settings_repository.dart';
import '../domain/entities/vault_session.dart';

/// Crea la boveda v2 en el nucleo Rust (NUC-2) y la deja abierta.
@lazySingleton
class SetupVaultUseCase {
  const SetupVaultUseCase(
    this._vault,
    this._settingsRepo,
    this._session,
    this._storage,
  );

  final VaultStore _vault;
  final ISettingsRepository _settingsRepo;
  final SessionManager _session;
  final FlutterSecureStorage _storage;

  Future<VaultSession> execute(String masterPassword) async {
    await _vault.create(masterPassword);

    final settings = await _settingsRepo.getSettings();
    if (settings.biometricEnabled) {
      await storeBiometricKey(_session, _storage);
    }
    return VaultSession.unlocked(autoLockMinutes: settings.autoLockMinutes);
  }
}

/// Guarda la clave de la boveda para la biometria y borra la copia en RAM.
Future<void> storeBiometricKey(
    SessionManager session, FlutterSecureStorage storage) async {
  final key = await session.keyCopy();
  if (key == null) return;
  try {
    await storage.write(key: 'bio_master_key', value: base64Encode(key));
  } finally {
    key.fillRange(0, key.length, 0);
  }
}
