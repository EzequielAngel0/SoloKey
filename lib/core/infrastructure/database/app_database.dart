import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

import 'daos/category_dao.dart';
import 'daos/credential_dao.dart';
import 'daos/folder_dao.dart';
import 'daos/password_history_dao.dart';
import 'daos/secure_file_dao.dart';
import 'tables/category_entries.dart';
import 'tables/credential_entries.dart';
import 'tables/folder_entries.dart';
import 'tables/password_history_entries.dart';
import 'tables/secure_file_entries.dart';

part 'app_database.g.dart';

@singleton
@DriftDatabase(
  tables: [
    CredentialEntries,
    CategoryEntries,
    FolderEntries,
    PasswordHistoryEntries,
    SecureFileEntries,
  ],
  daos: [
    CredentialDao,
    CategoryDao,
    FolderDao,
    PasswordHistoryDao,
    SecureFileDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test-only constructor: runs on a caller-provided executor (e.g.
  /// `NativeDatabase.memory()`), so unit tests exercise the schema/migrations
  /// in isolation without touching the on-disk vault.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(folderEntries);
            await m.createTable(passwordHistoryEntries);
          }
          if (from < 3) {
            await m.addColumn(folderEntries, folderEntries.parentId);
          }
          if (from < 4) {
            await m.addColumn(folderEntries, folderEntries.isFavorite);
          }
          if (from < 5) {
            // folderId for credential entries — enables folder organisation
            // for all types including passkeys.
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.folderId as GeneratedColumn,
            );
          }
          if (from < 6) {
            // isDoubleEncrypted for credential entries — enables double-envelope encryption.
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.isDoubleEncrypted as GeneratedColumn,
            );
          }
          if (from < 7) {
            // Password rotation reminder fields.
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.rotationInterval as GeneratedColumn,
            );
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.customRotationDays as GeneratedColumn,
            );
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.lastRotationPromptedAt as GeneratedColumn,
            );
          }
          if (from < 8) {
            // Secure files: encrypted-on-disk file vault metadata.
            await m.createTable(secureFileEntries);
          }
          if (from < 9) {
            // Secure files: folder organisation + favourites.
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              secureFileEntries,
              secureFileEntries.folderId as GeneratedColumn,
            );
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              secureFileEntries,
              secureFileEntries.isFavorite as GeneratedColumn,
            );
          }
          if (from < 10) {
            // Credentials: hide/archive + manual reorder.
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.isHidden as GeneratedColumn,
            );
            // ignore: invalid_use_of_visible_for_testing_member
            await m.addColumn(
              credentialEntries,
              credentialEntries.sortOrder as GeneratedColumn,
            );
          }
        },
      );

  /// Deletes every row from every table. Used by the brute-force wipe and any
  /// full vault reset. Runs in a single transaction.
  Future<void> wipeAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'vault_guard_db');
  }
}
