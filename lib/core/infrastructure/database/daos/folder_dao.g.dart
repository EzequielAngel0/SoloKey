// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_dao.dart';

// ignore_for_file: type=lint
mixin _$FolderDaoMixin on DatabaseAccessor<AppDatabase> {
  $FolderEntriesTable get folderEntries => attachedDatabase.folderEntries;
  FolderDaoManager get managers => FolderDaoManager(this);
}

class FolderDaoManager {
  final _$FolderDaoMixin _db;
  FolderDaoManager(this._db);
  $$FolderEntriesTableTableManager get folderEntries =>
      $$FolderEntriesTableTableManager(_db.attachedDatabase, _db.folderEntries);
}
