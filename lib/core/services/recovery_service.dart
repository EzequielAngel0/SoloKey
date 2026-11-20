import 'package:injectable/injectable.dart';

import '../infrastructure/security/session_manager.dart';
import '../infrastructure/vault/vault_store.dart';

/// Codigo de recuperacion de la boveda v2 (NUC-2): lo guarda el nucleo Rust envolviendo la clave de la boveda en
/// la cabecera; aqui solo se pide, se comprueba y se usa. Nada del codigo ni de la clave queda en el almacen seguro.
@lazySingleton
class RecoveryService {
  RecoveryService(this._vault, this._session);

  final VaultStore _vault;
  final SessionManager _session;

  /// Codigo comprobado en el paso 1 de la pantalla, para el paso 2.
  String? _pendingCode;

  /// El codigo para mostrar UNA vez: el de la boveda recien creada o, si no, uno nuevo que invalida el anterior.
  Future<String> generateRecoveryCode() async {
    if (!_session.hasActiveKey) throw StateError('Vault must be unlocked');
    return _vault.takeCreatedRecoveryCode() ??
        await _session.handle.resetRecovery();
  }

  /// Si la boveda abierta tiene codigo de recuperacion.
  Future<bool> hasRecoveryCode() async {
    if (!_session.hasActiveKey) return false;
    return _session.handle.hasRecovery();
  }

  /// Paso 1: comprueba el codigo sin cambiar nada.
  Future<bool> unlockWithRecoveryCode(String code) async {
    final ok = await _vault.checkRecovery(code.trim());
    _pendingCode = ok ? code.trim() : null;
    return ok;
  }

  /// Paso 2: abre con el codigo comprobado y pone la maestra nueva. El codigo sigue sirviendo.
  Future<void> resetMasterPassword(String newPassword) async {
    final code = _pendingCode;
    if (code == null) throw StateError('Recovery code not verified');
    await _vault.recover(code, newPassword);
    _pendingCode = null;
  }
}
