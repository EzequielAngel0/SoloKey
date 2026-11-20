import 'dart:convert';
import 'dart:typed_data';

import '../../../core/domain/crypto_utils.dart';
import '../../../core/infrastructure/rust/api/vault.dart' as core;
import '../../../core/infrastructure/vault/vault_store.dart';
import '../domain/sync_summary.dart';

/// DTO que viaja por el canal E2EE de la sync. Cada item lleva lo necesario para el LWW y, cuando hace falta, el
/// registro completo.
class SyncManifestItem {
  const SyncManifestItem({
    required this.id,
    required this.updatedAt,
    required this.isDeleted,
    this.rowData,
  });

  /// Id del registro (UUID v4).
  final String id;

  /// Milisegundos Unix: la fecha del LWW.
  final int updatedAt;

  /// Lapida: el registro se borro en el equipo de origen.
  final bool isDeleted;

  /// El registro: `{'data': <JSON de la entidad>}` y, en los archivos, `'content_plain'` (base64). Null en el
  /// manifiesto y en las lapidas.
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

/// Delta de la sync sobre los registros de la boveda v2 (NUC-2).
///
/// Protocolo (el mismo de la v1): los dos equipos cruzan un manifiesto `{id, updatedAt, isDeleted}` por carril
/// (credenciales, carpetas, archivos); cada lado pide lo que el otro tiene mas nuevo y empuja lo suyo. LWW por
/// `updatedAt` del registro; empate, gana el UUID menor. Los registros viajan en claro DENTRO del canal cifrado con
/// K_sync y cada equipo los guarda con su propia clave (el nucleo cifra al escribir).
///
/// Un `rowData` sin `data` (formato de la v1) se ignora: una v1 y una v2 no se mezclan (el aviso llega con NUC-3).
class DeltaSyncManager {
  DeltaSyncManager(this._vault);

  final VaultStore _vault;

  // ── Manifiestos ────────────────────────────────────────────────────────────

  Future<List<SyncManifestItem>> buildCredentialManifest() =>
      _manifest(RecordKind.credential);

  Future<List<SyncManifestItem>> buildFolderManifest() =>
      _manifest(RecordKind.folder);

  Future<List<SyncManifestItem>> buildSecureFileManifest() =>
      _manifest(RecordKind.file);

  Future<List<SyncManifestItem>> _manifest(String kind) async => [
        for (final r in await _vault.records(kind))
          SyncManifestItem(id: r.id, updatedAt: r.updatedAt, isDeleted: r.deleted),
      ];

  // ── Deltas ─────────────────────────────────────────────────────────────────

  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeCredentialDeltas(List<SyncManifestItem> remote) =>
          _deltas(RecordKind.credential, remote);

  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeFolderDeltas(List<SyncManifestItem> remote) =>
          _deltas(RecordKind.folder, remote);

  Future<({List<String> toRequest, List<SyncManifestItem> toPush})>
      computeSecureFileDeltas(List<SyncManifestItem> remote) =>
          _deltas(RecordKind.file, remote);

  /// Compara el manifiesto remoto con lo local: que pedir y que empujar. Las lapidas remotas que ganan se aplican
  /// aqui mismo.
  Future<({List<String> toRequest, List<SyncManifestItem> toPush})> _deltas(
      String kind, List<SyncManifestItem> remoteManifest) async {
    final local = {for (final r in await _vault.records(kind)) r.id: r};
    final toRequest = <String>[];
    final toPush = <SyncManifestItem>[];
    final seen = <String>{};

    for (final remote in remoteManifest) {
      seen.add(remote.id);
      final mine = local[remote.id];
      if (mine == null) {
        if (!remote.isDeleted) toRequest.add(remote.id);
        continue;
      }
      final winner = resolveSyncConflict(
        localUpdatedAt: mine.updatedAt,
        remoteUpdatedAt: remote.updatedAt,
        localId: mine.id,
        remoteId: remote.id,
      );
      if (winner == SyncConflictWinner.remote) {
        if (remote.isDeleted) {
          await _applyTombstone(kind, remote);
        } else {
          toRequest.add(remote.id);
        }
      } else if (mine.updatedAt != remote.updatedAt ||
          mine.deleted != remote.isDeleted) {
        final item = await _pushItem(kind, mine);
        if (item != null) toPush.add(item);
      }
    }

    // Solo locales: se empujan (las lapidas de algo que el otro nunca tuvo, no).
    for (final r in local.values) {
      if (seen.contains(r.id) || r.deleted) continue;
      final item = await _pushItem(kind, r);
      if (item != null) toPush.add(item);
    }
    return (toRequest: toRequest, toPush: toPush);
  }

