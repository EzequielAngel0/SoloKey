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
  String get unlockWrongPassword => 'Incorrect master password';

  @override
  String unlockWrongPasswordLocked(String time) {
    return 'Incorrect password. Locked for $time.';
  }

  @override
  String get unlockVaultWiped => 'Vault wiped after too many failed attempts.';

  @override
  String get unlockBiometricFailed =>
      'Biometric authentication failed or not configured.';

  @override
  String get unlockGenericError => 'Could not unlock the vault.';

  @override
  String get unlockWithWindowsHello => 'Unlock with Windows Hello';

  @override
  String get unlockWithBiometrics => 'Unlock with biometrics';

  @override
  String get unlockOrUseMasterPassword => 'or use your master password';

  @override
  String unlockAttemptsBeforeLockout(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left before a temporary lock',
      one: '1 attempt left before a temporary lock',
    );
    return '$_temp0';
  }

  @override
  String unlockAttemptsBeforeWipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left before the vault is wiped',
      one: '1 attempt left before the vault is wiped',
    );
    return '$_temp0';
  }

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
  String get commonDisabled => 'Disabled';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionDanger => 'Danger zone';

  @override
  String get settingsThemeTitle => 'App theme';

  @override
  String get settingsDensityTitle => 'Density';

  @override
  String get densityComfortable => 'Comfortable';

  @override
  String get densityCompact => 'Compact';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDim => 'Dim';

  @override
  String get themeOled => 'OLED';

  @override
  String get settingsWipeTitle => 'Wipe vault after failed attempts';

  @override
  String get settingsWipeSubtitle =>
      'Anti brute-force protection (irreversible)';

  @override
  String get settingsSyncComputerTitle => 'Sync computer';

  @override
  String get settingsSyncComputerSubtitle => 'Pair with desktop SoloKey';

  @override
  String get settingsExportImportTitle => 'Export / Import';

  @override
  String get settingsExportImportSubtitle =>
      'Make encrypted backups of your vault';

  @override
  String get settingsAutofillTitle => 'System autofill';

  @override
  String get settingsAutofillSubtitle => 'Fill passwords in other apps';

  @override
  String get settingsPasskeysTitle => 'Passkey backup';

  @override
  String get settingsPasskeysSubtitle => 'Store your passkey backups';

  @override
  String get settingsBackupTitle => 'Automatic backup';

  @override
  String get settingsBackupDaily => 'Daily';

  @override
  String get settingsBackupWeekly => 'Weekly';

  @override
  String get settingsBackupMonthly => 'Monthly';

  @override
  String settingsBackupEveryNDays(int days) {
    return 'Every $days days';
  }

  @override
  String get settingsBackupNoFolder => 'no folder';

  @override
  String get settingsBackupFrequency => 'Frequency';

  @override
  String get settingsBackupChooseFolder => 'Choose destination folder';

  @override
  String get settingsBackupPassword => 'Backup password';

  @override
  String get settingsBackupPasswordKeep =>
      'Backup password (leave empty = keep)';

  @override
  String get settingsLockNowTitle => 'Lock now';

  @override
  String get settingsLockNowSubtitle => 'Close the session immediately';

  @override
  String get settingsVersionLabel => 'Version';

  @override
  String get settingsAboutTagline => 'Local-first password manager';

  @override
  String get settingsSectionShortcuts => 'Keyboard shortcuts';

  @override
  String get shortcutCommandPalette => 'Command palette';

  @override
  String get shortcutNewCredential => 'New credential';

  @override
  String get shortcutLock => 'Lock vault';

  @override
  String get shortcutReset => 'Reset to defaults';

  @override
  String get shortcutEditTitle => 'Set shortcut';

  @override
  String get shortcutCapturePrompt => 'Press the key combination…';

  @override
  String get shortcutNeedsModifier => 'Add a modifier (Ctrl, Alt or Shift)';

  @override
  String get shortcutConflict =>
      'That combination is already used by another shortcut';

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
  String get navVault => 'Vault';

  @override
  String get navSecurity => 'Security';

  @override
  String get filterAll => 'All';

  @override
  String get filterPasswords => 'Passwords';

  @override
  String get securityHubSubtitle => 'Tools to keep your vault healthy';

  @override
  String get securityHubAuditDesc => 'Weak, reused and breached passwords';

  @override
  String get securityHubGenerator => 'Password generator';

  @override
  String get securityHubGeneratorDesc => 'Create strong, unique passwords';

  @override
  String get securityHubTransferDesc => 'Export or import your vault';

  @override
  String get securityHubSecureFilesDesc => 'Encrypted documents and images';

  @override
  String get securityHubPasskeysDesc => 'Manage your encrypted passkey backups';

  @override
  String get securityHubSyncDesc => 'Pair this device over your network';

  @override
  String get securityHubRecoveryDesc => 'Reset your master password';

  @override
  String get generatorSheetTitle => 'Generate password';

  @override
  String get commandNoResults => 'No results';

  @override
  String get detailAdvanced => 'Advanced';

  @override
  String get detailTotpSecret => 'Secret (seed)';

  @override
  String get detailCopyCode => 'Copy code';

  @override
  String get healthReused => 'Reused';

  @override
  String get auditScoreTitle => 'Vault health';

  @override
  String auditScoreIssues(int count) {
    return '$count issues to review';
  }

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
  String homeCredentialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credentials',
      one: '1 credential',
      zero: 'No credentials',
    );
    return '$_temp0';
  }

  @override
  String homeIssuesChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count issues',
      one: '1 issue',
    );
    return '$_temp0';
  }

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeHealthTooltip => 'Vault health — tap for details';

  @override
  String get homeSortTooltip => 'Sort';

  @override
  String get sortManual => 'Manual order';

  @override
  String get sortTitleAsc => 'Name (A–Z)';

  @override
  String get sortUpdatedDesc => 'Recently updated';

  @override
  String get homeReorderStart => 'Reorder';

  @override
  String get homeReorderDone => 'Done';

  @override
  String get homeReorderHint => 'Drag the handle to reorder';

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
  String get detailRevealAuthReason => 'Authenticate to reveal this secret';

  @override
  String get detailRevealSecret => 'Reveal secret';

  @override
  String get detailHideSecret => 'Hide secret';

  @override
  String detailCopyField(String field) {
    return 'Copy $field';
  }

  @override
  String detailHideCountdown(int seconds) {
    return 'Auto-hides in ${seconds}s';
  }

  @override
  String get detailOpenSite => 'Open site';

  @override
  String get detailOpenSiteError => 'Could not open the site';

  @override
  String get detailPasskeyHandleNote =>
      'The private key handle stays encrypted in your vault.';

  @override
  String get detailTotpExportQr => 'Export as QR';

  @override
  String get detailTotpExportQrAuthReason => 'Authenticate to show the TOTP QR';

  @override
  String get detailTotpExportQrTitle => 'Scan on another device';

  @override
  String get detailTotpExportQrWarning =>
      'Anyone who scans this can generate your codes. Keep it private.';

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
  String get a11yFavorite => 'Favourite';

  @override
  String get a11yDoubleEncrypted => 'Double-encrypted';

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

  @override
  String accessStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get recoveryStepEnterCode => 'Enter your recovery code';

  @override
  String get recoveryStepNewPassword => 'Set a new master password';

  @override
  String get setupStepCreate => 'Create your master password';

  @override
  String get setupStepSaveCode => 'Save your recovery code';

  @override
  String get autofillOnboardingTitle => 'Autofill';

  @override
  String get autofillActiveTitle => 'SoloKey is active!';

  @override
  String get autofillEnableTitle => 'Enable autofill';

  @override
  String get autofillActiveDesc =>
      'SoloKey will automatically fill your passwords in any app or browser on your device.';

  @override
  String get autofillEnableDesc =>
      'Let SoloKey fill your passwords automatically in apps and browsers.';

  @override
  String get autofillOpenSettings => 'Open Autofill settings';

  @override
  String get autofillVerifyStatus => 'I enabled it, check status';

  @override
  String get autofillFeatureDetection => 'Automatic login form detection';

  @override
  String get autofillFeatureBiometric =>
      'Asks for your fingerprint before filling (biometrics)';

  @override
  String get autofillFeatureNeverExposed =>
      'Credentials never exposed to the OS';

  @override
  String get autofillStatusActive => 'Active';

  @override
  String get autofillStatusInactive => 'Inactive';

  @override
  String get autofillStep1Title => 'Tap \"Open Autofill settings\"';

  @override
  String get autofillStep1Sub => 'The system settings will open';

  @override
  String get autofillStep2Title => 'Select \"SoloKey\" as the provider';

  @override
  String get autofillStep2Sub => 'Find SoloKey in the list of apps';

  @override
  String get autofillStep3Title => 'Confirm and return to the app';

  @override
  String get autofillStep3Sub => 'Autofill will be enabled';

  @override
  String get quickFillTitle => 'Quick-Fill';

  @override
  String get quickFillCloseTooltip => 'Close (Esc)';

  @override
  String get quickFillSearchHint => 'Search credential…';

  @override
  String get quickFillLoadError => 'Could not load credentials';

  @override
  String get quickFillNoMatches => 'No matches';

  @override
  String get quickFillFooter =>
      'Copy the value and paste it (Ctrl+V) into the field · it clears itself from the clipboard';

  @override
  String get quickFillCopyUser => 'Copy username';

  @override
  String get quickFillCopyPassword => 'Copy password';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get auditTitle => 'Security Audit';

  @override
  String get auditAnalysisTitle => 'Security Analysis';

  @override
  String get auditAnalysisDesc =>
      'SoloKey analyses your credentials locally to identify weak, short, reused or old passwords.';

  @override
  String get auditBreachCheck => 'Check breaches (online)';

  @override
  String get auditPrivateBadge => 'PRIVATE';

  @override
  String get auditBreachDesc =>
      'Uses k-Anonymity (HaveIBeenPwned) to look up exposed passwords without revealing your real password.';

  @override
  String get auditAllGoodTitle => 'All good!';

  @override
  String get auditAllGoodDesc => 'No problems were found in your vault.';

  @override
  String get auditSeverityCritical => 'Critical';

  @override
  String get auditSeverityWarning => 'Warning';

  @override
  String get auditSeverityInfo => 'Info';

  @override
  String get passkeysTitle => 'Passkey backups';

  @override
  String get passkeysAdd => 'Add passkey';

  @override
  String get passkeysHowToTitle => 'How to register a passkey?';

  @override
  String get passkeysHowToBody =>
      'Passkeys are registered directly on each web service (e.g. Google, GitHub, Apple).\n\n1. Go to the service\'s website\n2. Look for \"Passkeys\" under Security\n3. The system will register and sync the passkey automatically\n\nSoloKey will store the passkey information in your vault, encrypted, so you can manage it.';

  @override
  String get passkeysEmptyTitle => 'No passkey backups';

  @override
  String get passkeysEmptyDesc =>
      'Passkeys are the future of authentication: passwordless, safer and faster. Register them on your favourite services and SoloKey will keep an encrypted backup here.';

  @override
  String get passkeysEncryptedBadge => 'Encrypted backup in your vault';

  @override
  String passkeysUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get passkeysViewDetails => 'View details';

  @override
  String get passkeyDomain => 'Domain (RP ID)';

  @override
  String get passkeyService => 'Service';

  @override
  String get passkeyVerification => 'Verification';

  @override
  String get passkeyVerificationRequired => 'Required (Biometric / PIN)';

  @override
  String get passkeyVerificationOptional => 'Optional';

  @override
  String get passkeyCredentialId => 'Credential ID';

  @override
  String get passkeyCredentialIdCopied => 'Credential ID copied';

  @override
  String get passkeyIconLabel => 'Passkey';

  @override
  String get passkeyRegistered => 'Registered';

  @override
  String get passkeyPrivateKeyNote =>
      'The private key never leaves the device. Only the identifying information is stored.';

  @override
  String get passkeysDeleteTitle => 'Delete passkey';

  @override
  String passkeysDeleteBody(String title, String service) {
    return 'Delete the passkey \"$title\"?\n\nNote: you must also remove it from the corresponding web service ($service).';
  }

  @override
  String get passkeysSiteFallback => 'the site';

  @override
  String get passkeysDeleteAuthReason => 'Verify to delete this passkey';

  @override
  String get formNewTitle => 'New credential';

  @override
  String get formEditTitle => 'Edit credential';

  @override
  String get formCreated => 'Credential created';

  @override
  String get formSaved => 'Changes saved';

  @override
  String get formSaveChanges => 'Save changes';

  @override
  String get formCreateCredential => 'Create credential';

  @override
  String get formFieldRequired => 'Required field';

  @override
  String get formErrPinRequiredEnable =>
      'You must enter a secondary PIN for double encryption';

  @override
  String get formErrPinRequiredDisable =>
      'Enter the secondary PIN to disable double encryption';

  @override
  String get formQrNotTotp => 'The QR code is not a valid TOTP.';

  @override
  String get formQrScanned => 'QR code scanned successfully';

  @override
  String get formQrNoSecret => 'No secret key was found in the QR.';

  @override
  String get formQrReadError => 'Error reading the QR code.';

  @override
  String get formSshGenerated => 'Ed25519 key pair generated';

  @override
  String get formSshGenError => 'Error generating the SSH key.';

  @override
  String get formCustomFieldsTitle => 'Custom fields';

  @override
  String get formNoCustomFields => 'No custom fields.';

  @override
  String get formAddField => 'Add field';

  @override
  String get formEditField => 'Edit field';

  @override
  String get formNewCustomField => 'New custom field';

  @override
  String get formFieldNameLabel => 'Field name';

  @override
  String get formFieldNameHint => 'e.g. PIN, Security question';

  @override
  String get formNameRequired => 'Name required';

  @override
  String get formFieldValueLabel => 'Field value';

  @override
  String get formFieldValueHint => 'e.g. 1234, Home town';

  @override
  String get formValueRequired => 'Value required';

  @override
  String get formSecretField => 'Secret field';

  @override
  String get formSecretBadge => 'SECRET';

  @override
  String get formSecretFieldSub => 'Hides the value by default in the details.';

  @override
  String get formAdd => 'Add';

  @override
  String get formSectionIdentification => 'Identification';

  @override
  String get formTitleLabel => 'Title';

  @override
  String get formSectionContent => 'Content';

  @override
  String get formSectionNotes => 'Notes';

  @override
  String get formSecureContentLabel => 'Secure content';

  @override
  String get formNotesLabel => 'Additional notes';

  @override
  String get formSecureContentHint => 'Write your private note here…';

  @override
  String get formNotesHint => 'Optional — add context or reminders';

  @override
  String get formContentRequired => 'Content is required';

  @override
  String get formSectionOrganization => 'Organisation';

  @override
  String get formFolderLabel => 'Folder';

  @override
  String get formMainVault => 'Main vault';

  @override
  String get formHintPassword => 'e.g. Netflix, GitHub, Gmail';

  @override
  String get formHintApiKey => 'e.g. OpenAI, Stripe, AWS';

  @override
  String get formHintSecureNote => 'e.g. Server keys, Seeds';

  @override
  String get formHintTotp => 'e.g. GitHub 2FA, Google';

  @override
  String get formHintPasskey => 'e.g. google.com Passkey';

  @override
  String get formHintSshKey => 'e.g. Production Server, GitHub SSH Key';

  @override
  String get formSectionLogin => 'Login credentials';

  @override
  String get formUserEmailLabel => 'Username / Email';

  @override
  String get formUserEmailHint => 'user@example.com';

  @override
  String get formWebsiteLabel => 'Website / URL';

  @override
  String get formWebsiteHint => 'https://example.com';

  @override
  String get formSectionApi => 'API details';

  @override
  String get formServiceNameLabel => 'Service name';

  @override
  String get formServiceNameHint => 'e.g. OpenAI, Stripe, Supabase';

  @override
  String get formApiKeyLabel => 'API Key / Token';

  @override
  String get formEndpointLabel => 'Endpoint URL';

  @override
  String get formScopesLabel => 'Permissions / Scopes';

  @override
  String get formSection2fa => '2FA setup';

  @override
  String get formTotpDesc =>
      'Enter the TOTP secret key (Base32) of your account. You\'ll find it when enabling 2FA on the website, or you can scan the QR code directly.';

  @override
  String get formScanQr => 'Scan QR code';

  @override
  String get formOrManually => 'or enter manually';

  @override
  String get formAccountIssuerLabel => 'Account / Issuer';

  @override
  String get formAccountIssuerHint => 'e.g. GitHub, Google, AWS';

  @override
  String get formTotpSecretLabel => 'TOTP secret key (Base32)';

  @override
  String get formSectionPasskey => 'Passkey (FIDO2)';

  @override
  String get formPasskeyDesc =>
      'Passkeys are registered directly with the device\'s FIDO2 platform.';

  @override
  String get formPasskeyHint =>
      'Use the Passkeys screen in Settings to register or manage your passkeys.';

  @override
  String get formSectionSsh => 'SSH key configuration';

  @override
  String get formGenerateSsh => 'Generate Ed25519 key pair';

  @override
  String get formPrivateKeyRequired => 'The private key is required';

  @override
  String get formPublicKeyOptional => 'Public key (Optional)';

  @override
  String get formKeyPassphraseOptional => 'Key passphrase (Optional)';

  @override
  String get formSectionDoubleEnc => 'Double-envelope encryption';

  @override
  String get formEnableDoubleEnc => 'Enable double encryption';

  @override
  String get formDoubleEncDesc =>
      'Protects this entry\'s secrets with a secondary PIN. They will be encrypted additionally.';

  @override
  String get formPinSecondaryEditLabel =>
      'Secondary PIN (Leave empty to keep current, or enter to change)';

  @override
  String get formPinSecondaryLabel => 'Secondary PIN';

  @override
  String get formPinSecondaryRequired => 'The secondary PIN is required';

  @override
  String get formBiometricUnlock => 'Biometric unlock';

  @override
  String get formBiometricUnlockSub =>
      'Store the encrypted PIN to unlock quickly with fingerprint/face.';

  @override
  String get formSectionRotation => 'Rotation reminder';

  @override
  String get formRotationLabel => 'Remind to change password';

  @override
  String get formRotNone => 'Don\'t remind';

  @override
  String get formRotMonthly => 'Every month';

  @override
  String get formRotCustom => 'Custom (days)';

  @override
  String get formCustomDaysLabel => 'Days to remind';

  @override
  String get formCustomDaysRequired => 'You must enter the number of days';

  @override
  String get formCustomDaysInvalid => 'Enter a valid number of days';

  @override
  String get formDiscardTitle => 'Discard changes?';

  @override
  String get formDiscardMessage =>
      'You have unsaved changes. If you leave now they will be lost.';

  @override
  String get formDiscardKeep => 'Keep editing';

  @override
  String get formDiscardLeave => 'Discard';

  @override
  String get formErrInvalidUrl => 'Enter a valid URL';

  @override
  String get formErrInvalidTotp => 'Invalid Base32 secret (only A–Z and 2–7)';

  @override
  String get formPasteTotp => 'Paste otpauth link';

  @override
  String get formPasteApplied => 'TOTP filled from clipboard';

  @override
  String get formPasteNoOtpauth => 'No valid otpauth:// link in the clipboard';

  @override
  String get formDupTitle => 'Possible duplicate';

  @override
  String formDupMessage(String title) {
    return '\"$title\" already uses this username. Save anyway?';
  }

  @override
  String get formDupReview => 'Review';

  @override
  String get formDupSaveAnyway => 'Save anyway';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get folderNewSubfolder => 'New subfolder';

  @override
  String get folderDeleteTitle => 'Delete folder';

  @override
  String folderDeleteKeepBody(String name) {
    return 'Remove \"$name\"? Its subfolders and credentials are kept — choose where to move them. Nothing is deleted.';
  }

  @override
  String get folderDeleteMoveToParent => 'Move contents to parent folder';

  @override
  String get folderDeleteMoveToVault => 'Move contents to vault root';

  @override
  String get folderDeleted => 'Folder deleted';

  @override
  String get folderRename => 'Rename';

  @override
  String get folderRenameTitle => 'Rename folder';

  @override
  String get folderNewNameLabel => 'New name';

  @override
  String get folderCreateSubfolder => 'Create subfolder';

  @override
  String get folderEmptyTitle => 'Empty folder';

  @override
  String get folderEmptyDesc => 'There are no subfolders or credentials here.';

  @override
  String get folderNoFolders => 'No folders';

  @override
  String get folderOrganize => 'Organise your credentials';

  @override
  String get folderCreateRoot => 'Create root folder';

  @override
  String get folderNewRoot => 'New root folder';

  @override
  String get folderUnassigned => 'No folder assigned';

  @override
  String get folderNew => 'New folder';

  @override
  String get folderAddSubfolder => 'Add subfolder';

  @override
  String folderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get folderColorTitle => 'Color';

  @override
  String get folderEditTitle => 'Edit folder';

  @override
  String get folderTreeHint =>
      'Use the arrow keys to browse folders; press the menu button for actions.';

  @override
  String get folderSelectTitle => 'Select folder';

  @override
  String get folderNewRootShort => 'New root';

  @override
  String get folderNoneMainVault => 'None (Main vault)';

  @override
  String get favoritesEmptyTitle => 'No favourites yet';

  @override
  String get favoritesEmptyDesc => 'Star folders or credentials';

  @override
  String get favoritesFoldersHeader => 'Favourite folders';

  @override
  String get favoritesCredentialsHeader => 'Favourite credentials';

  @override
  String get favoriteToggleLabel => 'Mark as favourite';

  @override
  String get commonEdit => 'Edit';

  @override
  String get cardCopyUser => 'Copy username';

  @override
  String get cardCopyPassword => 'Copy password';

  @override
  String get cardCopyPasswordAuthReason => 'Authenticate to copy the password';

  @override
  String get cardMoveToFolder => 'Move to folder';

  @override
  String get cardNoFolder => 'No folder';

  @override
  String get cardMovedSuccess => 'Credential moved successfully';

  @override
  String get typeSelNote => 'Note';

  @override
  String get typeSelTotp => 'TOTP';

  @override
  String get typeSelPasskey => 'Passkey';

  @override
  String get genRegenerate => 'Regenerate';

  @override
  String genLength(int n) {
    return 'Length: $n';
  }

  @override
  String get genGeneratedPassword => 'Generated password';

  @override
  String get genUseAndCopy => 'Use & copy';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthStrong => 'Strong';

  @override
  String clipboardCopiedClears(String label, int seconds) {
    return '$label copied · clears in ${seconds}s';
  }

  @override
  String get passwordRowGeneratorTooltip => 'Key generator';

  @override
  String get keyboardSpace => 'Space';

  @override
  String get transferTitle => 'Transfer data';

  @override
  String get transferTabExport => 'Export';

  @override
  String get transferTabImport => 'Import';

  @override
  String get transferErrorTitle => 'Error';

  @override
  String get transferTypePasswords => 'Passwords';

  @override
  String get transferTypeApiKeys => 'API Keys';

  @override
  String get transferTypeSecureNotes => 'Secure notes';

  @override
  String get transferTypeTotp => 'Authenticators (TOTP)';

  @override
  String get transferTypePasskeys => 'Passkeys';

  @override
  String get transferTypeSshKeys => 'SSH keys';

  @override
  String get transferExportPasswordRequired => 'Enter an export password';

  @override
  String get transferSelectAtLeastOneType =>
      'Select at least one credential type';

  @override
  String transferExportedSummary(int creds, int folders) {
    return 'Exported $creds credentials · $folders folders';
  }

  @override
  String transferExportError(String msg) {
    return 'Export error: $msg';
  }

  @override
  String transferImportError(String msg) {
    return 'Import error: $msg';
  }

  @override
  String transferImportCsvError(String msg) {
    return 'CSV import error: $msg';
  }

  @override
  String get transferOverwriteTitle => 'Overwrite vault?';

  @override
  String get transferOverwriteBody =>
      'This will delete ALL current credentials and replace them with those from the file. This operation cannot be undone.';

  @override
  String get transferOverwriteConfirm => 'Overwrite';

  @override
  String get transferExportPasswordLabel => 'Export password';

  @override
  String get transferExportPasswordInfo =>
      'Create a password to protect this backup. You\'ll need it when importing on any device.';

  @override
  String get transferExportPasswordHint => 'e.g.: \"my-backup-key-2025\"';

  @override
  String get transferSelectWhatToExport => 'Choose what to export';

  @override
  String get transferEncryptionInfo =>
      'The file is encrypted with AES-256-GCM + Argon2id. Only someone who knows the export password can open it.';

  @override
  String get transferExportButton => 'Export vault';

  @override
  String get transferExportDone => 'Export completed';

  @override
  String get transferBackupReminder =>
      'It\'s been a while since your last backup. Export an encrypted copy and keep it somewhere safe.';

  @override
  String transferSavedTo(String path) {
    return 'Saved to: $path';
  }

  @override
  String transferSummary(int creds, int folders) {
    return '$creds credentials · $folders folders';
  }

  @override
  String get transferBackupPasswordLabel => 'Backup password';

  @override
  String get transferImportPasswordInfo =>
      'Enter the password you used when exporting the backup. If you import a backup of your own from the same device you can leave this field empty.';

  @override
  String get transferImportPasswordHint =>
      'Leave empty for same-device backups';

  @override
  String get transferImportModeLabel => 'Import mode';

  @override
  String get transferModeMerge => 'Merge';

  @override
  String get transferModeMergeSub =>
      'Add without deleting your current credentials';

  @override
  String get transferModeOverwrite => 'Overwrite';

  @override
  String get transferModeOverwriteSub =>
      'Will delete everything and replace with the file';

  @override
  String get transferSelectFile => 'Select file (.skvault)';

  @override
  String get transferImportCsv => 'Import from CSV (Bitwarden/Chrome/1Pass)';

  @override
  String get transferImportOtpauth => 'Import authenticators (otpauth)';

  @override
  String get transferOtpauthNone => 'No otpauth:// links found in that file';

  @override
  String get transferOtpauthMigrationUnsupported =>
      'Google Authenticator export QRs aren\'t supported. Export individual otpauth:// links instead.';

  @override
  String transferDuplicatesWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected items already exist in your vault',
      one: '1 selected item already exists in your vault',
    );
    return '$_temp0';
  }

  @override
  String get transferImportDone => 'Import completed';

  @override
  String get transferExportSelectFolders => 'Folders to export';

  @override
  String get transferNoFolder => 'No folder';

  @override
  String get transferImportSelectTitle => 'Select what to import';

  @override
  String get transferSectionTypes => 'Credential types';

  @override
  String get transferSectionFolders => 'Folders';

  @override
  String get transferImportConfirm => 'Import selection';

  @override
  String get transferNothingSelected => 'Select at least one item to import';

  @override
  String get transferSelectAll => 'Select all';

  @override
  String get transferSelectCredentials => 'Select what to export';

  @override
  String get transferSelectAtLeastOneCredential =>
      'Select at least one credential';

  @override
  String get commonSearch => 'Search…';

  @override
  String get navSync => 'Sync';

  @override
  String get desktopEmptyVault => 'Empty vault';

  @override
  String get desktopCreateFolder => 'Create folder';

  @override
  String get desktopNoCredentials => 'No credentials';

  @override
  String get desktopNoFavorites => 'No favourites';

  @override
  String get desktopSelectFolderTitle => 'Select a folder';

  @override
  String get desktopSelectFolderSub =>
      'Click a folder in the list to see its contents here.';

  @override
  String get desktopSecureVaultTitle => 'Secure Vault';

  @override
  String get desktopSelectCredentialSub =>
      'Select a credential from the list to view or edit its details.';

  @override
  String get desktopNewFolderTooltip => 'New folder';

  @override
  String get desktopNewCredentialTooltip => 'New credential';

  @override
  String get desktopLockVault => 'Lock vault';

  @override
  String get navSecureFiles => 'Secure files';

  @override
  String get secureFilesTitle => 'Secure files';

  @override
  String get secureFilesEmptyTitle => 'No files yet';

  @override
  String get secureFilesEmptyDesc =>
      'Store SSH private keys, credentials.json or any other file, encrypted with your master key.';

  @override
  String get secureFilesAdd => 'Add file';

  @override
  String get secureFilesExport => 'Export / Save';

  @override
  String get secureFilesDelete => 'Delete';

  @override
  String get secureFilesAuthReason => 'Verify your identity to access the file';

  @override
  String get secureFilesDeleteConfirmTitle => 'Delete file?';

  @override
  String secureFilesDeleteConfirmBody(String name) {
    return 'Delete \"$name\"? This permanently removes the encrypted file.';
  }

  @override
  String get secureFilesDeleted => 'File deleted';

  @override
  String get secureFilesSaved => 'File saved';

  @override
  String secureFilesAddedSummary(String name) {
    return 'Added $name';
  }

  @override
  String secureFilesAddError(String msg) {
    return 'Could not add file: $msg';
  }

  @override
  String secureFilesExportError(String msg) {
    return 'Could not export file: $msg';
  }

  @override
  String get secureFilesRename => 'Rename';

  @override
  String get secureFilesRenameTitle => 'Rename file';

  @override
  String get secureFilesMove => 'Move to folder';

  @override
  String get secureFilesMoveTitle => 'Move to folder';

  @override
  String get secureFilesFavorite => 'Favourite';

  @override
  String get secureFilesDropHint => 'Drop files here to add them';

  @override
  String secureFilesAddedCount(int count) {
    return 'Added $count file(s)';
  }

  @override
  String secureFilesTooLarge(String name, String limit) {
    return '\"$name\" exceeds the $limit limit and was skipped';
  }

  @override
  String secureFilesSkippedLarge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files skipped (too large)',
      one: '1 file skipped (too large)',
    );
    return '$_temp0';
  }

  @override
  String secureFilesProcessing(int done, int total) {
    return 'Encrypting $done of $total…';
  }

  @override
  String get secureFilesOptions => 'Options';

  @override
  String get secureFilesPreview => 'Preview';

  @override
  String secureFilesPreviewError(String msg) {
    return 'Could not preview file: $msg';
  }

  @override
  String get secureFilesPreviewUnsupported =>
      'This file can\'t be shown as an image.';

  @override
  String secureFilesFileTypeLabel(String type) {
    return '$type file';
  }

  @override
  String get secureFilesFileGeneric => 'File';

  @override
  String get relativeNow => 'just now';

  @override
  String relativeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String relativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count d ago',
      one: '1 d ago',
    );
    return '$_temp0';
  }

  @override
  String get homeShowHidden => 'Show hidden';

  @override
  String get homeShowActive => 'Show active';

  @override
  String get homeNoHidden => 'You have no hidden credentials';

  @override
  String get detailHide => 'Hide';

  @override
  String get detailUnhide => 'Show in list';

  @override
  String get detailHidden => 'Credential hidden from the main list';

  @override
  String get detailUnhidden => 'Credential visible again';

  @override
  String get unlockApprovalSent =>
      'Request sent to your phone. Approve it there to unlock.';

  @override
  String get unlockApprovalNoDevice =>
      'No phone connected. Open SoloKey on your phone on the same Wi-Fi network.';

  @override
  String get syncTitle => 'Sync device';

  @override
  String get syncServerActive =>
      'Server active. Waiting for the phone to connect…';

  @override
  String get syncServerOff => 'Server off.';

  @override
  String get syncClientConnecting => 'Phone connecting…';

  @override
  String get syncClientDisconnected => 'Phone disconnected. Server waiting…';

  @override
  String get syncPairedOk => 'Pairing completed successfully!';

  @override
  String get syncComparing => 'Comparing local data with the phone…';

  @override
  String get syncBidirOk => 'Two-way sync successful!';

  @override
  String get syncErrorGeneric => 'Error during sync.';

  @override
  String get syncRemoteUnlockReceived => 'Remote unlock request received.';

  @override
  String get syncPairTitle => 'Pair with mobile app';

  @override
  String get syncPairSubtitle =>
      'Sync your passwords in real time securely and unlock this vault using your phone\'s biometrics.';

  @override
  String get syncGenerateQr => 'Generate QR code';

  @override
  String get syncStartingServer => 'Starting local server…';

  @override
  String get syncScanThisQr => 'Scan this QR code';

  @override
  String get syncScanThisQrSub =>
      'Open SoloKey on your phone, go to Sync and scan this code.';

  @override
  String get syncConnectingDevice => 'Connecting to the mobile device…';

  @override
  String get syncLinkedTitle => 'Linked successfully!';

  @override
  String get syncLinkedSub => 'The devices are now securely linked.';

  @override
  String get syncUnderstood => 'Got it';

  @override
  String get syncErrorTitle => 'Pairing error';

  @override
  String get syncUnexpectedError => 'An unexpected error occurred.';

  @override
  String get syncRetry => 'Retry';

  @override
  String get syncComputerLinked => 'Computer linked';

  @override
  String get syncComputerLinkedSub =>
      'This computer is securely paired. You can connect several devices at once by scanning the same QR.';

  @override
  String get syncServerE2eeActive => 'Local E2EE server active';

  @override
  String get syncRemoveLink => 'Remove link';

  @override
  String get syncShowQr => 'Show QR';

  @override
  String get syncWaitingDevices => 'Waiting for devices…';

  @override
  String get syncStatusSyncing => 'Syncing…';

  @override
  String get syncStatusSynced => 'Synced';

  @override
  String get syncStatusConnected => 'Connected';

  @override
  String get syncStarting => 'Starting sync…';

  @override
  String get syncSendingLocal => 'Sending local changes…';

  @override
  String syncSuccessStats(String stats) {
    return 'Sync successful! ($stats)';
  }

  @override
  String get syncBiometricReason => 'Authenticate to unlock your computer';

  @override
  String get syncLinkComputer => 'Pair computer';

  @override
  String get syncLinkComputerSub =>
      'Scan the QR code generated by the SoloKey app on your computer to sync local data.';

  @override
  String get syncScanQrButton => 'Scan QR code';

  @override
  String get syncNegotiating => 'Negotiating encryption keys…';

  @override
  String get syncComputerLinkedExcl => 'Computer linked!';

  @override
  String get syncComputerLinkedExclSub =>
      'Data will now sync securely between devices.';

  @override
  String get syncBack => 'Back';

  @override
  String get syncCouldNotConnect => 'Could not connect to the computer.';

  @override
  String get syncRetryButton => 'Try again';

  @override
  String get syncRemoteUnlockTitle => 'Remote unlock';

  @override
  String get syncRemoteUnlockSub =>
      'Unlock your computer\'s vault using this device\'s biometrics.';

  @override
  String get syncSending => 'Sending…';

  @override
  String get syncUnlockComputer => 'Unlock computer';

  @override
  String get syncUnlockSentBanner => 'Request sent! The vault should unlock.';

  @override
  String get syncAuthCancelled => 'Biometric authentication cancelled.';

  @override
  String get syncNoToken =>
      'Pair again with the desktop UNLOCKED to enable remote unlock.';

  @override
  String get syncVaultTitle => 'Sync vault';

  @override
  String get syncVaultSub =>
      'Exchange and update your credentials both ways on the local network.';

  @override
  String get syncNotPairedYet =>
      'You haven\'t paired yet. Scan the QR on the desktop.';

  @override
  String get syncConnectingComputer => 'Connecting to the computer…';

  @override
  String get syncConnectFailCheck =>
      'Could not connect. Make sure the PC is on and on the same Wi-Fi network.';

  @override
  String get auditIssueTooShortTitle => 'Password too short';

  @override
  String get auditIssueTooShortDesc => 'It has fewer than 8 characters.';

  @override
  String get auditIssueWeakTitle => 'Weak password';

  @override
  String get auditIssueWeakLettersDesc =>
      'Only letters, no numbers or symbols.';

  @override
  String get auditIssueWeakNumbersDesc => 'Only numbers.';

  @override
  String get auditIssueReusedTitle => 'Reused password';

  @override
  String get auditIssueReusedDesc =>
      'This password is used on multiple accounts.';

  @override
  String get auditIssueBreachedTitle => 'Leaked password';

  @override
  String auditIssueBreachedDesc(int count) {
    return 'This password appears in $count data breaches online. Change it now!';
  }

  @override
  String get auditIssueNoPasswordTitle => 'No password saved';

  @override
  String get auditIssueNoPasswordDesc =>
      'This credential has no password stored.';

  @override
  String get auditIssueRotationTitle => 'Rotation required';

  @override
  String auditIssueRotationDesc(int days, int interval) {
    return 'Expired $days days ago (set every $interval days).';
  }

  @override
  String get auditIssueStaleTitle => 'Old password';

  @override
  String auditIssueStaleDesc(int days) {
    return 'Not updated in over 6 months ($days days).';
  }

  @override
  String get notifRotationChannelName => 'Rotation reminders';

  @override
  String get notifRotationChannelDesc =>
      'Alerts when a password should be rotated for security.';

  @override
  String get notifRotationTitle => 'Password rotation required';

  @override
  String notifRotationBody(String title) {
    return 'Your password for \"$title\" has expired. Change it now for security.';
  }

  @override
  String get notifActionChangePassword => 'Change password';

  @override
  String get notifActionSnooze3d => 'Snooze 3 days';

  @override
  String get notifApprovalTitle => 'Approve sign-in';

  @override
  String get notifApprovalBody =>
      'Your computer is asking to unlock. Tap to approve.';

  @override
  String notifApprovalBodyNamed(String name) {
    return 'Unlock \"$name\"? Tap to approve.';
  }

  @override
  String get syncSummaryTitle => 'Last sync';

  @override
  String get syncSummaryNoChanges =>
      'No changes — everything was already up to date';

  @override
  String syncSummaryFrom(String device) {
    return 'from $device';
  }

  @override
  String get syncOtherDevice => 'the other device';

  @override
  String get syncCredentialsLabel => 'Credentials';

  @override
  String get syncFoldersLabel => 'Folders';

  @override
  String syncCountAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '1 new',
      zero: '0 new',
    );
    return '$_temp0';
  }

  @override
  String syncCountUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updated',
      one: '1 updated',
      zero: '0 updated',
    );
    return '$_temp0';
  }

  @override
  String syncCountRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count removed',
      one: '1 removed',
      zero: '0 removed',
    );
    return '$_temp0';
  }

  @override
  String get syncItemsShow => 'Show items';

  @override
  String get syncItemsHide => 'Hide items';

  @override
  String get syncActionAdded => 'Added';

  @override
  String get syncActionUpdated => 'Updated';

  @override
  String get syncActionRemoved => 'Removed';

  @override
  String get syncHistoryTitle => 'Recent syncs';

  @override
  String get syncHistoryEmpty => 'No syncs recorded yet';

  @override
  String get syncRelativeNow => 'just now';

  @override
  String syncRelativeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String syncRelativeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String syncRelativeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count d ago',
      one: '1 d ago',
    );
    return '$_temp0';
  }

  @override
  String get syncBadgeSyncing => 'Syncing…';

  @override
  String get syncBadgeSynced => 'In sync';

  @override
  String get syncBadgeError => 'Sync error';

  @override
  String get syncPairedDevicesTitle => 'Linked devices';

  @override
  String get syncNeverSynced => 'Never synced';

  @override
  String syncLastSyncLabel(String when) {
    return 'Last sync: $when';
  }

  @override
  String get syncUnlinkDevice => 'Unlink';

  @override
  String get notifSyncTitle => 'Vault synced';

  @override
  String notifSyncBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes synced',
      one: '1 change synced',
    );
    return '$_temp0';
  }
}
