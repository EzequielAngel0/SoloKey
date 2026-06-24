import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../secure_files/domain/repositories/i_secure_file_repository.dart';

/// Wipes the entire vault: locks the in-RAM key, clears every DB table and
/// deletes all secure-storage entries (master key config, biometric key, sync
/// keys, brute-force counters…). After this, the vault is back to setup state.
///
/// Used by the anti brute-force guard when the configured failed-attempt
/// threshold is reached.
@lazySingleton
class WipeVaultUseCase {
  WipeVaultUseCase(this._storage, this._db, this._session, this._secureFiles);

  final FlutterSecureStorage _storage;
  final AppDatabase _db;
  final SessionManager _session;
  final ISecureFileRepository _secureFiles;

  Future<void> execute() async {
    // Delete encrypted-on-disk files before locking the key — best-effort, the
    // blobs become undecryptable garbage once the key is gone anyway.
    await _secureFiles.deleteAll();
    _session.lock();
    await _db.wipeAllData();
    await _storage.deleteAll();
  }
}
