import 'dart:convert';

class PairingPayload {
  const PairingPayload({
    required this.ip,
    required this.port,
    required this.pairingToken,
    required this.desktopPublicKeyHex,
  });

  final String ip;
  final int port;
  final String pairingToken;
  final String desktopPublicKeyHex;

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'port': port,
        'pairing_token': pairingToken,
        'desktop_public_key': desktopPublicKeyHex,
      };

  factory PairingPayload.fromJson(Map<String, dynamic> json) => PairingPayload(
        ip: json['ip'] as String,
        port: json['port'] as int,
        pairingToken: json['pairing_token'] as String,
        desktopPublicKeyHex: json['desktop_public_key'] as String,
      );

  String toQrString() => jsonEncode(toJson());

  factory PairingPayload.fromQrString(String qrStr) =>
      PairingPayload.fromJson(jsonDecode(qrStr) as Map<String, dynamic>);
}
