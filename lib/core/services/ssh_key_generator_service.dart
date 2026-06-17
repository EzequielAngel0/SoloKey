import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

/// Resultado de la generación de un par de llaves SSH.
class SshKeyPairResult {
  final String privateKey;
  final String publicKey;

  SshKeyPairResult({
    required this.privateKey,
    required this.publicKey,
  });
}

/// Servicio encargado de generar de forma segura pares de llaves SSH Ed25519.
///
/// Formatea los resultados en los formatos estándar ssh-ed25519 y OpenSSH PEM.
@lazySingleton
class SshKeyGeneratorService {
  /// Genera un par de llaves Ed25519 y las devuelve formateadas en OpenSSH.
  Future<SshKeyPairResult> generateEd25519KeyPair({String comment = 'solokey-key'}) async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBytes = publicKey.bytes;

    final pubKeyFormatted = _formatSshPublicKey(publicKeyBytes);
    final privKeyFormatted = _formatOpenSshPrivateKey(
      privateKeyBytes,
      publicKeyBytes,
      comment: comment,
    );

    return SshKeyPairResult(
      privateKey: privKeyFormatted,
      publicKey: pubKeyFormatted,
    );
  }

  String _formatSshPublicKey(List<int> pubBytes) {
    final builder = BytesBuilder();
    const typeStr = 'ssh-ed25519';

    // Escribir tipo
    builder.add(_uint32Bytes(typeStr.length));
    builder.add(utf8.encode(typeStr));

    // Escribir bytes de llave pública
    builder.add(_uint32Bytes(pubBytes.length));
    builder.add(pubBytes);

    final base64Pub = base64Encode(builder.toBytes());
    return 'ssh-ed25519 $base64Pub';
  }

  String _formatOpenSshPrivateKey(
    List<int> privBytes,
    List<int> pubBytes, {
    required String comment,
  }) {
    final builder = BytesBuilder();

    // 1. Magic Header
    builder.add(utf8.encode('openssh-key-v1\x00'));

    // 2. Ciphername: "none"
    builder.add(_stringBytes('none'));

    // 3. Kdfname: "none"
    builder.add(_stringBytes('none'));

    // 4. Kdfoptions: "" (vacío, longitud 0)
    builder.add(_uint32Bytes(0));

    // 5. Num keys: 1
    builder.add(_uint32Bytes(1));

    // 6. Pubkey block (con prefijo de longitud)
    final pubBuilder = BytesBuilder();
    pubBuilder.add(_stringBytes('ssh-ed25519'));
    pubBuilder.add(_stringBytesFromList(pubBytes));
    builder.add(_stringBytesFromList(pubBuilder.toBytes()));

    // 7. Private key block (con prefijo de longitud)
    final privBlockBuilder = BytesBuilder();

    // checkint1, checkint2 (números aleatorios idénticos para verificar integridad)
    final rand = Random.secure();
    final checkInt = rand.nextInt(0xFFFFFFFF);
    privBlockBuilder.add(_uint32Bytes(checkInt));
    privBlockBuilder.add(_uint32Bytes(checkInt));

    // Tipo de llave
    privBlockBuilder.add(_stringBytes('ssh-ed25519'));

    // Llave pública
    privBlockBuilder.add(_stringBytesFromList(pubBytes));

    // Llave privada (32-byte seed + 32-byte pubkey para Ed25519)
    final fullPrivBytes = Uint8List(64);
    fullPrivBytes.setAll(0, privBytes);
    fullPrivBytes.setAll(32, pubBytes);
    privBlockBuilder.add(_stringBytesFromList(fullPrivBytes));

    // Comentario
    privBlockBuilder.add(_stringBytes(comment));

    // Relleno (padding) para alinear el bloque a un múltiplo de 8 bytes
    final privBlockBytes = privBlockBuilder.toBytes();
    final padLength = 8 - (privBlockBytes.length % 8);
    if (padLength > 0 && padLength < 8) {
      for (var i = 1; i <= padLength; i++) {
        privBlockBuilder.addByte(i);
      }
    }

    builder.add(_stringBytesFromList(privBlockBuilder.toBytes()));
    final base64Payload = base64Encode(builder.toBytes());

    // Dividir en líneas de 70 caracteres
    final chunks = <String>[];
    for (var i = 0; i < base64Payload.length; i += 70) {
      chunks.add(base64Payload.substring(i, min(i + 70, base64Payload.length)));
    }

    final buffer = StringBuffer();
    buffer.writeln('-----BEGIN OPENSSH PRIVATE KEY-----');
    for (final chunk in chunks) {
      buffer.writeln(chunk);
    }
    buffer.write('-----END OPENSSH PRIVATE KEY-----');

    return buffer.toString();
  }

  Uint8List _uint32Bytes(int val) {
    final bytes = ByteData(4);
    bytes.setUint32(0, val, Endian.big);
    return bytes.buffer.asUint8List();
  }

  Uint8List _stringBytes(String s) {
    final encoded = utf8.encode(s);
    final builder = BytesBuilder();
    builder.add(_uint32Bytes(encoded.length));
    builder.add(encoded);
    return builder.toBytes();
  }

  Uint8List _stringBytesFromList(List<int> bytes) {
    final builder = BytesBuilder();
    builder.add(_uint32Bytes(bytes.length));
    builder.add(bytes);
    return builder.toBytes();
  }
}
