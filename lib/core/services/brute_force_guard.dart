import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Snapshot of the unlock brute-force state.
class BruteForceState {
  const BruteForceState({
    required this.failedAttempts,
    required this.lockoutRemaining,
  });

  /// Consecutive failed unlock attempts since the last success.
  final int failedAttempts;

  /// Time left before another attempt is allowed (zero if not locked out).
  final Duration lockoutRemaining;

  bool get isLockedOut => lockoutRemaining > Duration.zero;
}

/// Anti brute-force guard for the master-password unlock flow.
///
/// Tracks consecutive failed attempts and enforces an **escalating backoff**
/// lockout. State is persisted in the Keystore-backed secure storage so the
/// lockout survives app restarts (a restart can't reset the counter).
@lazySingleton
class BruteForceGuard {
  BruteForceGuard(this._storage);

  final FlutterSecureStorage _storage;

  static const _kFailures = 'bf_failed_attempts';
  static const _kLockoutUntil = 'bf_lockout_until';

  /// Attempts allowed with no penalty before the backoff kicks in.
  static const int freeAttempts = 4;
  static const int baseLockoutSeconds = 15;
  static const int maxLockoutSeconds = 900; // 15 minutes cap.

  /// Escalating backoff schedule (pure, deterministic — unit-tested directly).
  /// 1-4 → none · 5th → 15s · 6th → 30s · 7th → 60s · 8th → 2m · … capped 15m.
  static Duration lockoutForAttempts(int failedAttempts) {
    if (failedAttempts <= freeAttempts) return Duration.zero;
    final steps = failedAttempts - freeAttempts - 1; // 0 on the first penalty
    // 2^steps overflows for large counts; clamp early. With base=15s and a
    // 900s cap, steps>=6 (15*64=960) already reaches the maximum.
    if (steps >= 6) return const Duration(seconds: maxLockoutSeconds);
    final seconds = baseLockoutSeconds * (1 << steps); // base * 2^steps
    return Duration(
        seconds: seconds > maxLockoutSeconds ? maxLockoutSeconds : seconds);
  }

  /// Whether the vault should be wiped after [failedAttempts]. A [wipeThreshold]
  /// of 0 disables the wipe. Pure — unit-tested directly.
  static bool shouldWipe(int failedAttempts, int wipeThreshold) =>
      wipeThreshold > 0 && failedAttempts >= wipeThreshold;

  /// Current persisted state (failed attempts + remaining lockout).
  Future<BruteForceState> currentState() async {
    final failures = int.tryParse(await _storage.read(key: _kFailures) ?? '') ?? 0;
    final until = int.tryParse(await _storage.read(key: _kLockoutUntil) ?? '') ?? 0;
    final remainingMs = until - DateTime.now().millisecondsSinceEpoch;
    return BruteForceState(
      failedAttempts: failures,
      lockoutRemaining:
          remainingMs > 0 ? Duration(milliseconds: remainingMs) : Duration.zero,
    );
  }

  /// Clears the counter after a successful unlock.
  Future<void> recordSuccess() async {
    await _storage.delete(key: _kFailures);
    await _storage.delete(key: _kLockoutUntil);
  }

  /// Records a failed attempt, persists the new lockout, and returns the state.
  Future<BruteForceState> recordFailure() async {
    final failures =
        (int.tryParse(await _storage.read(key: _kFailures) ?? '') ?? 0) + 1;
    await _storage.write(key: _kFailures, value: '$failures');

    final lockout = lockoutForAttempts(failures);
    if (lockout > Duration.zero) {
      final until =
          DateTime.now().millisecondsSinceEpoch + lockout.inMilliseconds;
      await _storage.write(key: _kLockoutUntil, value: '$until');
    }
    return BruteForceState(failedAttempts: failures, lockoutRemaining: lockout);
  }
}
