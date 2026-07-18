import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/domain/crypto_utils.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../secure_files/domain/entities/secure_file.dart';
import '../../secure_files/domain/repositories/i_secure_file_repository.dart';
import '../domain/sync_summary.dart';

/// DTO exchanged over the E2EE WebSocket channel for delta-sync.
/// Each item carries enough metadata for LWW comparison plus the
/// full row data needed for upsert on the receiving side.
class SyncManifestItem {
  const SyncManifestItem({
    required this.id,
    required this.updatedAt,
    required this.isDeleted,
    this.rowData,
  });

  /// Unique record ID (UUID v4).
  final String id;

  /// Unix timestamp in milliseconds — used for LWW comparison.
  final int updatedAt;

  /// Tombstone flag — true if the record was deleted on the source device.
  final bool isDeleted;

  /// Full row data as JSON map. `null` when only sending the manifest
  /// (first handshake) or when [isDeleted] is true.
  final Map<String, dynamic>? rowData;

  Map<String, dynamic> toJson() => {
        'id': id,
        'updated_at': updatedAt,
        'is_deleted': isDeleted,
        if (rowData != null) 'row_data': rowData,
      };

  factory SyncManifestItem.fromJson(Map<String, dynamic> json) =>
      SyncManifestItem(
        id: json['id'] as String,
        updatedAt: json['updated_at'] as int,
        isDeleted: json['is_deleted'] as bool? ?? false,
        rowData: json['row_data'] as Map<String, dynamic>?,
      );
}

/// Result of a delta-sync round.
class DeltaSyncResult {
  const DeltaSyncResult({
    required this.received,
    required this.sent,
    required this.conflicts,
  });

  /// Number of rows received and applied from the remote device.
  final int received;

  /// Number of rows sent to the remote device.
  final int sent;

  /// Number of LWW conflicts resolved (remote wins counted as "received",
  /// local wins counted as "sent").
  final int conflicts;
}

/// Manages delta synchronization between two SoloKey Secure Vault instances.
///
/// **Protocol overview:**
/// 1. Both devices exchange a *manifest* — list of `{id, updatedAt, isDeleted}`.
/// 2. Each side compares the manifest against its local DB.
/// 3. Items where the remote `updatedAt` is newer → request full row from peer.
/// 4. Items where the local `updatedAt` is newer → push full row to peer.
/// 5. Items only present locally → push to peer as new rows.
/// 6. Items only present remotely → receive from peer as new rows.
///
/// **Conflict resolution:** Last-Write-Wins (LWW) on `updatedAt` timestamps.
/// Tie-breaker: alphabetically smaller UUID wins (deterministic on both sides).
class DeltaSyncManager {
  DeltaSyncManager(this._db, this._securityService, this._sessionManager,
      {ISecureFileRepository? secureFiles})
      : _secureFiles = secureFiles;

  final AppDatabase _db;
  final ISecurityService _securityService;
  final SessionManager _sessionManager;

  /// Storage/crypto for secure-file contents. Optional so pure-DB tests can
  /// construct the manager without it — when null, the file lane of the sync
  /// degrades to an empty manifest and apply becomes a no-op.
  final ISecureFileRepository? _secureFiles;

