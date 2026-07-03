import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/otpauth_import_service.dart';
import 'package:password_manager/features/credentials/domain/entities/credential.dart';

void main() {
  final service = OtpAuthImportService();

  group('OtpAuthImportService', () {
    test('parses a single otpauth totp URI with issuer:account label', () {
      const uri =
          'otpauth://totp/GitHub:octocat@example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub';
      final creds = service.parse(uri);

      expect(creds, hasLength(1));
      final c = creds.single;
      expect(c.type, CredentialType.totp);
      expect(c.title, 'GitHub');
      expect(c.username, 'octocat@example.com');
      expect(c.password, 'JBSWY3DPEHPK3PXP'); // secret stored in password
    });

    test('derives issuer from the label when no issuer query param', () {
      const uri = 'otpauth://totp/ACME:alice?secret=ABCDEF2345';
      final c = service.parse(uri).single;
      expect(c.title, 'ACME');
      expect(c.username, 'alice');
    });

    test('uses the account label as title when there is no issuer', () {
      const uri = 'otpauth://totp/just-an-account?secret=ABCDEF2345';
      final c = service.parse(uri).single;
      expect(c.title, 'just-an-account');
      expect(c.username, 'just-an-account');
    });

    test('parses multiple newline-separated URIs', () {
      const content = '''
otpauth://totp/A:a?secret=AAAAAAAA&issuer=A
otpauth://totp/B:b?secret=BBBBBBBB&issuer=B
otpauth://totp/C:c?secret=CCCCCCCC&issuer=C
''';
      final creds = service.parse(content);
      expect(creds, hasLength(3));
      expect(creds.map((c) => c.title), containsAll(['A', 'B', 'C']));
      expect(creds.every((c) => c.type == CredentialType.totp), isTrue);
    });

    test('skips URIs without a secret and non-otpauth text', () {
      const content = '''
otpauth://totp/NoSecret:x?issuer=NoSecret
https://example.com/not-a-token
otpauth://totp/Good:g?secret=ZZZZZZZZ&issuer=Good
''';
      final creds = service.parse(content);
      expect(creds, hasLength(1));
      expect(creds.single.title, 'Good');
    });

    test('returns empty for content with no otpauth links', () {
      expect(service.parse('just some random text'), isEmpty);
    });

    test('detects a Google Authenticator migration payload', () {
      const migration =
          'otpauth-migration://offline?data=CjEKCkhlbGxvId6tvu8SBWFsaWNlGgVBQ01FIAEoATACEAEYASAAKN2Vp7oF';
      expect(service.containsMigrationPayload(migration), isTrue);
      // The migration protobuf isn't decoded, so no credentials come out.
      expect(service.parse(migration), isEmpty);
      expect(service.containsMigrationPayload('otpauth://totp/x?secret=A'),
          isFalse);
    });
  });
}
