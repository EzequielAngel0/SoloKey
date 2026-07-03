import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks when the user last exported a `.skvault` backup and decides whether a
/// gentle "time to back up" reminder should be shown.
///
/// Intentionally a plain class (not `@injectable`) so it can be constructed with
/// `getIt<FlutterSecureStorage>()` without pulling in code generation. The
/// timestamp lives in secure storage — it is not sensitive, but keeping it there
/// avoids a settings/schema migration.
class BackupReminderService {
  BackupReminderService(this._storage);

  final FlutterSecureStorage _storage;

  static const _kLastExport = 'last_manual_export_at';

  /// A backup is considered stale after this long without exporting.
  static const staleAfter = Duration(days: 30);

  /// Records that a backup was just exported successfully.
  Future<void> markExportedNow() => _storage.write(
        key: _kLastExport,
        value: '${DateTime.now().millisecondsSinceEpoch}',
      );

  /// The last time a backup was exported, or `null` if never.
  Future<DateTime?> lastExportAt() async {
    final ms = int.tryParse(await _storage.read(key: _kLastExport) ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// True when no backup was ever exported, or the last one is older than
  /// [staleAfter]. Uses [now] for deterministic testing (defaults to wall clock).
  Future<bool> isBackupStale({DateTime? now}) async {
    final last = await lastExportAt();
    if (last == null) return true;
    return (now ?? DateTime.now()).difference(last) > staleAfter;
  }
}
