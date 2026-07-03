import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/csv_import_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';
import 'package:password_manager/features/credentials/domain/entities/password_history.dart';
import 'package:password_manager/features/credentials/domain/repositories/i_credential_repository.dart';

class FakeCredentialRepository implements ICredentialRepository {
  final List<Credential> saved = [];

  @override
  Future<List<Credential>> getAll() async => saved;

  @override
  Future<Credential?> getById(String id) async => null;

  @override
  Future<void> save(Credential credential) async {
    saved.add(credential);
  }

  @override
  Future<void> update(Credential credential) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Credential>> getByCategory(String categoryId) async => [];

  @override
  Future<List<Credential>> getFavorites() async => [];

  @override
  Future<List<Credential>> search(String query) async => [];

  @override
  Future<List<PasswordHistory>> getPasswordHistory(String credentialId) async => [];

  @override
  Future<void> setHidden(String id, bool hidden) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}

  @override
  Future<void> moveToFolder(String id, String? folderId) async {}

  @override
  Future<void> reassignFolder(String fromFolderId, String? toFolderId) async {}
}

void main() {
  group('CsvImportService Tests', () {
    test('Parses Bitwarden CSV format correctly', () {
      const csv = '''folder,favorite,type,name,notes,fields,login_uri,login_username,login_password,login_totp
Work,1,login,GitHub,My notes,,https://github.com,octocat,git-pass-123,
Personal,0,login,Google Account,My personal notes,,https://google.com,user@gmail.com,gmail-pass-456,JBSWY3DPEHPK3PXP
''';

      final repo = FakeCredentialRepository();
      final service = CsvImportService(repo);
      final credentials = service.parseCsv(csv);

      expect(credentials.length, 2);

      final github = credentials.firstWhere((c) => c.title == 'GitHub');
      expect(github.username, 'octocat');
      expect(github.password, 'git-pass-123');
      expect(github.website, 'https://github.com');
      expect(github.notes, 'My notes');
      expect(github.type, CredentialType.password);

      // A login row that ALSO carries a TOTP secret is a login with 2FA: it must
      // stay a password credential with the real login password preserved (not
      // turn into a TOTP whose "seed" is the login password).
      final google = credentials.firstWhere((c) => c.title == 'Google Account');
      expect(google.username, 'user@gmail.com');
      expect(google.password, 'gmail-pass-456'); // login password preserved
      expect(google.type, CredentialType.password);
    });

    test('TOTP-only row (no login password) becomes an authenticator', () {
      const csv = '''folder,favorite,type,name,notes,fields,login_uri,login_username,login_password,login_totp
,0,login,GitHub 2FA,,,,octocat,,JBSWY3DPEHPK3PXP
''';

      final service = CsvImportService(FakeCredentialRepository());
      final cred = service.parseCsv(csv).single;

      expect(cred.type, CredentialType.totp);
      expect(cred.password, 'JBSWY3DPEHPK3PXP'); // the actual TOTP seed
      expect(cred.username, 'octocat');
    });

    test('login row with both password and TOTP keeps the login password', () {
      const csv = '''name,url,username,password,login_totp
Bank,https://bank.com,me,super-secret,JBSWY3DPEHPK3PXP
''';

      final service = CsvImportService(FakeCredentialRepository());
      final cred = service.parseCsv(csv).single;

      expect(cred.type, CredentialType.password);
      expect(cred.password, 'super-secret'); // not the TOTP seed
    });

    test('Parses Google Chrome CSV format correctly', () {
      const csv = '''name,url,username,password
Netflix,https://netflix.com,netflix-user,netflix-pass
Spotify,https://spotify.com,spotify-user,spotify-pass
''';

      final repo = FakeCredentialRepository();
      final service = CsvImportService(repo);
      final credentials = service.parseCsv(csv);

      expect(credentials.length, 2);

      final netflix = credentials.firstWhere((c) => c.title == 'Netflix');
      expect(netflix.username, 'netflix-user');
      expect(netflix.password, 'netflix-pass');
      expect(netflix.website, 'https://netflix.com');
      expect(netflix.type, CredentialType.password);
    });

    test('Parses 1Password CSV format correctly', () {
      const csv = '''title,website,username,password,notes
AWS,https://aws.amazon.com,aws-user,aws-pass,my aws notes
''';

      final repo = FakeCredentialRepository();
      final service = CsvImportService(repo);
      final credentials = service.parseCsv(csv);

      expect(credentials.length, 1);

      final aws = credentials.first;
      expect(aws.title, 'AWS');
      expect(aws.username, 'aws-user');
      expect(aws.password, 'aws-pass');
      expect(aws.website, 'https://aws.amazon.com');
      expect(aws.notes, 'my aws notes');
    });
  });
}
