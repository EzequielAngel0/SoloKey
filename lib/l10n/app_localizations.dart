import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get commonClear;

  /// No description provided for @commonExpand.
  ///
  /// In es, this message translates to:
  /// **'Expandir'**
  String get commonExpand;

  /// No description provided for @commonCollapse.
  ///
  /// In es, this message translates to:
  /// **'Contraer'**
  String get commonCollapse;

  /// No description provided for @commonShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get commonHidePassword;

  /// No description provided for @formDeleteField.
  ///
  /// In es, this message translates to:
  /// **'Eliminar campo'**
  String get formDeleteField;

  /// No description provided for @unlockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu bóveda está cerrada'**
  String get unlockSubtitle;

  /// No description provided for @unlockMasterPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña maestra'**
  String get unlockMasterPasswordHint;

  /// No description provided for @unlockButton.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get unlockButton;

  /// No description provided for @unlockLockedFor.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado ({time})'**
  String unlockLockedFor(String time);

  /// No description provided for @unlockWifiAvailable.
  ///
  /// In es, this message translates to:
  /// **'Aprobar desde el celular'**
  String get unlockWifiAvailable;

  /// No description provided for @unlockForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña maestra?'**
  String get unlockForgotPassword;

  /// No description provided for @unlockFromMobile.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueando desde dispositivo móvil…'**
  String get unlockFromMobile;

  /// No description provided for @unlockTooManyAttempts.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Reintenta en {time}.'**
  String unlockTooManyAttempts(String time);

  /// No description provided for @unlockRemoteFailed.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo remoto fallido: {msg}'**
  String unlockRemoteFailed(String msg);

  /// No description provided for @unlockRemoteError.
  ///
  /// In es, this message translates to:
  /// **'Error en desbloqueo remoto'**
  String get unlockRemoteError;

  /// No description provided for @unlockBiometricReason.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea tu bóveda'**
  String get unlockBiometricReason;

  /// No description provided for @unlockWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña maestra incorrecta'**
  String get unlockWrongPassword;

  /// No description provided for @unlockWrongPasswordLocked.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Bloqueado {time}.'**
  String unlockWrongPasswordLocked(String time);

  /// No description provided for @unlockVaultWiped.
  ///
  /// In es, this message translates to:
  /// **'Bóveda borrada por demasiados intentos fallidos.'**
  String get unlockVaultWiped;

  /// No description provided for @unlockBiometricFailed.
  ///
  /// In es, this message translates to:
  /// **'Autenticación biométrica fallida o no configurada.'**
  String get unlockBiometricFailed;

  /// No description provided for @unlockGenericError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo desbloquear la bóveda.'**
  String get unlockGenericError;

  /// No description provided for @unlockWithWindowsHello.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Windows Hello'**
  String get unlockWithWindowsHello;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con biometría'**
  String get unlockWithBiometrics;

  /// No description provided for @unlockOrUseMasterPassword.
  ///
  /// In es, this message translates to:
  /// **'o escribe tu contraseña maestra'**
  String get unlockOrUseMasterPassword;

  /// No description provided for @unlockAttemptsBeforeLockout.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Queda 1 intento antes del bloqueo temporal} other{Quedan {count} intentos antes del bloqueo temporal}}'**
  String unlockAttemptsBeforeLockout(int count);

  /// No description provided for @unlockAttemptsBeforeWipe.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Queda 1 intento antes de borrar la bóveda} other{Quedan {count} intentos antes de borrar la bóveda}}'**
  String unlockAttemptsBeforeWipe(int count);

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAutoLock.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo automático'**
  String get settingsSectionAutoLock;

  /// No description provided for @settingsSectionClipboard.
  ///
  /// In es, this message translates to:
  /// **'Portapapeles'**
  String get settingsSectionClipboard;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionQuickFill.
  ///
  /// In es, this message translates to:
  /// **'Autocompletado rápido'**
  String get settingsSectionQuickFill;

  /// No description provided for @settingsAutoLockLabel.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo por inactividad'**
  String get settingsAutoLockLabel;

  /// No description provided for @settingsAutoLockValue.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String settingsAutoLockValue(int minutes);

  /// No description provided for @settingsClearClipboardLabel.
  ///
  /// In es, this message translates to:
  /// **'Limpiar portapapeles'**
  String get settingsClearClipboardLabel;

  /// No description provided for @settingsClearClipboardValue.
  ///
  /// In es, this message translates to:
  /// **'{seconds}s'**
  String settingsClearClipboardValue(int seconds);

  /// No description provided for @settingsBiometricLabel.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico'**
  String get settingsBiometricLabel;

  /// No description provided for @settingsBiometricSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa huella dactilar o rostro'**
  String get settingsBiometricSubtitle;

  /// No description provided for @settingsObscureLabel.
  ///
  /// In es, this message translates to:
  /// **'Ocultar en segundo plano'**
  String get settingsObscureLabel;

  /// No description provided for @settingsObscureSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aplica pantalla de privacidad al cambiar de app'**
  String get settingsObscureSubtitle;

  /// No description provided for @settingsAutostartLabel.
  ///
  /// In es, this message translates to:
  /// **'Iniciar con el sistema'**
  String get settingsAutostartLabel;

  /// No description provided for @settingsAutostartSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Arranca minimizado en la bandeja al encender el equipo'**
  String get settingsAutostartSubtitle;

  /// No description provided for @settingsQuickFillDescription.
  ///
  /// In es, this message translates to:
  /// **'Pulsa el atajo desde cualquier app para abrir SoloKey y copiar usuario/contraseña al portapapeles (se limpia solo).'**
  String get settingsQuickFillDescription;

  /// No description provided for @settingsQuickFillTryNow.
  ///
  /// In es, this message translates to:
  /// **'Probar ahora'**
  String get settingsQuickFillTryNow;

  /// No description provided for @commonDisabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get commonDisabled;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionData.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionDanger.
  ///
  /// In es, this message translates to:
  /// **'Zona peligrosa'**
  String get settingsSectionDanger;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tema de la aplicación'**
  String get settingsThemeTitle;

  /// No description provided for @settingsDensityTitle.
  ///
  /// In es, this message translates to:
  /// **'Densidad'**
  String get settingsDensityTitle;

  /// No description provided for @densityComfortable.
  ///
  /// In es, this message translates to:
  /// **'Cómoda'**
  String get densityComfortable;

  /// No description provided for @densityCompact.
  ///
  /// In es, this message translates to:
  /// **'Compacta'**
  String get densityCompact;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @themeDim.
  ///
  /// In es, this message translates to:
  /// **'Tenue'**
  String get themeDim;

  /// No description provided for @themeOled.
  ///
  /// In es, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @settingsWipeTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar bóveda tras intentos fallidos'**
  String get settingsWipeTitle;

  /// No description provided for @settingsWipeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Si alguien prueba muchas contraseñas, se borra todo (no se deshace)'**
  String get settingsWipeSubtitle;

  /// No description provided for @settingsSyncComputerTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar computadora'**
  String get settingsSyncComputerTitle;

  /// No description provided for @settingsSyncComputerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vincula con SoloKey de escritorio'**
  String get settingsSyncComputerSubtitle;

  /// No description provided for @settingsExportImportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar / Importar'**
  String get settingsExportImportTitle;

  /// No description provided for @settingsExportImportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Haz copias de respaldo cifradas de tu bóveda'**
  String get settingsExportImportSubtitle;

  /// No description provided for @settingsAutofillTitle.
  ///
  /// In es, this message translates to:
  /// **'Autocompletado del sistema'**
  String get settingsAutofillTitle;

  /// No description provided for @settingsAutofillSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completa contraseñas en otras apps'**
  String get settingsAutofillSubtitle;

  /// No description provided for @settingsPasskeysTitle.
  ///
  /// In es, this message translates to:
  /// **'Respaldo de Passkeys'**
  String get settingsPasskeysTitle;

  /// No description provided for @settingsPasskeysSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus respaldos de passkey'**
  String get settingsPasskeysSubtitle;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In es, this message translates to:
  /// **'Respaldo automático'**
  String get settingsBackupTitle;

  /// No description provided for @settingsBackupDaily.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get settingsBackupDaily;

  /// No description provided for @settingsBackupWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get settingsBackupWeekly;

  /// No description provided for @settingsBackupMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get settingsBackupMonthly;

  /// No description provided for @settingsBackupEveryNDays.
  ///
  /// In es, this message translates to:
  /// **'Cada {days} días'**
  String settingsBackupEveryNDays(int days);

  /// No description provided for @settingsBackupNoFolder.
  ///
  /// In es, this message translates to:
  /// **'sin carpeta'**
  String get settingsBackupNoFolder;

  /// No description provided for @settingsBackupFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get settingsBackupFrequency;

  /// No description provided for @settingsBackupChooseFolder.
  ///
  /// In es, this message translates to:
  /// **'Elegir carpeta destino'**
  String get settingsBackupChooseFolder;

  /// No description provided for @settingsBackupPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña del respaldo'**
  String get settingsBackupPassword;

  /// No description provided for @settingsBackupPasswordKeep.
  ///
  /// In es, this message translates to:
  /// **'Contraseña del respaldo (vacía para no cambiarla)'**
  String get settingsBackupPasswordKeep;

  /// No description provided for @settingsLockNowTitle.
  ///
  /// In es, this message translates to:
  /// **'Bloquear ahora'**
  String get settingsLockNowTitle;

  /// No description provided for @settingsLockNowSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cierra la sesión inmediatamente'**
  String get settingsLockNowSubtitle;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersionLabel;

  /// No description provided for @settingsAboutTagline.
  ///
  /// In es, this message translates to:
  /// **'Gestor de contraseñas local-first'**
  String get settingsAboutTagline;

  /// No description provided for @settingsSectionShortcuts.
  ///
  /// In es, this message translates to:
  /// **'Atajos de teclado'**
  String get settingsSectionShortcuts;

  /// No description provided for @shortcutCommandPalette.
  ///
  /// In es, this message translates to:
  /// **'Paleta de comandos'**
  String get shortcutCommandPalette;

  /// No description provided for @shortcutNewCredential.
  ///
  /// In es, this message translates to:
  /// **'Nueva credencial'**
  String get shortcutNewCredential;

  /// No description provided for @shortcutEditCredential.
  ///
  /// In es, this message translates to:
  /// **'Editar seleccionada'**
  String get shortcutEditCredential;

  /// No description provided for @shortcutLock.
  ///
  /// In es, this message translates to:
  /// **'Bloquear bóveda'**
  String get shortcutLock;

  /// No description provided for @shortcutReset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer atajos'**
  String get shortcutReset;

  /// No description provided for @shortcutEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar atajo'**
  String get shortcutEditTitle;

  /// No description provided for @shortcutCapturePrompt.
  ///
  /// In es, this message translates to:
  /// **'Pulsa la combinación de teclas…'**
  String get shortcutCapturePrompt;

  /// No description provided for @shortcutNeedsModifier.
  ///
  /// In es, this message translates to:
  /// **'Añade un modificador (Ctrl, Alt o Shift)'**
  String get shortcutNeedsModifier;

  /// No description provided for @shortcutConflict.
  ///
  /// In es, this message translates to:
  /// **'Esa combinación ya la usa otro atajo'**
  String get shortcutConflict;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Seguir el sistema'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @splashTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu bóveda segura'**
  String get splashTagline;

  /// No description provided for @setupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Es la llave de tu bóveda. Elige una que recuerdes: en el siguiente paso te damos un código por si algún día la olvidas.'**
  String get setupSubtitle;

  /// No description provided for @setupMinChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 12 caracteres'**
  String get setupMinChars;

  /// No description provided for @setupConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get setupConfirmLabel;

  /// No description provided for @setupPasswordsMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get setupPasswordsMismatch;

  /// No description provided for @setupCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear bóveda'**
  String get setupCreateButton;

  /// No description provided for @setupNeedUppercase.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos una mayúscula'**
  String get setupNeedUppercase;

  /// No description provided for @setupNeedNumber.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos un número'**
  String get setupNeedNumber;

  /// No description provided for @setupNeedSymbol.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos un símbolo'**
  String get setupNeedSymbol;

  /// No description provided for @setupReqChars.
  ///
  /// In es, this message translates to:
  /// **'12+ caracteres'**
  String get setupReqChars;

  /// No description provided for @setupReqUppercase.
  ///
  /// In es, this message translates to:
  /// **'Mayúscula'**
  String get setupReqUppercase;

  /// No description provided for @setupReqNumber.
  ///
  /// In es, this message translates to:
  /// **'Número'**
  String get setupReqNumber;

  /// No description provided for @setupReqSymbol.
  ///
  /// In es, this message translates to:
  /// **'Símbolo'**
  String get setupReqSymbol;

  /// No description provided for @commonCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get commonCreate;

  /// No description provided for @navAudit.
  ///
  /// In es, this message translates to:
  /// **'Auditoría'**
  String get navAudit;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @navCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales'**
  String get navCredentials;

  /// No description provided for @navFolders.
  ///
  /// In es, this message translates to:
  /// **'Carpetas'**
  String get navFolders;

  /// No description provided for @navFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritas'**
  String get navFavorites;

  /// No description provided for @navVault.
  ///
  /// In es, this message translates to:
  /// **'Bóveda'**
  String get navVault;

  /// No description provided for @navSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get navSecurity;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterPasswords.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas'**
  String get filterPasswords;

  /// No description provided for @securityHubSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Herramientas para mantener tu bóveda sana'**
  String get securityHubSubtitle;

  /// No description provided for @securityHubAuditDesc.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas débiles, repetidas y filtradas'**
  String get securityHubAuditDesc;

  /// No description provided for @securityHubGenerator.
  ///
  /// In es, this message translates to:
  /// **'Generador de contraseñas'**
  String get securityHubGenerator;

  /// No description provided for @securityHubGeneratorDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea contraseñas fuertes y únicas'**
  String get securityHubGeneratorDesc;

  /// No description provided for @securityHubTransferDesc.
  ///
  /// In es, this message translates to:
  /// **'Exporta o importa tu bóveda'**
  String get securityHubTransferDesc;

  /// No description provided for @securityHubSecureFilesDesc.
  ///
  /// In es, this message translates to:
  /// **'Documentos e imágenes cifradas'**
  String get securityHubSecureFilesDesc;

  /// No description provided for @securityHubPasskeysDesc.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus respaldos de passkey cifrados'**
  String get securityHubPasskeysDesc;

  /// No description provided for @securityHubSyncDesc.
  ///
  /// In es, this message translates to:
  /// **'Vincula este dispositivo en tu red'**
  String get securityHubSyncDesc;

  /// No description provided for @securityHubRecoveryDesc.
  ///
  /// In es, this message translates to:
  /// **'Restablece tu contraseña maestra'**
  String get securityHubRecoveryDesc;

  /// No description provided for @generatorSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Generar contraseña'**
  String get generatorSheetTitle;

  /// No description provided for @commandNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get commandNoResults;

  /// No description provided for @commandActionsGroup.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get commandActionsGroup;

  /// No description provided for @commandCredentialsGroup.
  ///
  /// In es, this message translates to:
  /// **'Credenciales'**
  String get commandCredentialsGroup;

  /// No description provided for @commandHintNavigate.
  ///
  /// In es, this message translates to:
  /// **'Navegar'**
  String get commandHintNavigate;

  /// No description provided for @commandHintSelect.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get commandHintSelect;

  /// No description provided for @commandHintClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commandHintClose;

  /// No description provided for @detailAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Avanzado'**
  String get detailAdvanced;

  /// No description provided for @detailTotpSecret.
  ///
  /// In es, this message translates to:
  /// **'Clave secreta'**
  String get detailTotpSecret;

  /// No description provided for @detailCopyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get detailCopyCode;

  /// No description provided for @healthReused.
  ///
  /// In es, this message translates to:
  /// **'Repetida'**
  String get healthReused;

  /// No description provided for @auditScoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud de la bóveda'**
  String get auditScoreTitle;

  /// No description provided for @auditScoreIssues.
  ///
  /// In es, this message translates to:
  /// **'{count} problemas por revisar'**
  String auditScoreIssues(int count);

  /// No description provided for @homeSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar credenciales…'**
  String get homeSearchHint;

  /// No description provided for @homeLockTooltip.
  ///
  /// In es, this message translates to:
  /// **'Bloquear'**
  String get homeLockTooltip;

  /// No description provided for @homeFabNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva'**
  String get homeFabNew;

  /// No description provided for @homeFabFolder.
  ///
  /// In es, this message translates to:
  /// **'Carpeta'**
  String get homeFabFolder;

  /// No description provided for @homeLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error: {msg}'**
  String homeLoadError(String msg);

  /// No description provided for @homeEmptyVault.
  ///
  /// In es, this message translates to:
  /// **'Tu bóveda está vacía'**
  String get homeEmptyVault;

  /// No description provided for @homeCredentialCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin credenciales} =1{1 credencial} other{{count} credenciales}}'**
  String homeCredentialCount(int count);

  /// No description provided for @homeIssuesChip.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 aviso} other{{count} avisos}}'**
  String homeIssuesChip(int count);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos dias'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get homeGreetingEvening;

  /// No description provided for @homeHealthTooltip.
  ///
  /// In es, this message translates to:
  /// **'Salud de la bóveda: toca para ver detalles'**
  String get homeHealthTooltip;

  /// No description provided for @homeSortTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get homeSortTooltip;

  /// No description provided for @sortManual.
  ///
  /// In es, this message translates to:
  /// **'Orden manual'**
  String get sortManual;

  /// No description provided for @sortTitleAsc.
  ///
  /// In es, this message translates to:
  /// **'Nombre (A–Z)'**
  String get sortTitleAsc;

  /// No description provided for @sortUpdatedDesc.
  ///
  /// In es, this message translates to:
  /// **'Modificadas recientemente'**
  String get sortUpdatedDesc;

  /// No description provided for @homeReorderStart.
  ///
  /// In es, this message translates to:
  /// **'Reordenar'**
  String get homeReorderStart;

  /// No description provided for @homeReorderDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get homeReorderDone;

  /// No description provided for @homeReorderHint.
  ///
  /// In es, this message translates to:
  /// **'Arrastra desde el asa para reordenar'**
  String get homeReorderHint;

  /// No description provided for @emptyAddFirst.
  ///
  /// In es, this message translates to:
  /// **'Añade tu primera credencial'**
  String get emptyAddFirst;

  /// No description provided for @emptyAddCredential.
  ///
  /// In es, this message translates to:
  /// **'Añadir credencial'**
  String get emptyAddCredential;

  /// No description provided for @folderDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Carpeta'**
  String get folderDialogTitle;

  /// No description provided for @folderNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la carpeta'**
  String get folderNameLabel;

  /// No description provided for @folderNameHint.
  ///
  /// In es, this message translates to:
  /// **'ej. Trabajo, Sociales…'**
  String get folderNameHint;

  /// No description provided for @commonAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonAccept;

  /// No description provided for @commonErrorDetail.
  ///
  /// In es, this message translates to:
  /// **'Error: {msg}'**
  String commonErrorDetail(String msg);

  /// No description provided for @detailNotFound.
  ///
  /// In es, this message translates to:
  /// **'Credencial no encontrada'**
  String get detailNotFound;

  /// No description provided for @detailRemoveFavorite.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritas'**
  String get detailRemoveFavorite;

  /// No description provided for @detailAddFavorite.
  ///
  /// In es, this message translates to:
  /// **'Añadir a favoritas'**
  String get detailAddFavorite;

  /// No description provided for @detailViewHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial de contraseñas'**
  String get detailViewHistory;

  /// No description provided for @detailDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar credencial'**
  String get detailDeleteTitle;

  /// No description provided for @detailDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{title}\"? Esta acción no se puede deshacer.'**
  String detailDeleteBody(String title);

  /// No description provided for @detailDeleteAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Verifica para eliminar esta credencial'**
  String get detailDeleteAuthReason;

  /// No description provided for @detailRevealAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Autentifícate para revelar este secreto'**
  String get detailRevealAuthReason;

  /// No description provided for @detailRevealSecret.
  ///
  /// In es, this message translates to:
  /// **'Revelar secreto'**
  String get detailRevealSecret;

  /// No description provided for @detailHideSecret.
  ///
  /// In es, this message translates to:
  /// **'Ocultar secreto'**
  String get detailHideSecret;

  /// No description provided for @detailCopyField.
  ///
  /// In es, this message translates to:
  /// **'Copiar {field}'**
  String detailCopyField(String field);

  /// No description provided for @detailHideCountdown.
  ///
  /// In es, this message translates to:
  /// **'Se oculta en {seconds}s'**
  String detailHideCountdown(int seconds);

  /// No description provided for @detailOpenSite.
  ///
  /// In es, this message translates to:
  /// **'Abrir sitio'**
  String get detailOpenSite;

  /// No description provided for @detailOpenSiteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el sitio'**
  String get detailOpenSiteError;

  /// No description provided for @detailPasskeyHandleNote.
  ///
  /// In es, this message translates to:
  /// **'El identificador de la clave privada permanece cifrado en tu bóveda.'**
  String get detailPasskeyHandleNote;

  /// No description provided for @detailTotpExportQr.
  ///
  /// In es, this message translates to:
  /// **'Exportar como QR'**
  String get detailTotpExportQr;

  /// No description provided for @detailTotpExportQrAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma que eres tú para mostrar el QR del autenticador'**
  String get detailTotpExportQrAuthReason;

  /// No description provided for @detailTotpExportQrTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanea en otro dispositivo'**
  String get detailTotpExportQrTitle;

  /// No description provided for @detailTotpExportQrWarning.
  ///
  /// In es, this message translates to:
  /// **'Quien escanee esto podrá generar tus códigos. Manténlo privado.'**
  String get detailTotpExportQrWarning;

  /// No description provided for @fieldUsername.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get fieldUsername;

  /// No description provided for @fieldPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get fieldPassword;

  /// No description provided for @fieldWebsite.
  ///
  /// In es, this message translates to:
  /// **'Sitio web'**
  String get fieldWebsite;

  /// No description provided for @fieldNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get fieldNotes;

  /// No description provided for @fieldKeyType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de llave'**
  String get fieldKeyType;

  /// No description provided for @fieldPrivateKey.
  ///
  /// In es, this message translates to:
  /// **'Llave privada'**
  String get fieldPrivateKey;

  /// No description provided for @fieldPublicKey.
  ///
  /// In es, this message translates to:
  /// **'Llave pública'**
  String get fieldPublicKey;

  /// No description provided for @fieldKeyPassphrase.
  ///
  /// In es, this message translates to:
  /// **'Passphrase de la llave'**
  String get fieldKeyPassphrase;

  /// No description provided for @typePassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get typePassword;

  /// No description provided for @typeApiKey.
  ///
  /// In es, this message translates to:
  /// **'Clave de API'**
  String get typeApiKey;

  /// No description provided for @typeSecureNote.
  ///
  /// In es, this message translates to:
  /// **'Nota segura'**
  String get typeSecureNote;

  /// No description provided for @typeTotp.
  ///
  /// In es, this message translates to:
  /// **'Autenticador (2FA)'**
  String get typeTotp;

  /// No description provided for @typePasskey.
  ///
  /// In es, this message translates to:
  /// **'Respaldo de Passkey'**
  String get typePasskey;

  /// No description provided for @typeSshKey.
  ///
  /// In es, this message translates to:
  /// **'Llave SSH'**
  String get typeSshKey;

  /// No description provided for @rotationMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get rotationMonthly;

  /// No description provided for @rotationQuarterly.
  ///
  /// In es, this message translates to:
  /// **'Cada 3 meses'**
  String get rotationQuarterly;

  /// No description provided for @rotationSemiAnnually.
  ///
  /// In es, this message translates to:
  /// **'Cada 6 meses'**
  String get rotationSemiAnnually;

  /// No description provided for @rotationCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado ({days} días)'**
  String rotationCustom(int days);

  /// No description provided for @rotationNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get rotationNone;

  /// No description provided for @rotationOverdueTitle.
  ///
  /// In es, this message translates to:
  /// **'ROTACIÓN DE CONTRASEÑA VENCIDA'**
  String get rotationOverdueTitle;

  /// No description provided for @rotationReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'RECORDATORIO DE ROTACIÓN'**
  String get rotationReminderTitle;

  /// No description provided for @rotationOverdueBody.
  ///
  /// In es, this message translates to:
  /// **'Debes cambiar esta contraseña. Han pasado más de {days} días desde la última actualización.'**
  String rotationOverdueBody(int days);

  /// No description provided for @rotationReminderBody.
  ///
  /// In es, this message translates to:
  /// **'Próximo cambio requerido en {days} días ({interval}).'**
  String rotationReminderBody(int days, String interval);

  /// No description provided for @secretDecrypting.
  ///
  /// In es, this message translates to:
  /// **'Descifrando…'**
  String get secretDecrypting;

  /// No description provided for @secretDecryptAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Autentícate para descifrar este secreto'**
  String get secretDecryptAuthReason;

  /// No description provided for @secretDecryptError.
  ///
  /// In es, this message translates to:
  /// **'Error al descifrar: {msg}'**
  String secretDecryptError(String msg);

  /// No description provided for @pinDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa PIN secundario'**
  String get pinDialogTitle;

  /// No description provided for @pinDialogLabel.
  ///
  /// In es, this message translates to:
  /// **'PIN secundario'**
  String get pinDialogLabel;

  /// No description provided for @totpTitle.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación (2FA)'**
  String get totpTitle;

  /// No description provided for @totpClipboardLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get totpClipboardLabel;

  /// No description provided for @totpInvalid.
  ///
  /// In es, this message translates to:
  /// **'Inválido'**
  String get totpInvalid;

  /// No description provided for @a11yFavorite.
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get a11yFavorite;

  /// No description provided for @a11yDoubleEncrypted.
  ///
  /// In es, this message translates to:
  /// **'Con doble cifrado'**
  String get a11yDoubleEncrypted;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay contraseñas antiguas.'**
  String get historyEmpty;

  /// No description provided for @historyCopyTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar contraseña'**
  String get historyCopyTooltip;

  /// No description provided for @historyClipboardLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña histórica'**
  String get historyClipboardLabel;

  /// No description provided for @historyRestoreTooltip.
  ///
  /// In es, this message translates to:
  /// **'Restaurar contraseña'**
  String get historyRestoreTooltip;

  /// No description provided for @historyRestoreTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Restaurar contraseña?'**
  String get historyRestoreTitle;

  /// No description provided for @historyRestoreBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción reemplazará la contraseña actual de la credencial con esta contraseña histórica. ¿Deseas continuar?'**
  String get historyRestoreBody;

  /// No description provided for @historyRestoreConfirm.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get historyRestoreConfirm;

  /// No description provided for @historyRestoreSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña restaurada con éxito'**
  String get historyRestoreSuccess;

  /// No description provided for @historyRestoreError.
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar la contraseña: {msg}'**
  String historyRestoreError(String msg);

  /// No description provided for @recoveryTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar acceso'**
  String get recoveryTitle;

  /// No description provided for @recoveryCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Código de recuperación'**
  String get recoveryCodeTitle;

  /// No description provided for @recoveryCodeDescription.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código que guardaste al crear tu bóveda. Con él eliges una contraseña maestra nueva.'**
  String get recoveryCodeDescription;

  /// No description provided for @recoveryEnterCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de recuperación'**
  String get recoveryEnterCode;

  /// No description provided for @recoveryWrongCode.
  ///
  /// In es, this message translates to:
  /// **'Código incorrecto. Verifica e intenta de nuevo.'**
  String get recoveryWrongCode;

  /// No description provided for @recoveryVerifyButton.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get recoveryVerifyButton;

  /// No description provided for @recoveryEnterNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la nueva contraseña maestra'**
  String get recoveryEnterNewPassword;

  /// No description provided for @recoveryMin8.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get recoveryMin8;

  /// No description provided for @recoveryPasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña maestra actualizada exitosamente'**
  String get recoveryPasswordUpdated;

  /// No description provided for @recoveryCodeVerified.
  ///
  /// In es, this message translates to:
  /// **'Código verificado. Ahora establece tu nueva contraseña maestra.'**
  String get recoveryCodeVerified;

  /// No description provided for @recoveryNewPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña maestra'**
  String get recoveryNewPasswordLabel;

  /// No description provided for @recoveryResetButton.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña maestra'**
  String get recoveryResetButton;

  /// No description provided for @recoveryCodeWarning.
  ///
  /// In es, this message translates to:
  /// **'Solo se muestra esta vez. Guárdalo fuera de este equipo, por ejemplo en papel.'**
  String get recoveryCodeWarning;

  /// No description provided for @recoveryCopyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get recoveryCopyCode;

  /// No description provided for @accessStepOf.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String accessStepOf(int current, int total);

  /// No description provided for @recoveryStepEnterCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu código de recuperación'**
  String get recoveryStepEnterCode;

  /// No description provided for @recoveryStepNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Define una nueva contraseña maestra'**
  String get recoveryStepNewPassword;

  /// No description provided for @setupStepCreate.
  ///
  /// In es, this message translates to:
  /// **'Crea tu contraseña maestra'**
  String get setupStepCreate;

  /// No description provided for @setupStepSaveCode.
  ///
  /// In es, this message translates to:
  /// **'Guarda tu código de recuperación'**
  String get setupStepSaveCode;

  /// No description provided for @setupStepImport.
  ///
  /// In es, this message translates to:
  /// **'Trae tus contraseñas'**
  String get setupStepImport;

  /// No description provided for @setupCodeIntro.
  ///
  /// In es, this message translates to:
  /// **'Si olvidas tu contraseña maestra, este código es la única forma de volver a entrar.'**
  String get setupCodeIntro;

  /// No description provided for @setupCodeConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Escribe el grupo {group} del código'**
  String setupCodeConfirmLabel(int group);

  /// No description provided for @setupCodeConfirmHelp.
  ///
  /// In es, this message translates to:
  /// **'Así sabemos que lo guardaste bien.'**
  String get setupCodeConfirmHelp;

  /// No description provided for @setupCodeConfirmWrong.
  ///
  /// In es, this message translates to:
  /// **'No coincide con el grupo {group}. Revisa el código.'**
  String setupCodeConfirmWrong(int group);

  /// No description provided for @setupCodeConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y seguir'**
  String get setupCodeConfirmButton;

  /// No description provided for @setupImportBody.
  ///
  /// In es, this message translates to:
  /// **'¿Usabas otro gestor de contraseñas? Puedes traerlas ahora o más tarde desde Ajustes.'**
  String get setupImportBody;

  /// No description provided for @setupImportButton.
  ///
  /// In es, this message translates to:
  /// **'Importar contraseñas'**
  String get setupImportButton;

  /// No description provided for @setupImportDone.
  ///
  /// In es, this message translates to:
  /// **'Entrar a mi bóveda'**
  String get setupImportDone;

  /// No description provided for @unlockUseSecureKeyboard.
  ///
  /// In es, this message translates to:
  /// **'Usar el teclado seguro'**
  String get unlockUseSecureKeyboard;

  /// No description provided for @autofillOnboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'Autocompletado'**
  String get autofillOnboardingTitle;

  /// No description provided for @autofillActiveTitle.
  ///
  /// In es, this message translates to:
  /// **'¡SoloKey está activo!'**
  String get autofillActiveTitle;

  /// No description provided for @autofillEnableTitle.
  ///
  /// In es, this message translates to:
  /// **'Activa el autocompletado'**
  String get autofillEnableTitle;

  /// No description provided for @autofillActiveDesc.
  ///
  /// In es, this message translates to:
  /// **'SoloKey completará automáticamente tus contraseñas en cualquier app o navegador de tu dispositivo.'**
  String get autofillActiveDesc;

  /// No description provided for @autofillEnableDesc.
  ///
  /// In es, this message translates to:
  /// **'Permite que SoloKey complete tus contraseñas automáticamente en apps y navegadores.'**
  String get autofillEnableDesc;

  /// No description provided for @autofillOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes de Autocompletado'**
  String get autofillOpenSettings;

  /// No description provided for @autofillVerifyStatus.
  ///
  /// In es, this message translates to:
  /// **'Ya lo activé, verificar estado'**
  String get autofillVerifyStatus;

  /// No description provided for @autofillFeatureDetection.
  ///
  /// In es, this message translates to:
  /// **'Detecta solo los formularios de inicio de sesión'**
  String get autofillFeatureDetection;

  /// No description provided for @autofillFeatureBiometric.
  ///
  /// In es, this message translates to:
  /// **'Pide tu huella antes de rellenar (biometría)'**
  String get autofillFeatureBiometric;

  /// No description provided for @autofillFeatureNeverExposed.
  ///
  /// In es, this message translates to:
  /// **'Credenciales nunca expuestas al SO'**
  String get autofillFeatureNeverExposed;

  /// No description provided for @autofillStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get autofillStatusActive;

  /// No description provided for @autofillStatusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get autofillStatusInactive;

  /// No description provided for @autofillStep1Title.
  ///
  /// In es, this message translates to:
  /// **'Toca \"Abrir ajustes de Autocompletado\"'**
  String get autofillStep1Title;

  /// No description provided for @autofillStep1Sub.
  ///
  /// In es, this message translates to:
  /// **'Se abrirá la configuración del sistema'**
  String get autofillStep1Sub;

  /// No description provided for @autofillStep2Title.
  ///
  /// In es, this message translates to:
  /// **'Selecciona \"SoloKey\" como proveedor'**
  String get autofillStep2Title;

  /// No description provided for @autofillStep2Sub.
  ///
  /// In es, this message translates to:
  /// **'Busca SoloKey en la lista de apps'**
  String get autofillStep2Sub;

  /// No description provided for @autofillStep3Title.
  ///
  /// In es, this message translates to:
  /// **'Confirma y regresa a la app'**
  String get autofillStep3Title;

  /// No description provided for @autofillStep3Sub.
  ///
  /// In es, this message translates to:
  /// **'El autocompletado quedará activado'**
  String get autofillStep3Sub;

  /// No description provided for @quickFillTitle.
  ///
  /// In es, this message translates to:
  /// **'Autocompletado rápido'**
  String get quickFillTitle;

  /// No description provided for @quickFillCloseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar (Esc)'**
  String get quickFillCloseTooltip;

  /// No description provided for @quickFillSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar credencial…'**
  String get quickFillSearchHint;

  /// No description provided for @quickFillLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las credenciales'**
  String get quickFillLoadError;

  /// No description provided for @quickFillNoMatches.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias'**
  String get quickFillNoMatches;

  /// No description provided for @quickFillFooter.
  ///
  /// In es, this message translates to:
  /// **'Copia el dato y pégalo (Ctrl+V) en el campo · se limpia solo del portapapeles'**
  String get quickFillFooter;

  /// No description provided for @quickFillCopyUser.
  ///
  /// In es, this message translates to:
  /// **'Copiar usuario'**
  String get quickFillCopyUser;

  /// No description provided for @quickFillCopyPassword.
  ///
  /// In es, this message translates to:
  /// **'Copiar contraseña'**
  String get quickFillCopyPassword;

  /// No description provided for @commonGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get commonGotIt;

  /// No description provided for @auditTitle.
  ///
  /// In es, this message translates to:
  /// **'Auditoría de Seguridad'**
  String get auditTitle;

  /// No description provided for @auditAnalysisTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis de Seguridad'**
  String get auditAnalysisTitle;

  /// No description provided for @auditAnalysisDesc.
  ///
  /// In es, this message translates to:
  /// **'SoloKey analiza tus credenciales localmente para identificar contraseñas débiles, cortas, reutilizadas o antiguas.'**
  String get auditAnalysisDesc;

  /// No description provided for @auditBreachCheck.
  ///
  /// In es, this message translates to:
  /// **'Verificar filtraciones (online)'**
  String get auditBreachCheck;

  /// No description provided for @auditPrivateBadge.
  ///
  /// In es, this message translates to:
  /// **'PRIVADO'**
  String get auditPrivateBadge;

  /// No description provided for @auditBreachDesc.
  ///
  /// In es, this message translates to:
  /// **'Revisa en HaveIBeenPwned si tus contraseñas aparecen en filtraciones, sin enviar nunca tu contraseña.'**
  String get auditBreachDesc;

  /// No description provided for @auditAllGoodTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Todo en orden!'**
  String get auditAllGoodTitle;

  /// No description provided for @auditAllGoodDesc.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron problemas en tu bóveda.'**
  String get auditAllGoodDesc;

  /// No description provided for @auditSeverityCritical.
  ///
  /// In es, this message translates to:
  /// **'Crítico'**
  String get auditSeverityCritical;

  /// No description provided for @auditSeverityWarning.
  ///
  /// In es, this message translates to:
  /// **'Advertencia'**
  String get auditSeverityWarning;

  /// No description provided for @auditSeverityInfo.
  ///
  /// In es, this message translates to:
  /// **'Info'**
  String get auditSeverityInfo;

  /// No description provided for @passkeysTitle.
  ///
  /// In es, this message translates to:
  /// **'Respaldos de Passkey'**
  String get passkeysTitle;

  /// No description provided for @passkeysAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir Passkey'**
  String get passkeysAdd;

  /// No description provided for @passkeysHowToTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo registrar una Passkey?'**
  String get passkeysHowToTitle;

  /// No description provided for @passkeysHowToBody.
  ///
  /// In es, this message translates to:
  /// **'Las Passkeys se registran directamente en cada servicio web (ej. Google, GitHub, Apple).\n\n1. Ve al sitio web del servicio\n2. Busca \"Passkeys\" o \"Llaves de acceso\" en Seguridad\n3. El sistema registrará y sincronizará la passkey automáticamente\n\nSoloKey almacenará la información de la passkey en tu bóveda de forma cifrada para que puedas gestionarla.'**
  String get passkeysHowToBody;

  /// No description provided for @passkeysEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin respaldos de passkey'**
  String get passkeysEmptyTitle;

  /// No description provided for @passkeysEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Las Passkeys son el futuro de la autenticación: sin contraseñas, más seguras y más rápidas. Regístralas en tus servicios favoritos y SoloKey guardará aquí un respaldo cifrado.'**
  String get passkeysEmptyDesc;

  /// No description provided for @passkeysEncryptedBadge.
  ///
  /// In es, this message translates to:
  /// **'Respaldo cifrado en tu bóveda'**
  String get passkeysEncryptedBadge;

  /// No description provided for @passkeysUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizado: {date}'**
  String passkeysUpdated(String date);

  /// No description provided for @passkeysViewDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get passkeysViewDetails;

  /// No description provided for @passkeyDomain.
  ///
  /// In es, this message translates to:
  /// **'Dominio (RP ID)'**
  String get passkeyDomain;

  /// No description provided for @passkeyService.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get passkeyService;

  /// No description provided for @passkeyVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación'**
  String get passkeyVerification;

  /// No description provided for @passkeyVerificationRequired.
  ///
  /// In es, this message translates to:
  /// **'Requerida (Biométrico / PIN)'**
  String get passkeyVerificationRequired;

  /// No description provided for @passkeyVerificationOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get passkeyVerificationOptional;

  /// No description provided for @passkeyCredentialId.
  ///
  /// In es, this message translates to:
  /// **'Credential ID'**
  String get passkeyCredentialId;

  /// No description provided for @passkeyCredentialIdCopied.
  ///
  /// In es, this message translates to:
  /// **'Credential ID copiado'**
  String get passkeyCredentialIdCopied;

  /// No description provided for @passkeyIconLabel.
  ///
  /// In es, this message translates to:
  /// **'Passkey'**
  String get passkeyIconLabel;

  /// No description provided for @passkeyRegistered.
  ///
  /// In es, this message translates to:
  /// **'Registrada'**
  String get passkeyRegistered;

  /// No description provided for @passkeyPrivateKeyNote.
  ///
  /// In es, this message translates to:
  /// **'La clave privada nunca sale del dispositivo. Solo la información de identificación está almacenada.'**
  String get passkeyPrivateKeyNote;

  /// No description provided for @passkeysDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Passkey'**
  String get passkeysDeleteTitle;

  /// No description provided for @passkeysDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar la passkey \"{title}\"?\n\nNota: también deberás eliminarla del servicio web correspondiente ({service}).'**
  String passkeysDeleteBody(String title, String service);

  /// No description provided for @passkeysSiteFallback.
  ///
  /// In es, this message translates to:
  /// **'el sitio'**
  String get passkeysSiteFallback;

  /// No description provided for @passkeysDeleteAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Verifica para eliminar esta passkey'**
  String get passkeysDeleteAuthReason;

  /// No description provided for @formNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva credencial'**
  String get formNewTitle;

  /// No description provided for @formEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar credencial'**
  String get formEditTitle;

  /// No description provided for @formCreated.
  ///
  /// In es, this message translates to:
  /// **'Credencial creada'**
  String get formCreated;

  /// No description provided for @formSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get formSaved;

  /// No description provided for @formSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get formSaveChanges;

  /// No description provided for @formCreateCredential.
  ///
  /// In es, this message translates to:
  /// **'Crear credencial'**
  String get formCreateCredential;

  /// No description provided for @formFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get formFieldRequired;

  /// No description provided for @formErrPinRequiredEnable.
  ///
  /// In es, this message translates to:
  /// **'Debes ingresar un PIN secundario para el cifrado doble'**
  String get formErrPinRequiredEnable;

  /// No description provided for @formErrPinRequiredDisable.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el PIN secundario para desactivar el cifrado doble'**
  String get formErrPinRequiredDisable;

  /// No description provided for @formQrNotTotp.
  ///
  /// In es, this message translates to:
  /// **'El código QR no es de un autenticador.'**
  String get formQrNotTotp;

  /// No description provided for @formQrScanned.
  ///
  /// In es, this message translates to:
  /// **'Código QR escaneado con éxito'**
  String get formQrScanned;

  /// No description provided for @formQrNoSecret.
  ///
  /// In es, this message translates to:
  /// **'No se encontró una clave secreta en el QR.'**
  String get formQrNoSecret;

  /// No description provided for @formQrReadError.
  ///
  /// In es, this message translates to:
  /// **'Error al leer el código QR.'**
  String get formQrReadError;

  /// No description provided for @formSshGenerated.
  ///
  /// In es, this message translates to:
  /// **'Llaves SSH generadas (Ed25519)'**
  String get formSshGenerated;

  /// No description provided for @formSshGenError.
  ///
  /// In es, this message translates to:
  /// **'Error al generar la llave SSH.'**
  String get formSshGenError;

  /// No description provided for @formCustomFieldsTitle.
  ///
  /// In es, this message translates to:
  /// **'Campos Personalizados'**
  String get formCustomFieldsTitle;

  /// No description provided for @formNoCustomFields.
  ///
  /// In es, this message translates to:
  /// **'No hay campos personalizados.'**
  String get formNoCustomFields;

  /// No description provided for @formAddField.
  ///
  /// In es, this message translates to:
  /// **'Añadir campo'**
  String get formAddField;

  /// No description provided for @formEditField.
  ///
  /// In es, this message translates to:
  /// **'Editar campo'**
  String get formEditField;

  /// No description provided for @formNewCustomField.
  ///
  /// In es, this message translates to:
  /// **'Nuevo campo personalizado'**
  String get formNewCustomField;

  /// No description provided for @formFieldNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del campo'**
  String get formFieldNameLabel;

  /// No description provided for @formFieldNameHint.
  ///
  /// In es, this message translates to:
  /// **'ej. PIN, Pregunta de Seguridad'**
  String get formFieldNameHint;

  /// No description provided for @formNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre requerido'**
  String get formNameRequired;

  /// No description provided for @formFieldValueLabel.
  ///
  /// In es, this message translates to:
  /// **'Valor del campo'**
  String get formFieldValueLabel;

  /// No description provided for @formFieldValueHint.
  ///
  /// In es, this message translates to:
  /// **'ej. 1234, Ciudad natal'**
  String get formFieldValueHint;

  /// No description provided for @formValueRequired.
  ///
  /// In es, this message translates to:
  /// **'Valor requerido'**
  String get formValueRequired;

  /// No description provided for @formSecretField.
  ///
  /// In es, this message translates to:
  /// **'Campo secreto'**
  String get formSecretField;

  /// No description provided for @formSecretBadge.
  ///
  /// In es, this message translates to:
  /// **'SECRETO'**
  String get formSecretBadge;

  /// No description provided for @formSecretFieldSub.
  ///
  /// In es, this message translates to:
  /// **'Ocultará el valor por defecto en los detalles.'**
  String get formSecretFieldSub;

  /// No description provided for @formAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get formAdd;

  /// No description provided for @formSectionIdentification.
  ///
  /// In es, this message translates to:
  /// **'Identificación'**
  String get formSectionIdentification;

  /// No description provided for @formTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get formTitleLabel;

  /// No description provided for @formSectionContent.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get formSectionContent;

  /// No description provided for @formSectionNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get formSectionNotes;

  /// No description provided for @formSecureContentLabel.
  ///
  /// In es, this message translates to:
  /// **'Contenido seguro'**
  String get formSecureContentLabel;

  /// No description provided for @formNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales'**
  String get formNotesLabel;

  /// No description provided for @formSecureContentHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nota privada aquí…'**
  String get formSecureContentHint;

  /// No description provided for @formNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Opcional — agregar contexto o recordatorios'**
  String get formNotesHint;

  /// No description provided for @formContentRequired.
  ///
  /// In es, this message translates to:
  /// **'El contenido es requerido'**
  String get formContentRequired;

  /// No description provided for @formSectionOrganization.
  ///
  /// In es, this message translates to:
  /// **'Organización'**
  String get formSectionOrganization;

  /// No description provided for @formFolderLabel.
  ///
  /// In es, this message translates to:
  /// **'Carpeta'**
  String get formFolderLabel;

  /// No description provided for @formMainVault.
  ///
  /// In es, this message translates to:
  /// **'Bóveda principal'**
  String get formMainVault;

  /// No description provided for @formHintPassword.
  ///
  /// In es, this message translates to:
  /// **'ej. Netflix, GitHub, Gmail'**
  String get formHintPassword;

  /// No description provided for @formHintApiKey.
  ///
  /// In es, this message translates to:
  /// **'ej. OpenAI, Stripe, AWS'**
  String get formHintApiKey;

  /// No description provided for @formHintSecureNote.
  ///
  /// In es, this message translates to:
  /// **'ej. Llaves del servidor, frase de recuperación'**
  String get formHintSecureNote;

  /// No description provided for @formHintTotp.
  ///
  /// In es, this message translates to:
  /// **'ej. GitHub 2FA, Google'**
  String get formHintTotp;

  /// No description provided for @formHintPasskey.
  ///
  /// In es, this message translates to:
  /// **'ej. google.com Passkey'**
  String get formHintPasskey;

  /// No description provided for @formHintSshKey.
  ///
  /// In es, this message translates to:
  /// **'ej. Servidor de producción, GitHub'**
  String get formHintSshKey;

  /// No description provided for @formSectionLogin.
  ///
  /// In es, this message translates to:
  /// **'Credenciales de acceso'**
  String get formSectionLogin;

  /// No description provided for @formUserEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Usuario / Email'**
  String get formUserEmailLabel;

  /// No description provided for @formUserEmailHint.
  ///
  /// In es, this message translates to:
  /// **'usuario@ejemplo.com'**
  String get formUserEmailHint;

  /// No description provided for @formWebsiteLabel.
  ///
  /// In es, this message translates to:
  /// **'Sitio web / URL'**
  String get formWebsiteLabel;

  /// No description provided for @formWebsiteHint.
  ///
  /// In es, this message translates to:
  /// **'https://ejemplo.com'**
  String get formWebsiteHint;

  /// No description provided for @formSectionApi.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la API'**
  String get formSectionApi;

  /// No description provided for @formServiceNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del servicio'**
  String get formServiceNameLabel;

  /// No description provided for @formServiceNameHint.
  ///
  /// In es, this message translates to:
  /// **'ej. OpenAI, Stripe, Supabase'**
  String get formServiceNameHint;

  /// No description provided for @formApiKeyLabel.
  ///
  /// In es, this message translates to:
  /// **'Clave de API'**
  String get formApiKeyLabel;

  /// No description provided for @formEndpointLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección del servicio (URL)'**
  String get formEndpointLabel;

  /// No description provided for @formScopesLabel.
  ///
  /// In es, this message translates to:
  /// **'Permisos / Scopes'**
  String get formScopesLabel;

  /// No description provided for @formSection2fa.
  ///
  /// In es, this message translates to:
  /// **'Configuración 2FA'**
  String get formSection2fa;

  /// No description provided for @formTotpDesc.
  ///
  /// In es, this message translates to:
  /// **'Escribe la clave secreta que te da el sitio al activar la verificación en dos pasos, o escanea su código QR.'**
  String get formTotpDesc;

  /// No description provided for @formScanQr.
  ///
  /// In es, this message translates to:
  /// **'Escanear código QR'**
  String get formScanQr;

  /// No description provided for @formScanQrScreen.
  ///
  /// In es, this message translates to:
  /// **'Escanear QR de la pantalla'**
  String get formScanQrScreen;

  /// No description provided for @formQrScreenNoQr.
  ///
  /// In es, this message translates to:
  /// **'No se encontró un código QR en la captura.'**
  String get formQrScreenNoQr;

  /// No description provided for @formQrScreenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo capturar la pantalla.'**
  String get formQrScreenError;

  /// No description provided for @formTotpNonStandard.
  ///
  /// In es, this message translates to:
  /// **'Este autenticador usa una configuración poco común; el código que muestre SoloKey podría no coincidir.'**
  String get formTotpNonStandard;

  /// No description provided for @formOrManually.
  ///
  /// In es, this message translates to:
  /// **'o ingresa manualmente'**
  String get formOrManually;

  /// No description provided for @formAccountIssuerLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuenta / Emisor'**
  String get formAccountIssuerLabel;

  /// No description provided for @formAccountIssuerHint.
  ///
  /// In es, this message translates to:
  /// **'ej. GitHub, Google, AWS'**
  String get formAccountIssuerHint;

  /// No description provided for @formTotpSecretLabel.
  ///
  /// In es, this message translates to:
  /// **'Clave secreta'**
  String get formTotpSecretLabel;

  /// No description provided for @formSectionPasskey.
  ///
  /// In es, this message translates to:
  /// **'Passkey'**
  String get formSectionPasskey;

  /// No description provided for @formPasskeyDesc.
  ///
  /// In es, this message translates to:
  /// **'Las passkeys se crean en cada sitio web, desde tu celular o tu computadora.'**
  String get formPasskeyDesc;

  /// No description provided for @formPasskeyHint.
  ///
  /// In es, this message translates to:
  /// **'Usa la pantalla de Passkeys en Ajustes para registrar o gestionar tus passkeys.'**
  String get formPasskeyHint;

  /// No description provided for @formSectionSsh.
  ///
  /// In es, this message translates to:
  /// **'Llave SSH'**
  String get formSectionSsh;

  /// No description provided for @formGenerateSsh.
  ///
  /// In es, this message translates to:
  /// **'Generar llaves SSH (Ed25519)'**
  String get formGenerateSsh;

  /// No description provided for @formPrivateKeyRequired.
  ///
  /// In es, this message translates to:
  /// **'La llave privada es requerida'**
  String get formPrivateKeyRequired;

  /// No description provided for @formPublicKeyOptional.
  ///
  /// In es, this message translates to:
  /// **'Llave Publica (Opcional)'**
  String get formPublicKeyOptional;

  /// No description provided for @formKeyPassphraseOptional.
  ///
  /// In es, this message translates to:
  /// **'Passphrase de la Llave (Opcional)'**
  String get formKeyPassphraseOptional;

  /// No description provided for @formSectionDoubleEnc.
  ///
  /// In es, this message translates to:
  /// **'Cifrado doble'**
  String get formSectionDoubleEnc;

  /// No description provided for @formEnableDoubleEnc.
  ///
  /// In es, this message translates to:
  /// **'Activar cifrado doble'**
  String get formEnableDoubleEnc;

  /// No description provided for @formDoubleEncDesc.
  ///
  /// In es, this message translates to:
  /// **'Pide un PIN extra para ver los secretos de este registro.'**
  String get formDoubleEncDesc;

  /// No description provided for @formPinSecondaryEditLabel.
  ///
  /// In es, this message translates to:
  /// **'PIN secundario (vacío para no cambiarlo)'**
  String get formPinSecondaryEditLabel;

  /// No description provided for @formPinSecondaryLabel.
  ///
  /// In es, this message translates to:
  /// **'PIN Secundario'**
  String get formPinSecondaryLabel;

  /// No description provided for @formPinSecondaryRequired.
  ///
  /// In es, this message translates to:
  /// **'El PIN secundario es requerido'**
  String get formPinSecondaryRequired;

  /// No description provided for @formBiometricUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo con huella o rostro'**
  String get formBiometricUnlock;

  /// No description provided for @formBiometricUnlockSub.
  ///
  /// In es, this message translates to:
  /// **'Guarda el PIN cifrado para abrirlo rápido con tu huella o tu rostro.'**
  String get formBiometricUnlockSub;

  /// No description provided for @formSectionRotation.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de Rotación'**
  String get formSectionRotation;

  /// No description provided for @formRotationLabel.
  ///
  /// In es, this message translates to:
  /// **'Recordar cambiar contraseña'**
  String get formRotationLabel;

  /// No description provided for @formRotNone.
  ///
  /// In es, this message translates to:
  /// **'No recordar'**
  String get formRotNone;

  /// No description provided for @formRotMonthly.
  ///
  /// In es, this message translates to:
  /// **'Cada mes'**
  String get formRotMonthly;

  /// No description provided for @formRotCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado (días)'**
  String get formRotCustom;

  /// No description provided for @formCustomDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días para recordar'**
  String get formCustomDaysLabel;

  /// No description provided for @formCustomDaysRequired.
  ///
  /// In es, this message translates to:
  /// **'Debe ingresar el número de días'**
  String get formCustomDaysRequired;

  /// No description provided for @formCustomDaysInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un número válido de días'**
  String get formCustomDaysInvalid;

  /// No description provided for @formDiscardTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar cambios?'**
  String get formDiscardTitle;

  /// No description provided for @formDiscardMessage.
  ///
  /// In es, this message translates to:
  /// **'Tienes cambios sin guardar. Si sales ahora se perderan.'**
  String get formDiscardMessage;

  /// No description provided for @formDiscardKeep.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get formDiscardKeep;

  /// No description provided for @formDiscardLeave.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get formDiscardLeave;

  /// No description provided for @formErrInvalidUrl.
  ///
  /// In es, this message translates to:
  /// **'Escribe una dirección web válida'**
  String get formErrInvalidUrl;

  /// No description provided for @formErrInvalidTotp.
  ///
  /// In es, this message translates to:
  /// **'Clave secreta no válida: solo letras de la A a la Z y números del 2 al 7'**
  String get formErrInvalidTotp;

  /// No description provided for @formPasteTotp.
  ///
  /// In es, this message translates to:
  /// **'Pegar enlace del autenticador'**
  String get formPasteTotp;

  /// No description provided for @formPasteApplied.
  ///
  /// In es, this message translates to:
  /// **'Autenticador rellenado desde el portapapeles'**
  String get formPasteApplied;

  /// No description provided for @formPasteNoOtpauth.
  ///
  /// In es, this message translates to:
  /// **'El portapapeles no tiene un enlace de autenticador (otpauth://)'**
  String get formPasteNoOtpauth;

  /// No description provided for @formDupTitle.
  ///
  /// In es, this message translates to:
  /// **'Posible duplicado'**
  String get formDupTitle;

  /// No description provided for @formDupMessage.
  ///
  /// In es, this message translates to:
  /// **'\"{title}\" ya usa este usuario. ¿Guardar de todos modos?'**
  String formDupMessage(String title);

  /// No description provided for @formDupReview.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get formDupReview;

  /// No description provided for @formDupSaveAnyway.
  ///
  /// In es, this message translates to:
  /// **'Guardar de todos modos'**
  String get formDupSaveAnyway;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @folderNewSubfolder.
  ///
  /// In es, this message translates to:
  /// **'Nueva subcarpeta'**
  String get folderNewSubfolder;

  /// No description provided for @folderDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar carpeta'**
  String get folderDeleteTitle;

  /// No description provided for @folderDeleteKeepBody.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar \"{name}\"? Sus subcarpetas y credenciales se conservan: elige a dónde moverlas. No se elimina nada.'**
  String folderDeleteKeepBody(String name);

  /// No description provided for @folderDeleteMoveToParent.
  ///
  /// In es, this message translates to:
  /// **'Mover contenido a la carpeta padre'**
  String get folderDeleteMoveToParent;

  /// No description provided for @folderDeleteMoveToVault.
  ///
  /// In es, this message translates to:
  /// **'Mover contenido a la raíz'**
  String get folderDeleteMoveToVault;

  /// No description provided for @folderDeleted.
  ///
  /// In es, this message translates to:
  /// **'Carpeta eliminada'**
  String get folderDeleted;

  /// No description provided for @folderRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get folderRename;

  /// No description provided for @folderRenameTitle.
  ///
  /// In es, this message translates to:
  /// **'Renombrar carpeta'**
  String get folderRenameTitle;

  /// No description provided for @folderNewNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo nombre'**
  String get folderNewNameLabel;

  /// No description provided for @folderCreateSubfolder.
  ///
  /// In es, this message translates to:
  /// **'Crear subcarpeta'**
  String get folderCreateSubfolder;

  /// No description provided for @folderEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Carpeta Vacía'**
  String get folderEmptyTitle;

  /// No description provided for @folderEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'No hay subcarpetas ni credenciales aquí.'**
  String get folderEmptyDesc;

  /// No description provided for @folderNoFolders.
  ///
  /// In es, this message translates to:
  /// **'Sin carpetas'**
  String get folderNoFolders;

  /// No description provided for @folderOrganize.
  ///
  /// In es, this message translates to:
  /// **'Organiza tus credenciales'**
  String get folderOrganize;

  /// No description provided for @folderCreateRoot.
  ///
  /// In es, this message translates to:
  /// **'Crear carpeta raíz'**
  String get folderCreateRoot;

  /// No description provided for @folderNewRoot.
  ///
  /// In es, this message translates to:
  /// **'Nueva carpeta raíz'**
  String get folderNewRoot;

  /// No description provided for @folderUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin carpeta asignada'**
  String get folderUnassigned;

  /// No description provided for @folderNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva carpeta'**
  String get folderNew;

  /// No description provided for @folderAddSubfolder.
  ///
  /// In es, this message translates to:
  /// **'Añadir subcarpeta'**
  String get folderAddSubfolder;

  /// No description provided for @folderItemCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin elementos} =1{1 elemento} other{{count} elementos}}'**
  String folderItemCount(int count);

  /// No description provided for @folderColorTitle.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get folderColorTitle;

  /// No description provided for @folderEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar carpeta'**
  String get folderEditTitle;

  /// No description provided for @folderTreeHint.
  ///
  /// In es, this message translates to:
  /// **'Usa las flechas para navegar por las carpetas; pulsa el botón de menú para acciones.'**
  String get folderTreeHint;

  /// No description provided for @folderSelectTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Carpeta'**
  String get folderSelectTitle;

  /// No description provided for @folderNewRootShort.
  ///
  /// In es, this message translates to:
  /// **'Nueva raíz'**
  String get folderNewRootShort;

  /// No description provided for @folderNoneMainVault.
  ///
  /// In es, this message translates to:
  /// **'Ninguna (Bóveda principal)'**
  String get folderNoneMainVault;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes favoritos'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Marca carpetas o credenciales con una estrella'**
  String get favoritesEmptyDesc;

  /// No description provided for @favoritesFoldersHeader.
  ///
  /// In es, this message translates to:
  /// **'Carpetas Favoritas'**
  String get favoritesFoldersHeader;

  /// No description provided for @favoritesCredentialsHeader.
  ///
  /// In es, this message translates to:
  /// **'Credenciales Favoritas'**
  String get favoritesCredentialsHeader;

  /// No description provided for @favoriteToggleLabel.
  ///
  /// In es, this message translates to:
  /// **'Marcar como favorita'**
  String get favoriteToggleLabel;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @cardCopyUser.
  ///
  /// In es, this message translates to:
  /// **'Copiar Usuario'**
  String get cardCopyUser;

  /// No description provided for @cardCopyPassword.
  ///
  /// In es, this message translates to:
  /// **'Copiar Contraseña'**
  String get cardCopyPassword;

  /// No description provided for @cardCopyPasswordAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Autentícate para copiar la contraseña'**
  String get cardCopyPasswordAuthReason;

  /// No description provided for @cardMoveToFolder.
  ///
  /// In es, this message translates to:
  /// **'Mover a carpeta'**
  String get cardMoveToFolder;

  /// No description provided for @cardNoFolder.
  ///
  /// In es, this message translates to:
  /// **'Sin carpeta'**
  String get cardNoFolder;

  /// No description provided for @cardMovedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Credencial movida con éxito'**
  String get cardMovedSuccess;

  /// No description provided for @typeSelNote.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get typeSelNote;

  /// No description provided for @typeSelTotp.
  ///
  /// In es, this message translates to:
  /// **'Autenticador'**
  String get typeSelTotp;

  /// No description provided for @typeSelPasskey.
  ///
  /// In es, this message translates to:
  /// **'Passkey'**
  String get typeSelPasskey;

  /// No description provided for @genRegenerate.
  ///
  /// In es, this message translates to:
  /// **'Regenerar'**
  String get genRegenerate;

  /// No description provided for @genLength.
  ///
  /// In es, this message translates to:
  /// **'Longitud: {n}'**
  String genLength(int n);

  /// No description provided for @genGeneratedPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña generada'**
  String get genGeneratedPassword;

  /// No description provided for @genUseAndCopy.
  ///
  /// In es, this message translates to:
  /// **'Usar y Copiar'**
  String get genUseAndCopy;

  /// No description provided for @strengthWeak.
  ///
  /// In es, this message translates to:
  /// **'Débil'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In es, this message translates to:
  /// **'Buena'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In es, this message translates to:
  /// **'Fuerte'**
  String get strengthStrong;

  /// No description provided for @clipboardCopiedClears.
  ///
  /// In es, this message translates to:
  /// **'{label} copiado · se limpia en {seconds}s'**
  String clipboardCopiedClears(String label, int seconds);

  /// No description provided for @passwordRowGeneratorTooltip.
  ///
  /// In es, this message translates to:
  /// **'Generador de claves'**
  String get passwordRowGeneratorTooltip;

  /// No description provided for @keyboardSpace.
  ///
  /// In es, this message translates to:
  /// **'Espacio'**
  String get keyboardSpace;

  /// No description provided for @transferTitle.
  ///
  /// In es, this message translates to:
  /// **'Transferir datos'**
  String get transferTitle;

  /// No description provided for @transferTabExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get transferTabExport;

  /// No description provided for @transferTabImport.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get transferTabImport;

  /// No description provided for @transferErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get transferErrorTitle;

  /// No description provided for @transferTypePasswords.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas'**
  String get transferTypePasswords;

  /// No description provided for @transferTypeApiKeys.
  ///
  /// In es, this message translates to:
  /// **'Claves de API'**
  String get transferTypeApiKeys;

  /// No description provided for @transferTypeSecureNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas seguras'**
  String get transferTypeSecureNotes;

  /// No description provided for @transferTypeTotp.
  ///
  /// In es, this message translates to:
  /// **'Autenticadores'**
  String get transferTypeTotp;

  /// No description provided for @transferTypePasskeys.
  ///
  /// In es, this message translates to:
  /// **'Passkeys'**
  String get transferTypePasskeys;

  /// No description provided for @transferTypeSshKeys.
  ///
  /// In es, this message translates to:
  /// **'Llaves SSH'**
  String get transferTypeSshKeys;

  /// No description provided for @transferExportPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una contraseña de exportación'**
  String get transferExportPasswordRequired;

  /// No description provided for @transferSelectAtLeastOneType.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un tipo de credencial'**
  String get transferSelectAtLeastOneType;

  /// No description provided for @transferExportedSummary.
  ///
  /// In es, this message translates to:
  /// **'Exportadas {creds} credenciales · {folders} carpetas'**
  String transferExportedSummary(int creds, int folders);

  /// No description provided for @transferExportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar: {msg}'**
  String transferExportError(String msg);

  /// No description provided for @transferImportError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar: {msg}'**
  String transferImportError(String msg);

  /// No description provided for @transferImportCsvError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar CSV: {msg}'**
  String transferImportCsvError(String msg);

  /// No description provided for @transferOverwriteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Sobrescribir bóveda?'**
  String get transferOverwriteTitle;

  /// No description provided for @transferOverwriteBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará TODAS las credenciales actuales y las reemplazará con las del archivo. Esta operación no se puede deshacer.'**
  String get transferOverwriteBody;

  /// No description provided for @transferOverwriteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sobrescribir'**
  String get transferOverwriteConfirm;

  /// No description provided for @transferExportPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña de exportación'**
  String get transferExportPasswordLabel;

  /// No description provided for @transferExportPasswordInfo.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña para proteger este respaldo. La necesitarás al importarlo en cualquier equipo.'**
  String get transferExportPasswordInfo;

  /// No description provided for @transferExportPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: \"mi-clave-de-respaldo\"'**
  String get transferExportPasswordHint;

  /// No description provided for @transferSelectWhatToExport.
  ///
  /// In es, this message translates to:
  /// **'Selecciona qué exportar'**
  String get transferSelectWhatToExport;

  /// No description provided for @transferEncryptionInfo.
  ///
  /// In es, this message translates to:
  /// **'El archivo va cifrado: solo quien conozca la contraseña de exportación puede abrirlo.'**
  String get transferEncryptionInfo;

  /// No description provided for @transferExportButton.
  ///
  /// In es, this message translates to:
  /// **'Exportar bóveda'**
  String get transferExportButton;

  /// No description provided for @transferExportDone.
  ///
  /// In es, this message translates to:
  /// **'Exportación completada'**
  String get transferExportDone;

  /// No description provided for @transferBackupReminder.
  ///
  /// In es, this message translates to:
  /// **'Hace tiempo que no haces un respaldo. Exporta una copia cifrada y guárdala en un lugar seguro.'**
  String get transferBackupReminder;

  /// No description provided for @transferSavedTo.
  ///
  /// In es, this message translates to:
  /// **'Guardado en: {path}'**
  String transferSavedTo(String path);

  /// No description provided for @transferSummary.
  ///
  /// In es, this message translates to:
  /// **'{creds} credenciales · {folders} carpetas'**
  String transferSummary(int creds, int folders);

  /// No description provided for @transferBackupPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña del respaldo'**
  String get transferBackupPasswordLabel;

  /// No description provided for @transferImportPasswordInfo.
  ///
  /// In es, this message translates to:
  /// **'Escribe la contraseña que usaste al exportar. Si el respaldo es de este mismo equipo, puedes dejarla vacía.'**
  String get transferImportPasswordInfo;

  /// No description provided for @transferImportPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Vacía si el respaldo es de este equipo'**
  String get transferImportPasswordHint;

  /// No description provided for @transferImportModeLabel.
  ///
  /// In es, this message translates to:
  /// **'Modo de importación'**
  String get transferImportModeLabel;

  /// No description provided for @transferModeMerge.
  ///
  /// In es, this message translates to:
  /// **'Combinar'**
  String get transferModeMerge;

  /// No description provided for @transferModeMergeSub.
  ///
  /// In es, this message translates to:
  /// **'Añadir sin borrar tus credenciales actuales'**
  String get transferModeMergeSub;

  /// No description provided for @transferModeOverwrite.
  ///
  /// In es, this message translates to:
  /// **'Sobrescribir'**
  String get transferModeOverwrite;

  /// No description provided for @transferModeOverwriteSub.
  ///
  /// In es, this message translates to:
  /// **'Borrará todo y reemplazará con el archivo'**
  String get transferModeOverwriteSub;

  /// No description provided for @transferSelectFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo (.skvault)'**
  String get transferSelectFile;

  /// No description provided for @transferImportCsv.
  ///
  /// In es, this message translates to:
  /// **'Importar desde CSV (Bitwarden, Chrome, 1Password)'**
  String get transferImportCsv;

  /// No description provided for @transferImportOtpauth.
  ///
  /// In es, this message translates to:
  /// **'Importar autenticadores'**
  String get transferImportOtpauth;

  /// No description provided for @transferOtpauthNone.
  ///
  /// In es, this message translates to:
  /// **'Ese archivo no tiene autenticadores (enlaces otpauth://)'**
  String get transferOtpauthNone;

  /// No description provided for @transferOtpauthMigrationUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Los QR de exportación de Google Authenticator no son compatibles. Exporta cada cuenta por separado.'**
  String get transferOtpauthMigrationUnsupported;

  /// No description provided for @transferDuplicatesWarning.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 elemento seleccionado ya existe en tu bóveda} other{{count} elementos seleccionados ya existen en tu bóveda}}'**
  String transferDuplicatesWarning(int count);

  /// No description provided for @transferImportDone.
  ///
  /// In es, this message translates to:
  /// **'Importación completada'**
  String get transferImportDone;

  /// No description provided for @transferExportSelectFolders.
  ///
  /// In es, this message translates to:
  /// **'Carpetas a exportar'**
  String get transferExportSelectFolders;

  /// No description provided for @transferNoFolder.
  ///
  /// In es, this message translates to:
  /// **'Sin carpeta'**
  String get transferNoFolder;

  /// No description provided for @transferImportSelectTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona qué importar'**
  String get transferImportSelectTitle;

  /// No description provided for @transferSectionTypes.
  ///
  /// In es, this message translates to:
  /// **'Tipos de credencial'**
  String get transferSectionTypes;

  /// No description provided for @transferSectionFolders.
  ///
  /// In es, this message translates to:
  /// **'Carpetas'**
  String get transferSectionFolders;

  /// No description provided for @transferImportConfirm.
  ///
  /// In es, this message translates to:
  /// **'Importar selección'**
  String get transferImportConfirm;

  /// No description provided for @transferNothingSelected.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un elemento para importar'**
  String get transferNothingSelected;

  /// No description provided for @transferSelectAll.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar todo'**
  String get transferSelectAll;

  /// No description provided for @transferSelectCredentials.
  ///
  /// In es, this message translates to:
  /// **'Selecciona qué exportar'**
  String get transferSelectCredentials;

  /// No description provided for @transferSelectAtLeastOneCredential.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una credencial'**
  String get transferSelectAtLeastOneCredential;

  /// No description provided for @commonSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar…'**
  String get commonSearch;

  /// No description provided for @navSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar'**
  String get navSync;

  /// No description provided for @desktopEmptyVault.
  ///
  /// In es, this message translates to:
  /// **'Bóveda vacía'**
  String get desktopEmptyVault;

  /// No description provided for @desktopCreateFolder.
  ///
  /// In es, this message translates to:
  /// **'Crear carpeta'**
  String get desktopCreateFolder;

  /// No description provided for @desktopNoCredentials.
  ///
  /// In es, this message translates to:
  /// **'Sin credenciales'**
  String get desktopNoCredentials;

  /// No description provided for @desktopNoFavorites.
  ///
  /// In es, this message translates to:
  /// **'Sin favoritas'**
  String get desktopNoFavorites;

  /// No description provided for @desktopSelectFolderTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una carpeta'**
  String get desktopSelectFolderTitle;

  /// No description provided for @desktopSelectFolderSub.
  ///
  /// In es, this message translates to:
  /// **'Haz clic en una carpeta de la lista para ver su contenido aquí.'**
  String get desktopSelectFolderSub;

  /// No description provided for @desktopSecureVaultTitle.
  ///
  /// In es, this message translates to:
  /// **'Bóveda Segura'**
  String get desktopSecureVaultTitle;

  /// No description provided for @desktopSelectCredentialSub.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una credencial de la lista para ver o editar sus detalles.'**
  String get desktopSelectCredentialSub;

  /// No description provided for @desktopNewFolderTooltip.
  ///
  /// In es, this message translates to:
  /// **'Nueva carpeta'**
  String get desktopNewFolderTooltip;

  /// No description provided for @desktopNewCredentialTooltip.
  ///
  /// In es, this message translates to:
  /// **'Nueva credencial'**
  String get desktopNewCredentialTooltip;

  /// No description provided for @desktopLockVault.
  ///
  /// In es, this message translates to:
  /// **'Bloquear Bóveda'**
  String get desktopLockVault;

  /// No description provided for @desktopSectionVault.
  ///
  /// In es, this message translates to:
  /// **'Bóveda'**
  String get desktopSectionVault;

  /// No description provided for @desktopSectionSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get desktopSectionSecurity;

  /// No description provided for @desktopSectionDevices.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos'**
  String get desktopSectionDevices;

  /// No description provided for @desktopCollapseSidebar.
  ///
  /// In es, this message translates to:
  /// **'Colapsar barra lateral'**
  String get desktopCollapseSidebar;

  /// No description provided for @desktopExpandSidebar.
  ///
  /// In es, this message translates to:
  /// **'Expandir barra lateral'**
  String get desktopExpandSidebar;

  /// No description provided for @desktopWatchtowerBadge.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} elemento requiere atención} other{{count} elementos requieren atención}}'**
  String desktopWatchtowerBadge(int count);

  /// No description provided for @trayShowVault.
  ///
  /// In es, this message translates to:
  /// **'Mostrar bóveda'**
  String get trayShowVault;

  /// No description provided for @trayExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get trayExit;

  /// No description provided for @navSecureFiles.
  ///
  /// In es, this message translates to:
  /// **'Archivos seguros'**
  String get navSecureFiles;

  /// No description provided for @secureFilesTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivos seguros'**
  String get secureFilesTitle;

  /// No description provided for @secureFilesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin archivos'**
  String get secureFilesEmptyTitle;

  /// No description provided for @secureFilesEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Guarda llaves SSH privadas, credentials.json o cualquier otro archivo, cifrado con tu contraseña maestra.'**
  String get secureFilesEmptyDesc;

  /// No description provided for @secureFilesAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir archivo'**
  String get secureFilesAdd;

  /// No description provided for @secureFilesExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar / Guardar'**
  String get secureFilesExport;

  /// No description provided for @secureFilesDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get secureFilesDelete;

  /// No description provided for @secureFilesAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu identidad para acceder al archivo'**
  String get secureFilesAuthReason;

  /// No description provided for @secureFilesDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar archivo?'**
  String get secureFilesDeleteConfirmTitle;

  /// No description provided for @secureFilesDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"? Esto borra permanentemente el archivo cifrado.'**
  String secureFilesDeleteConfirmBody(String name);

  /// No description provided for @secureFilesDeleted.
  ///
  /// In es, this message translates to:
  /// **'Archivo eliminado'**
  String get secureFilesDeleted;

  /// No description provided for @secureFilesSaved.
  ///
  /// In es, this message translates to:
  /// **'Archivo guardado'**
  String get secureFilesSaved;

  /// No description provided for @secureFilesAddedSummary.
  ///
  /// In es, this message translates to:
  /// **'Añadido {name}'**
  String secureFilesAddedSummary(String name);

  /// No description provided for @secureFilesAddError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo añadir el archivo: {msg}'**
  String secureFilesAddError(String msg);

  /// No description provided for @secureFilesExportError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo exportar el archivo: {msg}'**
  String secureFilesExportError(String msg);

  /// No description provided for @secureFilesRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get secureFilesRename;

  /// No description provided for @secureFilesRenameTitle.
  ///
  /// In es, this message translates to:
  /// **'Renombrar archivo'**
  String get secureFilesRenameTitle;

  /// No description provided for @secureFilesSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar archivos…'**
  String get secureFilesSearchHint;

  /// No description provided for @secureFilesSortRecent.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get secureFilesSortRecent;

  /// No description provided for @secureFilesSortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get secureFilesSortName;

  /// No description provided for @secureFilesSortSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get secureFilesSortSize;

  /// No description provided for @secureFilesEditNote.
  ///
  /// In es, this message translates to:
  /// **'Editar nota'**
  String get secureFilesEditNote;

  /// No description provided for @secureFilesNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Nota (no cifrada; no pongas secretos aquí)'**
  String get secureFilesNoteHint;

  /// No description provided for @secureFilesNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para tu búsqueda'**
  String get secureFilesNoResults;

  /// No description provided for @secureFilesMove.
  ///
  /// In es, this message translates to:
  /// **'Mover a carpeta'**
  String get secureFilesMove;

  /// No description provided for @secureFilesMoveTitle.
  ///
  /// In es, this message translates to:
  /// **'Mover a carpeta'**
  String get secureFilesMoveTitle;

  /// No description provided for @secureFilesFavorite.
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get secureFilesFavorite;

  /// No description provided for @secureFilesDropHint.
  ///
  /// In es, this message translates to:
  /// **'Suelta archivos aqui para agregarlos'**
  String get secureFilesDropHint;

  /// No description provided for @secureFilesAddedCount.
  ///
  /// In es, this message translates to:
  /// **'Agregados {count} archivo(s)'**
  String secureFilesAddedCount(int count);

  /// No description provided for @secureFilesTooLarge.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" supera el límite de {limit} y se omitió'**
  String secureFilesTooLarge(String name, String limit);

  /// No description provided for @secureFilesSkippedLarge.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 archivo omitido (muy grande)} other{{count} archivos omitidos (muy grandes)}}'**
  String secureFilesSkippedLarge(int count);

  /// No description provided for @secureFilesProcessing.
  ///
  /// In es, this message translates to:
  /// **'Cifrando {done} de {total}…'**
  String secureFilesProcessing(int done, int total);

  /// No description provided for @secureFilesOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get secureFilesOptions;

  /// No description provided for @secureFilesPreview.
  ///
  /// In es, this message translates to:
  /// **'Previsualizar'**
  String get secureFilesPreview;

  /// No description provided for @secureFilesPreviewError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo previsualizar el archivo: {msg}'**
  String secureFilesPreviewError(String msg);

  /// No description provided for @secureFilesPreviewUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Este archivo no se puede mostrar como imagen.'**
  String get secureFilesPreviewUnsupported;

  /// No description provided for @secureFilesFileTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Archivo {type}'**
  String secureFilesFileTypeLabel(String type);

  /// No description provided for @secureFilesFileGeneric.
  ///
  /// In es, this message translates to:
  /// **'Archivo'**
  String get secureFilesFileGeneric;

  /// No description provided for @relativeNow.
  ///
  /// In es, this message translates to:
  /// **'hace un momento'**
  String get relativeNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 min} other{hace {count} min}}'**
  String relativeMinutes(int count);

  /// No description provided for @relativeHours.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 h} other{hace {count} h}}'**
  String relativeHours(int count);

  /// No description provided for @relativeDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 d} other{hace {count} d}}'**
  String relativeDays(int count);

  /// No description provided for @homeShowHidden.
  ///
  /// In es, this message translates to:
  /// **'Ver ocultas'**
  String get homeShowHidden;

  /// No description provided for @homeShowActive.
  ///
  /// In es, this message translates to:
  /// **'Ver activas'**
  String get homeShowActive;

  /// No description provided for @homeNoHidden.
  ///
  /// In es, this message translates to:
  /// **'No tienes credenciales ocultas'**
  String get homeNoHidden;

  /// No description provided for @detailHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get detailHide;

  /// No description provided for @detailUnhide.
  ///
  /// In es, this message translates to:
  /// **'Mostrar en la lista'**
  String get detailUnhide;

  /// No description provided for @detailHidden.
  ///
  /// In es, this message translates to:
  /// **'Credencial oculta de la lista principal'**
  String get detailHidden;

  /// No description provided for @detailUnhidden.
  ///
  /// In es, this message translates to:
  /// **'Credencial visible de nuevo'**
  String get detailUnhidden;

  /// No description provided for @unlockApprovalSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada a tu celular. Apruebala alli para desbloquear.'**
  String get unlockApprovalSent;

  /// No description provided for @unlockApprovalNoDevice.
  ///
  /// In es, this message translates to:
  /// **'No hay un celular conectado. Abre SoloKey en tu celular en la misma red Wi-Fi.'**
  String get unlockApprovalNoDevice;

  /// No description provided for @syncTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar Dispositivo'**
  String get syncTitle;

  /// No description provided for @syncServerActive.
  ///
  /// In es, this message translates to:
  /// **'Servidor activo. Esperando conexión del celular...'**
  String get syncServerActive;

  /// No description provided for @syncServerOff.
  ///
  /// In es, this message translates to:
  /// **'Servidor apagado.'**
  String get syncServerOff;

  /// No description provided for @syncClientConnecting.
  ///
  /// In es, this message translates to:
  /// **'Celular conectándose...'**
  String get syncClientConnecting;

  /// No description provided for @syncClientDisconnected.
  ///
  /// In es, this message translates to:
  /// **'Celular desconectado. Servidor en espera...'**
  String get syncClientDisconnected;

  /// No description provided for @syncPairedOk.
  ///
  /// In es, this message translates to:
  /// **'¡Vinculación completada con éxito!'**
  String get syncPairedOk;

  /// No description provided for @syncComparing.
  ///
  /// In es, this message translates to:
  /// **'Comparando datos locales con celular...'**
  String get syncComparing;

  /// No description provided for @syncBidirOk.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Los dos equipos quedaron sincronizados'**
  String get syncBidirOk;

  /// No description provided for @syncErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error durante la sincronización.'**
  String get syncErrorGeneric;

  /// No description provided for @syncRemoteUnlockReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibida solicitud de desbloqueo remoto.'**
  String get syncRemoteUnlockReceived;

  /// No description provided for @syncPairTitle.
  ///
  /// In es, this message translates to:
  /// **'Vincular con App Móvil'**
  String get syncPairTitle;

  /// No description provided for @syncPairSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sincroniza tus contraseñas en tiempo real de forma segura y desbloquea esta bóveda usando la biometría de tu celular.'**
  String get syncPairSubtitle;

  /// No description provided for @syncGenerateQr.
  ///
  /// In es, this message translates to:
  /// **'Generar Código QR'**
  String get syncGenerateQr;

  /// No description provided for @syncStartingServer.
  ///
  /// In es, this message translates to:
  /// **'Iniciando servidor local...'**
  String get syncStartingServer;

  /// No description provided for @syncScanThisQr.
  ///
  /// In es, this message translates to:
  /// **'Escanea este código QR'**
  String get syncScanThisQr;

  /// No description provided for @syncScanThisQrSub.
  ///
  /// In es, this message translates to:
  /// **'Abre SoloKey en tu móvil, ve a Sincronizar y escanea este código.'**
  String get syncScanThisQrSub;

  /// No description provided for @syncConnectingDevice.
  ///
  /// In es, this message translates to:
  /// **'Conectando con el dispositivo móvil...'**
  String get syncConnectingDevice;

  /// No description provided for @syncLinkedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Vinculado Exitosamente!'**
  String get syncLinkedTitle;

  /// No description provided for @syncLinkedSub.
  ///
  /// In es, this message translates to:
  /// **'Los dispositivos ahora están enlazados de forma segura.'**
  String get syncLinkedSub;

  /// No description provided for @syncUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get syncUnderstood;

  /// No description provided for @syncErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error de Vinculación'**
  String get syncErrorTitle;

  /// No description provided for @syncUnexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado.'**
  String get syncUnexpectedError;

  /// No description provided for @syncRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get syncRetry;

  /// No description provided for @syncComputerLinked.
  ///
  /// In es, this message translates to:
  /// **'Computadora Vinculada'**
  String get syncComputerLinked;

  /// No description provided for @syncComputerLinkedSub.
  ///
  /// In es, this message translates to:
  /// **'Esta computadora está emparejada de forma segura. Puedes conectar varios dispositivos a la vez escaneando el mismo QR.'**
  String get syncComputerLinkedSub;

  /// No description provided for @syncServerE2eeActive.
  ///
  /// In es, this message translates to:
  /// **'Conexión cifrada activa'**
  String get syncServerE2eeActive;

  /// No description provided for @syncRemoveLink.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Vínculo'**
  String get syncRemoveLink;

  /// No description provided for @syncShowQr.
  ///
  /// In es, this message translates to:
  /// **'Mostrar QR'**
  String get syncShowQr;

  /// No description provided for @syncNowButton.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora'**
  String get syncNowButton;

  /// No description provided for @syncNowRequested.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Sincronización pedida a 1 dispositivo} other{Sincronización pedida a {count} dispositivos}}'**
  String syncNowRequested(int count);

  /// No description provided for @syncNowNoDevices.
  ///
  /// In es, this message translates to:
  /// **'No hay dispositivos conectados'**
  String get syncNowNoDevices;

  /// No description provided for @syncWaitingDevices.
  ///
  /// In es, this message translates to:
  /// **'Esperando dispositivos…'**
  String get syncWaitingDevices;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando…'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusSynced.
  ///
  /// In es, this message translates to:
  /// **'Sincronizado'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get syncStatusConnected;

  /// No description provided for @syncStarting.
  ///
  /// In es, this message translates to:
  /// **'Iniciando sincronización...'**
  String get syncStarting;

  /// No description provided for @syncSendingLocal.
  ///
  /// In es, this message translates to:
  /// **'Enviando cambios locales...'**
  String get syncSendingLocal;

  /// No description provided for @syncSuccessStats.
  ///
  /// In es, this message translates to:
  /// **'¡Sincronización exitosa! ({stats})'**
  String syncSuccessStats(String stats);

  /// No description provided for @syncBiometricReason.
  ///
  /// In es, this message translates to:
  /// **'Autentícate para desbloquear tu computadora'**
  String get syncBiometricReason;

  /// No description provided for @syncLinkComputer.
  ///
  /// In es, this message translates to:
  /// **'Vincular Computadora'**
  String get syncLinkComputer;

  /// No description provided for @syncLinkComputerSub.
  ///
  /// In es, this message translates to:
  /// **'Escanea el código QR generado por la aplicación SoloKey en tu computadora para sincronizar los datos locales.'**
  String get syncLinkComputerSub;

  /// No description provided for @syncScanQrButton.
  ///
  /// In es, this message translates to:
  /// **'Escanear Código QR'**
  String get syncScanQrButton;

  /// No description provided for @syncNegotiating.
  ///
  /// In es, this message translates to:
  /// **'Conectando de forma segura…'**
  String get syncNegotiating;

  /// No description provided for @syncComputerLinkedExcl.
  ///
  /// In es, this message translates to:
  /// **'¡Computadora Vinculada!'**
  String get syncComputerLinkedExcl;

  /// No description provided for @syncComputerLinkedExclSub.
  ///
  /// In es, this message translates to:
  /// **'Los datos ahora se sincronizarán de forma segura entre dispositivos.'**
  String get syncComputerLinkedExclSub;

  /// No description provided for @syncBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get syncBack;

  /// No description provided for @syncCouldNotConnect.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con la computadora.'**
  String get syncCouldNotConnect;

  /// No description provided for @syncRetryButton.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentar'**
  String get syncRetryButton;

  /// No description provided for @syncRemoteUnlockTitle.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo Remoto'**
  String get syncRemoteUnlockTitle;

  /// No description provided for @syncRemoteUnlockSub.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea la bóveda de tu computadora usando la biometría de este dispositivo.'**
  String get syncRemoteUnlockSub;

  /// No description provided for @syncSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get syncSending;

  /// No description provided for @syncUnlockComputer.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Computadora'**
  String get syncUnlockComputer;

  /// No description provided for @syncUnlockSentBanner.
  ///
  /// In es, this message translates to:
  /// **'¡Solicitud enviada! La bóveda debería desbloquearse.'**
  String get syncUnlockSentBanner;

  /// No description provided for @syncAuthCancelled.
  ///
  /// In es, this message translates to:
  /// **'Autenticación biométrica cancelada.'**
  String get syncAuthCancelled;

  /// No description provided for @syncNoToken.
  ///
  /// In es, this message translates to:
  /// **'Vincula de nuevo con el escritorio DESBLOQUEADO para habilitar el desbloqueo remoto.'**
  String get syncNoToken;

  /// No description provided for @syncVaultTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar Bóveda'**
  String get syncVaultTitle;

  /// No description provided for @syncVaultSub.
  ///
  /// In es, this message translates to:
  /// **'Intercambia y actualiza tus credenciales bidireccionalmente en red local.'**
  String get syncVaultSub;

  /// No description provided for @syncNotPairedYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no has vinculado. Escanea el QR de la computadora.'**
  String get syncNotPairedYet;

  /// No description provided for @syncConnectingComputer.
  ///
  /// In es, this message translates to:
  /// **'Conectando con la computadora...'**
  String get syncConnectingComputer;

  /// No description provided for @syncConnectFailCheck.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Verifica que el PC este encendido y en la misma red Wi-Fi.'**
  String get syncConnectFailCheck;

  /// No description provided for @auditIssueTooShortTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña demasiado corta'**
  String get auditIssueTooShortTitle;

  /// No description provided for @auditIssueTooShortDesc.
  ///
  /// In es, this message translates to:
  /// **'Tiene menos de 8 caracteres.'**
  String get auditIssueTooShortDesc;

  /// No description provided for @auditIssueWeakTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña débil'**
  String get auditIssueWeakTitle;

  /// No description provided for @auditIssueWeakLettersDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo letras, sin números ni símbolos.'**
  String get auditIssueWeakLettersDesc;

  /// No description provided for @auditIssueWeakNumbersDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo números.'**
  String get auditIssueWeakNumbersDesc;

  /// No description provided for @auditIssueReusedTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña reutilizada'**
  String get auditIssueReusedTitle;

  /// No description provided for @auditIssueReusedDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta contraseña está usada en múltiples cuentas.'**
  String get auditIssueReusedDesc;

  /// No description provided for @auditIssueBreachedTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña filtrada'**
  String get auditIssueBreachedTitle;

  /// No description provided for @auditIssueBreachedDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta contraseña aparece en {count} filtraciones de datos en internet. ¡Cámbiala de inmediato!'**
  String auditIssueBreachedDesc(int count);

  /// No description provided for @auditIssueNoPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin contraseña guardada'**
  String get auditIssueNoPasswordTitle;

  /// No description provided for @auditIssueNoPasswordDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta credencial no tiene contraseña registrada.'**
  String get auditIssueNoPasswordDesc;

  /// No description provided for @auditIssueRotationTitle.
  ///
  /// In es, this message translates to:
  /// **'Rotación requerida'**
  String get auditIssueRotationTitle;

  /// No description provided for @auditIssueRotationDesc.
  ///
  /// In es, this message translates to:
  /// **'Expiró hace {days} días (establecido cada {interval} días).'**
  String auditIssueRotationDesc(int days, int interval);

  /// No description provided for @auditIssueStaleTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña antigua'**
  String get auditIssueStaleTitle;

  /// No description provided for @auditIssueStaleDesc.
  ///
  /// In es, this message translates to:
  /// **'No se ha actualizado en más de 6 meses ({days} días).'**
  String auditIssueStaleDesc(int days);

  /// No description provided for @notifRotationChannelName.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de rotación'**
  String get notifRotationChannelName;

  /// No description provided for @notifRotationChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Alertas cuando una contraseña debe rotarse por seguridad.'**
  String get notifRotationChannelDesc;

  /// No description provided for @notifRotationTitle.
  ///
  /// In es, this message translates to:
  /// **'Rotación de contraseña requerida'**
  String get notifRotationTitle;

  /// No description provided for @notifRotationBody.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña para \"{title}\" ha expirado. Cámbiala ahora por seguridad.'**
  String notifRotationBody(String title);

  /// No description provided for @notifActionChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get notifActionChangePassword;

  /// No description provided for @notifActionSnooze3d.
  ///
  /// In es, this message translates to:
  /// **'Posponer 3 días'**
  String get notifActionSnooze3d;

  /// No description provided for @notifApprovalTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprobar inicio de sesión'**
  String get notifApprovalTitle;

  /// No description provided for @notifApprovalBody.
  ///
  /// In es, this message translates to:
  /// **'Tu computadora pide desbloquearse. Toca para aprobar.'**
  String get notifApprovalBody;

  /// No description provided for @notifApprovalBodyNamed.
  ///
  /// In es, this message translates to:
  /// **'¿Desbloquear \"{name}\"? Toca para aprobar.'**
  String notifApprovalBodyNamed(String name);

  /// No description provided for @syncSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización'**
  String get syncSummaryTitle;

  /// No description provided for @syncSummaryNoChanges.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios — ya estaba todo al día'**
  String get syncSummaryNoChanges;

  /// No description provided for @syncSummaryFrom.
  ///
  /// In es, this message translates to:
  /// **'desde {device}'**
  String syncSummaryFrom(String device);

  /// No description provided for @syncOtherDevice.
  ///
  /// In es, this message translates to:
  /// **'el otro dispositivo'**
  String get syncOtherDevice;

  /// No description provided for @syncCredentialsLabel.
  ///
  /// In es, this message translates to:
  /// **'Credenciales'**
  String get syncCredentialsLabel;

  /// No description provided for @syncFoldersLabel.
  ///
  /// In es, this message translates to:
  /// **'Carpetas'**
  String get syncFoldersLabel;

  /// No description provided for @syncFilesLabel.
  ///
  /// In es, this message translates to:
  /// **'Archivos'**
  String get syncFilesLabel;

  /// No description provided for @syncCountAdded.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{0 nuevas} =1{1 nueva} other{{count} nuevas}}'**
  String syncCountAdded(int count);

  /// No description provided for @syncCountUpdated.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{0 actualizadas} =1{1 actualizada} other{{count} actualizadas}}'**
  String syncCountUpdated(int count);

  /// No description provided for @syncCountRemoved.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{0 eliminadas} =1{1 eliminada} other{{count} eliminadas}}'**
  String syncCountRemoved(int count);

  /// No description provided for @syncItemsShow.
  ///
  /// In es, this message translates to:
  /// **'Ver elementos'**
  String get syncItemsShow;

  /// No description provided for @syncItemsHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar elementos'**
  String get syncItemsHide;

  /// No description provided for @syncActionAdded.
  ///
  /// In es, this message translates to:
  /// **'Añadida'**
  String get syncActionAdded;

  /// No description provided for @syncActionUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizada'**
  String get syncActionUpdated;

  /// No description provided for @syncActionRemoved.
  ///
  /// In es, this message translates to:
  /// **'Eliminada'**
  String get syncActionRemoved;

  /// No description provided for @syncHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizaciones recientes'**
  String get syncHistoryTitle;

  /// No description provided for @syncHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay sincronizaciones'**
  String get syncHistoryEmpty;

  /// No description provided for @syncRelativeNow.
  ///
  /// In es, this message translates to:
  /// **'hace un momento'**
  String get syncRelativeNow;

  /// No description provided for @syncRelativeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 min} other{hace {count} min}}'**
  String syncRelativeMinutes(int count);

  /// No description provided for @syncRelativeHours.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 h} other{hace {count} h}}'**
  String syncRelativeHours(int count);

  /// No description provided for @syncRelativeDays.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{hace 1 d} other{hace {count} d}}'**
  String syncRelativeDays(int count);

  /// No description provided for @syncBadgeSyncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando…'**
  String get syncBadgeSyncing;

  /// No description provided for @syncBadgeSynced.
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get syncBadgeSynced;

  /// No description provided for @syncBadgeError.
  ///
  /// In es, this message translates to:
  /// **'Error de sync'**
  String get syncBadgeError;

  /// No description provided for @syncPairedDevicesTitle.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos vinculados'**
  String get syncPairedDevicesTitle;

  /// No description provided for @syncNeverSynced.
  ///
  /// In es, this message translates to:
  /// **'Nunca sincronizado'**
  String get syncNeverSynced;

  /// No description provided for @syncLastSyncLabel.
  ///
  /// In es, this message translates to:
  /// **'Última sync: {when}'**
  String syncLastSyncLabel(String when);

  /// No description provided for @syncUnlinkDevice.
  ///
  /// In es, this message translates to:
  /// **'Desvincular'**
  String get syncUnlinkDevice;

  /// No description provided for @notifSyncTitle.
  ///
  /// In es, this message translates to:
  /// **'Bóveda sincronizada'**
  String get notifSyncTitle;

  /// No description provided for @notifSyncBody.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 cambio sincronizado} other{{count} cambios sincronizados}}'**
  String notifSyncBody(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
