import 'package:equatable/equatable.dart';

/// Immutable, parsed representation of an `otpauth://` URI (RFC / Key URI
/// format used by Google Authenticator and friends).
///
/// Pure domain value object: no crypto, no I/O. It is produced by
/// [OtpauthParser.parse] from a QR/paste payload and consumed by the credential
/// form to prefill the TOTP fields. The [secret] is sensitive — never log it.
class OtpAuth extends Equatable {
  const OtpAuth({
    required this.secret,
    this.type = 'totp',
    this.issuer,
    this.accountName,
    this.algorithm = 'SHA1',
    this.digits = 6,
    this.period = 30,
  });

  /// Base32 shared secret exactly as it appeared in the URI (not normalised).
  final String secret;

  /// `totp` or `hotp` (from the URI host). The app only generates TOTP.
  final String type;

  /// Service/issuer, e.g. `GitHub`. Taken from the `issuer` query param, or the
  /// label prefix (`Issuer:account`) as a fallback.
  final String? issuer;

  /// Account label, e.g. `alice@example.com` (the part after `:` in the label).
  final String? accountName;

  /// `SHA1` (default), `SHA256` or `SHA512`, upper-cased.
  final String algorithm;

  /// Number of digits in the generated code (default 6).
  final int digits;

  /// Time-step in seconds (default 30).
  final int period;

  /// True when the code generation parameters match what SoloKey generates
  /// (SHA1 / 6 digits / 30s). Non-standard params still prefill the secret but
  /// the produced code may not match the service.
  bool get isStandard =>
      algorithm == 'SHA1' && digits == 6 && period == 30 && type == 'totp';

  @override
  List<Object?> get props => [
    secret,
    type,
    issuer,
    accountName,
    algorithm,
    digits,
    period,
  ];
}

/// Parses `otpauth://` URIs into an [OtpAuth]. Tolerant of missing optional
/// parameters (fills documented defaults) and strict about the essentials
/// (scheme must be `otpauth` and a non-empty `secret` must be present).
abstract final class OtpauthParser {
  /// Returns an [OtpAuth] when [raw] is a valid `otpauth://` URI carrying a
  /// secret; otherwise `null`. Never throws.
  static OtpAuth? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return null;
    }
    if (uri.scheme.toLowerCase() != 'otpauth') return null;

    final secret = uri.queryParameters['secret'];
    if (secret == null || secret.trim().isEmpty) return null;

    // `Uri.pathSegments` are already percent-decoded.
    String? label;
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
      label = uri.pathSegments.first;
    }

    String? issuerFromLabel;
    String? accountName;
    if (label != null) {
      final colon = label.indexOf(':');
      if (colon >= 0) {
        issuerFromLabel = label.substring(0, colon).trim();
        accountName = label.substring(colon + 1).trim();
      } else {
        accountName = label.trim();
      }
      if (issuerFromLabel != null && issuerFromLabel.isEmpty) {
        issuerFromLabel = null;
      }
      if (accountName.isEmpty) accountName = null;
    }

    final issuerParam = uri.queryParameters['issuer']?.trim();
    final issuer = (issuerParam != null && issuerParam.isNotEmpty)
        ? issuerParam
        : issuerFromLabel;

    final type = uri.host.toLowerCase().isEmpty ? 'totp' : uri.host.toLowerCase();

    final algorithm =
        (uri.queryParameters['algorithm']?.trim().toUpperCase() ?? 'SHA1');
    final digits = int.tryParse(uri.queryParameters['digits'] ?? '') ?? 6;
    final period = int.tryParse(uri.queryParameters['period'] ?? '') ?? 30;

    return OtpAuth(
      secret: secret.trim(),
      type: type,
      issuer: issuer,
      accountName: accountName,
      algorithm: algorithm.isEmpty ? 'SHA1' : algorithm,
      digits: digits > 0 ? digits : 6,
      period: period > 0 ? period : 30,
    );
  }
}
