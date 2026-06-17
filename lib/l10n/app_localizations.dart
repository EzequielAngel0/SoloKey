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
