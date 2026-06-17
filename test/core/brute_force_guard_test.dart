import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/services/brute_force_guard.dart';

void main() {
  group('BruteForceGuard.lockoutForAttempts (escalating backoff)', () {
    test('no lockout within the free attempts', () {
      for (var i = 0; i <= BruteForceGuard.freeAttempts; i++) {
        expect(BruteForceGuard.lockoutForAttempts(i), Duration.zero,
            reason: 'attempt $i should be free');
      }
    });

    test('first penalty is the base lockout', () {
      expect(
        BruteForceGuard.lockoutForAttempts(BruteForceGuard.freeAttempts + 1),
        const Duration(seconds: BruteForceGuard.baseLockoutSeconds),
      );
    });

    test('doubles on each subsequent failure', () {
      // 5th=15s, 6th=30s, 7th=60s, 8th=120s, 9th=240s, 10th=480s.
      expect(BruteForceGuard.lockoutForAttempts(5), const Duration(seconds: 15));
      expect(BruteForceGuard.lockoutForAttempts(6), const Duration(seconds: 30));
      expect(BruteForceGuard.lockoutForAttempts(7), const Duration(seconds: 60));
      expect(BruteForceGuard.lockoutForAttempts(8), const Duration(seconds: 120));
      expect(BruteForceGuard.lockoutForAttempts(9), const Duration(seconds: 240));
      expect(BruteForceGuard.lockoutForAttempts(10), const Duration(seconds: 480));
    });

    test('caps at the maximum lockout and never overflows', () {
      const cap = Duration(seconds: BruteForceGuard.maxLockoutSeconds);
      expect(BruteForceGuard.lockoutForAttempts(11), cap);
      expect(BruteForceGuard.lockoutForAttempts(50), cap);
      // A very large count would overflow 1<<steps; must still be capped.
      expect(BruteForceGuard.lockoutForAttempts(1000), cap);
    });

    test('lockout is monotonically non-decreasing', () {
      Duration prev = Duration.zero;
      for (var i = 0; i < 40; i++) {
        final d = BruteForceGuard.lockoutForAttempts(i);
        expect(d >= prev, isTrue, reason: 'decreased at attempt $i');
        prev = d;
      }
    });
  });

  group('BruteForceGuard.shouldWipe', () {
    test('threshold 0 disables the wipe', () {
      expect(BruteForceGuard.shouldWipe(100, 0), isFalse);
    });

    test('wipes only at or above the threshold', () {
      expect(BruteForceGuard.shouldWipe(9, 10), isFalse);
      expect(BruteForceGuard.shouldWipe(10, 10), isTrue);
      expect(BruteForceGuard.shouldWipe(11, 10), isTrue);
    });
  });
}
