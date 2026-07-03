import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../features/credentials/domain/entities/credential.dart';
import '../../features/credentials/domain/repositories/i_credential_repository.dart';

@lazySingleton
class CsvImportService {
  CsvImportService(this._credRepo);

  final ICredentialRepository _credRepo;

  /// Parses a CSV string into a list of credentials.
  List<Credential> parseCsv(String csvContent) {
    final rows = _parseCsvRows(csvContent);
    if (rows.isEmpty) return [];

    final headers = rows.first.map((e) => e.trim().toLowerCase()).toList();
    final credentials = <Credential>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final rowMap = <String, String>{};
      for (var j = 0; j < headers.length && j < row.length; j++) {
        rowMap[headers[j]] = row[j];
      }

      final cred = _mapRowToCredential(rowMap);
      if (cred != null) {
        credentials.add(cred);
      }
    }

    return credentials;
  }

  /// Parses CSV format complying with RFC 4180
  List<List<String>> _parseCsvRows(String content) {
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentField = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < content.length && content[i + 1] == '"') {
            currentField.write('"');
            i++; // skip next quote
          } else {
            inQuotes = false;
          }
        } else {
          currentField.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentField.toString());
          currentField.clear();
        } else if (char == '\r') {
          if (i + 1 < content.length && content[i + 1] == '\n') {
            i++;
          }
          currentRow.add(currentField.toString());
          currentField.clear();
          rows.add(List.from(currentRow));
          currentRow.clear();
        } else if (char == '\n') {
          currentRow.add(currentField.toString());
          currentField.clear();
          rows.add(List.from(currentRow));
          currentRow.clear();
        } else {
          currentField.write(char);
        }
      }
    }

    if (currentRow.isNotEmpty || currentField.isNotEmpty) {
      currentRow.add(currentField.toString());
      rows.add(currentRow);
    }

    return rows;
  }

  Credential? _mapRowToCredential(Map<String, String> row) {
    final title = _getField(row, ['name', 'title', 'title_name', 'nombre']) ?? 'Sin título';
    final username = _getField(row, ['login_username', 'username', 'usuario', 'user']);
    final password = _getField(row, ['login_password', 'password', 'contraseña', 'pass', 'api_key', 'key']);
    final website = _getField(row, ['login_uri', 'website', 'url', 'uri', 'sitio web']);
    final notes = _getField(row, ['notes', 'note', 'notas', 'desc']);
    final totp = _getField(row, ['login_totp', 'totp', 'secret', 'otp']);

    final now = DateTime.now();
    final titleLower = title.toLowerCase();
    final hasPassword = password != null && password.isNotEmpty;
    final hasTotp = totp != null && totp.isNotEmpty;

    // Determine type. A row carrying BOTH a login password and a TOTP secret
    // (a login with 2FA, e.g. Bitwarden) stays a password credential so its login
    // password is preserved — turning it into a TOTP would store the login
    // password as the "seed" and break code generation. Only TOTP-only rows
    // become authenticators; standalone 2FA is best handled by the dedicated
    // otpauth import.
    var type = CredentialType.password;
    if (hasTotp && !hasPassword) {
      type = CredentialType.totp;
    } else if (row.containsKey('api_key') ||
        row.containsKey('key') ||
        titleLower.contains('api key') ||
        titleLower.contains('apikey')) {
      type = CredentialType.apiKey;
    }

    return Credential(
      id: const Uuid().v4(),
      type: type,
      title: title,
      username: username,
      // For TOTP-only rows the secret lives in [password] (where the TOTP tile
      // reads it); otherwise keep the real login/API password.
      password: hasPassword ? password : totp,
      website: website,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  String? _getField(Map<String, String> row, List<String> keys) {
    for (final key in keys) {
      if (row.containsKey(key)) {
        final val = row[key]!.trim();
        if (val.isNotEmpty) return val;
      }
    }
    return null;
  }

  /// Saves imported credentials in the database
  Future<int> importCredentials(List<Credential> credentials) async {
    int count = 0;
    for (final c in credentials) {
      await _credRepo.save(c);
      count++;
    }
    return count;
  }
}
