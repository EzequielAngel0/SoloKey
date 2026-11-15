import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../core/infrastructure/database/app_database.dart';
import '../../core/infrastructure/database/daos/category_dao.dart';
import '../../core/infrastructure/database/daos/credential_dao.dart';
import '../../features/sync/domain/i_sync_service.dart';
import '../../features/sync/infrastructure/sync_service.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  /// En Android, la v10 migra sola lo que la v9 guardó con
  /// EncryptedSharedPreferences (la v11 ya no sabe leerlo: PLA-4).
  /// `resetOnError: false` porque su default borra TODO el almacén ante un
  /// error de lectura, y ahí vive la configuración de la bóveda.
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          resetOnError: false,
          migrateOnAlgorithmChange: true,
          migrateWithBackup: true,
        ),
      );

  @lazySingleton
  CredentialDao credentialDao(AppDatabase db) => db.credentialDao;

  @lazySingleton
  CategoryDao categoryDao(AppDatabase db) => db.categoryDao;

  /// Registers the concrete [SyncService] singleton ALSO under its UI-facing
  /// interface, so the pairing screen/notifier can resolve `getIt<ISyncService>()`
  /// (and tests can register a fake by that interface). Same instance — this is
  /// a test seam, not a behavior change.
  @lazySingleton
  ISyncService syncService(SyncService service) => service;
}
