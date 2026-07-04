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
  String get commonClear => 'Limpiar';

  @override
  String get commonExpand => 'Expandir';

  @override
  String get commonCollapse => 'Contraer';

  @override
  String get commonShowPassword => 'Mostrar contraseña';

  @override
  String get commonHidePassword => 'Ocultar contraseña';

  @override
  String get formDeleteField => 'Eliminar campo';

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
  String get unlockWrongPassword => 'Contraseña maestra incorrecta';

  @override
  String unlockWrongPasswordLocked(String time) {
    return 'Contraseña incorrecta. Bloqueado $time.';
  }

  @override
  String get unlockVaultWiped =>
      'Bóveda borrada por demasiados intentos fallidos.';

  @override
  String get unlockBiometricFailed =>
      'Autenticación biométrica fallida o no configurada.';

  @override
  String get unlockGenericError => 'No se pudo desbloquear la bóveda.';

  @override
  String get unlockWithWindowsHello => 'Desbloquear con Windows Hello';

  @override
  String get unlockWithBiometrics => 'Desbloquear con biometría';

  @override
  String get unlockOrUseMasterPassword => 'o usa tu contraseña maestra';

  @override
  String unlockAttemptsBeforeLockout(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count intentos antes del bloqueo temporal',
      one: 'Queda 1 intento antes del bloqueo temporal',
    );
    return '$_temp0';
  }

  @override
  String unlockAttemptsBeforeWipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count intentos antes de borrar la bóveda',
      one: 'Queda 1 intento antes de borrar la bóveda',
    );
    return '$_temp0';
  }

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
  String get commonDisabled => 'Desactivado';

  @override
  String get settingsSectionSecurity => 'Seguridad';

  @override
  String get settingsSectionData => 'Datos';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsSectionDanger => 'Zona peligrosa';

  @override
  String get settingsThemeTitle => 'Tema de la aplicación';

  @override
  String get settingsDensityTitle => 'Densidad';

  @override
  String get densityComfortable => 'Cómoda';

  @override
  String get densityCompact => 'Compacta';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDim => 'Tenue';

  @override
  String get themeOled => 'OLED';

  @override
  String get settingsWipeTitle => 'Borrar bóveda tras intentos fallidos';

  @override
  String get settingsWipeSubtitle =>
      'Protección anti fuerza bruta (irreversible)';

  @override
  String get settingsSyncComputerTitle => 'Sincronizar computadora';

  @override
  String get settingsSyncComputerSubtitle =>
      'Vincula con SoloKey de escritorio';

  @override
  String get settingsExportImportTitle => 'Exportar / Importar';

  @override
  String get settingsExportImportSubtitle =>
      'Haz backups cifrados de tu bóveda';

  @override
  String get settingsAutofillTitle => 'Autocompletado del sistema';

  @override
  String get settingsAutofillSubtitle => 'Completa contraseñas en otras apps';

  @override
  String get settingsPasskeysTitle => 'Respaldo de Passkeys';

  @override
  String get settingsPasskeysSubtitle => 'Guarda tus respaldos de passkey';

  @override
  String get settingsBackupTitle => 'Backup automático';

  @override
  String get settingsBackupDaily => 'Diario';

  @override
  String get settingsBackupWeekly => 'Semanal';

  @override
  String get settingsBackupMonthly => 'Mensual';

  @override
  String settingsBackupEveryNDays(int days) {
    return 'Cada $days días';
  }

  @override
  String get settingsBackupNoFolder => 'sin carpeta';

  @override
  String get settingsBackupFrequency => 'Frecuencia';

  @override
  String get settingsBackupChooseFolder => 'Elegir carpeta destino';

  @override
  String get settingsBackupPassword => 'Contraseña del backup';

  @override
  String get settingsBackupPasswordKeep =>
      'Contraseña del backup (dejar vacío = mantener)';

  @override
  String get settingsLockNowTitle => 'Bloquear ahora';

  @override
  String get settingsLockNowSubtitle => 'Cierra la sesión inmediatamente';

  @override
  String get settingsVersionLabel => 'Versión';

  @override
  String get settingsAboutTagline => 'Gestor de contraseñas local-first';

  @override
  String get settingsSectionShortcuts => 'Atajos de teclado';

  @override
  String get shortcutCommandPalette => 'Paleta de comandos';

  @override
  String get shortcutNewCredential => 'Nueva credencial';

  @override
  String get shortcutEditCredential => 'Editar seleccionada';

  @override
  String get shortcutLock => 'Bloquear bóveda';

  @override
  String get shortcutReset => 'Restablecer atajos';

  @override
  String get shortcutEditTitle => 'Asignar atajo';

  @override
  String get shortcutCapturePrompt => 'Pulsa la combinación de teclas…';

  @override
  String get shortcutNeedsModifier =>
      'Añade un modificador (Ctrl, Alt o Shift)';

  @override
  String get shortcutConflict => 'Esa combinación ya la usa otro atajo';

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
  String get navVault => 'Bóveda';

  @override
  String get navSecurity => 'Seguridad';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPasswords => 'Contraseñas';

  @override
  String get securityHubSubtitle => 'Herramientas para mantener tu bóveda sana';

  @override
  String get securityHubAuditDesc =>
      'Contraseñas débiles, repetidas y filtradas';

  @override
  String get securityHubGenerator => 'Generador de contraseñas';

  @override
  String get securityHubGeneratorDesc => 'Crea contraseñas fuertes y únicas';

  @override
  String get securityHubTransferDesc => 'Exporta o importa tu bóveda';

  @override
  String get securityHubSecureFilesDesc => 'Documentos e imágenes cifradas';

  @override
  String get securityHubPasskeysDesc =>
      'Gestiona tus respaldos de passkey cifrados';

  @override
  String get securityHubSyncDesc => 'Vincula este dispositivo en tu red';

  @override
  String get securityHubRecoveryDesc => 'Restablece tu contraseña maestra';

  @override
  String get generatorSheetTitle => 'Generar contraseña';

  @override
  String get commandNoResults => 'Sin resultados';

  @override
  String get commandActionsGroup => 'Acciones';

  @override
  String get commandCredentialsGroup => 'Credenciales';

  @override
  String get commandHintNavigate => 'Navegar';

  @override
  String get commandHintSelect => 'Abrir';

  @override
  String get commandHintClose => 'Cerrar';

  @override
  String get detailAdvanced => 'Avanzado';

  @override
  String get detailTotpSecret => 'Secreto (semilla)';

  @override
  String get detailCopyCode => 'Copiar código';

  @override
  String get healthReused => 'Repetida';

  @override
  String get auditScoreTitle => 'Salud de la bóveda';

  @override
  String auditScoreIssues(int count) {
    return '$count problemas por revisar';
  }

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
  String homeCredentialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credenciales',
      one: '1 credencial',
      zero: 'Sin credenciales',
    );
    return '$_temp0';
  }

  @override
  String homeIssuesChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos',
      one: '1 aviso',
    );
    return '$_temp0';
  }

  @override
  String get homeGreetingMorning => 'Buenos dias';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes';

  @override
  String get homeGreetingEvening => 'Buenas noches';

  @override
  String get homeHealthTooltip => 'Salud de la boveda: toca para ver detalles';

  @override
  String get homeSortTooltip => 'Ordenar';

  @override
  String get sortManual => 'Orden manual';

  @override
  String get sortTitleAsc => 'Nombre (A–Z)';

  @override
  String get sortUpdatedDesc => 'Modificadas recientemente';

  @override
  String get homeReorderStart => 'Reordenar';

  @override
  String get homeReorderDone => 'Listo';

  @override
  String get homeReorderHint => 'Arrastra desde el asa para reordenar';

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
  String get detailRevealAuthReason =>
      'Autentifícate para revelar este secreto';

  @override
  String get detailRevealSecret => 'Revelar secreto';

  @override
  String get detailHideSecret => 'Ocultar secreto';

  @override
  String detailCopyField(String field) {
    return 'Copiar $field';
  }

  @override
  String detailHideCountdown(int seconds) {
    return 'Se oculta en ${seconds}s';
  }

  @override
  String get detailOpenSite => 'Abrir sitio';

  @override
  String get detailOpenSiteError => 'No se pudo abrir el sitio';

  @override
  String get detailPasskeyHandleNote =>
      'El identificador de la clave privada permanece cifrado en tu bóveda.';

  @override
  String get detailTotpExportQr => 'Exportar como QR';

  @override
  String get detailTotpExportQrAuthReason =>
      'Autentifícate para mostrar el QR del TOTP';

  @override
  String get detailTotpExportQrTitle => 'Escanea en otro dispositivo';

  @override
  String get detailTotpExportQrWarning =>
      'Quien escanee esto podrá generar tus códigos. Manténlo privado.';

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
  String get a11yFavorite => 'Favorito';

  @override
  String get a11yDoubleEncrypted => 'Con doble cifrado';

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
  String accessStepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get recoveryStepEnterCode => 'Ingresa tu código de recuperación';

  @override
  String get recoveryStepNewPassword => 'Define una nueva contraseña maestra';

  @override
  String get setupStepCreate => 'Crea tu contraseña maestra';

  @override
  String get setupStepSaveCode => 'Guarda tu código de recuperación';

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
  String get passkeyCredentialIdCopied => 'Credential ID copiado';

  @override
  String get passkeyIconLabel => 'Passkey';

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
  String get formScanQrScreen => 'Escanear QR de la pantalla';

  @override
  String get formQrScreenNoQr => 'No se encontró un código QR en la captura.';

  @override
  String get formQrScreenError => 'No se pudo capturar la pantalla.';

  @override
  String get formTotpNonStandard =>
      'TOTP detectado, pero con parámetros no estándar (SoloKey genera SHA1, 6 dígitos, 30s); el código podría no coincidir.';

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
  String get formDiscardTitle => '¿Descartar cambios?';

  @override
  String get formDiscardMessage =>
      'Tienes cambios sin guardar. Si sales ahora se perderan.';

  @override
  String get formDiscardKeep => 'Seguir editando';

  @override
  String get formDiscardLeave => 'Descartar';

  @override
  String get formErrInvalidUrl => 'Ingresa una URL valida';

  @override
  String get formErrInvalidTotp => 'Secreto Base32 invalido (solo A-Z y 2-7)';

  @override
  String get formPasteTotp => 'Pegar enlace otpauth';

  @override
  String get formPasteApplied => 'TOTP rellenado desde el portapapeles';

  @override
  String get formPasteNoOtpauth =>
      'No hay un enlace otpauth:// valido en el portapapeles';

  @override
  String get formDupTitle => 'Posible duplicado';

  @override
  String formDupMessage(String title) {
    return '\"$title\" ya usa este usuario. ¿Guardar de todos modos?';
  }

  @override
  String get formDupReview => 'Revisar';

  @override
  String get formDupSaveAnyway => 'Guardar de todos modos';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get folderNewSubfolder => 'Nueva subcarpeta';

  @override
  String get folderDeleteTitle => 'Eliminar carpeta';

  @override
  String folderDeleteKeepBody(String name) {
    return '¿Quitar \"$name\"? Sus subcarpetas y credenciales se conservan: elige a dónde moverlas. No se elimina nada.';
  }

  @override
  String get folderDeleteMoveToParent => 'Mover contenido a la carpeta padre';

  @override
  String get folderDeleteMoveToVault => 'Mover contenido a la raíz';

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
  String folderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String get folderColorTitle => 'Color';

  @override
  String get folderEditTitle => 'Editar carpeta';

  @override
  String get folderTreeHint =>
      'Usa las flechas para navegar por las carpetas; pulsa el botón de menú para acciones.';

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
  String get transferBackupReminder =>
      'Hace tiempo que no haces un respaldo. Exporta una copia cifrada y guárdala en un lugar seguro.';

  @override
  String transferSavedTo(String path) {
    return 'Guardado en: $path';
  }

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
  String get transferImportOtpauth => 'Importar autenticadores (otpauth)';

  @override
  String get transferOtpauthNone =>
      'No se encontraron enlaces otpauth:// en ese archivo';

  @override
  String get transferOtpauthMigrationUnsupported =>
      'Los QR de exportación de Google Authenticator no son compatibles. Exporta enlaces otpauth:// individuales.';

  @override
  String transferDuplicatesWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos seleccionados ya existen en tu bóveda',
      one: '1 elemento seleccionado ya existe en tu bóveda',
    );
    return '$_temp0';
  }

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
  String get desktopSectionVault => 'Bóveda';

  @override
  String get desktopSectionSecurity => 'Seguridad';

  @override
  String get desktopSectionDevices => 'Dispositivos';

  @override
  String get desktopCollapseSidebar => 'Colapsar barra lateral';

  @override
  String get desktopExpandSidebar => 'Expandir barra lateral';

  @override
  String desktopWatchtowerBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos requieren atención',
      one: '$count elemento requiere atención',
    );
    return '$_temp0';
  }

  @override
  String get trayShowVault => 'Mostrar bóveda';

  @override
  String get trayExit => 'Salir';

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

  @override
  String get secureFilesRename => 'Renombrar';

  @override
  String get secureFilesRenameTitle => 'Renombrar archivo';

  @override
  String get secureFilesMove => 'Mover a carpeta';

  @override
  String get secureFilesMoveTitle => 'Mover a carpeta';

  @override
  String get secureFilesFavorite => 'Favorito';

  @override
  String get secureFilesDropHint => 'Suelta archivos aqui para agregarlos';

  @override
  String secureFilesAddedCount(int count) {
    return 'Agregados $count archivo(s)';
  }

  @override
  String secureFilesTooLarge(String name, String limit) {
    return '\"$name\" supera el limite de $limit y se omitio';
  }

  @override
  String secureFilesSkippedLarge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos omitidos (muy grandes)',
      one: '1 archivo omitido (muy grande)',
    );
    return '$_temp0';
  }

  @override
  String secureFilesProcessing(int done, int total) {
    return 'Cifrando $done de $total…';
  }

  @override
  String get secureFilesOptions => 'Opciones';

  @override
  String get secureFilesPreview => 'Previsualizar';

  @override
  String secureFilesPreviewError(String msg) {
    return 'No se pudo previsualizar el archivo: $msg';
  }

  @override
  String get secureFilesPreviewUnsupported =>
      'Este archivo no se puede mostrar como imagen.';

  @override
  String secureFilesFileTypeLabel(String type) {
    return 'Archivo $type';
  }

  @override
  String get secureFilesFileGeneric => 'Archivo';

  @override
  String get relativeNow => 'hace un momento';

  @override
  String relativeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count h',
      one: 'hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count d',
      one: 'hace 1 d',
    );
    return '$_temp0';
  }

  @override
  String get homeShowHidden => 'Ver ocultas';

  @override
  String get homeShowActive => 'Ver activas';

  @override
  String get homeNoHidden => 'No tienes credenciales ocultas';

  @override
  String get detailHide => 'Ocultar';

  @override
  String get detailUnhide => 'Mostrar en la lista';

  @override
  String get detailHidden => 'Credencial oculta de la lista principal';

  @override
  String get detailUnhidden => 'Credencial visible de nuevo';

  @override
  String get unlockApprovalSent =>
      'Solicitud enviada a tu celular. Apruebala alli para desbloquear.';

  @override
  String get unlockApprovalNoDevice =>
      'No hay un celular conectado. Abre SoloKey en tu celular en la misma red Wi-Fi.';

  @override
  String get syncTitle => 'Sincronizar Dispositivo';

  @override
  String get syncServerActive =>
      'Servidor activo. Esperando conexión del celular...';

  @override
  String get syncServerOff => 'Servidor apagado.';

  @override
  String get syncClientConnecting => 'Celular conectándose...';

  @override
  String get syncClientDisconnected =>
      'Celular desconectado. Servidor en espera...';

  @override
  String get syncPairedOk => '¡Vinculación completada con éxito!';

  @override
  String get syncComparing => 'Comparando datos locales con celular...';

  @override
  String get syncBidirOk => '¡Sincronización bidireccional exitosa!';

  @override
  String get syncErrorGeneric => 'Error durante la sincronización.';

  @override
  String get syncRemoteUnlockReceived =>
      'Recibida solicitud de desbloqueo remoto.';

  @override
  String get syncPairTitle => 'Vincular con App Móvil';

  @override
  String get syncPairSubtitle =>
      'Sincroniza tus contraseñas en tiempo real de forma segura y desbloquea esta bóveda usando la biometría de tu celular.';

  @override
  String get syncGenerateQr => 'Generar Código QR';

  @override
  String get syncStartingServer => 'Iniciando servidor local...';

  @override
  String get syncScanThisQr => 'Escanea este código QR';

  @override
  String get syncScanThisQrSub =>
      'Abre SoloKey en tu móvil, ve a Sincronizar y escanea este código.';

  @override
  String get syncConnectingDevice => 'Conectando con el dispositivo móvil...';

  @override
  String get syncLinkedTitle => '¡Vinculado Exitosamente!';

  @override
  String get syncLinkedSub =>
      'Los dispositivos ahora están enlazados de forma segura.';

  @override
  String get syncUnderstood => 'Entendido';

  @override
  String get syncErrorTitle => 'Error de Vinculación';

  @override
  String get syncUnexpectedError => 'Ocurrió un error inesperado.';

  @override
  String get syncRetry => 'Reintentar';

  @override
  String get syncComputerLinked => 'Computadora Vinculada';

  @override
  String get syncComputerLinkedSub =>
      'Esta computadora está emparejada de forma segura. Puedes conectar varios dispositivos a la vez escaneando el mismo QR.';

  @override
  String get syncServerE2eeActive => 'Servidor local E2EE Activo';

  @override
  String get syncRemoveLink => 'Eliminar Vínculo';

  @override
  String get syncShowQr => 'Mostrar QR';

  @override
  String get syncWaitingDevices => 'Esperando dispositivos…';

  @override
  String get syncStatusSyncing => 'Sincronizando…';

  @override
  String get syncStatusSynced => 'Sincronizado';

  @override
  String get syncStatusConnected => 'Conectado';

  @override
  String get syncStarting => 'Iniciando sincronización...';

  @override
  String get syncSendingLocal => 'Enviando cambios locales...';

  @override
  String syncSuccessStats(String stats) {
    return '¡Sincronización exitosa! ($stats)';
  }

  @override
  String get syncBiometricReason =>
      'Autentícate para desbloquear tu computadora';

  @override
  String get syncLinkComputer => 'Vincular Computadora';

  @override
  String get syncLinkComputerSub =>
      'Escanea el código QR generado por la aplicación SoloKey en tu computadora para sincronizar los datos locales.';

  @override
  String get syncScanQrButton => 'Escanear Código QR';

  @override
  String get syncNegotiating => 'Negociando claves de encriptación...';

  @override
  String get syncComputerLinkedExcl => '¡Computadora Vinculada!';

  @override
  String get syncComputerLinkedExclSub =>
      'Los datos ahora se sincronizarán de forma segura entre dispositivos.';

  @override
  String get syncBack => 'Volver';

  @override
  String get syncCouldNotConnect => 'No se pudo conectar con la computadora.';

  @override
  String get syncRetryButton => 'Volver a Intentar';

  @override
  String get syncRemoteUnlockTitle => 'Desbloqueo Remoto';

  @override
  String get syncRemoteUnlockSub =>
      'Desbloquea la bóveda de tu computadora usando la biometría de este dispositivo.';

  @override
  String get syncSending => 'Enviando...';

  @override
  String get syncUnlockComputer => 'Desbloquear Computadora';

  @override
  String get syncUnlockSentBanner =>
      '¡Solicitud enviada! La bóveda debería desbloquearse.';

  @override
  String get syncAuthCancelled => 'Autenticación biométrica cancelada.';

  @override
  String get syncNoToken =>
      'Vincula de nuevo con el escritorio DESBLOQUEADO para habilitar el desbloqueo remoto.';

  @override
  String get syncVaultTitle => 'Sincronizar Bóveda';

  @override
  String get syncVaultSub =>
      'Intercambia y actualiza tus credenciales bidireccionalmente en red local.';

  @override
  String get syncNotPairedYet =>
      'Aun no has vinculado. Escanea el QR del escritorio.';

  @override
  String get syncConnectingComputer => 'Conectando con la computadora...';

  @override
  String get syncConnectFailCheck =>
      'No se pudo conectar. Verifica que el PC este encendido y en la misma red Wi-Fi.';

  @override
  String get auditIssueTooShortTitle => 'Contraseña demasiado corta';

  @override
  String get auditIssueTooShortDesc => 'Tiene menos de 8 caracteres.';

  @override
  String get auditIssueWeakTitle => 'Contraseña débil';

  @override
  String get auditIssueWeakLettersDesc =>
      'Solo letras, sin números ni símbolos.';

  @override
  String get auditIssueWeakNumbersDesc => 'Solo números.';

  @override
  String get auditIssueReusedTitle => 'Contraseña reutilizada';

  @override
  String get auditIssueReusedDesc =>
      'Esta contraseña está usada en múltiples cuentas.';

  @override
  String get auditIssueBreachedTitle => 'Contraseña filtrada';

  @override
  String auditIssueBreachedDesc(int count) {
    return 'Esta contraseña aparece en $count filtraciones de datos en internet. ¡Cámbiala de inmediato!';
  }

  @override
  String get auditIssueNoPasswordTitle => 'Sin contraseña guardada';

  @override
  String get auditIssueNoPasswordDesc =>
      'Esta credencial no tiene contraseña registrada.';

  @override
  String get auditIssueRotationTitle => 'Rotación requerida';

  @override
  String auditIssueRotationDesc(int days, int interval) {
    return 'Expiró hace $days días (establecido cada $interval días).';
  }

  @override
  String get auditIssueStaleTitle => 'Contraseña antigua';

  @override
  String auditIssueStaleDesc(int days) {
    return 'No se ha actualizado en más de 6 meses ($days días).';
  }

  @override
  String get notifRotationChannelName => 'Recordatorios de rotación';

  @override
  String get notifRotationChannelDesc =>
      'Alertas cuando una contraseña debe rotarse por seguridad.';

  @override
  String get notifRotationTitle => 'Rotación de contraseña requerida';

  @override
  String notifRotationBody(String title) {
    return 'Tu contraseña para \"$title\" ha expirado. Cámbiala ahora por seguridad.';
  }

  @override
  String get notifActionChangePassword => 'Cambiar contraseña';

  @override
  String get notifActionSnooze3d => 'Posponer 3 días';

  @override
  String get notifApprovalTitle => 'Aprobar inicio de sesión';

  @override
  String get notifApprovalBody =>
      'Tu computadora pide desbloquearse. Toca para aprobar.';

  @override
  String notifApprovalBodyNamed(String name) {
    return '¿Desbloquear \"$name\"? Toca para aprobar.';
  }

  @override
  String get syncSummaryTitle => 'Última sincronización';

  @override
  String get syncSummaryNoChanges => 'Sin cambios — ya estaba todo al día';

  @override
  String syncSummaryFrom(String device) {
    return 'desde $device';
  }

  @override
  String get syncOtherDevice => 'el otro dispositivo';

  @override
  String get syncCredentialsLabel => 'Credenciales';

  @override
  String get syncFoldersLabel => 'Carpetas';

  @override
  String syncCountAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevas',
      one: '1 nueva',
      zero: '0 nuevas',
    );
    return '$_temp0';
  }

  @override
  String syncCountUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actualizadas',
      one: '1 actualizada',
      zero: '0 actualizadas',
    );
    return '$_temp0';
  }

  @override
  String syncCountRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eliminadas',
      one: '1 eliminada',
      zero: '0 eliminadas',
    );
    return '$_temp0';
  }

  @override
  String get syncItemsShow => 'Ver elementos';

  @override
  String get syncItemsHide => 'Ocultar elementos';

  @override
  String get syncActionAdded => 'Añadida';

  @override
  String get syncActionUpdated => 'Actualizada';

  @override
  String get syncActionRemoved => 'Eliminada';

  @override
  String get syncHistoryTitle => 'Sincronizaciones recientes';

  @override
  String get syncHistoryEmpty => 'Aún no hay sincronizaciones';

  @override
  String get syncRelativeNow => 'hace un momento';

  @override
  String syncRelativeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String syncRelativeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count h',
      one: 'hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String syncRelativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count d',
      one: 'hace 1 d',
    );
    return '$_temp0';
  }

  @override
  String get syncBadgeSyncing => 'Sincronizando…';

  @override
  String get syncBadgeSynced => 'Al día';

  @override
  String get syncBadgeError => 'Error de sync';

  @override
  String get syncPairedDevicesTitle => 'Dispositivos vinculados';

  @override
  String get syncNeverSynced => 'Nunca sincronizado';

  @override
  String syncLastSyncLabel(String when) {
    return 'Última sync: $when';
  }

  @override
  String get syncUnlinkDevice => 'Desvincular';

  @override
  String get notifSyncTitle => 'Bóveda sincronizada';

  @override
  String notifSyncBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios sincronizados',
      one: '1 cambio sincronizado',
    );
    return '$_temp0';
  }
}