  /// Returns the in-RAM master key, or throws if the vault is locked.
  /// Required to re-encrypt credential payloads from the wire format to the
  /// local vault key (and vice-versa). See [_credentialEntryToJson].
  Uint8List _requireMasterKey() {
    final key = _sessionManager.getKeyCopy();
    if (key == null) {
      throw StateError(
          'La boveda debe estar desbloqueada para sincronizar credenciales.');
    }
    return key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Building the local manifest
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds a manifest of all local credential entries. The manifest only
  /// carries `{id, updatedAt, isDeleted}`; full (re-keyed) rows are exchanged
  /// later via the delta/push steps.
  Future<List<SyncManifestItem>> buildCredentialManifest() async {
    final rows = await _db.credentialEntries.select().get();
    return rows.map((row) {
      return SyncManifestItem(
        id: row.id,
        updatedAt: row.updatedAt,
        isDeleted: false,
      );
    }).toList();
  }

  /// Builds a manifest of all local secure-file entries (metadata only; the
  /// encrypted contents travel later in the delta/push steps, re-keyed).
  /// Empty when no [ISecureFileRepository] was provided.
  Future<List<SyncManifestItem>> buildSecureFileManifest() async {
    if (_secureFiles == null) return const [];
    final rows = await _db.secureFileDao.getAll();
    return rows
        .map((row) => SyncManifestItem(
              id: row.id,
              updatedAt: row.updatedAt,
              isDeleted: false,
            ))
        .toList();
  }

  /// Builds a manifest of all local folder entries.
  Future<List<SyncManifestItem>> buildFolderManifest() async {
    final rows = await _db.folderEntries.select().get();
    return rows.map((row) {
      return SyncManifestItem(
        id: row.id,
        updatedAt: row.createdAt, // Folders use createdAt as the version field
        isDeleted: false,
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Computing deltas
  // ─────────────────────────────────────────────────────────────────────────

  /// Compares a remote manifest against local data and returns:
  /// - `toRequest`: IDs we need full row data for (remote is newer or new).
  /// - `toPush`: full local rows that the remote device needs.
  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeCredentialDeltas(List<SyncManifestItem> remoteManifest) async {
    final localMap = <String, CredentialEntry>{};
    final localRows = await _db.credentialEntries.select().get();
    for (final row in localRows) {
      localMap[row.id] = row;
    }

    final toRequest = <String>[];
    final toPush = <SyncManifestItem>[];
    final seenIds = <String>{};

    for (final remote in remoteManifest) {
      seenIds.add(remote.id);
      final local = localMap[remote.id];

      if (local == null) {
        // New on remote → request full data
        if (!remote.isDeleted) {
          toRequest.add(remote.id);
        }
      } else {
        // Both have it → LWW
        final resolution = resolveSyncConflict(
          localUpdatedAt: local.updatedAt,
          remoteUpdatedAt: remote.updatedAt,
          localId: local.id,
          remoteId: remote.id,
        );

        if (resolution == SyncConflictWinner.remote) {
          if (remote.isDeleted) {
            // Remote deleted it — apply deletion locally
            await _db.credentialDao.deleteById(remote.id);
          } else {
            toRequest.add(remote.id);
          }
        } else {
          // Local wins — push to remote
          final item = await _credentialPushItemOrNull(local);
          if (item != null) toPush.add(item);
        }
      }
    }

    // Items only present locally → push to remote
    for (final entry in localMap.entries) {
      if (!seenIds.contains(entry.key)) {
        final item = await _credentialPushItemOrNull(entry.value);
        if (item != null) toPush.add(item);
      }
    }

    return (toRequest: toRequest, toPush: toPush);
  }

  /// Builds a push item for [row], re-keying its payload. Returns null if the
  /// row cannot be decrypted with the local key (e.g. an orphan left by a past
  /// broken sync) — such rows are skipped instead of aborting the whole sync.
  Future<SyncManifestItem?> _credentialPushItemOrNull(
      CredentialEntry row) async {
    try {
      return SyncManifestItem(
        id: row.id,
        updatedAt: row.updatedAt,
        isDeleted: false,
        rowData: await _credentialEntryToJson(row),
      );
    } catch (_) {
      return null;
    }
  }

  /// Same as [computeCredentialDeltas] but for folder entries.
  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeFolderDeltas(List<SyncManifestItem> remoteManifest) async {
    final localMap = <String, FolderEntry>{};
    final localRows = await _db.folderEntries.select().get();
    for (final row in localRows) {
      localMap[row.id] = row;
    }

    final toRequest = <String>[];
    final toPush = <SyncManifestItem>[];
    final seenIds = <String>{};

    for (final remote in remoteManifest) {
      seenIds.add(remote.id);
      final local = localMap[remote.id];

      if (local == null) {
        if (!remote.isDeleted) {
          toRequest.add(remote.id);
        }
      } else {
        final resolution = resolveSyncConflict(
          localUpdatedAt: local.createdAt,
          remoteUpdatedAt: remote.updatedAt,
          localId: local.id,
          remoteId: remote.id,
        );

        if (resolution == SyncConflictWinner.remote) {
          if (remote.isDeleted) {
            await _db.folderDao.deleteById(remote.id);
          } else {
            toRequest.add(remote.id);
          }
        } else {
          toPush.add(SyncManifestItem(
            id: local.id,
            updatedAt: local.createdAt,
            isDeleted: false,
            rowData: _folderEntryToJson(local),
          ));
        }
      }
    }

    for (final entry in localMap.entries) {
      if (!seenIds.contains(entry.key)) {
        toPush.add(SyncManifestItem(
          id: entry.value.id,
          updatedAt: entry.value.createdAt,
          isDeleted: false,
          rowData: _folderEntryToJson(entry.value),
        ));
      }
    }

    return (toRequest: toRequest, toPush: toPush);
  }

  /// Same as [computeCredentialDeltas] but for secure files. LWW on
  /// `updatedAt`; contents are exchanged re-keyed like credential payloads.
  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeSecureFileDeltas(List<SyncManifestItem> remoteManifest) async {
    final repo = _secureFiles;
    if (repo == null) {
      return (toRequest: const <String>[], toPush: const <SyncManifestItem>[]);
    }
    final localRows = await _db.secureFileDao.getAll();
    final localMap = {for (final row in localRows) row.id: row};

    final toRequest = <String>[];
    final toPush = <SyncManifestItem>[];
    final seenIds = <String>{};

    for (final remote in remoteManifest) {
      seenIds.add(remote.id);
      final local = localMap[remote.id];

      if (local == null) {
        if (!remote.isDeleted) {
          toRequest.add(remote.id);
        }
      } else {
        final resolution = resolveSyncConflict(
          localUpdatedAt: local.updatedAt,
          remoteUpdatedAt: remote.updatedAt,
          localId: local.id,
          remoteId: remote.id,
        );

        if (resolution == SyncConflictWinner.remote) {
          if (remote.isDeleted) {
            await repo.delete(remote.id);
          } else {
            toRequest.add(remote.id);
          }
        } else {
          final item = await buildSecureFilePushItem(local.id);
          if (item != null) toPush.add(item);
        }
      }
    }

    for (final entry in localMap.entries) {
      if (!seenIds.contains(entry.key)) {
        final item = await buildSecureFilePushItem(entry.key);
        if (item != null) toPush.add(item);
      }
    }

    return (toRequest: toRequest, toPush: toPush);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Applying remote rows to local DB
  // ─────────────────────────────────────────────────────────────────────────

  /// Applies a list of full credential rows received from the remote device and
  /// returns the list of changes actually applied locally (with plain titles and
  /// added/updated/deleted action), so the caller can build a sync summary.
  Future<List<SyncItemChange>> applyRemoteCredentials(
      List<SyncManifestItem> items) async {
    final changes = <SyncItemChange>[];
    for (final item in items) {
      // Deletes carry no row data; handle them first (order matters — a null
      // rowData must not skip a tombstone).
      if (item.isDeleted) {
        final existing = await _db.credentialDao.getById(item.id);
        await _db.credentialDao.deleteById(item.id);
        changes.add(SyncItemChange(
          id: item.id,
          name: existing?.title ?? item.id,
          kind: SyncEntityKind.credential,
          action: SyncChangeAction.deleted,
        ));
        continue;
      }

      if (item.rowData == null) continue;

      final existing = await _db.credentialDao.getById(item.id);
      final companion = await _jsonToCredentialCompanion(item.rowData!);
      await _db.credentialDao.upsert(companion);
      changes.add(SyncItemChange(
        id: item.id,
        name: item.rowData!['title'] as String? ?? item.id,
        kind: SyncEntityKind.credential,
        action:
            existing == null ? SyncChangeAction.added : SyncChangeAction.updated,
      ));
    }
    return changes;
  }

  /// Builds a single push item for a requested credential id, re-keying its
  /// payload to the wire format. Returns null if the row no longer exists or
  /// cannot be decrypted with the local key.
  Future<SyncManifestItem?> buildCredentialPushItem(String id) async {
    final row = await _db.credentialDao.getById(id);
    if (row == null) return null;
    return _credentialPushItemOrNull(row);
  }

  /// Builds a single push item for a requested folder id. Folders are not
  /// encrypted, so no re-keying is needed.
  Future<SyncManifestItem?> buildFolderPushItem(String id) async {
    final row = await _db.folderDao.getById(id);
    if (row == null) return null;
    return SyncManifestItem(
      id: row.id,
      updatedAt: row.createdAt,
      isDeleted: false,
      rowData: _folderEntryToJson(row),
    );
  }

  /// Builds a single push item for a requested secure-file id: metadata plus
  /// the DECRYPTED contents (base64) — the wire is E2EE with K_sync, and the
  /// receiver re-encrypts under its own vault key (same re-keying model as
  /// credential payloads). Returns null when the row/blob is missing or cannot
  /// be decrypted, so one broken file never aborts the whole round.
  Future<SyncManifestItem?> buildSecureFilePushItem(String id) async {
    final repo = _secureFiles;
    if (repo == null) return null;
    try {
      final meta = await repo.getById(id);
      if (meta == null) return null;
      final plain = await repo.readDecrypted(id);
      final contentPlain = base64Encode(plain);
      zeroBuffer(plain);
      return SyncManifestItem(
        id: meta.id,
        updatedAt: meta.updatedAt.millisecondsSinceEpoch,
        isDeleted: false,
        rowData: {
          'id': meta.id,
          'name': meta.name,
          'size_bytes': meta.sizeBytes,
          'stored_file_name': meta.storedFileName,
          'mime_hint': meta.mimeHint,
          'note': meta.note,
          'folder_id': meta.folderId,
          'is_favorite': meta.isFavorite,
          'created_at': meta.createdAt.millisecondsSinceEpoch,
          'updated_at': meta.updatedAt.millisecondsSinceEpoch,
          'content_plain': contentPlain,
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Applies full secure-file rows received from the remote device: re-encrypts
  /// the contents under the LOCAL vault key and upserts metadata verbatim.
  Future<List<SyncItemChange>> applyRemoteSecureFiles(
      List<SyncManifestItem> items) async {
    final repo = _secureFiles;
    if (repo == null || items.isEmpty) return const [];
    final changes = <SyncItemChange>[];
    for (final item in items) {
      if (item.isDeleted) {
        final existing = await repo.getById(item.id);
        await repo.delete(item.id);
        changes.add(SyncItemChange(
          id: item.id,
          name: existing?.name ?? item.id,
          kind: SyncEntityKind.file,
          action: SyncChangeAction.deleted,
        ));
        continue;
      }

      final data = item.rowData;
      if (data == null) continue;

      final existing = await repo.getById(item.id);
      final plain =
          Uint8List.fromList(base64Decode(data['content_plain'] as String));
      final meta = SecureFile(
        id: data['id'] as String,
        name: data['name'] as String,
        sizeBytes: data['size_bytes'] as int? ?? plain.length,
        storedFileName:
            data['stored_file_name'] as String? ?? '${data['id']}.enc',
        mimeHint: data['mime_hint'] as String?,
        note: data['note'] as String?,
        folderId: data['folder_id'] as String?,
        isFavorite: data['is_favorite'] as bool? ?? false,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int),
      );
      await repo.applySynced(meta, plain);
      zeroBuffer(plain);
      changes.add(SyncItemChange(
        id: item.id,
        name: meta.name,
        kind: SyncEntityKind.file,
        action:
            existing == null ? SyncChangeAction.added : SyncChangeAction.updated,
      ));
    }
    return changes;
  }

  /// Applies a list of full folder rows received from the remote device and
  /// returns the changes actually applied (name + added/updated/deleted).
  Future<List<SyncItemChange>> applyRemoteFolders(
      List<SyncManifestItem> items) async {
    final changes = <SyncItemChange>[];
    for (final item in items) {
      if (item.isDeleted) {
        final existing = await _db.folderDao.getById(item.id);
        await _db.folderDao.deleteById(item.id);
        changes.add(SyncItemChange(
          id: item.id,
          name: existing?.name ?? item.id,
          kind: SyncEntityKind.folder,
          action: SyncChangeAction.deleted,
        ));
        continue;
      }

      if (item.rowData == null) continue;

      final existing = await _db.folderDao.getById(item.id);
      final companion = _jsonToFolderCompanion(item.rowData!);
      await _db.folderDao.upsert(companion);
      changes.add(SyncItemChange(
        id: item.id,
        name: item.rowData!['name'] as String? ?? item.id,
        kind: SyncEntityKind.folder,
        action:
            existing == null ? SyncChangeAction.added : SyncChangeAction.updated,
      ));
    }
    return changes;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Row ↔ JSON serialization helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Serializes a credential row for the wire. The encrypted payload is
  /// **re-keyed**: decrypted with the LOCAL master key and sent as `payload_plain`
  /// (plaintext bytes, base64). The whole sync message is itself AES-256-GCM
  /// encrypted with K_sync over the wire, so the plaintext never travels in the
  /// clear. The receiver re-encrypts it under ITS own master key. This decouples
  /// the two devices' vault keys (they have different random salts) so a synced
  /// credential is always decryptable on the device that stores it.
  Future<Map<String, dynamic>> _credentialEntryToJson(
      CredentialEntry row) async {
    final key = _requireMasterKey();
    final plain = await _securityService.decrypt(row.encryptedPayload, key);
    final payloadPlain = base64Encode(plain);
    zeroBuffer(key);
    zeroBuffer(plain);
    return {
      'id': row.id,
      'title': row.title,
      'type': row.type,
      'category_id': row.categoryId,
      'folder_id': row.folderId,
      'is_favorite': row.isFavorite,
      'is_double_encrypted': row.isDoubleEncrypted,
      'is_hidden': row.isHidden,
      'sort_order': row.sortOrder,
      'payload_plain': payloadPlain,
      'created_at': row.createdAt,
      'updated_at': row.updatedAt,
      'rotation_interval': row.rotationInterval,
      'custom_rotation_days': row.customRotationDays,
      'last_rotation_prompted_at': row.lastRotationPromptedAt,
    };
  }

  Future<CredentialEntriesCompanion> _jsonToCredentialCompanion(
      Map<String, dynamic> json) async {
    final key = _requireMasterKey();
    final plain = Uint8List.fromList(
        base64Decode(json['payload_plain'] as String));
    final encryptedPayload = await _securityService.encrypt(plain, key);
    zeroBuffer(key);
    zeroBuffer(plain);
    return CredentialEntriesCompanion(
      id: Value(json['id'] as String),
      title: Value(json['title'] as String),
      type: Value(json['type'] as String),
      categoryId: Value(json['category_id'] as String?),
      folderId: Value(json['folder_id'] as String?),
      isFavorite: Value(json['is_favorite'] as bool? ?? false),
      isDoubleEncrypted: Value(json['is_double_encrypted'] as bool? ?? false),
      isHidden: Value(json['is_hidden'] as bool? ?? false),
      sortOrder: Value(json['sort_order'] as int? ?? 0),
      encryptedPayload: Value(encryptedPayload),
      createdAt: Value(json['created_at'] as int),
      updatedAt: Value(json['updated_at'] as int),
      rotationInterval: Value(json['rotation_interval'] as String? ?? 'none'),
      customRotationDays: Value(json['custom_rotation_days'] as int?),
      lastRotationPromptedAt: Value(json['last_rotation_prompted_at'] as int?),
    );
  }

  Map<String, dynamic> _folderEntryToJson(FolderEntry row) => {
        'id': row.id,
        'parent_id': row.parentId,
        'name': row.name,
        'icon': row.icon,
        'color_hex': row.colorHex,
        'is_favorite': row.isFavorite,
        'created_at': row.createdAt,
      };

  FolderEntriesCompanion _jsonToFolderCompanion(Map<String, dynamic> json) {
    return FolderEntriesCompanion(
      id: Value(json['id'] as String),
      parentId: Value(json['parent_id'] as String?),
      name: Value(json['name'] as String),
      icon: Value(json['icon'] as String? ?? 'folder'),
      colorHex: Value(json['color_hex'] as String? ?? '#6C63FF'),
      isFavorite: Value(json['is_favorite'] as bool? ?? false),
      createdAt: Value(json['created_at'] as int),
    );
  }
}

/// Winner of a Last-Write-Wins comparison.
enum SyncConflictWinner { local, remote }

/// Last-Write-Wins resolution shared by credential & folder deltas. Pure and
/// deterministic so BOTH devices independently agree on the same winner.
/// The newer `updatedAt` wins; on an exact tie the lexicographically smaller
/// UUID wins (`local` if `localId <= remoteId`). Public for unit testing.
SyncConflictWinner resolveSyncConflict({
  required int localUpdatedAt,
  required int remoteUpdatedAt,
  required String localId,
  required String remoteId,
}) {
  if (remoteUpdatedAt > localUpdatedAt) return SyncConflictWinner.remote;
  if (remoteUpdatedAt < localUpdatedAt) return SyncConflictWinner.local;
  return localId.compareTo(remoteId) <= 0
      ? SyncConflictWinner.local
      : SyncConflictWinner.remote;
}
