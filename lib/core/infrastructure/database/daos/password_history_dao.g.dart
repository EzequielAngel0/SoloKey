// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_history_dao.dart';

// ignore_for_file: type=lint
mixin _$PasswordHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $PasswordHistoryEntriesTable get passwordHistoryEntries =>
      attachedDatabase.passwordHistoryEntries;
  PasswordHistoryDaoManager get managers => PasswordHistoryDaoManager(this);
}

class PasswordHistoryDaoManager {
  final _$PasswordHistoryDaoMixin _db;
  PasswordHistoryDaoManager(this._db);
  $$PasswordHistoryEntriesTableTableManager get passwordHistoryEntries =>
      $$PasswordHistoryEntriesTableTableManager(
        _db.attachedDatabase,
        _db.passwordHistoryEntries,
      );
}
