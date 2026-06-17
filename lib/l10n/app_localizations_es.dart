// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get unlockSubtitle => 'Introduce tu contraseña maestra';

  @override
  String get unlockMasterPasswordHint => 'Contraseña maestra';

  @override
  String get unlockButton => 'Desbloquear';

  @override
  String unlockLockedFor(String time) {
    return 'Bloqueado ($time)';
  }

  @override
  String get unlockUseBiometrics => 'Usar biometría';

  @override
  String get unlockWifiAvailable => 'Desbloqueo WiFi disponible';

  @override
  String get unlockForgotPassword => '¿Olvidaste tu contraseña maestra?';

  @override
  String get unlockFromMobile => 'Desbloqueando desde dispositivo móvil…';

  @override
  String unlockTooManyAttempts(String time) {
    return 'Demasiados intentos. Reintenta en $time.';
  }

  @override
  String get unlockTapToEnter => 'Toca para ingresar tu contraseña';

  @override
  String unlockRemoteFailed(String msg) {
    return 'Desbloqueo remoto fallido: $msg';
  }

  @override
  String get unlockRemoteError => 'Error en desbloqueo remoto';

  @override
  String get unlockBiometricReason => 'Desbloquea tu bóveda';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsSectionAutoLock => 'Bloqueo automático';

  @override
  String get settingsSectionClipboard => 'Portapapeles';

  @override
  String get settingsSectionPrivacy => 'Privacidad';

  @override
  String get settingsSectionQuickFill => 'Autocompletado rápido';

  @override
  String get settingsAutoLockLabel => 'Bloqueo por inactividad';

  @override
  String settingsAutoLockValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsClearClipboardLabel => 'Limpiar portapapeles';

  @override
  String settingsClearClipboardValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get settingsBiometricLabel => 'Desbloqueo biométrico';

  @override
  String get settingsBiometricSubtitle => 'Usa huella dactilar o rostro';

  @override
  String get settingsObscureLabel => 'Ocultar en segundo plano';

  @override
  String get settingsObscureSubtitle =>
      'Aplica pantalla de privacidad al cambiar de app';

  @override
  String get settingsAutostartLabel => 'Iniciar con el sistema';

  @override
  String get settingsAutostartSubtitle =>
      'Arranca minimizado en la bandeja al encender el equipo';

  @override
  String get settingsQuickFillDescription =>
      'Pulsa el atajo desde cualquier app para abrir SoloKey y copiar usuario/contraseña al portapapeles (se limpia solo).';

  @override
  String get settingsQuickFillTryNow => 'Probar ahora';

  @override
  String get languageSystem => 'Seguir el sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';
}
