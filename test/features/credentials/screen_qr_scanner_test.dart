import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:password_manager/features/credentials/infrastructure/screen_qr_scanner.dart';

void main() {
  // These exercise the scanner orchestration with an injected capture function,
  // so they run without a real screen. isSupported is true on desktop CI hosts.
  group('ScreenQrScanner.captureAndDecode', () {
    final fixture = File('test/fixtures/totp_qr.png').readAsBytesSync();

    test('ok with the decoded payload when the region holds a QR', () async {
      final scanner = ScreenQrScanner(capture: () async => fixture);

      final result = await scanner.captureAndDecode();

      expect(result.status, ScreenQrStatus.ok);
      expect(result.payload, startsWith('otpauth://totp/'));
    });

    test('cancelled when the capture returns null (user backed out)', () async {
      final scanner = ScreenQrScanner(capture: () async => null);

      final result = await scanner.captureAndDecode();

      expect(result.status, ScreenQrStatus.cancelled);
      expect(result.payload, isNull);
    });

    test('noQr when the captured image has no decodable QR', () async {
      final blank = Uint8List.fromList(
        img.encodePng(img.Image(width: 120, height: 120)),
      );
      final scanner = ScreenQrScanner(capture: () async => blank);

      final result = await scanner.captureAndDecode();

      expect(result.status, ScreenQrStatus.noQr);
    });

    test('error when the capture step throws', () async {
      final scanner = ScreenQrScanner(
        capture: () async => throw Exception('capture failed'),
      );

      final result = await scanner.captureAndDecode();

      expect(result.status, ScreenQrStatus.error);
    });
  });
}
