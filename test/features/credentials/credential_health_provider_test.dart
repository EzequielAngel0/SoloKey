import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/credential_health_provider.dart';
import 'package:password_manager/features/credentials/application/credential_use_cases.dart';
import 'package:password_manager/features/credentials/application/credentials_provider.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

import '../../support/fake_credential_repository.dart';

Credential _c({
  required String id,
  String? password,
  CredentialType type = CredentialType.password,
}) =>
    Credential(
      id: id,
      type: type,
      title: 'cred-$id',
      password: password,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

/// Builds a container whose vault resolves to [creds], then awaits it so the
/// synchronous [credentialHealthProvider] sees data (not the loading value).
Future<Map<String, Set<CredentialHealth>>> _healthOf(
    List<Credential> creds) async {
  final container = ProviderContainer(
    overrides: [
      getCredentialsUseCaseProvider
          .overrideWithValue(GetCredentialsUseCase(FakeCredentialRepository(creds))),
    ],
  );
  addTearDown(container.dispose);
  await container.read(credentialsNotifierProvider.future);
  return container.read(credentialHealthProvider);
}

void main() {
  group('credentialHealthProvider — weak detection', () {
    test('short password (<8) is weak', () async {
      final health = await _healthOf([_c(id: '1', password: 'abc1')]);
      expect(health['1'], contains(CredentialHealth.weak));
    });

    test('digits-only password is weak', () async {
      final health = await _healthOf([_c(id: '1', password: '12345678')]);
      expect(health['1'], contains(CredentialHealth.weak));
    });

    test('letters-only and short-ish (<12) is weak', () async {
      final health = await _healthOf([_c(id: '1', password: 'abcdefghij')]);
      expect(health['1'], contains(CredentialHealth.weak));
    });

    test('letters-only but long (>=12) is NOT weak', () async {
      final health = await _healthOf([_c(id: '1', password: 'abcdefghijklmnop')]);
      expect(health['1'], isNull);
    });

    test('strong mixed password is not flagged', () async {
      final health = await _healthOf([_c(id: '1', password: 'Abcdef1!ghij')]);
      expect(health['1'], isNull);
    });
  });

  group('credentialHealthProvider — reuse detection', () {
    test('two credentials with the same password are both reused', () async {
      final health = await _healthOf([
        _c(id: '1', password: 'SharedPass99'),
        _c(id: '2', password: 'SharedPass99'),
      ]);
      expect(health['1'], contains(CredentialHealth.reused));
      expect(health['2'], contains(CredentialHealth.reused));
    });

    test('a unique password is not reused', () async {
      final health = await _healthOf([
        _c(id: '1', password: 'UniqueOne99'),
        _c(id: '2', password: 'UniqueTwo99'),
      ]);
      expect(health['1'], isNot(contains(CredentialHealth.reused)));
      expect(health['2'], isNot(contains(CredentialHealth.reused)));
    });
  });

  group('credentialHealthProvider — non-password types are never scored', () {
    test('SSH, passkey and TOTP with weak-looking secrets are ignored', () async {
      final health = await _healthOf([
        _c(id: 's', password: 'abc', type: CredentialType.sshKey),
        _c(id: 'p', password: 'abc', type: CredentialType.passkey),
        _c(id: 't', password: 'abc', type: CredentialType.totp),
      ]);
      expect(health, isEmpty);
    });

    test('same secret across a password and an SSH key: only the password reused',
        () async {
      final health = await _healthOf([
        _c(id: 'pw1', password: 'Repeated123'),
        _c(id: 'pw2', password: 'Repeated123'),
        _c(id: 'ssh', password: 'Repeated123', type: CredentialType.sshKey),
      ]);
      expect(health['ssh'], isNull);
      expect(health['pw1'], contains(CredentialHealth.reused));
      expect(health['pw2'], contains(CredentialHealth.reused));
    });

    test('apiKey passwords ARE scored', () async {
      final health = await _healthOf([
        _c(id: 'k', password: 'abc', type: CredentialType.apiKey),
      ]);
      expect(health['k'], contains(CredentialHealth.weak));
    });
  });

  group('credentialHealthProvider — empty/absent secrets', () {
    test('null or empty passwords are not flagged', () async {
      final health = await _healthOf([
        _c(id: 'n', password: null),
        _c(id: 'e', password: ''),
      ]);
      expect(health, isEmpty);
    });
  });
}
