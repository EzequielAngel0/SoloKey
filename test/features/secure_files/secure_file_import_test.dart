import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/secure_files/application/secure_file_import.dart';

void main() {
  group('isWithinSecureFileLimit', () {
    test('accepts files at or below the cap', () {
      expect(isWithinSecureFileLimit(0), isTrue);
      expect(isWithinSecureFileLimit(kMaxSecureFileBytes), isTrue);
    });

    test('rejects files above the cap', () {
      expect(isWithinSecureFileLimit(kMaxSecureFileBytes + 1), isFalse);
    });
  });

  group('uniqueSecureFileName', () {
    test('returns the candidate when there is no collision', () {
      expect(uniqueSecureFileName('id_rsa.pem', const {}), 'id_rsa.pem');
      expect(uniqueSecureFileName('a.txt', {'b.txt'}), 'a.txt');
    });

    test('suffixes before the extension on collision', () {
      expect(uniqueSecureFileName('id_rsa.pem', {'id_rsa.pem'}), 'id_rsa (2).pem');
    });

    test('walks up until a free suffix is found', () {
      final taken = {'notes.txt', 'notes (2).txt', 'notes (3).txt'};
      expect(uniqueSecureFileName('notes.txt', taken), 'notes (4).txt');
    });

    test('is case-insensitive', () {
      expect(uniqueSecureFileName('Creds.JSON', {'creds.json'}), 'Creds (2).JSON');
    });

    test('appends to the whole name for extensionless files', () {
      expect(uniqueSecureFileName('README', {'README'}), 'README (2)');
    });

    test('treats a leading-dot dotfile as having no extension', () {
      expect(uniqueSecureFileName('.env', {'.env'}), '.env (2)');
    });
  });

  group('formatFileSize', () {
    test('formats bytes, KB and MB', () {
      expect(formatFileSize(512), '512 B');
      expect(formatFileSize(1536), '1.5 KB');
      expect(formatFileSize(3 * 1024 * 1024), '3.0 MB');
    });
  });
}
