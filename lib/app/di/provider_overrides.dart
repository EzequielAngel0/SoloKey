import 'package:flutter_riverpod/misc.dart';

import '../../features/credentials/application/credential_use_cases.dart';
import '../../features/credentials/application/credentials_provider.dart';
import '../../features/folders/application/folders_provider.dart';
import '../../features/folders/domain/repositories/i_folder_repository.dart';
import '../../features/secure_files/application/secure_files_provider.dart';
import '../../features/secure_files/domain/repositories/i_secure_file_repository.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/vault_access/application/setup_vault_use_case.dart';
import '../../features/vault_access/application/unlock_vault_use_case.dart';
import '../../features/vault_access/application/vault_state_provider.dart';
import 'injection.dart';

/// Riverpod 3 reintenta solo un provider que falla; la v1 no lo hacía y una
/// bóveda que no se descifra no mejora reintentando. Se pasa como `retry` a
/// cada `ProviderScope` (la app y las pruebas) para conservar ese comportamiento.
Duration? noProviderRetry(int retryCount, Object error) => null;

/// Bridges get_it singletons into Riverpod providers.
/// Called once at app startup after [configureDependencies].
List<Override> buildProviderOverrides() => [
      setupVaultUseCaseProvider
          .overrideWithValue(getIt<SetupVaultUseCase>()),
      unlockVaultUseCaseProvider
          .overrideWithValue(getIt<UnlockVaultUseCase>()),
      getCredentialsUseCaseProvider
          .overrideWithValue(getIt<GetCredentialsUseCase>()),
      saveCredentialUseCaseProvider
          .overrideWithValue(getIt<SaveCredentialUseCase>()),
      deleteCredentialUseCaseProvider
          .overrideWithValue(getIt<DeleteCredentialUseCase>()),
      settingsRepositoryProvider
          .overrideWithValue(getIt<ISettingsRepository>()),
      folderRepositoryProvider
          .overrideWithValue(getIt<IFolderRepository>()),
      secureFileRepositoryProvider
          .overrideWithValue(getIt<ISecureFileRepository>()),
    ];
