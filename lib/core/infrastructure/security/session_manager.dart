import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../rust/api/vault.dart';

/// La sesion abierta: el `VaultHandle` del nucleo Rust (NUC-2). La clave de la boveda vive en el nucleo, no en Dart;
/// [keyCopy] da una copia solo cuando hace falta (guardarla tras la biometria) y quien la recibe la borra.
/// [lock] cierra el handle y el nucleo pone a cero la clave y el indice.
@LazySingleton()
class SessionManager {
  VaultHandle? _handle;

  bool get hasActiveKey => _handle != null;

  /// El handle abierto. Lanza [StateError] con la boveda bloqueada.
  VaultHandle get handle {
    final h = _handle;
    if (h == null) throw StateError('Vault is locked');
    return h;
  }

  /// Lo llama `VaultStore` al abrir. Cierra el anterior si lo habia.
  void attach(VaultHandle handle) {
    lock();
    _handle = handle;
  }

  /// Copia de la clave de la boveda, o null con la boveda bloqueada. Quien la recibe la pone a cero.
  Future<Uint8List?> keyCopy() async {
    final h = _handle;
    if (h == null) return null;
    return h.keyCopy();
  }

  /// Cierra el handle: el nucleo pone a cero la clave y los registros descifrados.
  void lock() {
    final h = _handle;
    _handle = null;
    if (h != null) h.close();
  }
}
