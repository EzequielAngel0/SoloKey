import 'dart:async';

import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';

/// Minimal in-memory [ICredentialRepository] for logic/widget tests. Holds a
/// fixed list; mutating methods are no-ops unless a test needs otherwise.
/// Shared so suites don't each re-declare the same fake.
///
/// Two optional knobs drive async UI states: [failWith] makes `getAll` throw
/// (error branch) and [loadForever] makes it never complete (loading branch).
class FakeCredentialRepository implements ICredentialRepository {
  FakeCredentialRepository(
    this.credentials, {
    this.failWith,
    this.loadForever = false,
  });
  final List<Credential> credentials;
  final Object? failWith;
  final bool loadForever;

  @override
  Future<List<Credential>> getAll() {
    if (failWith != null) return Future.error(failWith!);
    if (loadForever) return Completer<List<Credential>>().future;
    return Future.value(credentials);
  }

  @override
  Future<Credential?> getById(String id) async =>
      credentials.where((c) => c.id == id).firstOrNull;

  @override
  Future<void> save(Credential credential) async {}

  @override
  Future<void> update(Credential credential) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Credential>> getByCategory(String categoryId) async =>
      credentials.where((c) => c.categoryId == categoryId).toList();

  @override
  Future<List<Credential>> getFavorites() async =>
      credentials.where((c) => c.isFavorite).toList();

  @override
  Future<List<Credential>> search(String query) async => credentials
      .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId) async =>
      [];

  @override
  Future<void> setHidden(String id, bool hidden) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}
