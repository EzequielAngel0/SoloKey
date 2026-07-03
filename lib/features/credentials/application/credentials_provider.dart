import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/credential.dart';
import 'credential_use_cases.dart';

part 'credentials_provider.g.dart';

@riverpod
class CredentialsNotifier extends _$CredentialsNotifier {
  @override
  Future<List<Credential>> build() async {
    return ref.read(getCredentialsUseCaseProvider).all();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getCredentialsUseCaseProvider).all(),
    );
  }

  Future<void> save(Credential credential) async {
    await ref.read(saveCredentialUseCaseProvider).create(credential);
    await refresh();
  }

  Future<void> updateCredential(Credential credential) async {
    await ref.read(saveCredentialUseCaseProvider).update(credential);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(deleteCredentialUseCaseProvider).execute(id);
    await refresh();
  }

  /// Hides/unhides (archives) a credential, then refreshes the list.
  Future<void> setHidden(String id, bool hidden) async {
    await ref.read(saveCredentialUseCaseProvider).setHidden(id, hidden);
    await refresh();
  }

  /// Persists a new manual order (index = position) and refreshes.
  Future<void> reorder(List<String> orderedIds) async {
    await ref.read(saveCredentialUseCaseProvider).reorder(orderedIds);
    await refresh();
  }

  /// Moves one credential to [folderId] (`null` = vault root) and refreshes.
  Future<void> moveToFolder(String id, String? folderId) async {
    await ref.read(saveCredentialUseCaseProvider).moveToFolder(id, folderId);
    await refresh();
  }

  /// Bulk-reassigns every credential in [fromFolderId] to [toFolderId] and
  /// refreshes. Used when a folder is deleted so credentials aren't orphaned.
  Future<void> reassignFolder(String fromFolderId, String? toFolderId) async {
    await ref
        .read(saveCredentialUseCaseProvider)
        .reassignFolder(fromFolderId, toFolderId);
    await refresh();
  }
}

@riverpod
class CredentialSearchNotifier extends _$CredentialSearchNotifier {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<Credential>> filteredCredentials(Ref ref) async {
  final query = ref.watch(credentialSearchNotifierProvider);
  final credentials = await ref.watch(credentialsNotifierProvider.future);
  
  if (query.isEmpty) return credentials;
  
  final q = query.toLowerCase();
  return credentials.where((c) =>
      c.title.toLowerCase().contains(q) ||
      (c.username?.toLowerCase().contains(q) ?? false) ||
      (c.website?.toLowerCase().contains(q) ?? false)).toList();
}

// ── Use case providers ────────────────────────────────────────────────────────

@riverpod
GetCredentialsUseCase getCredentialsUseCase(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}

@riverpod
SaveCredentialUseCase saveCredentialUseCase(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}

@riverpod
DeleteCredentialUseCase deleteCredentialUseCase(Ref ref) {
  throw UnimplementedError('Register via get_it override');
}
