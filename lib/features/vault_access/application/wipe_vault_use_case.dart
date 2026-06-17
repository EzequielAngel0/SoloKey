import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/security/session_manager.dart';

/// Wipes the entire vault: locks the in-RAM key, clears every DB table and
/// deletes all secure-storage entries (master key config, biometric key, sync
/// keys, brute-force counters…). After this, the vault is back to setup state.
///
/// Used by the anti brute-force guard when the configured failed-attempt
/// threshold is reached.
@lazySingleton
class WipeVaultUseCase {
  WipeVaultUseCase(this._storage, this._db, this._session);

  final FlutterSecureStorage _storage;
  final AppDatabase _db;
  final SessionManager _session;

  Future<void> execute() async {
    _session.lock();
    await _db.wipeAllData();
    await _storage.deleteAll();
  }
}
