import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/credential.dart';
import '../domain/repositories/i_credential_repository.dart';

@lazySingleton
class GetCredentialsUseCase {
  const GetCredentialsUseCase(this._repo);
  final ICredentialRepository _repo;

  Future<List<Credential>> all() => _repo.getAll();
  Future<List<Credential>> favorites() => _repo.getFavorites();
  Future<List<Credential>> byCategory(String id) => _repo.getByCategory(id);
  Future<List<Credential>> search(String q) => _repo.search(q);
}

@lazySingleton
class SaveCredentialUseCase {
  const SaveCredentialUseCase(this._repo);
  final ICredentialRepository _repo;

  Future<void> create(Credential credential) {
    final withId = credential.id.isEmpty
        ? credential.copyWith(id: const Uuid().v4())
        : credential;
    return _repo.save(withId);
  }

  Future<void> update(Credential credential) => _repo.update(credential);

  Future<void> setHidden(String id, bool hidden) =>
      _repo.setHidden(id, hidden);

  Future<void> reorder(List<String> orderedIds) => _repo.reorder(orderedIds);
}

@lazySingleton
class DeleteCredentialUseCase {
  const DeleteCredentialUseCase(this._repo);
  final ICredentialRepository _repo;

  Future<void> execute(String id) => _repo.delete(id);
}
