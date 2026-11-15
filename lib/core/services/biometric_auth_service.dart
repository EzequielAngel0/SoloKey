import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

/// Servicio para manejar la autenticación biométrica o por PIN del dispositivo.
///
/// Encapsula a [LocalAuthentication] y provee un método de conveniencia para la Fase 13.
@lazySingleton
class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta alguna forma de autenticación local.
  Future<bool> isAuthAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Solicita autenticación local al usuario (huella, rostro o PIN/patrón de fallback).
  /// [reason] es el mensaje que se muestra en el diálogo del sistema operativo.
  Future<bool> authenticate({required String reason}) async {
    final available = await isAuthAvailable();
    if (!available) {
      // Si el SO no tiene auth soportada/configurada, por defecto fallamos de manera segura.
      // O bien podemos decidir devolver true si queremos evitar bloquear a usuarios sin auth,
      // pero por las reglas de Auditor_Seguridad_Mobile fallar de manera segura es preferible.
      return false;
    }

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (_) {
      // Cancelado, bloqueado o sin credenciales: se falla de forma segura.
      return false;
    } on PlatformException catch (_) {
      // Errores de plataforma que local_auth 3 no traduce.
      return false;
    }
  }
}
