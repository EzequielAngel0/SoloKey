// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

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
import '../../core/infrastructure/database/app_database.dart' as _i1042;
import '../../core/infrastructure/database/daos/category_dao.dart' as _i403;
import '../../core/infrastructure/database/daos/credential_dao.dart' as _i753;
import '../../core/infrastructure/database/daos/folder_dao.dart' as _i496;
import '../../core/infrastructure/database/daos/password_history_dao.dart'
    as _i386;
import '../../core/infrastructure/security/app_lifecycle_observer.dart'
    as _i301;
import '../../core/infrastructure/security/double_envelope_service.dart'
    as _i971;
import '../../core/infrastructure/security/i_security_service.dart' as _i1023;
import '../../core/infrastructure/security/security_service_impl.dart'
    as _i1063;
import '../../core/infrastructure/security/session_manager.dart' as _i795;
import '../../core/services/autofill_service.dart' as _i923;
import '../../core/services/biometric_auth_service.dart' as _i455;
import '../../core/services/csv_import_service.dart' as _i764;
import '../../core/services/notification_service.dart' as _i4;
import '../../core/services/recovery_service.dart' as _i323;
import '../../core/services/security_audit_service.dart' as _i400;
import '../../core/services/ssh_key_generator_service.dart' as _i972;
import '../../core/services/vault_export_service.dart' as _i332;
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
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/infrastructure/settings_repository_impl.dart'
    as _i569;
import '../../features/sync/infrastructure/sync_service.dart' as _i706;
import '../../features/vault_access/application/setup_vault_use_case.dart'
    as _i229;
import '../../features/vault_access/application/unlock_vault_use_case.dart'
    as _i155;
import '../../features/vault_access/domain/repositories/i_vault_repository.dart'
    as _i286;
import '../../features/vault_access/infrastructure/vault_repository_impl.dart'
    as _i939;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i1042.AppDatabase>(() => _i1042.AppDatabase());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i795.SessionManager>(() => _i795.SessionManager());
    gh.lazySingleton<_i923.AutofillSettingsService>(
      () => _i923.AutofillSettingsService(),
    );
    gh.lazySingleton<_i455.BiometricAuthService>(
      () => _i455.BiometricAuthService(),
    );
    gh.lazySingleton<_i972.SshKeyGeneratorService>(
      () => _i972.SshKeyGeneratorService(),
    );
    gh.lazySingleton<_i1023.ISecurityService>(
      () => _i1063.SecurityServiceImpl(),
    );
    gh.lazySingleton<_i4.NotificationService>(
      () => _i4.NotificationService(gh<_i1042.AppDatabase>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i753.CredentialDao>(
      () => registerModule.credentialDao(gh<_i1042.AppDatabase>()),
    );
    gh.lazySingleton<_i403.CategoryDao>(
      () => registerModule.categoryDao(gh<_i1042.AppDatabase>()),
    );
    gh.lazySingleton<_i496.FolderDao>(
      () => _i496.FolderDao(gh<_i1042.AppDatabase>()),
    );
    gh.lazySingleton<_i386.PasswordHistoryDao>(
      () => _i386.PasswordHistoryDao(gh<_i1042.AppDatabase>()),
    );
    gh.lazySingleton<_i657.ISettingsRepository>(
      () => _i569.SettingsRepositoryImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i286.IVaultRepository>(
      () => _i939.VaultRepositoryImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i229.SetupVaultUseCase>(
      () => _i229.SetupVaultUseCase(
        gh<_i286.IVaultRepository>(),
        gh<_i657.ISettingsRepository>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i155.UnlockVaultUseCase>(
      () => _i155.UnlockVaultUseCase(
        gh<_i286.IVaultRepository>(),
        gh<_i657.ISettingsRepository>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i366.ICategoryRepository>(
      () => _i316.CategoryRepositoryImpl(gh<_i403.CategoryDao>()),
    );
    gh.lazySingleton<_i1067.IFolderRepository>(
      () => _i759.FolderRepositoryImpl(gh<_i496.FolderDao>()),
    );
    gh.lazySingleton<_i366.ICredentialRepository>(
      () => _i316.CredentialRepositoryImpl(
        gh<_i753.CredentialDao>(),
        gh<_i386.PasswordHistoryDao>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i971.DoubleEnvelopeService>(
      () => _i971.DoubleEnvelopeService(
        gh<_i1023.ISecurityService>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i923.AutofillQueryHandler>(
      () => _i923.AutofillQueryHandler(
        gh<_i366.ICredentialRepository>(),
        gh<_i795.SessionManager>(),
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
    gh.lazySingleton<_i764.CsvImportService>(
      () => _i764.CsvImportService(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i400.SecurityAuditService>(
      () => _i400.SecurityAuditService(gh<_i366.ICredentialRepository>()),
    );
    gh.lazySingleton<_i885.ClipboardService>(
      () => _i885.ClipboardService(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i301.AppLifecycleObserver>(
      () => _i301.AppLifecycleObserver(
        gh<_i795.SessionManager>(),
        gh<_i657.ISettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i706.SyncService>(
      () => _i706.SyncService(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i1042.AppDatabase>(),
        gh<_i1023.ISecurityService>(),
        gh<_i286.IVaultRepository>(),
      ),
    );
    gh.lazySingleton<_i332.VaultExportService>(
      () => _i332.VaultExportService(
        gh<_i366.ICredentialRepository>(),
        gh<_i1067.IFolderRepository>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i323.RecoveryService>(
      () => _i323.RecoveryService(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i1023.ISecurityService>(),
        gh<_i795.SessionManager>(),
        gh<_i286.IVaultRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
