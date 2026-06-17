import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../infrastructure/security/session_manager.dart';
import 'vault_export_service.dart';

/// Scheduled encrypted backups.
///
/// When enabled, exports an AES-encrypted `.skvault` to the user-chosen folder
/// every N days. Runs only while the vault is UNLOCKED (it must read+encrypt the
/// data), so it's triggered opportunistically on unlock. The backup password is
/// kept in the Keystore (never in plain settings).
@lazySingleton
class ScheduledBackupService {
  ScheduledBackupService(this._export, this._settingsRepo, this._storage,
      this._session);

  final VaultExportService _export;
  final ISettingsRepository _settingsRepo;
  final FlutterSecureStorage _storage;
  final SessionManager _session;

  static const _kLastBackup = 'scheduled_backup_last';
  static const _kBackupPassword = 'scheduled_backup_password';

  /// Stores the backup password (Keystore) when the user configures the schedule.
  Future<void> setBackupPassword(String password) =>
      _storage.write(key: _kBackupPassword, value: password);

  Future<bool> hasBackupPassword() async =>
      (await _storage.read(key: _kBackupPassword)) != null;

  Future<DateTime?> lastBackupAt() async {
    final ms = int.tryParse(await _storage.read(key: _kLastBackup) ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Runs a backup if the schedule is enabled, the vault is unlocked and a
  /// backup is due. Best-effort: never throws.
  Future<void> runIfDue() async {
    try {
      if (!_session.hasActiveKey) return; // vault locked → can't read data
      final settings = await _settingsRepo.getSettings();
      final interval = settings.scheduledBackupIntervalDays;
      final dir = settings.backupDirectory;
      if (interval <= 0 || dir == null || dir.isEmpty) return;

      final lastMs =
          int.tryParse(await _storage.read(key: _kLastBackup) ?? '') ?? 0;
      final dueMs = interval * Duration.millisecondsPerDay;
      if (DateTime.now().millisecondsSinceEpoch - lastMs < dueMs) return;

      final password = await _storage.read(key: _kBackupPassword);
      if (password == null || password.isEmpty) return;

      await _export.exportVaultToDirectory(
        exportPassword: password,
        directoryPath: dir,
      );
      await _storage.write(
        key: _kLastBackup,
        value: '${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (_) {
      // Backup failures must not disrupt the app.
    }
  }
}
