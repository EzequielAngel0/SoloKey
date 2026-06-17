import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/infrastructure/database/app_database.dart';

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
  DeltaSyncManager(this._db);

  final AppDatabase _db;

  // ─────────────────────────────────────────────────────────────────────────
  // Building the local manifest
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds a manifest of all local credential entries.
  Future<List<SyncManifestItem>> buildCredentialManifest({
    bool includeRowData = false,
  }) async {
    final rows = await _db.credentialEntries.select().get();
    return rows.map((row) {
      return SyncManifestItem(
        id: row.id,
        updatedAt: row.updatedAt,
        isDeleted: false,
        rowData: includeRowData ? _credentialEntryToJson(row) : null,
      );
    }).toList();
  }

  /// Builds a manifest of all local folder entries.
  Future<List<SyncManifestItem>> buildFolderManifest({
    bool includeRowData = false,
  }) async {
    final rows = await _db.folderEntries.select().get();
    return rows.map((row) {
      return SyncManifestItem(
        id: row.id,
        updatedAt: row.createdAt, // Folders use createdAt as the version field
        isDeleted: false,
        rowData: includeRowData ? _folderEntryToJson(row) : null,
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
        final resolution = _resolveConflict(
          localUpdatedAt: local.updatedAt,
          remoteUpdatedAt: remote.updatedAt,
          localId: local.id,
          remoteId: remote.id,
        );

        if (resolution == _ConflictWinner.remote) {
          if (remote.isDeleted) {
            // Remote deleted it — apply deletion locally
            await _db.credentialDao.deleteById(remote.id);
          } else {
            toRequest.add(remote.id);
          }
        } else {
          // Local wins — push to remote
          toPush.add(SyncManifestItem(
            id: local.id,
            updatedAt: local.updatedAt,
            isDeleted: false,
            rowData: _credentialEntryToJson(local),
          ));
        }
      }
    }

    // Items only present locally → push to remote
    for (final entry in localMap.entries) {
      if (!seenIds.contains(entry.key)) {
        toPush.add(SyncManifestItem(
          id: entry.value.id,
          updatedAt: entry.value.updatedAt,
          isDeleted: false,
          rowData: _credentialEntryToJson(entry.value),
        ));
      }
    }

    return (toRequest: toRequest, toPush: toPush);
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
        final resolution = _resolveConflict(
          localUpdatedAt: local.createdAt,
          remoteUpdatedAt: remote.updatedAt,
          localId: local.id,
          remoteId: remote.id,
        );

        if (resolution == _ConflictWinner.remote) {
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

  // ─────────────────────────────────────────────────────────────────────────
  // Applying remote rows to local DB
  // ─────────────────────────────────────────────────────────────────────────

  /// Applies a list of full credential rows received from the remote device.
  Future<int> applyRemoteCredentials(List<SyncManifestItem> items) async {
    var applied = 0;
    for (final item in items) {
      if (item.rowData == null) continue;

      if (item.isDeleted) {
        await _db.credentialDao.deleteById(item.id);
        applied++;
        continue;
      }

      final companion = _jsonToCredentialCompanion(item.rowData!);
      await _db.credentialDao.upsert(companion);
      applied++;
    }
    return applied;
  }

  /// Applies a list of full folder rows received from the remote device.
  Future<int> applyRemoteFolders(List<SyncManifestItem> items) async {
    var applied = 0;
    for (final item in items) {
      if (item.rowData == null) continue;

      if (item.isDeleted) {
        await _db.folderDao.deleteById(item.id);
        applied++;
        continue;
      }

      final companion = _jsonToFolderCompanion(item.rowData!);
      await _db.folderDao.upsert(companion);
      applied++;
    }
    return applied;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LWW Conflict Resolution
  // ─────────────────────────────────────────────────────────────────────────

  _ConflictWinner _resolveConflict({
    required int localUpdatedAt,
    required int remoteUpdatedAt,
    required String localId,
    required String remoteId,
  }) {
    if (remoteUpdatedAt > localUpdatedAt) return _ConflictWinner.remote;
    if (remoteUpdatedAt < localUpdatedAt) return _ConflictWinner.local;
    // Timestamps equal — tie-break by lexicographic UUID comparison.
    // Deterministic on both sides because both see the same IDs.
    return localId.compareTo(remoteId) <= 0
        ? _ConflictWinner.local
        : _ConflictWinner.remote;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Row ↔ JSON serialization helpers
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _credentialEntryToJson(CredentialEntry row) => {
        'id': row.id,
        'title': row.title,
        'type': row.type,
        'category_id': row.categoryId,
        'folder_id': row.folderId,
        'is_favorite': row.isFavorite,
        'is_double_encrypted': row.isDoubleEncrypted,
        'encrypted_payload': base64Encode(row.encryptedPayload),
        'created_at': row.createdAt,
        'updated_at': row.updatedAt,
      };

  CredentialEntriesCompanion _jsonToCredentialCompanion(
      Map<String, dynamic> json) {
    return CredentialEntriesCompanion(
      id: Value(json['id'] as String),
      title: Value(json['title'] as String),
      type: Value(json['type'] as String),
      categoryId: Value(json['category_id'] as String?),
      folderId: Value(json['folder_id'] as String?),
      isFavorite: Value(json['is_favorite'] as bool? ?? false),
      isDoubleEncrypted: Value(json['is_double_encrypted'] as bool? ?? false),
      encryptedPayload:
          Value(Uint8List.fromList(base64Decode(json['encrypted_payload'] as String))),
      createdAt: Value(json['created_at'] as int),
      updatedAt: Value(json['updated_at'] as int),
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

enum _ConflictWinner { local, remote }
