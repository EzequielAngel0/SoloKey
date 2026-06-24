import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/vault_access/application/vault_state_provider.dart';

class AutoLockManager extends ConsumerStatefulWidget {
  const AutoLockManager({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AutoLockManager> createState() => _AutoLockManagerState();
}

class _AutoLockManagerState extends ConsumerState<AutoLockManager> {
  Timer? _timer;
  final _focusNode = FocusNode();

  /// Authoritative auto-lock timeout in minutes. Stays null until the persisted
  /// settings have loaded — we never arm the timer with a guessed value, so the
  /// vault can never lock earlier than the user's configured timeout.
  int? _autoLockMinutes;

  @override
  void initState() {
    super.initState();
    _loadTimeoutAndArm();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTimeoutAndArm() async {
    try {
      final settings = await getIt<ISettingsRepository>().getSettings();
      _autoLockMinutes = settings.autoLockMinutes;
    } catch (_) {
      // Leave null; the reactive listener in build() arms the timer once the
      // settings provider resolves.
    }
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    final minutes = _autoLockMinutes;
    if (!mounted || minutes == null) return;

    _timer = Timer(Duration(minutes: minutes), () {
      ref.read(vaultNotifierProvider.notifier).lock();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep the timeout in sync with live changes made in the Settings screen.
    ref.listen(settingsNotifierProvider, (_, next) {
      final minutes = next.valueOrNull?.autoLockMinutes;
      if (minutes != null && minutes != _autoLockMinutes) {
        _autoLockMinutes = minutes;
        _resetTimer();
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_) => _resetTimer(),
        child: widget.child,
      ),
    );
  }
}
