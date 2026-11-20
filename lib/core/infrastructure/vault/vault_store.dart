import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../constants/app_constants.dart';
import '../rust/api/error.dart';
import '../rust/api/vault.dart' as core;
import '../security/session_manager.dart';
import 'data_location.dart';

/// Tipos de registro de la boveda v2 (los mismos que escribe la migracion de la v1, `migrate_v1.rs`).
abstract final class RecordKind {
  static const credential = 'credential';
  static const folder = 'folder';
  static const category = 'category';
  static const history = 'history';
  static const file = 'file';
}

/// Argon2id de la boveda: los de la v1 (ADR-0003), el piso que acepta el nucleo (SEC-012).
const core.KdfConfig kVaultKdf =
    core.KdfConfig(memoryKib: 65536, iterations: 3, parallelism: 4);

/// Lo que queda del almacen seguro de la v1 en la copia previa (nada secreto: ni la clave de la biometria ni la
/// contrasena de los respaldos programados ni las llaves de sync).
const List<String> _v1BackupKeys = [
  AppConstants.kMasterKeyConfig,
  AppConstants.kVaultMetadata,
  AppConstants.kSecuritySettings,
  'recovery_key_hash',
  'recovery_encrypted_master',
];

/// Claves de la v1 que sobran tras migrar (la v2 guarda todo eso en su cabecera).
const List<String> _v1ObsoleteKeys = [
  AppConstants.kMasterKeyConfig,
  AppConstants.kVaultMetadata,
  'recovery_key_hash',
  'recovery_encrypted_master',
  'bio_master_key',
  'master_password',
  // Desbloqueo por WiFi: envolvia la clave de la v1, que ya no existe (hay que volver a emparejar).
  'solokey_remote_unlock_wrapped',
];

/// La v1 tenia codigo de recuperacion y ya no sirve: la interfaz pide generar uno nuevo (C).
const String kRecoveryResetNeeded = 'recovery_reset_needed';

/// La boveda v2 del nucleo Rust (NUC-2): abrirla, migrar la v1 una vez y leer o escribir registros.
/// El handle abierto vive en [SessionManager]; bloquear lo cierra.
@lazySingleton
class VaultStore {
  VaultStore(this._session, this._storage);

  final SessionManager _session;
  final FlutterSecureStorage _storage;

  DataLocation? _location;
  String? _createdRecoveryCode;

  Future<DataLocation> location() async =>
      _location ??= await resolveDataLocation();

  bool get isOpen => _session.hasActiveKey;

  /// Hay boveda: la v2, o una v1 que se migra al desbloquear.
  Future<bool> exists() async {
    final loc = await location();
    if (await _hasV2(loc)) return true;
    return _hasV1(loc);
  }

  Future<bool> _hasV2(DataLocation loc) async =>
      await core.vaultState(dataDir: loc.dataDir) == core.VaultState.present;

  Future<bool> _hasV1(DataLocation loc) async =>
      File(loc.v1Db).existsSync() &&
      await _storage.read(key: AppConstants.kMasterKeyConfig) != null;

  /// Crea la boveda y la deja abierta. El codigo de recuperacion se toma una vez con [takeCreatedRecoveryCode].
  Future<void> create(String password) async {
    final loc = await location();
    final created = await core.vaultCreate(
      dataDir: loc.dataDir,
      password: utf8.encode(password),
      kdf: kVaultKdf,
    );
    _createdRecoveryCode = created.recoveryCode;
    _session.attach(created.vault);
  }

  /// El codigo de la boveda recien creada, una sola vez.
  String? takeCreatedRecoveryCode() {
    final c = _createdRecoveryCode;
    _createdRecoveryCode = null;
    return c;
  }

  /// Abre con la maestra. Si solo hay v1, la migra antes (copia previa, verificacion; si falla, la v1 queda intacta).
  /// Maestra incorrecta: [CoreFailure] con [FailureCode.wrongPassword].
  Future<core.MigrationSummary?> open(String password) async {
    final loc = await location();
    core.MigrationSummary? migrated;
    if (!await _hasV2(loc) && await _hasV1(loc)) {
      migrated = await _migrate(loc, password);
    }
    final handle = await core.vaultOpen(
      dataDir: loc.dataDir,
      password: utf8.encode(password),
    );
    _session.attach(handle);
    return migrated;
  }

