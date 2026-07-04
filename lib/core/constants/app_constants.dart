abstract final class AppConstants {
  // Secure storage keys
  static const String kMasterKeyConfig = 'master_key_config';
  static const String kVaultMetadata = 'vault_metadata';
  static const String kSecuritySettings = 'security_settings';

  // Crypto
  static const int kDerivedKeyLengthBytes = 32; // 256-bit
  static const int kIvLengthBytes = 12;         // GCM standard
  static const int kSaltLengthBytes = 32;       // 256-bit salt

  // Session
  static const int kDefaultAutoLockMinutes = 5;
  static const int kDefaultClipboardClearSeconds = 30;

  // App metadata (mantener en sync con `version:` de pubspec.yaml).
  static const String appVersion = '1.0.0';
}
