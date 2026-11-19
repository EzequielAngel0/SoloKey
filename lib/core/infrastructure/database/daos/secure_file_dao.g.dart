// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_file_dao.dart';

// ignore_for_file: type=lint
mixin _$SecureFileDaoMixin on DatabaseAccessor<AppDatabase> {
  $SecureFileEntriesTable get secureFileEntries =>
      attachedDatabase.secureFileEntries;
  SecureFileDaoManager get managers => SecureFileDaoManager(this);
}

class SecureFileDaoManager {
  final _$SecureFileDaoMixin _db;
  SecureFileDaoManager(this._db);
  $$SecureFileEntriesTableTableManager get secureFileEntries =>
      $$SecureFileEntriesTableTableManager(
        _db.attachedDatabase,
        _db.secureFileEntries,
      );
}
