import 'package:password_manager/features/credentials/domain/entities/category.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';

abstract interface class ICredentialRepository {
  Future<List<Credential>> getAll();
  Future<Credential?> getById(String id);
  Future<void> save(Credential credential);
  Future<void> update(Credential credential);
  Future<void> delete(String id);
  Future<List<Credential>> getByCategory(String categoryId);
  Future<List<Credential>> getFavorites();
  Future<List<Credential>> search(String query);
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId);

  /// Hides/unhides a credential (archive). Plain-column update, no re-encryption.
  Future<void> setHidden(String id, bool hidden);

  /// Persists the manual order of the given credential ids (index = position).
  Future<void> reorder(List<String> orderedIds);

  /// Moves a single credential to [folderId] (`null` = vault root). Plain-column
  /// update (no re-encryption); bumps `updatedAt` so the move syncs.
  Future<void> moveToFolder(String id, String? folderId);

  /// Bulk-reassigns every credential in [fromFolderId] to [toFolderId]
  /// (`null` = vault root). Used when a folder is deleted so its credentials
  /// are never orphaned.
  Future<void> reassignFolder(String fromFolderId, String? toFolderId);
}

abstract interface class ICategoryRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(String id);
  Future<void> save(Category category);
  Future<void> delete(String id);
}
