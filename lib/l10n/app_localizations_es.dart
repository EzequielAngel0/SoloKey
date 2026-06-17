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

  @override
  String get splashTagline => 'Tu bóveda segura';

  @override
  String get setupTitle => 'Crear contraseña\nmaestra';

  @override
  String get setupSubtitle =>
      'Esta contraseña protege toda tu bóveda. No se puede recuperar si la olvidas.';

  @override
  String get setupMinChars => 'Mínimo 12 caracteres';

  @override
  String get setupConfirmLabel => 'Confirmar contraseña';

  @override
  String get setupPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get setupCreateButton => 'Crear bóveda';

  @override
  String get setupNeedUppercase => 'Incluye al menos una mayúscula';

  @override
  String get setupNeedNumber => 'Incluye al menos un número';

  @override
  String get setupNeedSymbol => 'Incluye al menos un símbolo';

  @override
  String get setupReqChars => '12+ caracteres';

  @override
  String get setupReqUppercase => 'Mayúscula';

  @override
  String get setupReqNumber => 'Número';

  @override
  String get setupReqSymbol => 'Símbolo';

  @override
  String get commonCreate => 'Crear';

  @override
  String get navAudit => 'Auditoría';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navCredentials => 'Credenciales';

  @override
  String get navFolders => 'Carpetas';

  @override
  String get navFavorites => 'Favoritas';

  @override
  String get homeSearchHint => 'Buscar credenciales…';

  @override
  String get homeLockTooltip => 'Bloquear';

  @override
  String get homeFabNew => 'Nueva';

  @override
  String get homeFabFolder => 'Carpeta';

  @override
  String homeLoadError(String msg) {
    return 'Error: $msg';
  }

  @override
  String get homeEmptyVault => 'Tu bóveda está vacía';

  @override
  String get emptyAddFirst => 'Añade tu primera credencial';

  @override
  String get emptyAddCredential => 'Añadir credencial';

  @override
  String get folderDialogTitle => 'Carpeta';

  @override
  String get folderNameLabel => 'Nombre de la carpeta';

  @override
  String get folderNameHint => 'ej. Trabajo, Sociales…';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String commonErrorDetail(String msg) {
    return 'Error: $msg';
  }

  @override
  String get detailNotFound => 'Credencial no encontrada';

  @override
  String get detailRemoveFavorite => 'Quitar de favoritas';

  @override
  String get detailAddFavorite => 'Añadir a favoritas';

  @override
  String get detailViewHistory => 'Ver historial de contraseñas';

  @override
  String get detailDeleteTitle => 'Eliminar credencial';

  @override
  String detailDeleteBody(String title) {
    return '¿Eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

  @override
  String get detailDeleteAuthReason => 'Verifica para eliminar esta credencial';

  @override
  String get fieldUsername => 'Usuario';

  @override
  String get fieldPassword => 'Contraseña';

  @override
  String get fieldWebsite => 'Sitio web';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldKeyType => 'Tipo de llave';

  @override
  String get fieldPrivateKey => 'Llave privada';

  @override
  String get fieldPublicKey => 'Llave pública';

  @override
  String get fieldKeyPassphrase => 'Passphrase de la llave';

  @override
  String get typePassword => 'Contraseña';

  @override
  String get typeApiKey => 'API Key';

  @override
  String get typeSecureNote => 'Nota segura';

  @override
  String get typeTotp => 'TOTP / 2FA';

  @override
  String get typePasskey => 'Respaldo de Passkey';

  @override
  String get typeSshKey => 'Llave SSH';

  @override
  String get rotationMonthly => 'Mensual';

  @override
  String get rotationQuarterly => 'Cada 3 meses';

  @override
  String get rotationSemiAnnually => 'Cada 6 meses';

  @override
  String rotationCustom(int days) {
    return 'Personalizado ($days días)';
  }

  @override
  String get rotationNone => 'Ninguno';

  @override
  String get rotationOverdueTitle => 'ROTACIÓN DE CONTRASEÑA VENCIDA';

  @override
  String get rotationReminderTitle => 'RECORDATORIO DE ROTACIÓN';

  @override
  String rotationOverdueBody(int days) {
    return 'Debes cambiar esta contraseña. Han pasado más de $days días desde la última actualización.';
  }

  @override
  String rotationReminderBody(int days, String interval) {
    return 'Próximo cambio requerido en $days días ($interval).';
  }

  @override
  String get secretDecrypting => 'Descifrando…';

  @override
  String get secretDecryptAuthReason =>
      'Autentícate para descifrar este secreto';

  @override
  String secretDecryptError(String msg) {
    return 'Error al descifrar: $msg';
  }

  @override
  String get pinDialogTitle => 'Ingresa PIN secundario';

  @override
  String get pinDialogLabel => 'PIN de sobre cifrado';

  @override
  String get totpTitle => 'Código de verificación (2FA)';

  @override
  String get totpClipboardLabel => 'Código TOTP';

  @override
  String get totpInvalid => 'Inválido';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyEmpty => 'No hay contraseñas antiguas.';

  @override
  String get historyCopyTooltip => 'Copiar contraseña';

  @override
  String get historyClipboardLabel => 'Contraseña histórica';

  @override
  String get historyRestoreTooltip => 'Restaurar contraseña';

  @override
  String get historyRestoreTitle => '¿Restaurar contraseña?';

  @override
  String get historyRestoreBody =>
      'Esta acción reemplazará la contraseña actual de la credencial con esta contraseña histórica. ¿Deseas continuar?';

  @override
  String get historyRestoreConfirm => 'Restaurar';

  @override
  String get historyRestoreSuccess => 'Contraseña restaurada con éxito';

  @override
  String historyRestoreError(String msg) {
    return 'Error al restaurar la contraseña: $msg';
  }

  @override
  String get recoveryTitle => 'Recuperar acceso';

  @override
  String get recoveryCodeTitle => 'Código de recuperación';

  @override
  String get recoveryCodeDescription =>
      'El código de recuperación fue generado al configurar tu bóveda. Si lo guardaste, introdúcelo aquí para restablecer tu contraseña maestra.';

  @override
  String get recoveryEnterCode => 'Ingresa el código de recuperación';

  @override
  String get recoveryWrongCode =>
      'Código incorrecto. Verifica e intenta de nuevo.';

  @override
  String get recoveryVerifyButton => 'Verificar código';

  @override
  String get recoveryEnterNewPassword => 'Ingresa la nueva contraseña maestra';

  @override
  String get recoveryMin8 => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get recoveryPasswordUpdated =>
      'Contraseña maestra actualizada exitosamente';

  @override
  String get recoveryCodeVerified =>
      'Código verificado. Ahora establece tu nueva contraseña maestra.';

  @override
  String get recoveryNewPasswordLabel => 'Nueva contraseña maestra';

  @override
  String get recoveryResetButton => 'Restablecer contraseña maestra';

  @override
  String get recoveryCodeWarning =>
      '¡Guarda este código en un lugar seguro! Solo se muestra UNA VEZ y no se puede recuperar.';

  @override
  String get recoveryCopyCode => 'Copiar código';

  @override
  String get recoveryCodeSavedContinue => 'Ya lo guardé, continuar';

  @override
  String get autofillOnboardingTitle => 'Autocompletado';

  @override
  String get autofillActiveTitle => '¡SoloKey está activo!';

  @override
  String get autofillEnableTitle => 'Activa el autocompletado';

  @override
  String get autofillActiveDesc =>
      'SoloKey completará automáticamente tus contraseñas en cualquier app o navegador de tu dispositivo.';

  @override
  String get autofillEnableDesc =>
      'Permite que SoloKey complete tus contraseñas automáticamente en apps y navegadores.';

  @override
  String get autofillOpenSettings => 'Abrir ajustes de Autocompletado';

  @override
  String get autofillVerifyStatus => 'Ya lo activé, verificar estado';

  @override
  String get autofillFeatureDetection =>
      'Detección automática de formularios de login';

  @override
  String get autofillFeatureBiometric =>
      'Pide tu huella antes de rellenar (biometría)';

  @override
  String get autofillFeatureNeverExposed =>
      'Credenciales nunca expuestas al SO';

  @override
  String get autofillStatusActive => 'Activo';

  @override
  String get autofillStatusInactive => 'Inactivo';

  @override
  String get autofillStep1Title => 'Toca \"Abrir ajustes de Autocompletado\"';

  @override
  String get autofillStep1Sub => 'Se abrirá la configuración del sistema';

  @override
  String get autofillStep2Title => 'Selecciona \"SoloKey\" como proveedor';

  @override
  String get autofillStep2Sub => 'Busca SoloKey en la lista de apps';

  @override
  String get autofillStep3Title => 'Confirma y regresa a la app';

  @override
  String get autofillStep3Sub => 'El autocompletado quedará activado';

  @override
  String get quickFillTitle => 'Autocompletado rápido';

  @override
  String get quickFillCloseTooltip => 'Cerrar (Esc)';

  @override
  String get quickFillSearchHint => 'Buscar credencial…';

  @override
  String get quickFillLoadError => 'No se pudieron cargar las credenciales';

  @override
  String get quickFillNoMatches => 'Sin coincidencias';

  @override
  String get quickFillFooter =>
      'Copia el dato y pégalo (Ctrl+V) en el campo · se limpia solo del portapapeles';

  @override
  String get quickFillCopyUser => 'Copiar usuario';

  @override
  String get quickFillCopyPassword => 'Copiar contraseña';
}
