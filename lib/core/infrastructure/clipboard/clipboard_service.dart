import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../features/settings/domain/repositories/i_settings_repository.dart';

/// Copies text to the clipboard and schedules an automatic clear after
/// [AppSecuritySettings.clearClipboardSeconds] seconds.
///
/// Zero-Print policy: this service never logs the copied value.
@lazySingleton
class ClipboardService {
  ClipboardService(this._settingsRepo);

  final ISettingsRepository _settingsRepo;

  Timer? _clearTimer;
  DateTime? _copiedAt;
  Duration? _clearDuration;

  /// Copies [value] and returns the number of seconds until auto-clear.
  Future<int> copySecure(String value) async {
    _clearTimer?.cancel();

    await Clipboard.setData(ClipboardData(text: value));

    final settings = await _settingsRepo.getSettings();
    final seconds = settings.clearClipboardSeconds;

    _copiedAt = DateTime.now();
    _clearDuration = Duration(seconds: seconds);

    _clearTimer = Timer(_clearDuration!, _clear);
    return seconds;
  }

  Future<void> _clear() async {
    try {
      await Clipboard.setData(const ClipboardData(text: ''));

      // On desktop (notably Windows) an empty-string write is frequently
      // ignored by the OS clipboard, leaving the secret in place. Verify the
      // result and hard-overwrite with a single space if the secret survived.
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (data?.text != null && data!.text!.isNotEmpty) {
          await Clipboard.setData(const ClipboardData(text: ' '));
        }
      }
    } catch (_) {
      // Best-effort fallback: guarantee the secret is scrubbed.
      try {
        await Clipboard.setData(const ClipboardData(text: ' '));
      } catch (_) {
        // Nothing more we can do if the platform channel is unavailable.
      }
    }
    _clearTimer = null;
    _copiedAt = null;
    _clearDuration = null;
  }

  /// Immediately clears the clipboard (e.g. when vault locks).
  Future<void> clearNow() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    _copiedAt = null;
    _clearDuration = null;
    await _clear();
  }

  /// Checks if a secure copy has expired while the app was backgrounded
  /// and clears the clipboard if necessary.
  Future<void> checkAndClear() async {
    if (_copiedAt != null && _clearDuration != null) {
      final elapsed = DateTime.now().difference(_copiedAt!);
      if (elapsed >= _clearDuration!) {
        await clearNow();
      }
    }
  }
}
