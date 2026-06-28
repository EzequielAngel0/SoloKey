import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/sync/domain/pairing_payload.dart';

void main() {
  group('PairingPayload', () {
    const payload = PairingPayload(
      ip: '192.168.1.45',
      port: 8283,
      pairingToken: '7f8a9b2c3d4e5f6a',
      desktopPublicKeyHex: 'AAECAwQF',
    );

    test('toJson/fromJson round-trip preserves all fields', () {
      final back = PairingPayload.fromJson(payload.toJson());
      expect(back.ip, payload.ip);
      expect(back.port, payload.port);
      expect(back.pairingToken, payload.pairingToken);
      expect(back.desktopPublicKeyHex, payload.desktopPublicKeyHex);
    });

    test('QR string round-trip (what the scanner reads)', () {
      final back = PairingPayload.fromQrString(payload.toQrString());
      expect(back.ip, payload.ip);
      expect(back.port, payload.port);
      expect(back.pairingToken, payload.pairingToken);
      expect(back.desktopPublicKeyHex, payload.desktopPublicKeyHex);
    });

    test('JSON uses the snake_case keys the mobile/desktop sides agree on', () {
      final json = payload.toJson();
      expect(json.containsKey('pairing_token'), isTrue);
      expect(json.containsKey('desktop_public_key'), isTrue);
    });

    test('fromQrString throws on malformed input', () {
      expect(() => PairingPayload.fromQrString('not-json'), throwsA(anything));
    });
  });
}
