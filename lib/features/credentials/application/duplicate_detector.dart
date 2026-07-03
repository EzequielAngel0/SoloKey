import '../domain/entities/credential.dart';

/// Normalises a URL/host for loose comparison: lowercased host without a
/// leading `www.`. Returns '' when there's nothing usable.
String normalizeHost(String url) {
  final s = url.trim();
  if (s.isEmpty) return '';
  final uri = Uri.tryParse(s.contains('://') ? s : 'https://$s');
  final host = (uri?.host ?? '').toLowerCase();
  return host.replaceFirst(RegExp(r'^www\.'), '');
}

/// Finds an existing credential that looks like a duplicate of the one being
/// created: same [type], same (non-empty) [username], and — when [website] has
/// a host — the same host. Pure and side-effect free so it can be unit tested.
///
/// Returns `null` when there's no strong match (or [username] is empty, which
/// is the case for notes/TOTP/SSH where this heuristic doesn't apply).
Credential? findDuplicate({
  required List<Credential> all,
  required CredentialType type,
  required String username,
  required String website,
  String? excludeId,
}) {
  final user = username.trim().toLowerCase();
  if (user.isEmpty) return null;
  final host = normalizeHost(website);
  for (final c in all) {
    if (c.id == excludeId) continue;
    if (c.type != type) continue;
    if ((c.username ?? '').trim().toLowerCase() != user) continue;
    if (host.isNotEmpty && normalizeHost(c.website ?? '') != host) continue;
    return c;
  }
  return null;
}
