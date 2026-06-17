// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get unlockSubtitle => 'Enter your master password';

  @override
  String get unlockMasterPasswordHint => 'Master password';

  @override
  String get unlockButton => 'Unlock';

  @override
  String unlockLockedFor(String time) {
    return 'Locked ($time)';
  }

  @override
  String get unlockUseBiometrics => 'Use biometrics';

  @override
  String get unlockWifiAvailable => 'WiFi unlock available';

  @override
  String get unlockForgotPassword => 'Forgot your master password?';

  @override
  String get unlockFromMobile => 'Unlocking from mobile device…';

  @override
  String unlockTooManyAttempts(String time) {
    return 'Too many attempts. Retry in $time.';
  }

  @override
  String get unlockTapToEnter => 'Tap to enter your password';

  @override
  String unlockRemoteFailed(String msg) {
    return 'Remote unlock failed: $msg';
  }

  @override
  String get unlockRemoteError => 'Remote unlock error';

  @override
  String get unlockBiometricReason => 'Unlock your vault';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAutoLock => 'Auto-lock';

  @override
  String get settingsSectionClipboard => 'Clipboard';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionQuickFill => 'Quick-Fill';

  @override
  String get settingsAutoLockLabel => 'Lock on inactivity';

  @override
  String settingsAutoLockValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsClearClipboardLabel => 'Clear clipboard';

  @override
  String settingsClearClipboardValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get settingsBiometricLabel => 'Biometric unlock';

  @override
  String get settingsBiometricSubtitle => 'Use fingerprint or face';

  @override
  String get settingsObscureLabel => 'Hide in background';

  @override
  String get settingsObscureSubtitle =>
      'Apply a privacy screen when switching apps';

  @override
  String get settingsAutostartLabel => 'Start with the system';

  @override
  String get settingsAutostartSubtitle =>
      'Starts minimised in the tray when the device boots';

  @override
  String get settingsQuickFillDescription =>
      'Press the shortcut from any app to open SoloKey and copy the username/password to the clipboard (it clears itself).';

  @override
  String get settingsQuickFillTryNow => 'Try now';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get splashTagline => 'Your secure vault';

  @override
  String get setupTitle => 'Create master\npassword';

  @override
  String get setupSubtitle =>
      'This password protects your entire vault. It cannot be recovered if you forget it.';

  @override
  String get setupMinChars => 'At least 12 characters';

  @override
  String get setupConfirmLabel => 'Confirm password';

  @override
  String get setupPasswordsMismatch => 'Passwords do not match';

  @override
  String get setupCreateButton => 'Create vault';

  @override
  String get setupNeedUppercase => 'Include at least one uppercase letter';

  @override
  String get setupNeedNumber => 'Include at least one number';

  @override
  String get setupNeedSymbol => 'Include at least one symbol';

  @override
  String get setupReqChars => '12+ characters';

  @override
  String get setupReqUppercase => 'Uppercase';

  @override
  String get setupReqNumber => 'Number';

  @override
  String get setupReqSymbol => 'Symbol';

  @override
  String get commonCreate => 'Create';

  @override
  String get navAudit => 'Audit';

  @override
  String get navSettings => 'Settings';

  @override
  String get navCredentials => 'Credentials';

  @override
  String get navFolders => 'Folders';

  @override
  String get navFavorites => 'Favourites';

  @override
  String get homeSearchHint => 'Search credentials…';

  @override
  String get homeLockTooltip => 'Lock';

  @override
  String get homeFabNew => 'New';

  @override
  String get homeFabFolder => 'Folder';

  @override
  String homeLoadError(String msg) {
    return 'Error: $msg';
  }

  @override
  String get homeEmptyVault => 'Your vault is empty';

  @override
  String get emptyAddFirst => 'Add your first credential';

  @override
  String get emptyAddCredential => 'Add credential';

  @override
  String get folderDialogTitle => 'Folder';

  @override
  String get folderNameLabel => 'Folder name';

  @override
  String get folderNameHint => 'e.g. Work, Social…';

  @override
  String get commonAccept => 'Accept';

  @override
  String commonErrorDetail(String msg) {
    return 'Error: $msg';
  }

  @override
  String get detailNotFound => 'Credential not found';

  @override
  String get detailRemoveFavorite => 'Remove from favourites';

  @override
  String get detailAddFavorite => 'Add to favourites';

  @override
  String get detailViewHistory => 'View password history';

  @override
  String get detailDeleteTitle => 'Delete credential';

  @override
  String detailDeleteBody(String title) {
    return 'Delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get detailDeleteAuthReason => 'Verify to delete this credential';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldKeyType => 'Key type';

  @override
  String get fieldPrivateKey => 'Private key';

  @override
  String get fieldPublicKey => 'Public key';

  @override
  String get fieldKeyPassphrase => 'Key passphrase';

  @override
  String get typePassword => 'Password';

  @override
  String get typeApiKey => 'API key';

  @override
  String get typeSecureNote => 'Secure note';

  @override
  String get typeTotp => 'TOTP / 2FA';

  @override
  String get typePasskey => 'Passkey backup';

  @override
  String get typeSshKey => 'SSH key';

  @override
  String get rotationMonthly => 'Monthly';

  @override
  String get rotationQuarterly => 'Every 3 months';

  @override
  String get rotationSemiAnnually => 'Every 6 months';

  @override
  String rotationCustom(int days) {
    return 'Custom ($days days)';
  }

  @override
  String get rotationNone => 'None';

  @override
  String get rotationOverdueTitle => 'PASSWORD ROTATION OVERDUE';

  @override
  String get rotationReminderTitle => 'ROTATION REMINDER';

  @override
  String rotationOverdueBody(int days) {
    return 'You should change this password. More than $days days have passed since the last update.';
  }

  @override
  String rotationReminderBody(int days, String interval) {
    return 'Next change required in $days days ($interval).';
  }

  @override
  String get secretDecrypting => 'Decrypting…';

  @override
  String get secretDecryptAuthReason => 'Authenticate to decrypt this secret';

  @override
  String secretDecryptError(String msg) {
    return 'Decryption error: $msg';
  }

  @override
  String get pinDialogTitle => 'Enter secondary PIN';

  @override
  String get pinDialogLabel => 'Double-envelope PIN';

  @override
  String get totpTitle => 'Verification code (2FA)';

  @override
  String get totpClipboardLabel => 'TOTP code';

  @override
  String get totpInvalid => 'Invalid';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No old passwords.';

  @override
  String get historyCopyTooltip => 'Copy password';

  @override
  String get historyClipboardLabel => 'Historical password';

  @override
  String get historyRestoreTooltip => 'Restore password';

  @override
  String get historyRestoreTitle => 'Restore password?';

  @override
  String get historyRestoreBody =>
      'This will replace the credential\'s current password with this historical one. Continue?';

  @override
  String get historyRestoreConfirm => 'Restore';

  @override
  String get historyRestoreSuccess => 'Password restored successfully';

  @override
  String historyRestoreError(String msg) {
    return 'Error restoring the password: $msg';
  }

  @override
  String get recoveryTitle => 'Recover access';

  @override
  String get recoveryCodeTitle => 'Recovery code';

  @override
  String get recoveryCodeDescription =>
      'The recovery code was generated when you set up your vault. If you saved it, enter it here to reset your master password.';

  @override
  String get recoveryEnterCode => 'Enter the recovery code';

  @override
  String get recoveryWrongCode => 'Incorrect code. Check it and try again.';

  @override
  String get recoveryVerifyButton => 'Verify code';

  @override
  String get recoveryEnterNewPassword => 'Enter the new master password';

  @override
  String get recoveryMin8 => 'The password must be at least 8 characters';

  @override
  String get recoveryPasswordUpdated => 'Master password updated successfully';

  @override
  String get recoveryCodeVerified =>
      'Code verified. Now set your new master password.';

  @override
  String get recoveryNewPasswordLabel => 'New master password';

  @override
  String get recoveryResetButton => 'Reset master password';

  @override
  String get recoveryCodeWarning =>
      'Save this code somewhere safe! It is shown ONLY ONCE and cannot be recovered.';

  @override
  String get recoveryCopyCode => 'Copy code';

  @override
  String get recoveryCodeSavedContinue => 'I saved it, continue';
}
