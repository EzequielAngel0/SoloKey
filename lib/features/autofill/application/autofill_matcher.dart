import '../../credentials/domain/entities/credential.dart';

/// Pure, platform-agnostic matching logic shared by the Android autofill
/// entry point and the desktop Quick-Fill overlay.
///
/// It operates over already-decrypted [Credential]s — no crypto, no I/O — so it
/// can run anywhere. The caller is identified either by an app [packageName]
/// (Android) or a [webDomain] (browsers / desktop window heuristics).
abstract final class AutofillMatcher {
  /// Returns the password-type credentials whose stored website matches the
  /// caller [packageName] / [webDomain], capped at [limit].
  ///
  /// Heuristics (fuzzy, intentionally lenient so real logins still match):
  ///  - the stored site contains the caller domain, or vice-versa;
  ///  - the stored site contains the last segment of the package name
  ///    (e.g. `com.spotify.music` -> `spotify`).
  static List<Credential> match(
    List<Credential> credentials, {
    String packageName = '',
    String webDomain = '',
    int limit = 5,
  }) {
    final domain = webDomain.toLowerCase().trim();
    final pkgTail = (packageName.toLowerCase().split('.').lastOrNull ?? '');

    return credentials.where((c) {
      if (c.type != CredentialType.password) return false;
      final site = (c.website ?? '').toLowerCase();
      if (site.isEmpty) return false;
      final siteDomain = extractDomain(site);

      if (domain.isNotEmpty &&
          (site.contains(domain) ||
              domain.contains(siteDomain) ||
              siteDomain == domain)) {
        return true;
      }
      // Package-name fallback: require a meaningful tail to avoid noise.
      if (pkgTail.length > 2 && site.contains(pkgTail)) return true;
      return false;
    }).take(limit).toList();
  }

  /// Extracts a bare host (without `www.`) from a URL or naked domain.
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}
