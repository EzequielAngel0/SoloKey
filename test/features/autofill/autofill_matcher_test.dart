import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/autofill/application/autofill_matcher.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

Credential _c({
  required String id,
  String? website,
  CredentialType type = CredentialType.password,
}) =>
    Credential(
      id: id,
      type: type,
      title: 'cred-$id',
      website: website,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

void main() {
  group('AutofillMatcher.extractDomain', () {
    test('strips scheme, path and www', () {
      expect(AutofillMatcher.extractDomain('https://www.github.com/login'),
          'github.com');
    });

    test('accepts a naked domain (no scheme)', () {
      expect(AutofillMatcher.extractDomain('github.com'), 'github.com');
    });

    test('keeps subdomains other than www', () {
      expect(AutofillMatcher.extractDomain('https://accounts.google.com'),
          'accounts.google.com');
    });
  });

  group('AutofillMatcher.match — domain', () {
    test('matches when the stored site contains the caller domain', () {
      final creds = [_c(id: '1', website: 'https://github.com')];
      final out = AutofillMatcher.match(creds, webDomain: 'github.com');
      expect(out.map((c) => c.id), ['1']);
    });

    test('matches a broader stored site from a subdomain caller (vice-versa)',
        () {
      // stored: google.com ; caller: accounts.google.com → should still match.
      final creds = [_c(id: '1', website: 'https://google.com')];
      final out = AutofillMatcher.match(creds, webDomain: 'accounts.google.com');
      expect(out.map((c) => c.id), ['1']);
    });

    test('matches a subdomain stored site from a broader caller', () {
      final creds = [_c(id: '1', website: 'https://accounts.google.com')];
      final out = AutofillMatcher.match(creds, webDomain: 'google.com');
      expect(out.map((c) => c.id), ['1']);
    });

    test('does not match unrelated domains', () {
      final creds = [_c(id: '1', website: 'https://example.com')];
      final out = AutofillMatcher.match(creds, webDomain: 'github.com');
      expect(out, isEmpty);
    });
  });

  group('AutofillMatcher.match — package-name fallback', () {
    test('matches when the site contains the package tail', () {
      final creds = [_c(id: '1', website: 'https://open.spotify.com')];
      final out = AutofillMatcher.match(creds, packageName: 'com.spotify');
      expect(out.map((c) => c.id), ['1']);
    });

    test('tails of length <= 2 do not create noise', () {
      // tail 'io' (len 2) must NOT match even though the site contains "io".
      final creds = [_c(id: '1', website: 'https://mysite.io')];
      final out = AutofillMatcher.match(creds, packageName: 'com.io');
      expect(out, isEmpty);
    });
  });

  group('AutofillMatcher.match — filters', () {
    test('only password-type credentials are eligible', () {
      final creds = [
        _c(id: 'k', website: 'https://github.com', type: CredentialType.apiKey),
        _c(id: 'n', website: 'https://github.com', type: CredentialType.secureNote),
      ];
      final out = AutofillMatcher.match(creds, webDomain: 'github.com');
      expect(out, isEmpty);
    });

    test('credentials without a website are ignored', () {
      final creds = [
        _c(id: '1', website: null),
        _c(id: '2', website: ''),
      ];
      final out = AutofillMatcher.match(creds, webDomain: 'github.com');
      expect(out, isEmpty);
    });

    test('empty caller (no domain, no package) matches nothing', () {
      final creds = [_c(id: '1', website: 'https://github.com')];
      expect(AutofillMatcher.match(creds), isEmpty);
    });

    test('respects the limit', () {
      final creds = List.generate(
        6,
        (i) => _c(id: '$i', website: 'https://github.com'),
      );
      final out = AutofillMatcher.match(creds, webDomain: 'github.com', limit: 3);
      expect(out.length, 3);
    });
  });
}
