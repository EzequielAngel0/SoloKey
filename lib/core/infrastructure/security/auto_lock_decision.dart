/// Pure auto-lock decision for the app lifecycle observer, kept free of
/// clocks, timers and plugins so it can be unit-tested with injected instants
/// (see test/core/auto_lock_decision_test.dart).
library;

/// What to do when the app resumes after having been backgrounded at
/// [backgroundedAt]:
/// - `lock: true` — the time in background consumed the auto-lock budget.
/// - otherwise restart the inactivity timer with [restartMinutes] (the whole
///   minutes still available, clamped to `[1, autoLockMinutes]` so a nearly
///   spent budget still gets a real timer instead of an instant lock).
({bool lock, int restartMinutes}) resumeDecision({
  required DateTime backgroundedAt,
  required DateTime now,
  required int autoLockMinutes,
}) {
  final elapsedMinutes = now.difference(backgroundedAt).inMinutes;
  if (elapsedMinutes >= autoLockMinutes) {
    return (lock: true, restartMinutes: 0);
  }
  final remaining =
      (autoLockMinutes - elapsedMinutes).clamp(1, autoLockMinutes);
  return (lock: false, restartMinutes: remaining);
}
