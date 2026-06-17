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
