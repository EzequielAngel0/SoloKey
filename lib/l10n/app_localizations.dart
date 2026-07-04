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
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @unlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password'**
  String get unlockSubtitle;

  /// No description provided for @unlockMasterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get unlockMasterPasswordHint;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @unlockLockedFor.
  ///
  /// In en, this message translates to:
  /// **'Locked ({time})'**
  String unlockLockedFor(String time);

  /// No description provided for @unlockUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get unlockUseBiometrics;

  /// No description provided for @unlockWifiAvailable.
  ///
  /// In en, this message translates to:
  /// **'WiFi unlock available'**
  String get unlockWifiAvailable;

  /// No description provided for @unlockForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your master password?'**
  String get unlockForgotPassword;

  /// No description provided for @unlockFromMobile.
  ///
  /// In en, this message translates to:
  /// **'Unlocking from mobile device…'**
  String get unlockFromMobile;

  /// No description provided for @unlockTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Retry in {time}.'**
  String unlockTooManyAttempts(String time);

  /// No description provided for @unlockTapToEnter.
  ///
  /// In en, this message translates to:
  /// **'Tap to enter your password'**
  String get unlockTapToEnter;

  /// No description provided for @unlockRemoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Remote unlock failed: {msg}'**
  String unlockRemoteFailed(String msg);

  /// No description provided for @unlockRemoteError.
  ///
  /// In en, this message translates to:
  /// **'Remote unlock error'**
  String get unlockRemoteError;

  /// No description provided for @unlockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your vault'**
  String get unlockBiometricReason;

  /// No description provided for @unlockWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect master password'**
  String get unlockWrongPassword;

  /// No description provided for @unlockWrongPasswordLocked.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Locked for {time}.'**
  String unlockWrongPasswordLocked(String time);

  /// No description provided for @unlockVaultWiped.
  ///
  /// In en, this message translates to:
  /// **'Vault wiped after too many failed attempts.'**
  String get unlockVaultWiped;

  /// No description provided for @unlockBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed or not configured.'**
  String get unlockBiometricFailed;

  /// No description provided for @unlockGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock the vault.'**
  String get unlockGenericError;

  /// No description provided for @unlockWithWindowsHello.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Windows Hello'**
  String get unlockWithWindowsHello;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockWithBiometrics;

  /// No description provided for @unlockOrUseMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'or use your master password'**
  String get unlockOrUseMasterPassword;

  /// No description provided for @unlockAttemptsBeforeLockout.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 attempt left before a temporary lock} other{{count} attempts left before a temporary lock}}'**
  String unlockAttemptsBeforeLockout(int count);

  /// No description provided for @unlockAttemptsBeforeWipe.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 attempt left before the vault is wiped} other{{count} attempts left before the vault is wiped}}'**
  String unlockAttemptsBeforeWipe(int count);

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get settingsSectionAutoLock;

  /// No description provided for @settingsSectionClipboard.
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get settingsSectionClipboard;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionQuickFill.
  ///
  /// In en, this message translates to:
  /// **'Quick-Fill'**
  String get settingsSectionQuickFill;

  /// No description provided for @settingsAutoLockLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock on inactivity'**
  String get settingsAutoLockLabel;

  /// No description provided for @settingsAutoLockValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String settingsAutoLockValue(int minutes);

  /// No description provided for @settingsClearClipboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear clipboard'**
  String get settingsClearClipboardLabel;

  /// No description provided for @settingsClearClipboardValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String settingsClearClipboardValue(int seconds);

  /// No description provided for @settingsBiometricLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get settingsBiometricLabel;

  /// No description provided for @settingsBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face'**
  String get settingsBiometricSubtitle;

  /// No description provided for @settingsObscureLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide in background'**
  String get settingsObscureLabel;

  /// No description provided for @settingsObscureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply a privacy screen when switching apps'**
  String get settingsObscureSubtitle;

  /// No description provided for @settingsAutostartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start with the system'**
  String get settingsAutostartLabel;

  /// No description provided for @settingsAutostartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Starts minimised in the tray when the device boots'**
  String get settingsAutostartSubtitle;

  /// No description provided for @settingsQuickFillDescription.
  ///
  /// In en, this message translates to:
  /// **'Press the shortcut from any app to open SoloKey and copy the username/password to the clipboard (it clears itself).'**
  String get settingsQuickFillDescription;

  /// No description provided for @settingsQuickFillTryNow.
  ///
  /// In en, this message translates to:
  /// **'Try now'**
  String get settingsQuickFillTryNow;

  /// No description provided for @commonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get commonDisabled;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get settingsSectionDanger;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsDensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get settingsDensityTitle;

  /// No description provided for @densityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get densityComfortable;

  /// No description provided for @densityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get densityCompact;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDim.
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get themeDim;

  /// No description provided for @themeOled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @settingsWipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe vault after failed attempts'**
  String get settingsWipeTitle;

  /// No description provided for @settingsWipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anti brute-force protection (irreversible)'**
  String get settingsWipeSubtitle;

  /// No description provided for @settingsSyncComputerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync computer'**
  String get settingsSyncComputerTitle;

  /// No description provided for @settingsSyncComputerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pair with desktop SoloKey'**
  String get settingsSyncComputerSubtitle;

  /// No description provided for @settingsExportImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get settingsExportImportTitle;

  /// No description provided for @settingsExportImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make encrypted backups of your vault'**
  String get settingsExportImportSubtitle;

  /// No description provided for @settingsAutofillTitle.
  ///
  /// In en, this message translates to:
  /// **'System autofill'**
  String get settingsAutofillTitle;

  /// No description provided for @settingsAutofillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill passwords in other apps'**
  String get settingsAutofillSubtitle;

  /// No description provided for @settingsPasskeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Passkey backup'**
  String get settingsPasskeysTitle;

  /// No description provided for @settingsPasskeysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store your passkey backups'**
  String get settingsPasskeysSubtitle;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get settingsBackupTitle;

  /// No description provided for @settingsBackupDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get settingsBackupDaily;

  /// No description provided for @settingsBackupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get settingsBackupWeekly;

  /// No description provided for @settingsBackupMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingsBackupMonthly;

  /// No description provided for @settingsBackupEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days'**
  String settingsBackupEveryNDays(int days);

  /// No description provided for @settingsBackupNoFolder.
  ///
  /// In en, this message translates to:
  /// **'no folder'**
  String get settingsBackupNoFolder;

  /// No description provided for @settingsBackupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get settingsBackupFrequency;

  /// No description provided for @settingsBackupChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose destination folder'**
  String get settingsBackupChooseFolder;

  /// No description provided for @settingsBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get settingsBackupPassword;

  /// No description provided for @settingsBackupPasswordKeep.
  ///
  /// In en, this message translates to:
  /// **'Backup password (leave empty = keep)'**
  String get settingsBackupPasswordKeep;

  /// No description provided for @settingsLockNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get settingsLockNowTitle;

  /// No description provided for @settingsLockNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close the session immediately'**
  String get settingsLockNowSubtitle;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersionLabel;

  /// No description provided for @settingsAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Local-first password manager'**
  String get settingsAboutTagline;

  /// No description provided for @settingsSectionShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get settingsSectionShortcuts;

  /// No description provided for @shortcutCommandPalette.
  ///
  /// In en, this message translates to:
  /// **'Command palette'**
  String get shortcutCommandPalette;

  /// No description provided for @shortcutNewCredential.
  ///
  /// In en, this message translates to:
  /// **'New credential'**
  String get shortcutNewCredential;

  /// No description provided for @shortcutLock.
  ///
  /// In en, this message translates to:
  /// **'Lock vault'**
  String get shortcutLock;

  /// No description provided for @shortcutReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get shortcutReset;

  /// No description provided for @shortcutEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Set shortcut'**
  String get shortcutEditTitle;

  /// No description provided for @shortcutCapturePrompt.
  ///
  /// In en, this message translates to:
  /// **'Press the key combination…'**
  String get shortcutCapturePrompt;

  /// No description provided for @shortcutNeedsModifier.
  ///
  /// In en, this message translates to:
  /// **'Add a modifier (Ctrl, Alt or Shift)'**
  String get shortcutNeedsModifier;

  /// No description provided for @shortcutConflict.
  ///
  /// In en, this message translates to:
  /// **'That combination is already used by another shortcut'**
  String get shortcutConflict;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your secure vault'**
  String get splashTagline;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create master\npassword'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This password protects your entire vault. It cannot be recovered if you forget it.'**
  String get setupSubtitle;

  /// No description provided for @setupMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters'**
  String get setupMinChars;

  /// No description provided for @setupConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get setupConfirmLabel;

  /// No description provided for @setupPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get setupPasswordsMismatch;

  /// No description provided for @setupCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get setupCreateButton;

  /// No description provided for @setupNeedUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one uppercase letter'**
  String get setupNeedUppercase;

  /// No description provided for @setupNeedNumber.
  ///
  /// In en, this message translates to:
  /// **'Include at least one number'**
  String get setupNeedNumber;

  /// No description provided for @setupNeedSymbol.
  ///
  /// In en, this message translates to:
  /// **'Include at least one symbol'**
  String get setupNeedSymbol;

  /// No description provided for @setupReqChars.
  ///
  /// In en, this message translates to:
  /// **'12+ characters'**
  String get setupReqChars;

  /// No description provided for @setupReqUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get setupReqUppercase;

  /// No description provided for @setupReqNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get setupReqNumber;

  /// No description provided for @setupReqSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get setupReqSymbol;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @navAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get navAudit;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navCredentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get navCredentials;

  /// No description provided for @navFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get navFolders;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get navFavorites;

  /// No description provided for @navVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get navVault;

  /// No description provided for @navSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get navSecurity;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPasswords.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get filterPasswords;

  /// No description provided for @securityHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tools to keep your vault healthy'**
  String get securityHubSubtitle;

  /// No description provided for @securityHubAuditDesc.
  ///
  /// In en, this message translates to:
  /// **'Weak, reused and breached passwords'**
  String get securityHubAuditDesc;

  /// No description provided for @securityHubGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password generator'**
  String get securityHubGenerator;

  /// No description provided for @securityHubGeneratorDesc.
  ///
  /// In en, this message translates to:
  /// **'Create strong, unique passwords'**
  String get securityHubGeneratorDesc;

  /// No description provided for @securityHubTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Export or import your vault'**
  String get securityHubTransferDesc;

  /// No description provided for @securityHubSecureFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Encrypted documents and images'**
  String get securityHubSecureFilesDesc;

  /// No description provided for @securityHubPasskeysDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your encrypted passkey backups'**
  String get securityHubPasskeysDesc;

  /// No description provided for @securityHubSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Pair this device over your network'**
  String get securityHubSyncDesc;

  /// No description provided for @securityHubRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset your master password'**
  String get securityHubRecoveryDesc;

  /// No description provided for @generatorSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate password'**
  String get generatorSheetTitle;

  /// No description provided for @commandNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get commandNoResults;

  /// No description provided for @detailAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get detailAdvanced;

  /// No description provided for @detailTotpSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret (seed)'**
  String get detailTotpSecret;

  /// No description provided for @detailCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get detailCopyCode;

  /// No description provided for @healthReused.
  ///
  /// In en, this message translates to:
  /// **'Reused'**
  String get healthReused;

  /// No description provided for @auditScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Vault health'**
  String get auditScoreTitle;

  /// No description provided for @auditScoreIssues.
  ///
  /// In en, this message translates to:
  /// **'{count} issues to review'**
  String auditScoreIssues(int count);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search credentials…'**
  String get homeSearchHint;

  /// No description provided for @homeLockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get homeLockTooltip;

  /// No description provided for @homeFabNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homeFabNew;

  /// No description provided for @homeFabFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get homeFabFolder;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String homeLoadError(String msg);

  /// No description provided for @homeEmptyVault.
  ///
  /// In en, this message translates to:
  /// **'Your vault is empty'**
  String get homeEmptyVault;

  /// No description provided for @homeCredentialCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No credentials} =1{1 credential} other{{count} credentials}}'**
  String homeCredentialCount(int count);

  /// No description provided for @homeIssuesChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 issue} other{{count} issues}}'**
  String homeIssuesChip(int count);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeHealthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Vault health — tap for details'**
  String get homeHealthTooltip;

  /// No description provided for @homeSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get homeSortTooltip;

  /// No description provided for @sortManual.
  ///
  /// In en, this message translates to:
  /// **'Manual order'**
  String get sortManual;

  /// No description provided for @sortTitleAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortTitleAsc;

  /// No description provided for @sortUpdatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortUpdatedDesc;

  /// No description provided for @homeReorderStart.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get homeReorderStart;

  /// No description provided for @homeReorderDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeReorderDone;

  /// No description provided for @homeReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to reorder'**
  String get homeReorderHint;

  /// No description provided for @emptyAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first credential'**
  String get emptyAddFirst;

  /// No description provided for @emptyAddCredential.
  ///
  /// In en, this message translates to:
  /// **'Add credential'**
  String get emptyAddCredential;

  /// No description provided for @folderDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderDialogTitle;

  /// No description provided for @folderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderNameLabel;

  /// No description provided for @folderNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Work, Social…'**
  String get folderNameHint;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String commonErrorDetail(String msg);

  /// No description provided for @detailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Credential not found'**
  String get detailNotFound;

  /// No description provided for @detailRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get detailRemoveFavorite;

  /// No description provided for @detailAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get detailAddFavorite;

  /// No description provided for @detailViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View password history'**
  String get detailViewHistory;

  /// No description provided for @detailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete credential'**
  String get detailDeleteTitle;

  /// No description provided for @detailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This action cannot be undone.'**
  String detailDeleteBody(String title);

  /// No description provided for @detailDeleteAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Verify to delete this credential'**
  String get detailDeleteAuthReason;

  /// No description provided for @detailRevealAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to reveal this secret'**
  String get detailRevealAuthReason;

  /// No description provided for @detailRevealSecret.
  ///
  /// In en, this message translates to:
  /// **'Reveal secret'**
  String get detailRevealSecret;

  /// No description provided for @detailHideSecret.
  ///
  /// In en, this message translates to:
  /// **'Hide secret'**
  String get detailHideSecret;

  /// No description provided for @detailCopyField.
  ///
  /// In en, this message translates to:
  /// **'Copy {field}'**
  String detailCopyField(String field);

  /// No description provided for @detailHideCountdown.
  ///
  /// In en, this message translates to:
  /// **'Auto-hides in {seconds}s'**
  String detailHideCountdown(int seconds);

  /// No description provided for @detailOpenSite.
  ///
  /// In en, this message translates to:
  /// **'Open site'**
  String get detailOpenSite;

  /// No description provided for @detailOpenSiteError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the site'**
  String get detailOpenSiteError;

  /// No description provided for @detailPasskeyHandleNote.
  ///
  /// In en, this message translates to:
  /// **'The private key handle stays encrypted in your vault.'**
  String get detailPasskeyHandleNote;

  /// No description provided for @detailTotpExportQr.
  ///
  /// In en, this message translates to:
  /// **'Export as QR'**
  String get detailTotpExportQr;

  /// No description provided for @detailTotpExportQrAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to show the TOTP QR'**
  String get detailTotpExportQrAuthReason;

  /// No description provided for @detailTotpExportQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan on another device'**
  String get detailTotpExportQrTitle;

  /// No description provided for @detailTotpExportQrWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone who scans this can generate your codes. Keep it private.'**
  String get detailTotpExportQrWarning;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get fieldWebsite;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldKeyType.
  ///
  /// In en, this message translates to:
  /// **'Key type'**
  String get fieldKeyType;

  /// No description provided for @fieldPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get fieldPrivateKey;

  /// No description provided for @fieldPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get fieldPublicKey;

  /// No description provided for @fieldKeyPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Key passphrase'**
  String get fieldKeyPassphrase;

  /// No description provided for @typePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get typePassword;

  /// No description provided for @typeApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get typeApiKey;

  /// No description provided for @typeSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Secure note'**
  String get typeSecureNote;

  /// No description provided for @typeTotp.
  ///
  /// In en, this message translates to:
  /// **'TOTP / 2FA'**
  String get typeTotp;

  /// No description provided for @typePasskey.
  ///
  /// In en, this message translates to:
  /// **'Passkey backup'**
  String get typePasskey;

  /// No description provided for @typeSshKey.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get typeSshKey;

  /// No description provided for @rotationMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rotationMonthly;

  /// No description provided for @rotationQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every 3 months'**
  String get rotationQuarterly;

  /// No description provided for @rotationSemiAnnually.
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get rotationSemiAnnually;

  /// No description provided for @rotationCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom ({days} days)'**
  String rotationCustom(int days);

  /// No description provided for @rotationNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get rotationNone;

  /// No description provided for @rotationOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD ROTATION OVERDUE'**
  String get rotationOverdueTitle;

  /// No description provided for @rotationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'ROTATION REMINDER'**
  String get rotationReminderTitle;

  /// No description provided for @rotationOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'You should change this password. More than {days} days have passed since the last update.'**
  String rotationOverdueBody(int days);

  /// No description provided for @rotationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Next change required in {days} days ({interval}).'**
  String rotationReminderBody(int days, String interval);

  /// No description provided for @secretDecrypting.
  ///
  /// In en, this message translates to:
  /// **'Decrypting…'**
  String get secretDecrypting;

  /// No description provided for @secretDecryptAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to decrypt this secret'**
  String get secretDecryptAuthReason;

  /// No description provided for @secretDecryptError.
  ///
  /// In en, this message translates to:
  /// **'Decryption error: {msg}'**
  String secretDecryptError(String msg);

  /// No description provided for @pinDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter secondary PIN'**
  String get pinDialogTitle;

  /// No description provided for @pinDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Double-envelope PIN'**
  String get pinDialogLabel;

  /// No description provided for @totpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code (2FA)'**
  String get totpTitle;

  /// No description provided for @totpClipboardLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTP code'**
  String get totpClipboardLabel;

  /// No description provided for @totpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get totpInvalid;

  /// No description provided for @a11yFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get a11yFavorite;

  /// No description provided for @a11yDoubleEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Double-encrypted'**
  String get a11yDoubleEncrypted;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No old passwords.'**
  String get historyEmpty;

  /// No description provided for @historyCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get historyCopyTooltip;

  /// No description provided for @historyClipboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Historical password'**
  String get historyClipboardLabel;

  /// No description provided for @historyRestoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore password'**
  String get historyRestoreTooltip;

  /// No description provided for @historyRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore password?'**
  String get historyRestoreTitle;

  /// No description provided for @historyRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace the credential\'s current password with this historical one. Continue?'**
  String get historyRestoreBody;

  /// No description provided for @historyRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get historyRestoreConfirm;

  /// No description provided for @historyRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password restored successfully'**
  String get historyRestoreSuccess;

  /// No description provided for @historyRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Error restoring the password: {msg}'**
  String historyRestoreError(String msg);

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover access'**
  String get recoveryTitle;

  /// No description provided for @recoveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCodeTitle;

  /// No description provided for @recoveryCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'The recovery code was generated when you set up your vault. If you saved it, enter it here to reset your master password.'**
  String get recoveryCodeDescription;

  /// No description provided for @recoveryEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery code'**
  String get recoveryEnterCode;

  /// No description provided for @recoveryWrongCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Check it and try again.'**
  String get recoveryWrongCode;

  /// No description provided for @recoveryVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get recoveryVerifyButton;

  /// No description provided for @recoveryEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the new master password'**
  String get recoveryEnterNewPassword;

  /// No description provided for @recoveryMin8.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters'**
  String get recoveryMin8;

  /// No description provided for @recoveryPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Master password updated successfully'**
  String get recoveryPasswordUpdated;

  /// No description provided for @recoveryCodeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified. Now set your new master password.'**
  String get recoveryCodeVerified;

  /// No description provided for @recoveryNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New master password'**
  String get recoveryNewPasswordLabel;

  /// No description provided for @recoveryResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset master password'**
  String get recoveryResetButton;

  /// No description provided for @recoveryCodeWarning.
  ///
  /// In en, this message translates to:
  /// **'Save this code somewhere safe! It is shown ONLY ONCE and cannot be recovered.'**
  String get recoveryCodeWarning;

  /// No description provided for @recoveryCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get recoveryCopyCode;

  /// No description provided for @recoveryCodeSavedContinue.
  ///
  /// In en, this message translates to:
  /// **'I saved it, continue'**
  String get recoveryCodeSavedContinue;

  /// No description provided for @accessStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String accessStepOf(int current, int total);

  /// No description provided for @recoveryStepEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery code'**
  String get recoveryStepEnterCode;

  /// No description provided for @recoveryStepNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new master password'**
  String get recoveryStepNewPassword;

  /// No description provided for @setupStepCreate.
  ///
  /// In en, this message translates to:
  /// **'Create your master password'**
  String get setupStepCreate;

  /// No description provided for @setupStepSaveCode.
  ///
  /// In en, this message translates to:
  /// **'Save your recovery code'**
  String get setupStepSaveCode;

  /// No description provided for @autofillOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Autofill'**
  String get autofillOnboardingTitle;

  /// No description provided for @autofillActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'SoloKey is active!'**
  String get autofillActiveTitle;

  /// No description provided for @autofillEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable autofill'**
  String get autofillEnableTitle;

  /// No description provided for @autofillActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'SoloKey will automatically fill your passwords in any app or browser on your device.'**
  String get autofillActiveDesc;

  /// No description provided for @autofillEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Let SoloKey fill your passwords automatically in apps and browsers.'**
  String get autofillEnableDesc;

  /// No description provided for @autofillOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Autofill settings'**
  String get autofillOpenSettings;

  /// No description provided for @autofillVerifyStatus.
  ///
  /// In en, this message translates to:
  /// **'I enabled it, check status'**
  String get autofillVerifyStatus;

  /// No description provided for @autofillFeatureDetection.
  ///
  /// In en, this message translates to:
  /// **'Automatic login form detection'**
  String get autofillFeatureDetection;

  /// No description provided for @autofillFeatureBiometric.
  ///
  /// In en, this message translates to:
  /// **'Asks for your fingerprint before filling (biometrics)'**
  String get autofillFeatureBiometric;

  /// No description provided for @autofillFeatureNeverExposed.
  ///
  /// In en, this message translates to:
  /// **'Credentials never exposed to the OS'**
  String get autofillFeatureNeverExposed;

  /// No description provided for @autofillStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get autofillStatusActive;

  /// No description provided for @autofillStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get autofillStatusInactive;

  /// No description provided for @autofillStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open Autofill settings\"'**
  String get autofillStep1Title;

  /// No description provided for @autofillStep1Sub.
  ///
  /// In en, this message translates to:
  /// **'The system settings will open'**
  String get autofillStep1Sub;

  /// No description provided for @autofillStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Select \"SoloKey\" as the provider'**
  String get autofillStep2Title;

  /// No description provided for @autofillStep2Sub.
  ///
  /// In en, this message translates to:
  /// **'Find SoloKey in the list of apps'**
  String get autofillStep2Sub;

  /// No description provided for @autofillStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Confirm and return to the app'**
  String get autofillStep3Title;

  /// No description provided for @autofillStep3Sub.
  ///
  /// In en, this message translates to:
  /// **'Autofill will be enabled'**
  String get autofillStep3Sub;

  /// No description provided for @quickFillTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick-Fill'**
  String get quickFillTitle;

  /// No description provided for @quickFillCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close (Esc)'**
  String get quickFillCloseTooltip;

  /// No description provided for @quickFillSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search credential…'**
  String get quickFillSearchHint;

  /// No description provided for @quickFillLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load credentials'**
  String get quickFillLoadError;

  /// No description provided for @quickFillNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get quickFillNoMatches;

  /// No description provided for @quickFillFooter.
  ///
  /// In en, this message translates to:
  /// **'Copy the value and paste it (Ctrl+V) into the field · it clears itself from the clipboard'**
  String get quickFillFooter;

  /// No description provided for @quickFillCopyUser.
  ///
  /// In en, this message translates to:
  /// **'Copy username'**
  String get quickFillCopyUser;

  /// No description provided for @quickFillCopyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get quickFillCopyPassword;

  /// No description provided for @commonGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// No description provided for @auditTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Audit'**
  String get auditTitle;

  /// No description provided for @auditAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Analysis'**
  String get auditAnalysisTitle;

  /// No description provided for @auditAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'SoloKey analyses your credentials locally to identify weak, short, reused or old passwords.'**
  String get auditAnalysisDesc;

  /// No description provided for @auditBreachCheck.
  ///
  /// In en, this message translates to:
  /// **'Check breaches (online)'**
  String get auditBreachCheck;

  /// No description provided for @auditPrivateBadge.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE'**
  String get auditPrivateBadge;

  /// No description provided for @auditBreachDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses k-Anonymity (HaveIBeenPwned) to look up exposed passwords without revealing your real password.'**
  String get auditBreachDesc;

  /// No description provided for @auditAllGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'All good!'**
  String get auditAllGoodTitle;

  /// No description provided for @auditAllGoodDesc.
  ///
  /// In en, this message translates to:
  /// **'No problems were found in your vault.'**
  String get auditAllGoodDesc;

  /// No description provided for @auditSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get auditSeverityCritical;

  /// No description provided for @auditSeverityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get auditSeverityWarning;

  /// No description provided for @auditSeverityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get auditSeverityInfo;

  /// No description provided for @passkeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Passkey backups'**
  String get passkeysTitle;

  /// No description provided for @passkeysAdd.
  ///
  /// In en, this message translates to:
  /// **'Add passkey'**
  String get passkeysAdd;

  /// No description provided for @passkeysHowToTitle.
  ///
  /// In en, this message translates to:
  /// **'How to register a passkey?'**
  String get passkeysHowToTitle;

  /// No description provided for @passkeysHowToBody.
  ///
  /// In en, this message translates to:
  /// **'Passkeys are registered directly on each web service (e.g. Google, GitHub, Apple).\n\n1. Go to the service\'s website\n2. Look for \"Passkeys\" under Security\n3. The system will register and sync the passkey automatically\n\nSoloKey will store the passkey information in your vault, encrypted, so you can manage it.'**
  String get passkeysHowToBody;

  /// No description provided for @passkeysEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No passkey backups'**
  String get passkeysEmptyTitle;

  /// No description provided for @passkeysEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Passkeys are the future of authentication: passwordless, safer and faster. Register them on your favourite services and SoloKey will keep an encrypted backup here.'**
  String get passkeysEmptyDesc;

  /// No description provided for @passkeysEncryptedBadge.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup in your vault'**
  String get passkeysEncryptedBadge;

  /// No description provided for @passkeysUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String passkeysUpdated(String date);

  /// No description provided for @passkeysViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get passkeysViewDetails;

  /// No description provided for @passkeyDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain (RP ID)'**
  String get passkeyDomain;

  /// No description provided for @passkeyService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get passkeyService;

  /// No description provided for @passkeyVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get passkeyVerification;

  /// No description provided for @passkeyVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required (Biometric / PIN)'**
  String get passkeyVerificationRequired;

  /// No description provided for @passkeyVerificationOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get passkeyVerificationOptional;

  /// No description provided for @passkeyCredentialId.
  ///
  /// In en, this message translates to:
  /// **'Credential ID'**
  String get passkeyCredentialId;

  /// No description provided for @passkeyCredentialIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Credential ID copied'**
  String get passkeyCredentialIdCopied;

  /// No description provided for @passkeyIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get passkeyIconLabel;

  /// No description provided for @passkeyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get passkeyRegistered;

  /// No description provided for @passkeyPrivateKeyNote.
  ///
  /// In en, this message translates to:
  /// **'The private key never leaves the device. Only the identifying information is stored.'**
  String get passkeyPrivateKeyNote;

  /// No description provided for @passkeysDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete passkey'**
  String get passkeysDeleteTitle;

  /// No description provided for @passkeysDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete the passkey \"{title}\"?\n\nNote: you must also remove it from the corresponding web service ({service}).'**
  String passkeysDeleteBody(String title, String service);

  /// No description provided for @passkeysSiteFallback.
  ///
  /// In en, this message translates to:
  /// **'the site'**
  String get passkeysSiteFallback;

  /// No description provided for @passkeysDeleteAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Verify to delete this passkey'**
  String get passkeysDeleteAuthReason;

  /// No description provided for @formNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New credential'**
  String get formNewTitle;

  /// No description provided for @formEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit credential'**
  String get formEditTitle;

  /// No description provided for @formCreated.
  ///
  /// In en, this message translates to:
  /// **'Credential created'**
  String get formCreated;

  /// No description provided for @formSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get formSaved;

  /// No description provided for @formSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get formSaveChanges;

  /// No description provided for @formCreateCredential.
  ///
  /// In en, this message translates to:
  /// **'Create credential'**
  String get formCreateCredential;

  /// No description provided for @formFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get formFieldRequired;

  /// No description provided for @formErrPinRequiredEnable.
  ///
  /// In en, this message translates to:
  /// **'You must enter a secondary PIN for double encryption'**
  String get formErrPinRequiredEnable;

  /// No description provided for @formErrPinRequiredDisable.
  ///
  /// In en, this message translates to:
  /// **'Enter the secondary PIN to disable double encryption'**
  String get formErrPinRequiredDisable;

  /// No description provided for @formQrNotTotp.
  ///
  /// In en, this message translates to:
  /// **'The QR code is not a valid TOTP.'**
  String get formQrNotTotp;

  /// No description provided for @formQrScanned.
  ///
  /// In en, this message translates to:
  /// **'QR code scanned successfully'**
  String get formQrScanned;

  /// No description provided for @formQrNoSecret.
  ///
  /// In en, this message translates to:
  /// **'No secret key was found in the QR.'**
  String get formQrNoSecret;

  /// No description provided for @formQrReadError.
  ///
  /// In en, this message translates to:
  /// **'Error reading the QR code.'**
  String get formQrReadError;

  /// No description provided for @formSshGenerated.
  ///
  /// In en, this message translates to:
  /// **'Ed25519 key pair generated'**
  String get formSshGenerated;

  /// No description provided for @formSshGenError.
  ///
  /// In en, this message translates to:
  /// **'Error generating the SSH key.'**
  String get formSshGenError;

  /// No description provided for @formCustomFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get formCustomFieldsTitle;

  /// No description provided for @formNoCustomFields.
  ///
  /// In en, this message translates to:
  /// **'No custom fields.'**
  String get formNoCustomFields;

  /// No description provided for @formAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get formAddField;

  /// No description provided for @formEditField.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get formEditField;

  /// No description provided for @formNewCustomField.
  ///
  /// In en, this message translates to:
  /// **'New custom field'**
  String get formNewCustomField;

  /// No description provided for @formFieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get formFieldNameLabel;

  /// No description provided for @formFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. PIN, Security question'**
  String get formFieldNameHint;

  /// No description provided for @formNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get formNameRequired;

  /// No description provided for @formFieldValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Field value'**
  String get formFieldValueLabel;

  /// No description provided for @formFieldValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1234, Home town'**
  String get formFieldValueHint;

  /// No description provided for @formValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Value required'**
  String get formValueRequired;

  /// No description provided for @formSecretField.
  ///
  /// In en, this message translates to:
  /// **'Secret field'**
  String get formSecretField;

  /// No description provided for @formSecretBadge.
  ///
  /// In en, this message translates to:
  /// **'SECRET'**
  String get formSecretBadge;

  /// No description provided for @formSecretFieldSub.
  ///
  /// In en, this message translates to:
  /// **'Hides the value by default in the details.'**
  String get formSecretFieldSub;

  /// No description provided for @formAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get formAdd;

  /// No description provided for @formSectionIdentification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get formSectionIdentification;

  /// No description provided for @formTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formTitleLabel;

  /// No description provided for @formSectionContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get formSectionContent;

  /// No description provided for @formSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get formSectionNotes;

  /// No description provided for @formSecureContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Secure content'**
  String get formSecureContentLabel;

  /// No description provided for @formNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get formNotesLabel;

  /// No description provided for @formSecureContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your private note here…'**
  String get formSecureContentHint;

  /// No description provided for @formNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — add context or reminders'**
  String get formNotesHint;

  /// No description provided for @formContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get formContentRequired;

  /// No description provided for @formSectionOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get formSectionOrganization;

  /// No description provided for @formFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get formFolderLabel;

  /// No description provided for @formMainVault.
  ///
  /// In en, this message translates to:
  /// **'Main vault'**
  String get formMainVault;

  /// No description provided for @formHintPassword.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix, GitHub, Gmail'**
  String get formHintPassword;

  /// No description provided for @formHintApiKey.
  ///
  /// In en, this message translates to:
  /// **'e.g. OpenAI, Stripe, AWS'**
  String get formHintApiKey;

  /// No description provided for @formHintSecureNote.
  ///
  /// In en, this message translates to:
  /// **'e.g. Server keys, Seeds'**
  String get formHintSecureNote;

  /// No description provided for @formHintTotp.
  ///
  /// In en, this message translates to:
  /// **'e.g. GitHub 2FA, Google'**
  String get formHintTotp;

  /// No description provided for @formHintPasskey.
  ///
  /// In en, this message translates to:
  /// **'e.g. google.com Passkey'**
  String get formHintPasskey;

  /// No description provided for @formHintSshKey.
  ///
  /// In en, this message translates to:
  /// **'e.g. Production Server, GitHub SSH Key'**
  String get formHintSshKey;

  /// No description provided for @formSectionLogin.
  ///
  /// In en, this message translates to:
  /// **'Login credentials'**
  String get formSectionLogin;

  /// No description provided for @formUserEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Username / Email'**
  String get formUserEmailLabel;

  /// No description provided for @formUserEmailHint.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get formUserEmailHint;

  /// No description provided for @formWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website / URL'**
  String get formWebsiteLabel;

  /// No description provided for @formWebsiteHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get formWebsiteHint;

  /// No description provided for @formSectionApi.
  ///
  /// In en, this message translates to:
  /// **'API details'**
  String get formSectionApi;

  /// No description provided for @formServiceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get formServiceNameLabel;

  /// No description provided for @formServiceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. OpenAI, Stripe, Supabase'**
  String get formServiceNameHint;

  /// No description provided for @formApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key / Token'**
  String get formApiKeyLabel;

  /// No description provided for @formEndpointLabel.
  ///
  /// In en, this message translates to:
  /// **'Endpoint URL'**
  String get formEndpointLabel;

  /// No description provided for @formScopesLabel.
  ///
  /// In en, this message translates to:
  /// **'Permissions / Scopes'**
  String get formScopesLabel;

  /// No description provided for @formSection2fa.
  ///
  /// In en, this message translates to:
  /// **'2FA setup'**
  String get formSection2fa;

  /// No description provided for @formTotpDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the TOTP secret key (Base32) of your account. You\'ll find it when enabling 2FA on the website, or you can scan the QR code directly.'**
  String get formTotpDesc;

  /// No description provided for @formScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get formScanQr;

  /// No description provided for @formOrManually.
  ///
  /// In en, this message translates to:
  /// **'or enter manually'**
  String get formOrManually;

  /// No description provided for @formAccountIssuerLabel.
  ///
  /// In en, this message translates to:
  /// **'Account / Issuer'**
  String get formAccountIssuerLabel;

  /// No description provided for @formAccountIssuerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GitHub, Google, AWS'**
  String get formAccountIssuerHint;

  /// No description provided for @formTotpSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTP secret key (Base32)'**
  String get formTotpSecretLabel;

  /// No description provided for @formSectionPasskey.
  ///
  /// In en, this message translates to:
  /// **'Passkey (FIDO2)'**
  String get formSectionPasskey;

  /// No description provided for @formPasskeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Passkeys are registered directly with the device\'s FIDO2 platform.'**
  String get formPasskeyDesc;

  /// No description provided for @formPasskeyHint.
  ///
  /// In en, this message translates to:
  /// **'Use the Passkeys screen in Settings to register or manage your passkeys.'**
  String get formPasskeyHint;

  /// No description provided for @formSectionSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH key configuration'**
  String get formSectionSsh;

  /// No description provided for @formGenerateSsh.
  ///
  /// In en, this message translates to:
  /// **'Generate Ed25519 key pair'**
  String get formGenerateSsh;

  /// No description provided for @formPrivateKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'The private key is required'**
  String get formPrivateKeyRequired;

  /// No description provided for @formPublicKeyOptional.
  ///
  /// In en, this message translates to:
  /// **'Public key (Optional)'**
  String get formPublicKeyOptional;

  /// No description provided for @formKeyPassphraseOptional.
  ///
  /// In en, this message translates to:
  /// **'Key passphrase (Optional)'**
  String get formKeyPassphraseOptional;

  /// No description provided for @formSectionDoubleEnc.
  ///
  /// In en, this message translates to:
  /// **'Double-envelope encryption'**
  String get formSectionDoubleEnc;

  /// No description provided for @formEnableDoubleEnc.
  ///
  /// In en, this message translates to:
  /// **'Enable double encryption'**
  String get formEnableDoubleEnc;

  /// No description provided for @formDoubleEncDesc.
  ///
  /// In en, this message translates to:
  /// **'Protects this entry\'s secrets with a secondary PIN. They will be encrypted additionally.'**
  String get formDoubleEncDesc;

  /// No description provided for @formPinSecondaryEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary PIN (Leave empty to keep current, or enter to change)'**
  String get formPinSecondaryEditLabel;

  /// No description provided for @formPinSecondaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary PIN'**
  String get formPinSecondaryLabel;

  /// No description provided for @formPinSecondaryRequired.
  ///
  /// In en, this message translates to:
  /// **'The secondary PIN is required'**
  String get formPinSecondaryRequired;

  /// No description provided for @formBiometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get formBiometricUnlock;

  /// No description provided for @formBiometricUnlockSub.
  ///
  /// In en, this message translates to:
  /// **'Store the encrypted PIN to unlock quickly with fingerprint/face.'**
  String get formBiometricUnlockSub;

  /// No description provided for @formSectionRotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation reminder'**
  String get formSectionRotation;

  /// No description provided for @formRotationLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind to change password'**
  String get formRotationLabel;

  /// No description provided for @formRotNone.
  ///
  /// In en, this message translates to:
  /// **'Don\'t remind'**
  String get formRotNone;

  /// No description provided for @formRotMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get formRotMonthly;

  /// No description provided for @formRotCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom (days)'**
  String get formRotCustom;

  /// No description provided for @formCustomDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days to remind'**
  String get formCustomDaysLabel;

  /// No description provided for @formCustomDaysRequired.
  ///
  /// In en, this message translates to:
  /// **'You must enter the number of days'**
  String get formCustomDaysRequired;

  /// No description provided for @formCustomDaysInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of days'**
  String get formCustomDaysInvalid;

  /// No description provided for @formDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get formDiscardTitle;

  /// No description provided for @formDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you leave now they will be lost.'**
  String get formDiscardMessage;

  /// No description provided for @formDiscardKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get formDiscardKeep;

  /// No description provided for @formDiscardLeave.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get formDiscardLeave;

  /// No description provided for @formErrInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get formErrInvalidUrl;

  /// No description provided for @formErrInvalidTotp.
  ///
  /// In en, this message translates to:
  /// **'Invalid Base32 secret (only A–Z and 2–7)'**
  String get formErrInvalidTotp;

  /// No description provided for @formPasteTotp.
  ///
  /// In en, this message translates to:
  /// **'Paste otpauth link'**
  String get formPasteTotp;

  /// No description provided for @formPasteApplied.
  ///
  /// In en, this message translates to:
  /// **'TOTP filled from clipboard'**
  String get formPasteApplied;

  /// No description provided for @formPasteNoOtpauth.
  ///
  /// In en, this message translates to:
  /// **'No valid otpauth:// link in the clipboard'**
  String get formPasteNoOtpauth;

  /// No description provided for @formDupTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get formDupTitle;

  /// No description provided for @formDupMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" already uses this username. Save anyway?'**
  String formDupMessage(String title);

  /// No description provided for @formDupReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get formDupReview;

  /// No description provided for @formDupSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get formDupSaveAnyway;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @folderNewSubfolder.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get folderNewSubfolder;

  /// No description provided for @folderDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get folderDeleteTitle;

  /// No description provided for @folderDeleteKeepBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? Its subfolders and credentials are kept — choose where to move them. Nothing is deleted.'**
  String folderDeleteKeepBody(String name);

  /// No description provided for @folderDeleteMoveToParent.
  ///
  /// In en, this message translates to:
  /// **'Move contents to parent folder'**
  String get folderDeleteMoveToParent;

  /// No description provided for @folderDeleteMoveToVault.
  ///
  /// In en, this message translates to:
  /// **'Move contents to vault root'**
  String get folderDeleteMoveToVault;

  /// No description provided for @folderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted'**
  String get folderDeleted;

  /// No description provided for @folderRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get folderRename;

  /// No description provided for @folderRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get folderRenameTitle;

  /// No description provided for @folderNewNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get folderNewNameLabel;

  /// No description provided for @folderCreateSubfolder.
  ///
  /// In en, this message translates to:
  /// **'Create subfolder'**
  String get folderCreateSubfolder;

  /// No description provided for @folderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get folderEmptyTitle;

  /// No description provided for @folderEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'There are no subfolders or credentials here.'**
  String get folderEmptyDesc;

  /// No description provided for @folderNoFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders'**
  String get folderNoFolders;

  /// No description provided for @folderOrganize.
  ///
  /// In en, this message translates to:
  /// **'Organise your credentials'**
  String get folderOrganize;

  /// No description provided for @folderCreateRoot.
  ///
  /// In en, this message translates to:
  /// **'Create root folder'**
  String get folderCreateRoot;

  /// No description provided for @folderNewRoot.
  ///
  /// In en, this message translates to:
  /// **'New root folder'**
  String get folderNewRoot;

  /// No description provided for @folderUnassigned.
  ///
  /// In en, this message translates to:
  /// **'No folder assigned'**
  String get folderUnassigned;

  /// No description provided for @folderNew.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get folderNew;

  /// No description provided for @folderAddSubfolder.
  ///
  /// In en, this message translates to:
  /// **'Add subfolder'**
  String get folderAddSubfolder;

  /// No description provided for @folderItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String folderItemCount(int count);

  /// No description provided for @folderColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get folderColorTitle;

  /// No description provided for @folderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit folder'**
  String get folderEditTitle;

  /// No description provided for @folderTreeHint.
  ///
  /// In en, this message translates to:
  /// **'Use the arrow keys to browse folders; press the menu button for actions.'**
  String get folderTreeHint;

  /// No description provided for @folderSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get folderSelectTitle;

  /// No description provided for @folderNewRootShort.
  ///
  /// In en, this message translates to:
  /// **'New root'**
  String get folderNewRootShort;

  /// No description provided for @folderNoneMainVault.
  ///
  /// In en, this message translates to:
  /// **'None (Main vault)'**
  String get folderNoneMainVault;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Star folders or credentials'**
  String get favoritesEmptyDesc;

  /// No description provided for @favoritesFoldersHeader.
  ///
  /// In en, this message translates to:
  /// **'Favourite folders'**
  String get favoritesFoldersHeader;

  /// No description provided for @favoritesCredentialsHeader.
  ///
  /// In en, this message translates to:
  /// **'Favourite credentials'**
  String get favoritesCredentialsHeader;

  /// No description provided for @favoriteToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark as favourite'**
  String get favoriteToggleLabel;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @cardCopyUser.
  ///
  /// In en, this message translates to:
  /// **'Copy username'**
  String get cardCopyUser;

  /// No description provided for @cardCopyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get cardCopyPassword;

  /// No description provided for @cardCopyPasswordAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to copy the password'**
  String get cardCopyPasswordAuthReason;

  /// No description provided for @cardMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get cardMoveToFolder;

  /// No description provided for @cardNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get cardNoFolder;

  /// No description provided for @cardMovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Credential moved successfully'**
  String get cardMovedSuccess;

  /// No description provided for @typeSelNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get typeSelNote;

  /// No description provided for @typeSelTotp.
  ///
  /// In en, this message translates to:
  /// **'TOTP'**
  String get typeSelTotp;

  /// No description provided for @typeSelPasskey.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get typeSelPasskey;

  /// No description provided for @genRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get genRegenerate;

  /// No description provided for @genLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {n}'**
  String genLength(int n);

  /// No description provided for @genGeneratedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated password'**
  String get genGeneratedPassword;

  /// No description provided for @genUseAndCopy.
  ///
  /// In en, this message translates to:
  /// **'Use & copy'**
  String get genUseAndCopy;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @clipboardCopiedClears.
  ///
  /// In en, this message translates to:
  /// **'{label} copied · clears in {seconds}s'**
  String clipboardCopiedClears(String label, int seconds);

  /// No description provided for @passwordRowGeneratorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Key generator'**
  String get passwordRowGeneratorTooltip;

  /// No description provided for @keyboardSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get keyboardSpace;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer data'**
  String get transferTitle;

  /// No description provided for @transferTabExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get transferTabExport;

  /// No description provided for @transferTabImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get transferTabImport;

  /// No description provided for @transferErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get transferErrorTitle;

  /// No description provided for @transferTypePasswords.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get transferTypePasswords;

  /// No description provided for @transferTypeApiKeys.
  ///
  /// In en, this message translates to:
  /// **'API Keys'**
  String get transferTypeApiKeys;

  /// No description provided for @transferTypeSecureNotes.
  ///
  /// In en, this message translates to:
  /// **'Secure notes'**
  String get transferTypeSecureNotes;

  /// No description provided for @transferTypeTotp.
  ///
  /// In en, this message translates to:
  /// **'Authenticators (TOTP)'**
  String get transferTypeTotp;

  /// No description provided for @transferTypePasskeys.
  ///
  /// In en, this message translates to:
  /// **'Passkeys'**
  String get transferTypePasskeys;

  /// No description provided for @transferTypeSshKeys.
  ///
  /// In en, this message translates to:
  /// **'SSH keys'**
  String get transferTypeSshKeys;

  /// No description provided for @transferExportPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an export password'**
  String get transferExportPasswordRequired;

  /// No description provided for @transferSelectAtLeastOneType.
  ///
  /// In en, this message translates to:
  /// **'Select at least one credential type'**
  String get transferSelectAtLeastOneType;

  /// No description provided for @transferExportedSummary.
  ///
  /// In en, this message translates to:
  /// **'Exported {creds} credentials · {folders} folders'**
  String transferExportedSummary(int creds, int folders);

  /// No description provided for @transferExportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: {msg}'**
  String transferExportError(String msg);

  /// No description provided for @transferImportError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {msg}'**
  String transferImportError(String msg);

  /// No description provided for @transferImportCsvError.
  ///
  /// In en, this message translates to:
  /// **'CSV import error: {msg}'**
  String transferImportCsvError(String msg);

  /// No description provided for @transferOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite vault?'**
  String get transferOverwriteTitle;

  /// No description provided for @transferOverwriteBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete ALL current credentials and replace them with those from the file. This operation cannot be undone.'**
  String get transferOverwriteBody;

  /// No description provided for @transferOverwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get transferOverwriteConfirm;

  /// No description provided for @transferExportPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Export password'**
  String get transferExportPasswordLabel;

  /// No description provided for @transferExportPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Create a password to protect this backup. You\'ll need it when importing on any device.'**
  String get transferExportPasswordInfo;

  /// No description provided for @transferExportPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: \"my-backup-key-2025\"'**
  String get transferExportPasswordHint;

  /// No description provided for @transferSelectWhatToExport.
  ///
  /// In en, this message translates to:
  /// **'Choose what to export'**
  String get transferSelectWhatToExport;

  /// No description provided for @transferEncryptionInfo.
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted with AES-256-GCM + Argon2id. Only someone who knows the export password can open it.'**
  String get transferEncryptionInfo;

  /// No description provided for @transferExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export vault'**
  String get transferExportButton;

  /// No description provided for @transferExportDone.
  ///
  /// In en, this message translates to:
  /// **'Export completed'**
  String get transferExportDone;

  /// No description provided for @transferBackupReminder.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while since your last backup. Export an encrypted copy and keep it somewhere safe.'**
  String get transferBackupReminder;

  /// No description provided for @transferSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to: {path}'**
  String transferSavedTo(String path);

  /// No description provided for @transferSummary.
  ///
  /// In en, this message translates to:
  /// **'{creds} credentials · {folders} folders'**
  String transferSummary(int creds, int folders);

  /// No description provided for @transferBackupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get transferBackupPasswordLabel;

  /// No description provided for @transferImportPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you used when exporting the backup. If you import a backup of your own from the same device you can leave this field empty.'**
  String get transferImportPasswordInfo;

  /// No description provided for @transferImportPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for same-device backups'**
  String get transferImportPasswordHint;

  /// No description provided for @transferImportModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Import mode'**
  String get transferImportModeLabel;

  /// No description provided for @transferModeMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get transferModeMerge;

  /// No description provided for @transferModeMergeSub.
  ///
  /// In en, this message translates to:
  /// **'Add without deleting your current credentials'**
  String get transferModeMergeSub;

  /// No description provided for @transferModeOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get transferModeOverwrite;

  /// No description provided for @transferModeOverwriteSub.
  ///
  /// In en, this message translates to:
  /// **'Will delete everything and replace with the file'**
  String get transferModeOverwriteSub;

  /// No description provided for @transferSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file (.skvault)'**
  String get transferSelectFile;

  /// No description provided for @transferImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV (Bitwarden/Chrome/1Pass)'**
  String get transferImportCsv;

  /// No description provided for @transferImportOtpauth.
  ///
  /// In en, this message translates to:
  /// **'Import authenticators (otpauth)'**
  String get transferImportOtpauth;

  /// No description provided for @transferOtpauthNone.
  ///
  /// In en, this message translates to:
  /// **'No otpauth:// links found in that file'**
  String get transferOtpauthNone;

  /// No description provided for @transferOtpauthMigrationUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Google Authenticator export QRs aren\'t supported. Export individual otpauth:// links instead.'**
  String get transferOtpauthMigrationUnsupported;

  /// No description provided for @transferDuplicatesWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected item already exists in your vault} other{{count} selected items already exist in your vault}}'**
  String transferDuplicatesWarning(int count);

  /// No description provided for @transferImportDone.
  ///
  /// In en, this message translates to:
  /// **'Import completed'**
  String get transferImportDone;

  /// No description provided for @transferExportSelectFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders to export'**
  String get transferExportSelectFolders;

  /// No description provided for @transferNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get transferNoFolder;

  /// No description provided for @transferImportSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select what to import'**
  String get transferImportSelectTitle;

  /// No description provided for @transferSectionTypes.
  ///
  /// In en, this message translates to:
  /// **'Credential types'**
  String get transferSectionTypes;

  /// No description provided for @transferSectionFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get transferSectionFolders;

  /// No description provided for @transferImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import selection'**
  String get transferImportConfirm;

  /// No description provided for @transferNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one item to import'**
  String get transferNothingSelected;

  /// No description provided for @transferSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get transferSelectAll;

  /// No description provided for @transferSelectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Select what to export'**
  String get transferSelectCredentials;

  /// No description provided for @transferSelectAtLeastOneCredential.
  ///
  /// In en, this message translates to:
  /// **'Select at least one credential'**
  String get transferSelectAtLeastOneCredential;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get commonSearch;

  /// No description provided for @navSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// No description provided for @desktopEmptyVault.
  ///
  /// In en, this message translates to:
  /// **'Empty vault'**
  String get desktopEmptyVault;

  /// No description provided for @desktopCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get desktopCreateFolder;

  /// No description provided for @desktopNoCredentials.
  ///
  /// In en, this message translates to:
  /// **'No credentials'**
  String get desktopNoCredentials;

  /// No description provided for @desktopNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favourites'**
  String get desktopNoFavorites;

  /// No description provided for @desktopSelectFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a folder'**
  String get desktopSelectFolderTitle;

  /// No description provided for @desktopSelectFolderSub.
  ///
  /// In en, this message translates to:
  /// **'Click a folder in the list to see its contents here.'**
  String get desktopSelectFolderSub;

  /// No description provided for @desktopSecureVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Vault'**
  String get desktopSecureVaultTitle;

  /// No description provided for @desktopSelectCredentialSub.
  ///
  /// In en, this message translates to:
  /// **'Select a credential from the list to view or edit its details.'**
  String get desktopSelectCredentialSub;

  /// No description provided for @desktopNewFolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get desktopNewFolderTooltip;

  /// No description provided for @desktopNewCredentialTooltip.
  ///
  /// In en, this message translates to:
  /// **'New credential'**
  String get desktopNewCredentialTooltip;

  /// No description provided for @desktopLockVault.
  ///
  /// In en, this message translates to:
  /// **'Lock vault'**
  String get desktopLockVault;

  /// No description provided for @navSecureFiles.
  ///
  /// In en, this message translates to:
  /// **'Secure files'**
  String get navSecureFiles;

  /// No description provided for @secureFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure files'**
  String get secureFilesTitle;

  /// No description provided for @secureFilesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get secureFilesEmptyTitle;

  /// No description provided for @secureFilesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Store SSH private keys, credentials.json or any other file, encrypted with your master key.'**
  String get secureFilesEmptyDesc;

  /// No description provided for @secureFilesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get secureFilesAdd;

  /// No description provided for @secureFilesExport.
  ///
  /// In en, this message translates to:
  /// **'Export / Save'**
  String get secureFilesExport;

  /// No description provided for @secureFilesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get secureFilesDelete;

  /// No description provided for @secureFilesAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to access the file'**
  String get secureFilesAuthReason;

  /// No description provided for @secureFilesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete file?'**
  String get secureFilesDeleteConfirmTitle;

  /// No description provided for @secureFilesDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This permanently removes the encrypted file.'**
  String secureFilesDeleteConfirmBody(String name);

  /// No description provided for @secureFilesDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get secureFilesDeleted;

  /// No description provided for @secureFilesSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get secureFilesSaved;

  /// No description provided for @secureFilesAddedSummary.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String secureFilesAddedSummary(String name);

  /// No description provided for @secureFilesAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add file: {msg}'**
  String secureFilesAddError(String msg);

  /// No description provided for @secureFilesExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export file: {msg}'**
  String secureFilesExportError(String msg);

  /// No description provided for @secureFilesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get secureFilesRename;

  /// No description provided for @secureFilesRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename file'**
  String get secureFilesRenameTitle;

  /// No description provided for @secureFilesMove.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get secureFilesMove;

  /// No description provided for @secureFilesMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get secureFilesMoveTitle;

  /// No description provided for @secureFilesFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get secureFilesFavorite;

  /// No description provided for @secureFilesDropHint.
  ///
  /// In en, this message translates to:
  /// **'Drop files here to add them'**
  String get secureFilesDropHint;

  /// No description provided for @secureFilesAddedCount.
  ///
  /// In en, this message translates to:
  /// **'Added {count} file(s)'**
  String secureFilesAddedCount(int count);

  /// No description provided for @secureFilesTooLarge.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" exceeds the {limit} limit and was skipped'**
  String secureFilesTooLarge(String name, String limit);

  /// No description provided for @secureFilesSkippedLarge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file skipped (too large)} other{{count} files skipped (too large)}}'**
  String secureFilesSkippedLarge(int count);

  /// No description provided for @secureFilesProcessing.
  ///
  /// In en, this message translates to:
  /// **'Encrypting {done} of {total}…'**
  String secureFilesProcessing(int done, int total);

  /// No description provided for @secureFilesOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get secureFilesOptions;

  /// No description provided for @secureFilesPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get secureFilesPreview;

  /// No description provided for @secureFilesPreviewError.
  ///
  /// In en, this message translates to:
  /// **'Could not preview file: {msg}'**
  String secureFilesPreviewError(String msg);

  /// No description provided for @secureFilesPreviewUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This file can\'t be shown as an image.'**
  String get secureFilesPreviewUnsupported;

  /// No description provided for @secureFilesFileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'{type} file'**
  String secureFilesFileTypeLabel(String type);

  /// No description provided for @secureFilesFileGeneric.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get secureFilesFileGeneric;

  /// No description provided for @relativeNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String relativeMinutes(int count);

  /// No description provided for @relativeHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 h ago} other{{count} h ago}}'**
  String relativeHours(int count);

  /// No description provided for @relativeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 d ago} other{{count} d ago}}'**
  String relativeDays(int count);

  /// No description provided for @homeShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show hidden'**
  String get homeShowHidden;

  /// No description provided for @homeShowActive.
  ///
  /// In en, this message translates to:
  /// **'Show active'**
  String get homeShowActive;

  /// No description provided for @homeNoHidden.
  ///
  /// In en, this message translates to:
  /// **'You have no hidden credentials'**
  String get homeNoHidden;

  /// No description provided for @detailHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get detailHide;

  /// No description provided for @detailUnhide.
  ///
  /// In en, this message translates to:
  /// **'Show in list'**
  String get detailUnhide;

  /// No description provided for @detailHidden.
  ///
  /// In en, this message translates to:
  /// **'Credential hidden from the main list'**
  String get detailHidden;

  /// No description provided for @detailUnhidden.
  ///
  /// In en, this message translates to:
  /// **'Credential visible again'**
  String get detailUnhidden;

  /// No description provided for @unlockApprovalSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to your phone. Approve it there to unlock.'**
  String get unlockApprovalSent;

  /// No description provided for @unlockApprovalNoDevice.
  ///
  /// In en, this message translates to:
  /// **'No phone connected. Open SoloKey on your phone on the same Wi-Fi network.'**
  String get unlockApprovalNoDevice;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync device'**
  String get syncTitle;

  /// No description provided for @syncServerActive.
  ///
  /// In en, this message translates to:
  /// **'Server active. Waiting for the phone to connect…'**
  String get syncServerActive;

  /// No description provided for @syncServerOff.
  ///
  /// In en, this message translates to:
  /// **'Server off.'**
  String get syncServerOff;

  /// No description provided for @syncClientConnecting.
  ///
  /// In en, this message translates to:
  /// **'Phone connecting…'**
  String get syncClientConnecting;

  /// No description provided for @syncClientDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Phone disconnected. Server waiting…'**
  String get syncClientDisconnected;

  /// No description provided for @syncPairedOk.
  ///
  /// In en, this message translates to:
  /// **'Pairing completed successfully!'**
  String get syncPairedOk;

  /// No description provided for @syncComparing.
  ///
  /// In en, this message translates to:
  /// **'Comparing local data with the phone…'**
  String get syncComparing;

  /// No description provided for @syncBidirOk.
  ///
  /// In en, this message translates to:
  /// **'Two-way sync successful!'**
  String get syncBidirOk;

  /// No description provided for @syncErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error during sync.'**
  String get syncErrorGeneric;

  /// No description provided for @syncRemoteUnlockReceived.
  ///
  /// In en, this message translates to:
  /// **'Remote unlock request received.'**
  String get syncRemoteUnlockReceived;

  /// No description provided for @syncPairTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair with mobile app'**
  String get syncPairTitle;

  /// No description provided for @syncPairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your passwords in real time securely and unlock this vault using your phone\'s biometrics.'**
  String get syncPairSubtitle;

  /// No description provided for @syncGenerateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate QR code'**
  String get syncGenerateQr;

  /// No description provided for @syncStartingServer.
  ///
  /// In en, this message translates to:
  /// **'Starting local server…'**
  String get syncStartingServer;

  /// No description provided for @syncScanThisQr.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code'**
  String get syncScanThisQr;

  /// No description provided for @syncScanThisQrSub.
  ///
  /// In en, this message translates to:
  /// **'Open SoloKey on your phone, go to Sync and scan this code.'**
  String get syncScanThisQrSub;

  /// No description provided for @syncConnectingDevice.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the mobile device…'**
  String get syncConnectingDevice;

  /// No description provided for @syncLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked successfully!'**
  String get syncLinkedTitle;

  /// No description provided for @syncLinkedSub.
  ///
  /// In en, this message translates to:
  /// **'The devices are now securely linked.'**
  String get syncLinkedSub;

  /// No description provided for @syncUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get syncUnderstood;

  /// No description provided for @syncErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pairing error'**
  String get syncErrorTitle;

  /// No description provided for @syncUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get syncUnexpectedError;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncComputerLinked.
  ///
  /// In en, this message translates to:
  /// **'Computer linked'**
  String get syncComputerLinked;

  /// No description provided for @syncComputerLinkedSub.
  ///
  /// In en, this message translates to:
  /// **'This computer is securely paired. You can connect several devices at once by scanning the same QR.'**
  String get syncComputerLinkedSub;

  /// No description provided for @syncServerE2eeActive.
  ///
  /// In en, this message translates to:
  /// **'Local E2EE server active'**
  String get syncServerE2eeActive;

  /// No description provided for @syncRemoveLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get syncRemoveLink;

  /// No description provided for @syncShowQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get syncShowQr;

  /// No description provided for @syncWaitingDevices.
  ///
  /// In en, this message translates to:
  /// **'Waiting for devices…'**
  String get syncWaitingDevices;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get syncStatusConnected;

  /// No description provided for @syncStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting sync…'**
  String get syncStarting;

  /// No description provided for @syncSendingLocal.
  ///
  /// In en, this message translates to:
  /// **'Sending local changes…'**
  String get syncSendingLocal;

  /// No description provided for @syncSuccessStats.
  ///
  /// In en, this message translates to:
  /// **'Sync successful! ({stats})'**
  String syncSuccessStats(String stats);

  /// No description provided for @syncBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock your computer'**
  String get syncBiometricReason;

  /// No description provided for @syncLinkComputer.
  ///
  /// In en, this message translates to:
  /// **'Pair computer'**
  String get syncLinkComputer;

  /// No description provided for @syncLinkComputerSub.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code generated by the SoloKey app on your computer to sync local data.'**
  String get syncLinkComputerSub;

  /// No description provided for @syncScanQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get syncScanQrButton;

  /// No description provided for @syncNegotiating.
  ///
  /// In en, this message translates to:
  /// **'Negotiating encryption keys…'**
  String get syncNegotiating;

  /// No description provided for @syncComputerLinkedExcl.
  ///
  /// In en, this message translates to:
  /// **'Computer linked!'**
  String get syncComputerLinkedExcl;

  /// No description provided for @syncComputerLinkedExclSub.
  ///
  /// In en, this message translates to:
  /// **'Data will now sync securely between devices.'**
  String get syncComputerLinkedExclSub;

  /// No description provided for @syncBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get syncBack;

  /// No description provided for @syncCouldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the computer.'**
  String get syncCouldNotConnect;

  /// No description provided for @syncRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get syncRetryButton;

  /// No description provided for @syncRemoteUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote unlock'**
  String get syncRemoteUnlockTitle;

  /// No description provided for @syncRemoteUnlockSub.
  ///
  /// In en, this message translates to:
  /// **'Unlock your computer\'s vault using this device\'s biometrics.'**
  String get syncRemoteUnlockSub;

  /// No description provided for @syncSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get syncSending;

  /// No description provided for @syncUnlockComputer.
  ///
  /// In en, this message translates to:
  /// **'Unlock computer'**
  String get syncUnlockComputer;

  /// No description provided for @syncUnlockSentBanner.
  ///
  /// In en, this message translates to:
  /// **'Request sent! The vault should unlock.'**
  String get syncUnlockSentBanner;

  /// No description provided for @syncAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication cancelled.'**
  String get syncAuthCancelled;

  /// No description provided for @syncNoToken.
  ///
  /// In en, this message translates to:
  /// **'Pair again with the desktop UNLOCKED to enable remote unlock.'**
  String get syncNoToken;

  /// No description provided for @syncVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync vault'**
  String get syncVaultTitle;

  /// No description provided for @syncVaultSub.
  ///
  /// In en, this message translates to:
  /// **'Exchange and update your credentials both ways on the local network.'**
  String get syncVaultSub;

  /// No description provided for @syncNotPairedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t paired yet. Scan the QR on the desktop.'**
  String get syncNotPairedYet;

  /// No description provided for @syncConnectingComputer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the computer…'**
  String get syncConnectingComputer;

  /// No description provided for @syncConnectFailCheck.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Make sure the PC is on and on the same Wi-Fi network.'**
  String get syncConnectFailCheck;

  /// No description provided for @auditIssueTooShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get auditIssueTooShortTitle;

  /// No description provided for @auditIssueTooShortDesc.
  ///
  /// In en, this message translates to:
  /// **'It has fewer than 8 characters.'**
  String get auditIssueTooShortDesc;

  /// No description provided for @auditIssueWeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get auditIssueWeakTitle;

  /// No description provided for @auditIssueWeakLettersDesc.
  ///
  /// In en, this message translates to:
  /// **'Only letters, no numbers or symbols.'**
  String get auditIssueWeakLettersDesc;

  /// No description provided for @auditIssueWeakNumbersDesc.
  ///
  /// In en, this message translates to:
  /// **'Only numbers.'**
  String get auditIssueWeakNumbersDesc;

  /// No description provided for @auditIssueReusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reused password'**
  String get auditIssueReusedTitle;

  /// No description provided for @auditIssueReusedDesc.
  ///
  /// In en, this message translates to:
  /// **'This password is used on multiple accounts.'**
  String get auditIssueReusedDesc;

  /// No description provided for @auditIssueBreachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaked password'**
  String get auditIssueBreachedTitle;

  /// No description provided for @auditIssueBreachedDesc.
  ///
  /// In en, this message translates to:
  /// **'This password appears in {count} data breaches online. Change it now!'**
  String auditIssueBreachedDesc(int count);

  /// No description provided for @auditIssueNoPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'No password saved'**
  String get auditIssueNoPasswordTitle;

  /// No description provided for @auditIssueNoPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'This credential has no password stored.'**
  String get auditIssueNoPasswordDesc;

  /// No description provided for @auditIssueRotationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotation required'**
  String get auditIssueRotationTitle;

  /// No description provided for @auditIssueRotationDesc.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago (set every {interval} days).'**
  String auditIssueRotationDesc(int days, int interval);

  /// No description provided for @auditIssueStaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get auditIssueStaleTitle;

  /// No description provided for @auditIssueStaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Not updated in over 6 months ({days} days).'**
  String auditIssueStaleDesc(int days);

  /// No description provided for @notifRotationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Rotation reminders'**
  String get notifRotationChannelName;

  /// No description provided for @notifRotationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Alerts when a password should be rotated for security.'**
  String get notifRotationChannelDesc;

  /// No description provided for @notifRotationTitle.
  ///
  /// In en, this message translates to:
  /// **'Password rotation required'**
  String get notifRotationTitle;

  /// No description provided for @notifRotationBody.
  ///
  /// In en, this message translates to:
  /// **'Your password for \"{title}\" has expired. Change it now for security.'**
  String notifRotationBody(String title);

  /// No description provided for @notifActionChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get notifActionChangePassword;

  /// No description provided for @notifActionSnooze3d.
  ///
  /// In en, this message translates to:
  /// **'Snooze 3 days'**
  String get notifActionSnooze3d;

  /// No description provided for @notifApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve sign-in'**
  String get notifApprovalTitle;

  /// No description provided for @notifApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Your computer is asking to unlock. Tap to approve.'**
  String get notifApprovalBody;

  /// No description provided for @notifApprovalBodyNamed.
  ///
  /// In en, this message translates to:
  /// **'Unlock \"{name}\"? Tap to approve.'**
  String notifApprovalBodyNamed(String name);

  /// No description provided for @syncSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get syncSummaryTitle;

  /// No description provided for @syncSummaryNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes — everything was already up to date'**
  String get syncSummaryNoChanges;

  /// No description provided for @syncSummaryFrom.
  ///
  /// In en, this message translates to:
  /// **'from {device}'**
  String syncSummaryFrom(String device);

  /// No description provided for @syncOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'the other device'**
  String get syncOtherDevice;

  /// No description provided for @syncCredentialsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get syncCredentialsLabel;

  /// No description provided for @syncFoldersLabel.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get syncFoldersLabel;

  /// No description provided for @syncCountAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 new} =1{1 new} other{{count} new}}'**
  String syncCountAdded(int count);

  /// No description provided for @syncCountUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 updated} =1{1 updated} other{{count} updated}}'**
  String syncCountUpdated(int count);

  /// No description provided for @syncCountRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 removed} =1{1 removed} other{{count} removed}}'**
  String syncCountRemoved(int count);

  /// No description provided for @syncItemsShow.
  ///
  /// In en, this message translates to:
  /// **'Show items'**
  String get syncItemsShow;

  /// No description provided for @syncItemsHide.
  ///
  /// In en, this message translates to:
  /// **'Hide items'**
  String get syncItemsHide;

  /// No description provided for @syncActionAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get syncActionAdded;

  /// No description provided for @syncActionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get syncActionUpdated;

  /// No description provided for @syncActionRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get syncActionRemoved;

  /// No description provided for @syncHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent syncs'**
  String get syncHistoryTitle;

  /// No description provided for @syncHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No syncs recorded yet'**
  String get syncHistoryEmpty;

  /// No description provided for @syncRelativeNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get syncRelativeNow;

  /// No description provided for @syncRelativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String syncRelativeMinutes(int count);

  /// No description provided for @syncRelativeHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 h ago} other{{count} h ago}}'**
  String syncRelativeHours(int count);

  /// No description provided for @syncRelativeDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 d ago} other{{count} d ago}}'**
  String syncRelativeDays(int count);

  /// No description provided for @syncBadgeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncBadgeSyncing;

  /// No description provided for @syncBadgeSynced.
  ///
  /// In en, this message translates to:
  /// **'In sync'**
  String get syncBadgeSynced;

  /// No description provided for @syncBadgeError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncBadgeError;

  /// No description provided for @syncPairedDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked devices'**
  String get syncPairedDevicesTitle;

  /// No description provided for @syncNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get syncNeverSynced;

  /// No description provided for @syncLastSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {when}'**
  String syncLastSyncLabel(String when);

  /// No description provided for @syncUnlinkDevice.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get syncUnlinkDevice;

  /// No description provided for @notifSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Vault synced'**
  String get notifSyncTitle;

  /// No description provided for @notifSyncBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change synced} other{{count} changes synced}}'**
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
