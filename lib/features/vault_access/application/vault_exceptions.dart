/// Thrown when an unlock is attempted while the vault is in a brute-force
/// lockout window. [remaining] is the time left before another try is allowed.
class VaultLockedOutException implements Exception {
  const VaultLockedOutException(this.remaining);
  final Duration remaining;
}

/// Thrown on a wrong master password. [lockoutAfter] is the backoff applied as
/// a result of this failure (zero while still within the free attempts).
class WrongMasterPasswordException implements Exception {
  const WrongMasterPasswordException(this.lockoutAfter);
  final Duration lockoutAfter;
}

/// Thrown when the vault was wiped because the configured failed-attempt
/// threshold was reached.
class VaultWipedException implements Exception {
  const VaultWipedException();
}
