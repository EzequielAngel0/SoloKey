import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/core/infrastructure/security/auto_lock_decision.dart';

// Pure auto-lock decision (prompt 99): every instant is injected, so the edge
// cases that only bite in production (exact boundary, sub-minute background,
// nearly spent budget) are pinned deterministically here.
void main() {
  final base = DateTime(2026, 7, 18, 12, 0, 0);

  group('resumeDecision', () {
    test('short background keeps the vault unlocked with the remaining budget',
        () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(minutes: 2)),
        autoLockMinutes: 5,
      );
      expect(d.lock, isFalse);
      expect(d.restartMinutes, 3);
    });

    test('sub-minute background does not consume any whole minute', () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(seconds: 59)),
        autoLockMinutes: 5,
      );
      expect(d.lock, isFalse);
      expect(d.restartMinutes, 5);
    });

    test('locks at the exact auto-lock boundary', () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(minutes: 5)),
        autoLockMinutes: 5,
      );
      expect(d.lock, isTrue);
    });

    test('locks well past the boundary', () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(hours: 3)),
        autoLockMinutes: 5,
      );
      expect(d.lock, isTrue);
    });

    test('one second before the boundary stays unlocked with a 1-minute timer',
        () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(minutes: 4, seconds: 59)),
        autoLockMinutes: 5,
      );
      expect(d.lock, isFalse);
      // 4 whole minutes elapsed → 1 minute left; clamp keeps it >= 1.
      expect(d.restartMinutes, 1);
    });

    test('a 1-minute budget survives a 59s background with a full restart', () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base.add(const Duration(seconds: 59)),
        autoLockMinutes: 1,
      );
      expect(d.lock, isFalse);
      expect(d.restartMinutes, 1);
    });

    test('a zero-minute budget locks immediately', () {
      final d = resumeDecision(
        backgroundedAt: base,
        now: base,
        autoLockMinutes: 0,
      );
      expect(d.lock, isTrue);
    });
  });
}
