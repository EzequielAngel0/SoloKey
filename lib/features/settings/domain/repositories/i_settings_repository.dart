import 'package:solokey/features/settings/domain/entities/app_security_settings.dart';

abstract interface class ISettingsRepository {
  Future<AppSecuritySettings> getSettings();
  Future<void> saveSettings(AppSecuritySettings settings);
}
