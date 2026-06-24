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

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get auditTitle => 'Auditoría de Seguridad';

  @override
  String get auditAnalysisTitle => 'Análisis de Seguridad';

  @override
  String get auditAnalysisDesc =>
      'SoloKey analiza tus credenciales localmente para identificar contraseñas débiles, cortas, reutilizadas o antiguas.';

  @override
  String get auditBreachCheck => 'Verificar filtraciones (online)';

  @override
  String get auditPrivateBadge => 'PRIVADO';

  @override
  String get auditBreachDesc =>
      'Usa k-Anonymity (HaveIBeenPwned) para buscar contraseñas expuestas sin revelar tu contraseña real.';

  @override
  String get auditAllGoodTitle => '¡Todo en orden!';

  @override
  String get auditAllGoodDesc => 'No se encontraron problemas en tu bóveda.';

  @override
  String get auditSeverityCritical => 'Crítico';

  @override
  String get auditSeverityWarning => 'Advertencia';

  @override
  String get auditSeverityInfo => 'Info';

  @override
  String get passkeysTitle => 'Respaldos de Passkey';

  @override
  String get passkeysAdd => 'Añadir Passkey';

  @override
  String get passkeysHowToTitle => '¿Cómo registrar una Passkey?';

  @override
  String get passkeysHowToBody =>
      'Las Passkeys se registran directamente en cada servicio web (ej. Google, GitHub, Apple).\n\n1. Ve al sitio web del servicio\n2. Busca \"Passkeys\" o \"Llaves de acceso\" en Seguridad\n3. El sistema registrará y sincronizará la passkey automáticamente\n\nSoloKey almacenará la información de la passkey en tu bóveda de forma cifrada para que puedas gestionarla.';

  @override
  String get passkeysEmptyTitle => 'Sin respaldos de passkey';

  @override
  String get passkeysEmptyDesc =>
      'Las Passkeys son el futuro de la autenticación: sin contraseñas, más seguras y más rápidas. Regístralas en tus servicios favoritos y SoloKey guardará aquí un respaldo cifrado.';

  @override
  String get passkeysEncryptedBadge => 'Respaldo cifrado en tu bóveda';

  @override
  String passkeysUpdated(String date) {
    return 'Actualizado: $date';
  }

  @override
  String get passkeysViewDetails => 'Ver detalles';

  @override
  String get passkeyDomain => 'Dominio (RP ID)';

  @override
  String get passkeyService => 'Servicio';

  @override
  String get passkeyVerification => 'Verificación';

  @override
  String get passkeyVerificationRequired => 'Requerida (Biométrico / PIN)';

  @override
  String get passkeyVerificationOptional => 'Opcional';

  @override
  String get passkeyCredentialId => 'Credential ID';

  @override
  String get passkeyRegistered => 'Registrada';

  @override
  String get passkeyPrivateKeyNote =>
      'La clave privada nunca sale del dispositivo. Solo la información de identificación está almacenada.';

  @override
  String get passkeysDeleteTitle => 'Eliminar Passkey';

  @override
  String passkeysDeleteBody(String title, String service) {
    return '¿Eliminar la passkey \"$title\"?\n\nNota: también deberás eliminarla del servicio web correspondiente ($service).';
  }

  @override
  String get passkeysSiteFallback => 'el sitio';

  @override
  String get passkeysDeleteAuthReason => 'Verifica para eliminar esta passkey';

  @override
  String get formNewTitle => 'Nueva credencial';

  @override
  String get formEditTitle => 'Editar credencial';

  @override
  String get formCreated => 'Credencial creada';

  @override
  String get formSaved => 'Cambios guardados';

  @override
  String get formSaveChanges => 'Guardar cambios';

  @override
  String get formCreateCredential => 'Crear credencial';

  @override
  String get formFieldRequired => 'Campo requerido';

  @override
  String get formErrPinRequiredEnable =>
      'Debes ingresar un PIN secundario para el cifrado doble';

  @override
  String get formErrPinRequiredDisable =>
      'Ingresa el PIN secundario para desactivar el cifrado doble';

  @override
  String get formQrNotTotp => 'El código QR no es un TOTP válido.';

  @override
  String get formQrScanned => 'Código QR escaneado con éxito';

  @override
  String get formQrNoSecret => 'No se encontró una clave secreta en el QR.';

  @override
  String get formQrReadError => 'Error al leer el código QR.';

  @override
  String get formSshGenerated => 'Par de llaves Ed25519 generado';

  @override
  String get formSshGenError => 'Error al generar la llave SSH.';

  @override
  String get formCustomFieldsTitle => 'Campos Personalizados';

  @override
  String get formNoCustomFields => 'No hay campos personalizados.';

  @override
  String get formAddField => 'Añadir campo';

  @override
  String get formEditField => 'Editar campo';

  @override
  String get formNewCustomField => 'Nuevo campo personalizado';

  @override
  String get formFieldNameLabel => 'Nombre del campo';

  @override
  String get formFieldNameHint => 'ej. PIN, Pregunta de Seguridad';

  @override
  String get formNameRequired => 'Nombre requerido';

  @override
  String get formFieldValueLabel => 'Valor del campo';

  @override
  String get formFieldValueHint => 'ej. 1234, Ciudad natal';

  @override
  String get formValueRequired => 'Valor requerido';

  @override
  String get formSecretField => 'Campo secreto';

  @override
  String get formSecretBadge => 'SECRETO';

  @override
  String get formSecretFieldSub =>
      'Ocultará el valor por defecto en los detalles.';

  @override
  String get formAdd => 'Agregar';

  @override
  String get formSectionIdentification => 'Identificación';

  @override
  String get formTitleLabel => 'Título';

  @override
  String get formSectionContent => 'Contenido';

  @override
  String get formSectionNotes => 'Notas';

  @override
  String get formSecureContentLabel => 'Contenido seguro';

  @override
  String get formNotesLabel => 'Notas adicionales';

  @override
  String get formSecureContentHint => 'Escribe tu nota privada aquí…';

  @override
  String get formNotesHint => 'Opcional — agregar contexto o recordatorios';

  @override
  String get formContentRequired => 'El contenido es requerido';

  @override
  String get formSectionOrganization => 'Organización';

  @override
  String get formFolderLabel => 'Carpeta';

  @override
  String get formMainVault => 'Bóveda principal';

  @override
  String get formHintPassword => 'ej. Netflix, GitHub, Gmail';

  @override
  String get formHintApiKey => 'ej. OpenAI, Stripe, AWS';

  @override
  String get formHintSecureNote => 'ej. Llaves del servidor, Seeds';

  @override
  String get formHintTotp => 'ej. GitHub 2FA, Google';

  @override
  String get formHintPasskey => 'ej. google.com Passkey';

  @override
  String get formHintSshKey => 'ej. Servidor Produccion, GitHub SSH Key';

  @override
  String get formSectionLogin => 'Credenciales de acceso';

  @override
  String get formUserEmailLabel => 'Usuario / Email';

  @override
  String get formUserEmailHint => 'usuario@ejemplo.com';

  @override
  String get formWebsiteLabel => 'Sitio web / URL';

  @override
  String get formWebsiteHint => 'https://ejemplo.com';

  @override
  String get formSectionApi => 'Detalles de la API';

  @override
  String get formServiceNameLabel => 'Nombre del servicio';

  @override
  String get formServiceNameHint => 'ej. OpenAI, Stripe, Supabase';

  @override
  String get formApiKeyLabel => 'API Key / Token';

  @override
  String get formEndpointLabel => 'Endpoint URL';

  @override
  String get formScopesLabel => 'Permisos / Scopes';

  @override
  String get formSection2fa => 'Configuración 2FA';

  @override
  String get formTotpDesc =>
      'Ingresa la clave secreta TOTP (Base32) de tu cuenta. La encontrarás al activar 2FA en el sitio web, o puedes escanear el código QR directamente.';

  @override
  String get formScanQr => 'Escanear código QR';

  @override
  String get formOrManually => 'o ingresa manualmente';

  @override
  String get formAccountIssuerLabel => 'Cuenta / Emisor';

  @override
  String get formAccountIssuerHint => 'ej. GitHub, Google, AWS';

  @override
  String get formTotpSecretLabel => 'Clave secreta TOTP (Base32)';

  @override
  String get formSectionPasskey => 'Passkey (FIDO2)';

  @override
  String get formPasskeyDesc =>
      'Las Passkeys se registran directamente con la plataforma FIDO2 del dispositivo.';

  @override
  String get formPasskeyHint =>
      'Usa la pantalla de Passkeys en Ajustes para registrar o gestionar tus passkeys.';

  @override
  String get formSectionSsh => 'Configuracion de Llave SSH';

  @override
  String get formGenerateSsh => 'Generar par de llaves Ed25519';

  @override
  String get formPrivateKeyRequired => 'La llave privada es requerida';

  @override
  String get formPublicKeyOptional => 'Llave Publica (Opcional)';

  @override
  String get formKeyPassphraseOptional => 'Passphrase de la Llave (Opcional)';

  @override
  String get formSectionDoubleEnc => 'Cifrado de Sobre Doble';

  @override
  String get formEnableDoubleEnc => 'Activar Cifrado Doble';

  @override
  String get formDoubleEncDesc =>
      'Protege los secretos de este registro con un PIN secundario. Se cifraran adicionalmente.';

  @override
  String get formPinSecondaryEditLabel =>
      'PIN Secundario (Dejar vacio para mantener actual o ingresar para cambiar)';

  @override
  String get formPinSecondaryLabel => 'PIN Secundario';

  @override
  String get formPinSecondaryRequired => 'El PIN secundario es requerido';

  @override
  String get formBiometricUnlock => 'Desbloqueo biometrico';

  @override
  String get formBiometricUnlockSub =>
      'Guardar el PIN cifrado para desbloquear rapidamente con huella/rostro.';

  @override
  String get formSectionRotation => 'Recordatorio de Rotación';

  @override
  String get formRotationLabel => 'Recordar cambiar contraseña';

  @override
  String get formRotNone => 'No recordar';

  @override
  String get formRotMonthly => 'Cada mes';

  @override
  String get formRotCustom => 'Personalizado (días)';

  @override
  String get formCustomDaysLabel => 'Días para recordar';

  @override
  String get formCustomDaysRequired => 'Debe ingresar el número de días';

  @override
  String get formCustomDaysInvalid => 'Ingrese un número válido de días';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get folderNewSubfolder => 'Nueva subcarpeta';

  @override
  String get folderDeleteTitle => 'Eliminar carpeta';

  @override
  String folderDeleteBodyOrphan(String name) {
    return '¿Eliminar \"$name\"? Sus credenciales quedarán huérfanas o movidas a la raíz.';
  }

  @override
  String folderDeleteBodyReleased(String name) {
    return '¿Eliminar \"$name\"? Sus subcarpetas o credenciales quedarán liberadas.';
  }

  @override
  String get folderDeleted => 'Carpeta eliminada';

  @override
  String get folderRename => 'Renombrar';

  @override
  String get folderRenameTitle => 'Renombrar carpeta';

  @override
  String get folderNewNameLabel => 'Nuevo nombre';

  @override
  String get folderCreateSubfolder => 'Crear subcarpeta';

  @override
  String get folderEmptyTitle => 'Carpeta Vacía';

  @override
  String get folderEmptyDesc => 'No hay subcarpetas ni credenciales aquí.';

  @override
  String get folderNoFolders => 'Sin carpetas';

  @override
  String get folderOrganize => 'Organiza tus credenciales';

  @override
  String get folderCreateRoot => 'Crear carpeta raíz';

  @override
  String get folderNewRoot => 'Nueva carpeta raíz';

  @override
  String get folderUnassigned => 'Sin carpeta asignada';

  @override
  String get folderNew => 'Nueva carpeta';

  @override
  String get folderAddSubfolder => 'Añadir subcarpeta';

  @override
  String get folderSelectTitle => 'Seleccionar Carpeta';

  @override
  String get folderNewRootShort => 'Nueva raíz';

  @override
  String get folderNoneMainVault => 'Ninguna (Bóveda principal)';

  @override
  String get favoritesEmptyTitle => 'No tienes favoritos';

  @override
  String get favoritesEmptyDesc =>
      'Marca carpetas o credenciales con una estrella';

  @override
  String get favoritesFoldersHeader => 'Carpetas Favoritas';

  @override
  String get favoritesCredentialsHeader => 'Credenciales Favoritas';

  @override
  String get favoriteToggleLabel => 'Marcar como favorita';

  @override
  String get commonEdit => 'Editar';

  @override
  String get cardCopyUser => 'Copiar Usuario';

  @override
  String get cardCopyPassword => 'Copiar Contraseña';

  @override
  String get cardCopyPasswordAuthReason =>
      'Autentícate para copiar la contraseña';

  @override
  String get cardMoveToFolder => 'Mover a carpeta';

  @override
  String get cardNoFolder => 'Sin carpeta';

  @override
  String get cardMovedSuccess => 'Credencial movida con éxito';

  @override
  String get typeSelNote => 'Nota';

  @override
  String get typeSelTotp => 'TOTP';

  @override
  String get typeSelPasskey => 'Passkey';

  @override
  String get genRegenerate => 'Regenerar';

  @override
  String genLength(int n) {
    return 'Longitud: $n';
  }

  @override
  String get genGeneratedPassword => 'Contraseña generada';

  @override
  String get genUseAndCopy => 'Usar y Copiar';

  @override
  String get strengthWeak => 'Débil';

  @override
  String get strengthFair => 'Regular';

  @override
  String get strengthGood => 'Buena';

  @override
  String get strengthStrong => 'Fuerte';

  @override
  String clipboardCopiedClears(String label, int seconds) {
    return '$label copiado · se limpia en ${seconds}s';
  }

  @override
  String get passwordRowGeneratorTooltip => 'Generador de claves';

  @override
  String get keyboardSpace => 'Espacio';

  @override
  String get transferTitle => 'Transferir datos';

  @override
  String get transferTabExport => 'Exportar';

  @override
  String get transferTabImport => 'Importar';

  @override
  String get transferErrorTitle => 'Error';

  @override
  String get transferTypePasswords => 'Contraseñas';

  @override
  String get transferTypeApiKeys => 'API Keys';

  @override
  String get transferTypeSecureNotes => 'Notas seguras';

  @override
  String get transferTypeTotp => 'Autenticadores (TOTP)';

  @override
  String get transferTypePasskeys => 'Passkeys';

  @override
  String get transferTypeSshKeys => 'Llaves SSH';

  @override
  String get transferExportPasswordRequired =>
      'Ingresa una contraseña de exportación';

  @override
  String get transferSelectAtLeastOneType =>
      'Selecciona al menos un tipo de credencial';

  @override
  String transferExportedSummary(int creds, int folders) {
    return 'Exportadas $creds credenciales · $folders carpetas';
  }

  @override
  String transferExportError(String msg) {
    return 'Error al exportar: $msg';
  }

  @override
  String transferImportError(String msg) {
    return 'Error al importar: $msg';
  }

  @override
  String transferImportCsvError(String msg) {
    return 'Error al importar CSV: $msg';
  }

  @override
  String get transferOverwriteTitle => '¿Sobrescribir bóveda?';

  @override
  String get transferOverwriteBody =>
      'Esta acción eliminará TODAS las credenciales actuales y las reemplazará con las del archivo. Esta operación no se puede deshacer.';

  @override
  String get transferOverwriteConfirm => 'Sobrescribir';

  @override
  String get transferExportPasswordLabel => 'Contraseña de exportación';

  @override
  String get transferExportPasswordInfo =>
      'Crea una contraseña para proteger este backup. Necesitarás ingresarla al importar en cualquier dispositivo.';

  @override
  String get transferExportPasswordHint => 'Ej: \"mi-clave-backup-2025\"';

  @override
  String get transferSelectWhatToExport => 'Selecciona qué exportar';

  @override
  String get transferEncryptionInfo =>
      'El archivo se cifra con AES-256-GCM + Argon2id. Solo quién conozca la contraseña de exportación puede abrirlo.';

  @override
  String get transferExportButton => 'Exportar bóveda';

  @override
  String get transferExportDone => 'Exportación completada';

  @override
  String transferSummary(int creds, int folders) {
    return '$creds credenciales · $folders carpetas';
  }

  @override
  String get transferBackupPasswordLabel => 'Contraseña del backup';

  @override
  String get transferImportPasswordInfo =>
      'Ingresa la contraseña que usaste al exportar el backup. Si importas un backup tuyo del mismo dispositivo puedes dejar este campo vacío.';

  @override
  String get transferImportPasswordHint =>
      'Déjala vacía para backups del mismo dispositivo';

  @override
  String get transferImportModeLabel => 'Modo de importación';

  @override
  String get transferModeMerge => 'Combinar';

  @override
  String get transferModeMergeSub =>
      'Añadir sin borrar tus credenciales actuales';

  @override
  String get transferModeOverwrite => 'Sobrescribir';

  @override
  String get transferModeOverwriteSub =>
      'Borrará todo y reemplazará con el archivo';

  @override
  String get transferSelectFile => 'Seleccionar archivo (.skvault)';

  @override
  String get transferImportCsv => 'Importar desde CSV (Bitwarden/Chrome/1Pass)';

  @override
  String get transferImportDone => 'Importación completada';

  @override
  String get transferExportSelectFolders => 'Carpetas a exportar';

  @override
  String get transferNoFolder => 'Sin carpeta';

  @override
  String get transferImportSelectTitle => 'Selecciona qué importar';

  @override
  String get transferSectionTypes => 'Tipos de credencial';

  @override
  String get transferSectionFolders => 'Carpetas';

  @override
  String get transferImportConfirm => 'Importar selección';

  @override
  String get transferNothingSelected =>
      'Selecciona al menos un elemento para importar';

  @override
  String get transferSelectAll => 'Seleccionar todo';

  @override
  String get transferSelectCredentials => 'Selecciona qué exportar';

  @override
  String get transferSelectAtLeastOneCredential =>
      'Selecciona al menos una credencial';

  @override
  String get commonSearch => 'Buscar…';

  @override
  String get navSync => 'Sincronizar';

  @override
  String get desktopEmptyVault => 'Bóveda vacía';

  @override
  String get desktopCreateFolder => 'Crear carpeta';

  @override
  String get desktopNoCredentials => 'Sin credenciales';

  @override
  String get desktopNoFavorites => 'Sin favoritas';

  @override
  String get desktopSelectFolderTitle => 'Selecciona una carpeta';

  @override
  String get desktopSelectFolderSub =>
      'Haz clic en una carpeta de la lista para ver su contenido aquí.';

  @override
  String get desktopSecureVaultTitle => 'Bóveda Segura';

  @override
  String get desktopSelectCredentialSub =>
      'Selecciona una credencial de la lista para ver o editar sus detalles.';

  @override
  String get desktopNewFolderTooltip => 'Nueva carpeta';

  @override
  String get desktopNewCredentialTooltip => 'Nueva credencial';

  @override
  String get desktopLockVault => 'Bloquear Bóveda';

  @override
  String get navSecureFiles => 'Archivos seguros';

  @override
  String get secureFilesTitle => 'Archivos seguros';

  @override
  String get secureFilesEmptyTitle => 'Sin archivos';

  @override
  String get secureFilesEmptyDesc =>
      'Guarda llaves SSH privadas, credentials.json o cualquier otro archivo, cifrado con tu clave maestra.';

  @override
  String get secureFilesAdd => 'Añadir archivo';

  @override
  String get secureFilesExport => 'Exportar / Guardar';

  @override
  String get secureFilesDelete => 'Eliminar';

  @override
  String get secureFilesAuthReason =>
      'Verifica tu identidad para acceder al archivo';

  @override
  String get secureFilesDeleteConfirmTitle => '¿Eliminar archivo?';

  @override
  String secureFilesDeleteConfirmBody(String name) {
    return '¿Eliminar \"$name\"? Esto borra permanentemente el archivo cifrado.';
  }

  @override
  String get secureFilesDeleted => 'Archivo eliminado';

  @override
  String get secureFilesSaved => 'Archivo guardado';

  @override
  String secureFilesAddedSummary(String name) {
    return 'Añadido $name';
  }

  @override
  String secureFilesAddError(String msg) {
    return 'No se pudo añadir el archivo: $msg';
  }

  @override
  String secureFilesExportError(String msg) {
    return 'No se pudo exportar el archivo: $msg';
  }
}
