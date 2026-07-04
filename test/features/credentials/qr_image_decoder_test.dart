import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:password_manager/features/credentials/domain/otpauth.dart';
import 'package:password_manager/features/credentials/infrastructure/qr_image_decoder.dart';

void main() {
  group('decodeQrFromImageBytes', () {
    test('decodes an otpauth QR from a PNG fixture and it parses back', () {
      // Fixture generated from
      // otpauth://totp/SoloKey:tester@example.com?secret=JBSWY3DPEHPK3PXP&issuer=SoloKey
      final bytes = File('test/fixtures/totp_qr.png').readAsBytesSync();

      final text = decodeQrFromImageBytes(bytes);

      expect(text, isNotNull, reason: 'the fixture QR should decode');
      expect(text, startsWith('otpauth://totp/'));

      final otp = OtpauthParser.parse(text!);
      expect(otp, isNotNull);
      expect(otp!.secret, 'JBSWY3DPEHPK3PXP');
      expect(otp.issuer, 'SoloKey');
      expect(otp.accountName, 'tester@example.com');
      expect(otp.isStandard, isTrue);
    });

    test('returns null for an image that contains no QR code', () {
      final blank = img.Image(width: 200, height: 200);
      final png = img.encodePng(blank);

      expect(decodeQrFromImageBytes(png), isNull);
    });

    test('returns null for bytes that are not a decodable image', () {
      expect(
        decodeQrFromImageBytes(Uint8List.fromList([0, 1, 2, 3, 4, 5])),
        isNull,
      );
    });

    test('returns null for empty bytes', () {
      expect(decodeQrFromImageBytes(Uint8List(0)), isNull);
    });
  });
}
