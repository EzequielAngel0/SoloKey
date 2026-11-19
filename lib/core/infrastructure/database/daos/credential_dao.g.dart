// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_dao.dart';

// ignore_for_file: type=lint
mixin _$CredentialDaoMixin on DatabaseAccessor<AppDatabase> {
  $CredentialEntriesTable get credentialEntries =>
      attachedDatabase.credentialEntries;
  CredentialDaoManager get managers => CredentialDaoManager(this);
}

class CredentialDaoManager {
  final _$CredentialDaoMixin _db;
  CredentialDaoManager(this._db);
  $$CredentialEntriesTableTableManager get credentialEntries =>
      $$CredentialEntriesTableTableManager(
        _db.attachedDatabase,
        _db.credentialEntries,
      );
}
