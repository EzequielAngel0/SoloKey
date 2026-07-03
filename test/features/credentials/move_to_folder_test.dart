import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

import '../../support/fake_credential_repository.dart';

Credential _c(String id, {String? categoryId}) => Credential(
      id: id,
      type: CredentialType.password,
      title: id,
      categoryId: categoryId,
      password: 'p',
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

ProviderContainer _container(FakeCredentialRepository repo) {
  final c = ProviderContainer(overrides: [
    getCredentialsUseCaseProvider
        .overrideWithValue(GetCredentialsUseCase(repo)),
    saveCredentialUseCaseProvider
        .overrideWithValue(SaveCredentialUseCase(repo)),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('moveToFolder assigns the credential to the target folder', () async {
    final repo = FakeCredentialRepository([_c('gh')]); // unfiled
    final c = _container(repo);
    await c.read(credentialsNotifierProvider.future);

    await c
        .read(credentialsNotifierProvider.notifier)
        .moveToFolder('gh', 'work');

    expect(repo.credentials.single.categoryId, 'work');
  });

  test('moveToFolder with null releases the credential to the vault root',
      () async {
    final repo = FakeCredentialRepository([_c('gh', categoryId: 'work')]);
    final c = _container(repo);
    await c.read(credentialsNotifierProvider.future);

    await c
        .read(credentialsNotifierProvider.notifier)
        .moveToFolder('gh', null);

    expect(repo.credentials.single.categoryId, isNull);
  });
}
