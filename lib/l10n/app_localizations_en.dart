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
  String get commonLoading => 'Loading…';

  @override
  String get folderNewSubfolder => 'New subfolder';

  @override
  String get folderDeleteTitle => 'Delete folder';

  @override
  String folderDeleteBodyOrphan(String name) {
    return 'Delete \"$name\"? Its credentials will be orphaned or moved to the root.';
  }

  @override
  String folderDeleteBodyReleased(String name) {
    return 'Delete \"$name\"? Its subfolders or credentials will be released.';
  }

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
}
