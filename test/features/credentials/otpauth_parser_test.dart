import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/credentials/domain/otpauth.dart';

void main() {
  group('OtpauthParser.parse', () {
    test('parses a full URI with all parameters', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/GitHub:alice@example.com'
        '?secret=JBSWY3DPEHPK3PXP&issuer=GitHub'
        '&algorithm=SHA256&digits=8&period=60',
      );

      expect(otp, isNotNull);
      expect(otp!.secret, 'JBSWY3DPEHPK3PXP');
      expect(otp.type, 'totp');
      expect(otp.issuer, 'GitHub');
      expect(otp.accountName, 'alice@example.com');
      expect(otp.algorithm, 'SHA256');
      expect(otp.digits, 8);
      expect(otp.period, 60);
      expect(otp.isStandard, isFalse);
    });

    test('fills documented defaults when optional params are absent', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/Example?secret=JBSWY3DPEHPK3PXP',
      );

      expect(otp, isNotNull);
      expect(otp!.secret, 'JBSWY3DPEHPK3PXP');
      expect(otp.algorithm, 'SHA1');
      expect(otp.digits, 6);
      expect(otp.period, 30);
      expect(otp.issuer, isNull);
      expect(otp.accountName, 'Example');
      expect(otp.isStandard, isTrue);
    });

    test('derives issuer from the label prefix when no issuer param', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/ACME%20Co:john?secret=ABCDEFGH',
      );

      expect(otp, isNotNull);
      expect(otp!.issuer, 'ACME Co');
      expect(otp.accountName, 'john');
    });

    test('issuer query param wins over the label prefix', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/Wrong:john?secret=ABCDEFGH&issuer=Correct',
      );

      expect(otp!.issuer, 'Correct');
      expect(otp.accountName, 'john');
    });

    test('normalises the algorithm to upper case', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/x?secret=ABCDEFGH&algorithm=sha512',
      );

      expect(otp!.algorithm, 'SHA512');
    });

    test('recognises the hotp type from the host', () {
      final otp = OtpauthParser.parse(
        'otpauth://hotp/x?secret=ABCDEFGH&counter=0',
      );

      expect(otp!.type, 'hotp');
      expect(otp.isStandard, isFalse);
    });

    test('falls back to defaults on malformed numeric params', () {
      final otp = OtpauthParser.parse(
        'otpauth://totp/x?secret=ABCDEFGH&digits=abc&period=-5',
      );

      expect(otp!.digits, 6);
      expect(otp.period, 30);
    });

    test('accepts an upper-case scheme', () {
      final otp = OtpauthParser.parse(
        'OTPAUTH://TOTP/x?secret=ABCDEFGH',
      );

      expect(otp, isNotNull);
      expect(otp!.type, 'totp');
    });

    test('returns null for a non-otpauth scheme', () {
      expect(OtpauthParser.parse('https://example.com/?secret=X'), isNull);
    });

    test('returns null when the secret is missing', () {
      expect(OtpauthParser.parse('otpauth://totp/Example?issuer=X'), isNull);
    });

    test('returns null for an empty or garbage payload', () {
      expect(OtpauthParser.parse(''), isNull);
      expect(OtpauthParser.parse('   '), isNull);
      expect(OtpauthParser.parse('not a uri at all'), isNull);
    });

    test('trims surrounding whitespace before parsing', () {
      final otp = OtpauthParser.parse(
        '  otpauth://totp/x?secret=ABCDEFGH  ',
      );

      expect(otp, isNotNull);
      expect(otp!.secret, 'ABCDEFGH');
    });
  });
}
