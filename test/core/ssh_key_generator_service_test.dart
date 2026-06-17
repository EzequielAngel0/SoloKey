import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/ssh_key_generator_service.dart';

void main() {
  late SshKeyGeneratorService sut;

  setUp(() {
    sut = SshKeyGeneratorService();
  });

  group('SshKeyGeneratorService', () {
    test('generates valid Ed25519 SSH key pair', () async {
      const comment = 'test-key-comment';
      final result = await sut.generateEd25519KeyPair(comment: comment);

      // Verify public key format
      expect(result.publicKey, startsWith('ssh-ed25519 '));
      final pubKeyParts = result.publicKey.split(' ');
      expect(pubKeyParts.length, equals(2)); // ssh-ed25519 <base64>
      
      final pubBase64 = pubKeyParts[1];
      final decodedPubBytes = base64Decode(pubBase64);
      expect(decodedPubBytes.length, greaterThan(32));

      // Verify private key formatting and PEM envelope
      expect(result.privateKey, startsWith('-----BEGIN OPENSSH PRIVATE KEY-----'));
      expect(result.privateKey, endsWith('-----END OPENSSH PRIVATE KEY-----'));

      // Extract private key base64 payload
      final lines = result.privateKey.split('\n');
      final payloadLines = lines.sublist(1, lines.length - 1);
      final privateKeyBase64 = payloadLines.join('').trim();
      
      final decodedPrivBytes = base64Decode(privateKeyBase64);
      
      // OpenSSH key starts with magic: "openssh-key-v1\x00"
      final magic = utf8.decode(decodedPrivBytes.sublist(0, 15));
      expect(magic, equals('openssh-key-v1\x00'));
    });
  });
}
