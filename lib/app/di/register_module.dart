import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../core/infrastructure/vault/data_location.dart';
import '../../core/infrastructure/vault/file_secure_storage.dart';
import '../../features/sync/domain/i_sync_service.dart';
import '../../features/sync/infrastructure/sync_service.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  /// En Android, la v10 migra sola lo que la v9 guardó con
  /// EncryptedSharedPreferences (la v11 ya no sabe leerlo: PLA-4).
  /// `resetOnError: false` porque su default borra TODO el almacén ante un
  /// error de lectura, y ahí vive la configuración de la bóveda.
  /// NO usar `migrateWithBackup: true`: en 10.3.4 se salta la migración de
  /// EncryptedSharedPreferences y la app arranca como bóveda nueva (probado
  /// en el emulador el 2026-11-15).
  ///
  /// Con datos aislados (NUC-6, `SOLOKEY_DATA_DIR`, nunca en release) el almacen es un JSON en esa carpeta: las
  /// pruebas no tocan el almacen real del sistema.
  FlutterSecureStorage get secureStorage => isIsolatedDataDir
      ? FileSecureStorage()
      : const FlutterSecureStorage(
          aOptions: AndroidOptions(
            resetOnError: false,
            migrateOnAlgorithmChange: true,
          ),
        );

  /// Registers the concrete [SyncService] singleton ALSO under its UI-facing
  /// interface, so the pairing screen/notifier can resolve `getIt<ISyncService>()`
  /// (and tests can register a fake by that interface). Same instance — this is
  /// a test seam, not a behavior change.
  @lazySingleton
  ISyncService syncService(SyncService service) => service;
}