  // ── Items para empujar ─────────────────────────────────────────────────────

  Future<SyncManifestItem?> buildCredentialPushItem(String id) =>
      _pushItemById(RecordKind.credential, id);

  Future<SyncManifestItem?> buildFolderPushItem(String id) =>
      _pushItemById(RecordKind.folder, id);

  Future<SyncManifestItem?> buildSecureFilePushItem(String id) =>
      _pushItemById(RecordKind.file, id);

  Future<SyncManifestItem?> _pushItemById(String kind, String id) async {
    final r = await _vault.record(id);
    if (r == null || r.kind != kind) return null;
    return _pushItem(kind, r);
  }

  /// El item de un registro local. Null si no se puede armar (un archivo sin contenido): un registro roto no
  /// aborta la ronda.
  Future<SyncManifestItem?> _pushItem(String kind, core.VaultRecord r) async {
    if (r.deleted) {
      return SyncManifestItem(id: r.id, updatedAt: r.updatedAt, isDeleted: true);
    }
    try {
      final row = <String, dynamic>{'data': jsonDecode(r.data)};
      if (kind == RecordKind.file) {
        final bytes = await _vault.getBlob(r.id);
        if (bytes == null) return null;
        row['content_plain'] = base64Encode(bytes);
        zeroBuffer(bytes);
      }
      return SyncManifestItem(
          id: r.id, updatedAt: r.updatedAt, isDeleted: false, rowData: row);
    } catch (_) {
      return null;
    }
  }

  // ── Aplicar lo remoto ──────────────────────────────────────────────────────

  Future<List<SyncItemChange>> applyRemoteCredentials(
          List<SyncManifestItem> items) =>
      _apply(RecordKind.credential, SyncEntityKind.credential, 'title', items);

  Future<List<SyncItemChange>> applyRemoteFolders(
          List<SyncManifestItem> items) =>
      _apply(RecordKind.folder, SyncEntityKind.folder, 'name', items);

  Future<List<SyncItemChange>> applyRemoteSecureFiles(
          List<SyncManifestItem> items) =>
      _apply(RecordKind.file, SyncEntityKind.file, 'name', items);

  /// Aplica los registros remotos conservando su `updatedAt` y devuelve lo que cambio (con nombre, para el resumen).
  Future<List<SyncItemChange>> _apply(String kind, SyncEntityKind entity,
      String nameField, List<SyncManifestItem> items) async {
    final changes = <SyncItemChange>[];
    for (final item in items) {
      final existing = await _vault.record(item.id);
      if (existing != null && existing.kind != kind) continue;
      final before = existing == null || existing.deleted
          ? null
          : jsonDecode(existing.data) as Map<String, dynamic>;

      if (item.isDeleted) {
        if (before == null) continue;
        await _applyTombstone(kind, item);
        changes.add(SyncItemChange(
          id: item.id,
          name: before[nameField] as String? ?? item.id,
          kind: entity,
          action: SyncChangeAction.deleted,
        ));
        continue;
      }

      final data = item.rowData?['data'];
      if (data is! Map<String, dynamic>) continue;
      if (kind == RecordKind.file) {
        final b64 = item.rowData?['content_plain'];
        if (b64 is! String) continue;
        final bytes = Uint8List.fromList(base64Decode(b64));
        try {
          await _vault.putBlob(item.id, bytes);
        } finally {
          zeroBuffer(bytes);
        }
      }
      await _vault.putSynced([
        core.VaultRecord(
          id: item.id,
          kind: kind,
          updatedAt: item.updatedAt,
          deleted: false,
          data: jsonEncode(data),
        ),
      ]);
      changes.add(SyncItemChange(
        id: item.id,
        name: data[nameField] as String? ?? item.id,
        kind: entity,
        action: before == null ? SyncChangeAction.added : SyncChangeAction.updated,
      ));
    }
    return changes;
  }

  Future<void> _applyTombstone(String kind, SyncManifestItem item) async {
    if (kind == RecordKind.file) {
      try {
        await _vault.deleteBlob(item.id);
      } catch (_) {
        // Sin contenido que borrar.
      }
    }
    await _vault.remove(item.id, at: item.updatedAt);
  }
}

/// Ganador de una comparacion LWW.
enum SyncConflictWinner { local, remote }

/// LWW comun a todos los carriles. Pura y determinista para que los DOS equipos elijan lo mismo: gana el
/// `updatedAt` mas nuevo; en empate exacto, el UUID menor (`local` si `localId <= remoteId`).
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
