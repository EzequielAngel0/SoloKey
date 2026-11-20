// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/infrastructure/clipboard/clipboard_service.dart' as _i885;
import '../../core/infrastructure/security/app_lifecycle_observer.dart'
    as _i301;
import '../../core/infrastructure/security/double_envelope_service.dart'
    as _i971;
import '../../core/infrastructure/security/i_security_service.dart' as _i1023;
import '../../core/infrastructure/security/security_service_impl.dart'
    as _i1063;
import '../../core/infrastructure/security/session_manager.dart' as _i795;
import '../../core/infrastructure/vault/vault_store.dart' as _i93;
import '../../core/services/biometric_auth_service.dart' as _i455;
import '../../core/services/brute_force_guard.dart' as _i714;
import '../../core/services/csv_import_service.dart' as _i764;
import '../../core/services/notification_service.dart' as _i4;
import '../../core/services/recovery_service.dart' as _i323;
import '../../core/services/rotation_schedule.dart' as _i781;
import '../../core/services/scheduled_backup_service.dart' as _i1009;
import '../../core/services/security_audit_service.dart' as _i400;
import '../../core/services/ssh_key_generator_service.dart' as _i972;
import '../../core/services/vault_export_service.dart' as _i332;
import '../../features/autofill/infrastructure/autofill_fetch_service.dart'
    as _i1059;
import '../../features/autofill/infrastructure/autofill_settings_service.dart'
    as _i479;
import '../../features/credentials/application/credential_use_cases.dart'
    as _i472;
import '../../features/credentials/domain/repositories/i_credential_repository.dart'
    as _i366;
import '../../features/credentials/infrastructure/credential_repository_impl.dart'
    as _i316;
import '../../features/folders/domain/repositories/i_folder_repository.dart'
    as _i1067;
import '../../features/folders/infrastructure/folder_repository_impl.dart'
    as _i759;
import '../../features/secure_files/domain/repositories/i_secure_file_repository.dart'
    as _i112;
import '../../features/secure_files/infrastructure/secure_file_repository_impl.dart'
    as _i701;
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/infrastructure/settings_repository_impl.dart'
    as _i569;
import '../../features/sync/domain/i_sync_service.dart' as _i1055;
import '../../features/sync/infrastructure/sync_service.dart' as _i706;
import '../../features/vault_access/application/setup_vault_use_case.dart'
    as _i229;
import '../../features/vault_access/application/unlock_vault_use_case.dart'
    as _i155;
import '../../features/vault_access/application/wipe_vault_use_case.dart'
    as _i1;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i795.SessionManager>(() => _i795.SessionManager());
    gh.lazySingleton<_i455.BiometricAuthService>(
      () => _i455.BiometricAuthService(),
    );
    gh.lazySingleton<_i972.SshKeyGeneratorService>(
      () => _i972.SshKeyGeneratorService(),
    );
    gh.lazySingleton<_i479.AutofillSettingsService>(
      () => _i479.AutofillSettingsService(),
    );
    gh.lazySingleton<_i714.BruteForceGuard>(
      () => _i714.BruteForceGuard(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i1023.ISecurityService>(
      () => _i1063.SecurityServiceImpl(),
    );
    gh.lazySingleton<_i657.ISettingsRepository>(
      () => _i569.SettingsRepositoryImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i93.VaultStore>(
      () => _i93.VaultStore(
        gh<_i795.SessionManager>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i1067.IFolderRepository>(
      () => _i759.FolderRepositoryImpl(gh<_i93.VaultStore>()),
    );
    gh.lazySingleton<_i971.DoubleEnvelopeService>(
      () => _i971.DoubleEnvelopeService(
        gh<_i1023.ISecurityService>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i885.ClipboardService>(
      () => _i885.ClipboardService(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i706.SyncService>(
      () => _i706.SyncService(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i93.VaultStore>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i301.AppLifecycleObserver>(
      () => _i301.AppLifecycleObserver(
        gh<_i795.SessionManager>(),
        gh<_i657.ISettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i229.SetupVaultUseCase>(
      () => _i229.SetupVaultUseCase(
        gh<_i93.VaultStore>(),
        gh<_i657.ISettingsRepository>(),
        gh<_i795.SessionManager>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i781.RotationSchedule>(
      () => _i781.RotationSchedule(gh<_i93.VaultStore>()),
    );
    gh.lazySingleton<_i1.WipeVaultUseCase>(
      () => _i1.WipeVaultUseCase(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i93.VaultStore>(),
        gh<_i781.RotationSchedule>(),
      ),
    );
    gh.lazySingleton<_i323.RecoveryService>(
      () => _i323.RecoveryService(
        gh<_i93.VaultStore>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i4.NotificationService>(
      () => _i4.NotificationService(gh<_i781.RotationSchedule>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i112.ISecureFileRepository>(
      () => _i701.SecureFileRepositoryImpl(gh<_i93.VaultStore>()),
    );
    gh.lazySingleton<_i366.ICategoryRepository>(
      () => _i316.CategoryRepositoryImpl(gh<_i93.VaultStore>()),
    );
    gh.lazySingleton<_i1055.ISyncService>(
      () => registerModule.syncService(gh<_i706.SyncService>()),
    );
    gh.lazySingleton<_i366.ICredentialRepository>(
      () => _i316.CredentialRepositoryImpl(
        gh<_i93.VaultStore>(),
        gh<_i781.RotationSchedule>(),
      ),
    );
    gh.lazySingleton<_i472.GetCredentialsUseCase>(
      () => _i472.GetCredentialsUseCase(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i472.SaveCredentialUseCase>(
      () => _i472.SaveCredentialUseCase(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i472.DeleteCredentialUseCase>(
      () => _i472.DeleteCredentialUseCase(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i155.UnlockVaultUseCase>(
      () => _i155.UnlockVaultUseCase(
        gh<_i93.VaultStore>(),
        gh<_i657.ISettingsRepository>(),
        gh<_i795.SessionManager>(),
        gh<_i714.BruteForceGuard>(),
        gh<_i1.WipeVaultUseCase>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i781.RotationSchedule>(),
      ),
    );
    gh.lazySingleton<_i1059.AutofillFetchService>(
      () => _i1059.AutofillFetchService(
        gh<_i366.ICredentialRepository>(),
        gh<_i795.SessionManager>(),
        gh<_i93.VaultStore>(),
      ),
    );
    gh.lazySingleton<_i764.CsvImportService>(
      () => _i764.CsvImportService(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i400.SecurityAuditService>(
      () => _i400.SecurityAuditService(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i332.VaultExportService>(
      () => _i332.VaultExportService(
        gh<_i366.ICredentialRepository>(),
        gh<_i1067.IFolderRepository>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i1009.ScheduledBackupService>(
      () => _i1009.ScheduledBackupService(
        gh<_i332.VaultExportService>(),
        gh<_i657.ISettingsRepository>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i795.SessionManager>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
