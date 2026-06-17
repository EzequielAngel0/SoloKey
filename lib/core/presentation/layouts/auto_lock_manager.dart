import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../../../features/settings/domain/repositories/i_settings_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _resetTimer() async {
    _timer?.cancel();
    
    try {
      final settingsRepo = getIt<ISettingsRepository>();
      final settings = await settingsRepo.getSettings();
      final timeout = Duration(minutes: settings.autoLockMinutes);
      
      if (mounted) {
        _timer = Timer(timeout, () {
          ref.read(vaultNotifierProvider.notifier).lock();
        });
      }
    } catch (_) {
      // Fallback to 5 minutes if settings are not initialized yet
      if (mounted) {
        _timer = Timer(const Duration(minutes: 5), () {
          ref.read(vaultNotifierProvider.notifier).lock();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
