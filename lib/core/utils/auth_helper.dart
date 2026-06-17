import 'package:flutter/material.dart';

import '../../app/di/injection.dart';
import '../../theme/app_palette.dart';
import '../services/biometric_auth_service.dart';

/// Funciones auxiliares para requerir autenticación contextual antes de acciones sensibles.
class AuthHelper {
  /// Solicita al servicio biométrico una validación.
  /// Si tiene éxito, devuelve true. De lo contrario, muestra un SnackBar de error y devuelve false.
  static Future<bool> requireAuth(
    BuildContext context, {
    String reason = 'Verifica tu identidad para continuar',
  }) async {
    final bioService = getIt<BiometricAuthService>();
    final success = await bioService.authenticate(reason: reason);

    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Autenticación cancelada o fallida'),
            backgroundColor: context.palette.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    return success;
  }
}
