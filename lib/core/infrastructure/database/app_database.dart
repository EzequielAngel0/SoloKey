import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

import 'daos/category_dao.dart';
import 'daos/credential_dao.dart';
import 'daos/folder_dao.dart';
import 'daos/password_history_dao.dart';
import 'tables/category_entries.dart';
import 'tables/credential_entries.dart';
import 'tables/folder_entries.dart';
import 'tables/password_history_entries.dart';

part 'app_database.g.dart';

@singleton
@DriftDatabase(
  tables: [
    CredentialEntries,
    CategoryEntries,
    FolderEntries,
    PasswordHistoryEntries,
  ],
  daos: [CredentialDao, CategoryDao, FolderDao, PasswordHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'vault_guard_db');
  }
}
