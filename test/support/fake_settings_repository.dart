import 'package:password_manager/features/settings/domain/entities/app_security_settings.dart';
import 'package:password_manager/features/settings/domain/repositories/i_settings_repository.dart';

/// In-memory [ISettingsRepository] for widget tests: hands back [settings] and
/// records every save, so tests can assert persistence without get_it/Keystore.
class FakeSettingsRepository implements ISettingsRepository {
  FakeSettingsRepository([AppSecuritySettings? initial])
      : settings = initial ?? AppSecuritySettings.defaults();

  AppSecuritySettings settings;

  @override
  Future<AppSecuritySettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSecuritySettings s) async => settings = s;
}
