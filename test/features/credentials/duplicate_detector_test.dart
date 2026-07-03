import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/application/duplicate_detector.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

Credential _cred({
  required String id,
  CredentialType type = CredentialType.password,
  String? username,
  String? website,
}) => Credential(
  id: id,
  type: type,
  title: id,
  username: username,
  website: website,
  createdAt: DateTime(2020),
  updatedAt: DateTime(2020),
);

void main() {
  final existing = [
    _cred(id: 'a', username: 'octocat', website: 'https://github.com'),
    _cred(id: 'b', username: 'alice', website: 'https://gitlab.com'),
  ];

  Credential? find(
    String username,
    String website, {
    CredentialType type = CredentialType.password,
    String? excludeId,
  }) => findDuplicate(
    all: existing,
    type: type,
    username: username,
    website: website,
    excludeId: excludeId,
  );

  test('matches same type + username + host', () {
    expect(find('octocat', 'github.com')?.id, 'a');
  });

  test('normalises case, scheme and www. when comparing', () {
    expect(find('OCTOCAT', 'http://www.github.com/login')?.id, 'a');
  });

  test('no match when the host differs', () {
    expect(find('octocat', 'bitbucket.org'), isNull);
  });

  test('an empty username never matches (notes/TOTP/SSH)', () {
    expect(find('', 'github.com'), isNull);
  });

  test('matches on username alone when the new entry has no website', () {
    expect(find('octocat', '')?.id, 'a');
  });

  test('excludes the credential being edited', () {
    expect(find('octocat', 'github.com', excludeId: 'a'), isNull);
  });

  test('a different type does not match', () {
    expect(find('octocat', 'github.com', type: CredentialType.apiKey), isNull);
  });
}
