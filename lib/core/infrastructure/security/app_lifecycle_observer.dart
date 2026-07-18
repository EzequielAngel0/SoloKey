import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../app/di/injection.dart';
import '../../../features/settings/domain/repositories/i_settings_repository.dart';
import '../clipboard/clipboard_service.dart';
import 'auto_lock_decision.dart';
import 'session_manager.dart';

/// Observes app lifecycle events to enforce security policies:
/// - Controls FLAG_SECURE via native MethodChannel (Android WindowManager).
/// - Locks the vault after [autoLockMinutes] of inactivity or background.
@lazySingleton
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver(this._sessionManager, this._settingsRepo);

  final SessionManager _sessionManager;
  final ISettingsRepository _settingsRepo;

  static const _channel = MethodChannel('com.solokey/security');

  Timer? _inactivityTimer;
  DateTime? _backgroundedAt;
  bool _flagSecureActive = false;

  /// Called once at app startup — registers the observer and syncs screen protection.
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _syncScreenProtection();
  }

  /// Re-reads [obscureOnBackground] and applies or removes FLAG_SECURE.
  /// Call this whenever the setting changes in real-time.
  Future<void> syncScreenProtection() async {
    await _syncScreenProtection();
  }

  Future<void> _syncScreenProtection() async {
    final settings = await _settingsRepo.getSettings();
    await _applyFlagSecure(enable: settings.obscureOnBackground);
  }

  Future<void> _applyFlagSecure({required bool enable}) async {
    if (enable == _flagSecureActive) return;
    try {
      await _channel.invokeMethod('setFlagSecure', {'enable': enable});
      _flagSecureActive = enable;
    } catch (_) {
      // Best-effort — never crash the app if the channel call fails.
    }
  }

  /// Must be called when the user interacts with the app.
  Future<void> onUserActivity() async {
    final settings = await _settingsRepo.getSettings();
    if (!settings.biometricEnabled && !_sessionManager.hasActiveKey) return;
    _resetInactivityTimer(settings.autoLockMinutes);
  }

  /// Starts the inactivity timer after the vault is unlocked.
  Future<void> onVaultUnlocked() async {
    final settings = await _settingsRepo.getSettings();
    _resetInactivityTimer(settings.autoLockMinutes);
  }

  void _resetInactivityTimer(int minutes) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(minutes: minutes), _lockVault);
  }

  void _lockVault() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _sessionManager.lock();
    getIt<ClipboardService>().clearNow();
    onLockRequested?.call();
  }

  /// Callback set by the UI to navigate to unlock screen when lock fires.
  VoidCallback? onLockRequested;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        _inactivityTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        _handleResumed();
        getIt<ClipboardService>().checkAndClear();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _handleResumed() async {
    final backgroundedAt = _backgroundedAt;
    if (backgroundedAt == null) return;
    _backgroundedAt = null;

    final settings = await _settingsRepo.getSettings();
    final decision = resumeDecision(
      backgroundedAt: backgroundedAt,
      now: DateTime.now(),
      autoLockMinutes: settings.autoLockMinutes,
    );
    if (decision.lock) {
      _lockVault();
    } else {
      _resetInactivityTimer(decision.restartMinutes);
    }
  }

  void dispose() {
    _inactivityTimer?.cancel();
    if (_flagSecureActive) {
      _channel.invokeMethod('setFlagSecure', {'enable': false});
    }
    WidgetsBinding.instance.removeObserver(this);
  }
}
