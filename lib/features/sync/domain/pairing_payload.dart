import 'dart:convert';

/// Lo que muestra el QR del escritorio (sync v2, NUC-3): donde esta, su llave publica fija (Noise IK) y el token
/// de un solo emparejamiento. `v` dice la version del protocolo para avisar si el otro tiene la v1.
class PairingPayload {
  const PairingPayload({
    required this.ip,
    required this.port,
    required this.pairingToken,
    required this.desktopPublicKey,
    this.version = kSyncProtocolVersion,
  });

  final String ip;
  final int port;
  final String pairingToken;

  /// Llave publica X25519 fija del escritorio, en base64.
  final String desktopPublicKey;
  final int version;

  Map<String, dynamic> toJson() => {
        'v': version,
        'ip': ip,
        'port': port,
        'token': pairingToken,
        'pub': desktopPublicKey,
      };

  /// Lanza [PeerVersionException] si el QR es de otra version (el de la v1 no trae `v`).
  factory PairingPayload.fromJson(Map<String, dynamic> json) {
    final v = json['v'];
    if (v != kSyncProtocolVersion) {
      throw PeerVersionException(isV1: v == null);
    }
    return PairingPayload(
      ip: json['ip'] as String,
      port: json['port'] as int,
      pairingToken: json['token'] as String,
      desktopPublicKey: json['pub'] as String,
    );
  }

  String toQrString() => jsonEncode(toJson());

  factory PairingPayload.fromQrString(String qrStr) =>
      PairingPayload.fromJson(jsonDecode(qrStr) as Map<String, dynamic>);
}

/// Version del protocolo de sync de esta app (la del nucleo, `syncProtocolVersion`).
const int kSyncProtocolVersion = 2;

/// El otro equipo habla otra version de la sync: una v1 y una v2 no se mezclan.
class PeerVersionException implements Exception {
  const PeerVersionException({required this.isV1});

  final bool isV1;

  @override
  String toString() => isV1 ? kPeerV1Message : kPeerOtherVersionMessage;
}

/// Aviso para el usuario cuando el otro equipo tiene la v1 (o una version que esta no entiende).
const String kPeerV1Message =
    'El otro equipo tiene SoloKey 1. Actualiza los dos a SoloKey 2 para sincronizar.';
const String kPeerOtherVersionMessage =
    'El otro equipo tiene otra version de SoloKey. Actualiza los dos a la misma para sincronizar.';
