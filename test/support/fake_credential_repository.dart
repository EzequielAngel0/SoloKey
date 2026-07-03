import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';

/// Minimal in-memory [ICredentialRepository] for logic/widget tests. Holds a
/// fixed list; mutating methods are no-ops unless a test needs otherwise.
/// Shared so suites don't each re-declare the same fake.
class FakeCredentialRepository implements ICredentialRepository {
  FakeCredentialRepository(this.credentials);
  final List<Credential> credentials;

  @override
  Future<List<Credential>> getAll() async => credentials;

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
