import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/vault/vault_store.dart';
import '../../../core/services/rotation_schedule.dart';

/// Borra la boveda entera: cierra la sesion, borra la boveda v2 (registros y archivos) y todo el almacen seguro
/// (clave de la biometria, llaves de sync, contadores...). Despues la app vuelve a la configuracion inicial.
///
/// Lo usa el guardian anti fuerza bruta al llegar al limite de intentos fallidos.
@lazySingleton
class WipeVaultUseCase {
  WipeVaultUseCase(this._storage, this._vault, this._rotation);

  final FlutterSecureStorage _storage;
  final VaultStore _vault;
  final RotationSchedule _rotation;

  Future<void> execute() async {
    await _vault.wipe();
    await _rotation.clear();
    await _storage.deleteAll();
  }
}
