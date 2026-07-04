import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';

import '../../support/fake_credential_repository.dart';

Credential _c(
  String id, {
  String? title,
  String? username,
  String? website,
}) =>
    Credential(
      id: id,
      type: CredentialType.password,
      title: title ?? id,
      username: username,
      website: website,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

/// Repository spy that mutates its list on writes so a notifier `refresh()`
/// observes the change, and records which mutating method fired.
class _SpyCredentialRepository implements ICredentialRepository {
  _SpyCredentialRepository(this._items);
  final List<Credential> _items;

  final List<Credential> saved = [];
  final List<Credential> updated = [];
  final List<String> deleted = [];
  final List<(String, bool)> hidden = [];
  final List<List<String>> reordered = [];
  final List<(String, String?)> moved = [];
  final List<(String, String?)> reassigned = [];

  @override
  Future<List<Credential>> getAll() async => List.of(_items);

  @override
  Future<void> save(Credential credential) async {
    saved.add(credential);
    _items.add(credential);
  }

  @override
  Future<void> update(Credential credential) async {
    updated.add(credential);
    final i = _items.indexWhere((c) => c.id == credential.id);
    if (i != -1) _items[i] = credential;
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);
    _items.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> setHidden(String id, bool hide) async => hidden.add((id, hide));

  @override
  Future<void> reorder(List<String> orderedIds) async =>
      reordered.add(orderedIds);

  @override
  Future<void> moveToFolder(String id, String? folderId) async =>
      moved.add((id, folderId));

  @override
  Future<void> reassignFolder(String fromFolderId, String? toFolderId) async =>
      reassigned.add((fromFolderId, toFolderId));

  @override
  Future<Credential?> getById(String id) async =>
      _items.where((c) => c.id == id).firstOrNull;

  @override
  Future<List<Credential>> getByCategory(String categoryId) async =>
      _items.where((c) => c.categoryId == categoryId).toList();

  @override
  Future<List<Credential>> getFavorites() async =>
      _items.where((c) => c.isFavorite).toList();

  @override
  Future<List<Credential>> search(String query) async => _items;

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String id) async => const [];
}

ProviderContainer _containerFor(ICredentialRepository repo) {
  final container = ProviderContainer(
    overrides: [
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(repo)),
      saveCredentialUseCaseProvider
          .overrideWithValue(SaveCredentialUseCase(repo)),
      deleteCredentialUseCaseProvider
          .overrideWithValue(DeleteCredentialUseCase(repo)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('filteredCredentials search filter', () {
    late ProviderContainer container;
    setUp(() {
      container = _containerFor(FakeCredentialRepository([
        _c('1', title: 'GitHub', username: 'octocat', website: 'github.com'),
        _c('2', title: 'Email', username: 'me@x.com', website: 'mail.google.com'),
        _c('3', title: 'Bank', username: 'user1'),
      ]));
    });

    Future<List<Credential>> filtered(String query) async {
      container.read(credentialSearchNotifierProvider.notifier).update(query);
      return container.read(filteredCredentialsProvider.future);
    }

    test('empty query returns every credential', () async {
      expect(await filtered(''), hasLength(3));
    });

    test('matches by title', () async {
      final r = await filtered('bank');
      expect(r.map((c) => c.id), ['3']);
    });

    test('matches by username, case-insensitive', () async {
      final r = await filtered('OCTOCAT');
      expect(r.map((c) => c.id), ['1']);
    });

    test('matches by website', () async {
      final r = await filtered('google');
      expect(r.map((c) => c.id), ['2']);
    });

    test('no match yields an empty list', () async {
      expect(await filtered('zzz-nope'), isEmpty);
    });
  });

  group('CredentialsNotifier orchestration (calls use case + refreshes)', () {
    test('save persists then the refreshed list contains the new credential',
        () async {
      final repo = _SpyCredentialRepository([]);
      final container = _containerFor(repo);
      await container.read(credentialsNotifierProvider.future);

      await container
          .read(credentialsNotifierProvider.notifier)
          .save(_c('new', title: 'New'));

      expect(repo.saved.single.id, 'new');
      final list = await container.read(credentialsNotifierProvider.future);
      expect(list.map((c) => c.id), contains('new'));
    });

    test('delete removes it and the refreshed list drops it', () async {
      final repo = _SpyCredentialRepository([_c('a'), _c('b')]);
      final container = _containerFor(repo);
      await container.read(credentialsNotifierProvider.future);

      await container.read(credentialsNotifierProvider.notifier).delete('a');

      expect(repo.deleted, ['a']);
      final list = await container.read(credentialsNotifierProvider.future);
      expect(list.map((c) => c.id), ['b']);
    });

    test('updateCredential forwards to the update use case', () async {
      final repo = _SpyCredentialRepository([_c('a', title: 'Old')]);
      final container = _containerFor(repo);
      await container.read(credentialsNotifierProvider.future);

      await container
          .read(credentialsNotifierProvider.notifier)
          .updateCredential(_c('a', title: 'Edited'));

      expect(repo.updated.single.title, 'Edited');
    });

    test('setHidden, reorder, moveToFolder and reassignFolder forward through',
        () async {
      final repo = _SpyCredentialRepository([_c('a'), _c('b')]);
      final container = _containerFor(repo);
      final notifier = container.read(credentialsNotifierProvider.notifier);
      await container.read(credentialsNotifierProvider.future);

      await notifier.setHidden('a', true);
      await notifier.reorder(['b', 'a']);
      await notifier.moveToFolder('a', 'folder-1');
      await notifier.reassignFolder('folder-1', null);

      expect(repo.hidden, [('a', true)]);
      expect(repo.reordered, [
        ['b', 'a']
      ]);
      expect(repo.moved, [('a', 'folder-1')]);
      expect(repo.reassigned, [('folder-1', null)]);
    });
  });

  group('SaveCredentialUseCase.create id handling', () {
    test('assigns a UUID when the incoming id is empty', () async {
      final repo = _SpyCredentialRepository([]);
      await SaveCredentialUseCase(repo).create(_c('', title: 'X'));
      expect(repo.saved.single.id, isNotEmpty);
    });

    test('keeps a caller-provided id', () async {
      final repo = _SpyCredentialRepository([]);
      await SaveCredentialUseCase(repo).create(_c('fixed-id', title: 'X'));
      expect(repo.saved.single.id, 'fixed-id');
    });
  });
}
