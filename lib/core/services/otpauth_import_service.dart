import 'package:uuid/uuid.dart';

import '../../features/credentials/domain/entities/credential.dart';

/// Parses one or more `otpauth://totp/...` URIs into TOTP [Credential]s.
///
/// Supports the interoperable Key URI Format used by most authenticators
/// (Google Authenticator, Aegis, 2FAS, Bitwarden, …) when they export or show
/// individual TOTP links. Accepts a blob with any number of URIs separated by
/// whitespace/newlines, or inlined in surrounding text.
///
/// The Google Authenticator *migration* payload (`otpauth-migration://`) packs
/// several accounts into a base64 protobuf; that binary format is intentionally
/// **not** decoded here (see [containsMigrationPayload] for a friendly hint).
class OtpAuthImportService {
  static const _uuid = Uuid();

  /// Matches an `otpauth://…` URI up to the next whitespace or quote/angle char.
  static final _uriPattern =
      RegExp(r'''otpauth://[^\s"'<>]+''', caseSensitive: false);

  /// Extracts every valid `otpauth://totp` (or `hotp`) URI in [content] and
  /// returns them as TOTP credentials. Invalid or secret-less URIs are skipped.
  List<Credential> parse(String content) {
    final now = DateTime.now();
    final credentials = <Credential>[];
    for (final match in _uriPattern.allMatches(content)) {
      final cred = _fromUri(match.group(0)!, now);
      if (cred != null) credentials.add(cred);
    }
    return credentials;
  }

  /// True when [content] carries a Google Authenticator migration payload, which
  /// this parser cannot decode. Lets the UI show a targeted hint instead of a
  /// generic "nothing found".
  bool containsMigrationPayload(String content) =>
      content.toLowerCase().contains('otpauth-migration://');

  Credential? _fromUri(String raw, DateTime now) {
    final Uri uri;
    try {
      uri = Uri.parse(raw);
    } catch (_) {
      return null;
    }
    if (uri.scheme.toLowerCase() != 'otpauth') return null;
    final kind = uri.host.toLowerCase();
    if (kind != 'totp' && kind != 'hotp') return null;

    final secret = uri.queryParameters['secret']?.trim();
    if (secret == null || secret.isEmpty) return null;

    // Uri.pathSegments and queryParameters are already percent-decoded.
    final label = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    String? issuer = uri.queryParameters['issuer']?.trim();
    String? account;
    if (label.contains(':')) {
      final parts = label.split(':');
      issuer ??= parts.first.trim();
      account = parts.sublist(1).join(':').trim();
    } else if (label.isNotEmpty) {
      account = label.trim();
    }

    final title = (issuer != null && issuer.isNotEmpty)
        ? issuer
        : (account != null && account.isNotEmpty ? account : 'TOTP');

    return Credential(
      id: _uuid.v4(),
      type: CredentialType.totp,
      title: title,
      username: (account != null && account.isNotEmpty) ? account : null,
      // The TOTP tile reads the shared secret from [Credential.password].
      password: secret,
      createdAt: now,
      updatedAt: now,
    );
  }
}
