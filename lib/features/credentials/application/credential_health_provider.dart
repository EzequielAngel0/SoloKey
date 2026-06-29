import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/credential.dart';
import 'credentials_provider.dart';

/// Lightweight, inline health flags for a credential. Computed cheaply from the
/// already-decrypted in-memory vault (NO extra decryption, NO network) so the
/// list/detail can surface risk where the user actually sees the credential —
/// not only in the dedicated Audit screen. "Breached" is intentionally excluded
/// here because it needs the opt-in HIBP network check (stays in Audit).
enum CredentialHealth { weak, reused }

/// Only login/API-key passwords are meaningful to score. TOTP seeds, SSH keys
/// and passkeys are not user passwords and must never be flagged "weak/reused".
bool _isCheckable(Credential c) =>
    c.password != null &&
    c.password!.isNotEmpty &&
    (c.type == CredentialType.password || c.type == CredentialType.apiKey);

/// Mirrors the Audit "weak" basics: short, or letters-only / digits-only.
bool _isWeak(String pw) {
  if (pw.length < 8) return true;
  final hasLetter = pw.contains(RegExp(r'[A-Za-z]'));
  final hasDigit = pw.contains(RegExp(r'\d'));
  if (hasLetter && !hasDigit && !pw.contains(RegExp(r'[^A-Za-z0-9]'))) {
    return pw.length < 12; // letters only and not long
  }
  if (!hasLetter && hasDigit) return true; // digits only
  return false;
}

/// Map of credentialId → health flags. Recomputes when the vault changes.
final credentialHealthProvider =
    Provider<Map<String, Set<CredentialHealth>>>((ref) {
  final creds = ref.watch(credentialsNotifierProvider).valueOrNull ?? const [];

  final counts = <String, int>{};
  for (final c in creds) {
    if (_isCheckable(c)) {
      counts[c.password!] = (counts[c.password!] ?? 0) + 1;
    }
  }

  final result = <String, Set<CredentialHealth>>{};
  for (final c in creds) {
    if (!_isCheckable(c)) continue;
    final flags = <CredentialHealth>{};
    if (_isWeak(c.password!)) flags.add(CredentialHealth.weak);
    if ((counts[c.password!] ?? 0) > 1) flags.add(CredentialHealth.reused);
    if (flags.isNotEmpty) result[c.id] = flags;
  }
  return result;
});