  Future<core.MigrationSummary> _migrate(
      DataLocation loc, String password) async {
    final all = await _storage.readAll();
    final config = all[AppConstants.kMasterKeyConfig]!;
    final backup = [
      for (final k in _v1BackupKeys)
        if (all[k] != null) (k, all[k]!),
    ];
    final summary = await core.migrateFromV1(
      v1DbPath: loc.v1Db,
      v1SecureFilesDir: loc.v1SecureFiles,
      masterKeyConfigJson: config,
      secureStorageBackup: backup,
      password: password,
      dataDir: loc.dataDir,
      backupDir: loc.backupDir(DateTime.now()),
    );
    for (final k in _v1ObsoleteKeys) {
      await _storage.delete(key: k);
    }
    if (summary.v1HadRecovery) {
      await _storage.write(key: kRecoveryResetNeeded, value: '1');
    }
    return summary;
  }

  /// Abre con la clave guardada tras la biometria (la de [SessionManager.keyCopy]).
  Future<void> openWithKey(Uint8List key) async {
    final loc = await location();
    final handle = await core.vaultOpenWithKey(dataDir: loc.dataDir, key: key);
    _session.attach(handle);
  }

  /// Si el codigo de recuperacion sirve, sin cambiar nada.
  Future<bool> checkRecovery(String code) async {
    final loc = await location();
    try {
      await core.vaultCheckRecovery(dataDir: loc.dataDir, recoveryCode: code);
      return true;
    } on CoreFailure catch (e) {
      if (e.code == FailureCode.wrongPassword ||
          e.code == FailureCode.noRecovery) {
        return false;
      }
      rethrow;
    }
  }

  /// Abre con el codigo de recuperacion y pone una maestra nueva.
  Future<void> recover(String code, String newPassword) async {
    final loc = await location();
    final handle = await core.vaultRecover(
      dataDir: loc.dataDir,
      recoveryCode: code,
      newPassword: utf8.encode(newPassword),
      kdf: kVaultKdf,
    );
    _session.attach(handle);
  }

  /// Bloquea: el nucleo pone a cero la clave.
  void lock() => _session.lock();

  /// Borra la boveda v2 del disco (bloquea antes).
  Future<void> wipe() async {
    _session.lock();
    final loc = await location();
    await core.vaultWipe(dataDir: loc.dataDir);
  }

  // ── Registros ────────────────────────────────────────────────────────────

  core.VaultHandle get _handle => _session.handle;

  /// Los registros vivos de [kind], como el JSON de cada entidad.
  Future<List<Map<String, dynamic>>> list(String kind) async {
    final records = await _handle.list(kind: kind, includeDeleted: false);
    return [for (final r in records) jsonDecode(r.data) as Map<String, dynamic>];
  }

  /// Un registro vivo de [kind], o null.
  Future<Map<String, dynamic>?> get(String kind, String id) async {
    final r = await _handle.get_(id: id);
    if (r == null || r.deleted || r.kind != kind) return null;
    return jsonDecode(r.data) as Map<String, dynamic>;
  }

  /// Inserta o reemplaza en una transaccion. `updatedAt` (LWW de la sync) es ahora.
  Future<void> put(String kind, Map<String, Map<String, dynamic>> byId) async {
    if (byId.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _handle.put(records: [
      for (final e in byId.entries)
        core.VaultRecord(
          id: e.key,
          kind: kind,
          updatedAt: now,
          deleted: false,
          data: jsonEncode(e.value),
        ),
    ]);
  }

  /// Borra dejando lapida (la sync propaga el borrado). [at] = cuando, por defecto ahora.
  Future<void> remove(String id, {int? at}) =>
      _handle.remove(id: id, at: at ?? DateTime.now().millisecondsSinceEpoch);

  /// Los registros de [kind] tal cual, lapidas incluidas (manifiesto de la sync).
  Future<List<core.VaultRecord>> records(String kind) =>
      _handle.list(kind: kind, includeDeleted: true);

  /// Un registro tal cual, lapida incluida, o null.
  Future<core.VaultRecord?> record(String id) => _handle.get_(id: id);

  /// Escribe registros que llegan de la sync conservando su `updatedAt` (LWW).
  Future<void> putSynced(List<core.VaultRecord> records) async {
    if (records.isEmpty) return;
    await _handle.put(records: records);
  }

  Future<void> putBlob(String id, Uint8List bytes) =>
      _handle.putBlob(id: id, bytes: bytes);

  Future<Uint8List?> getBlob(String id) => _handle.getBlob(id: id);

  Future<void> deleteBlob(String id) => _handle.deleteBlob(id: id);

  /// Vacia la boveda (misma maestra).
  Future<void> clear() => _handle.clear();
}
