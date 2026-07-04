import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/di/injection.dart';
import '../../../core/services/brute_force_guard.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/secure_keyboard/secure_keyboard.dart';
import '../../../shared/widgets/secure_keyboard/secure_keyboard_overlay.dart';
import '../../settings/domain/repositories/i_settings_repository.dart';
import '../../sync/infrastructure/sync_service.dart';
import '../../../theme/app_palette.dart';
import '../application/vault_state_provider.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;

  // Number of chars entered via the SecureKeyboard (used for the masked display)
  int _charCount = 0;

  // Remote unlock listener
  StreamSubscription<String>? _remoteUnlockSub;
  bool _isRemoteUnlocking = false;

  // Anti brute-force lockout
  Duration _lockout = Duration.zero;
  Timer? _lockoutTimer;
  int _failedAttempts = 0;
  int _wipeThreshold = 0; // 0 = wipe-on-failure disabled

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _listenForRemoteUnlock();
    _refreshLockout();
  }

  @override
  void dispose() {
    _remoteUnlockSub?.cancel();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  /// Reads the persisted brute-force lockout and starts a 1s countdown ticker.
  /// Also captures the failed-attempt counter and the configured wipe threshold
  /// so the UI can warn how many tries remain before a lock/wipe.
  Future<void> _refreshLockout() async {
    try {
      final state = await getIt<BruteForceGuard>().currentState();
      var wipe = 0;
      try {
        wipe = (await getIt<ISettingsRepository>().getSettings())
            .wipeAfterFailedAttempts;
      } catch (_) {
        // Settings repo may be unavailable in tests — keep wipe disabled.
      }
      if (!mounted) return;
      setState(() {
        _lockout = state.lockoutRemaining;
        _failedAttempts = state.failedAttempts;
        _wipeThreshold = wipe;
      });
      _lockoutTimer?.cancel();
      if (_lockout > Duration.zero) {
        _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) return;
          final next = _lockout - const Duration(seconds: 1);
          setState(() => _lockout = next > Duration.zero ? next : Duration.zero);
          if (_lockout <= Duration.zero) t.cancel();
        });
      }
    } catch (_) {
      // BruteForceGuard may be unavailable in test environments.
    }
  }

  String _formatLockout(Duration d) {
    if (d.inMinutes >= 1) {
      final s = d.inSeconds % 60;
      return s > 0 ? '${d.inMinutes}m ${s}s' : '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }

  /// Subscribes to the SyncService's serverEvents stream to catch
  /// `remote_unlock:<password>` events emitted when a paired mobile
  /// device sends a WiFi unlock request.
  ///
  /// Only active on desktop platforms where the Shelf server runs.
  void _listenForRemoteUnlock() {
    // Only listen on desktop platforms (Windows, macOS, Linux)
    if (!_isDesktopPlatform) return;

    try {
      final syncService = getIt<SyncService>();
      _remoteUnlockSub = syncService.serverEvents.listen((event) {
        if (!mounted) return;

        // WiFi-unlock: the desktop already decrypted its master key from the
        // phone's DUK and emits it (base64) here — never a password.
        if (event.startsWith('remote_unlock_key:')) {
          final keyB64 = event.replaceFirst('remote_unlock_key:', '');
          _handleRemoteUnlock(keyB64);
        }
      });
    } catch (_) {
      // SyncService may not be registered in test environments
    }
  }

  /// Handles the remote unlock with the raw master key (base64) decrypted from
  /// the phone's DUK. The key buffer is zeroed right after the use case stores it.
  Future<void> _handleRemoteUnlock(String keyB64) async {
    if (_isRemoteUnlocking || !mounted) return;

    setState(() => _isRemoteUnlocking = true);

    try {
      final key = Uint8List.fromList(base64Decode(keyB64));
      await ref.read(vaultNotifierProvider.notifier).unlockWithRawKey(key);
      key.fillRange(0, key.length, 0);

      if (!mounted) return;

      ref.read(vaultNotifierProvider).maybeWhen(
            unlocked: (_) => _navigateHome(),
            error: (kind, lockout, message) {
              setState(() => _isRemoteUnlocking = false);
              _showError(_localizeVaultError(kind, lockout, message));
            },
            orElse: () {
              setState(() => _isRemoteUnlocking = false);
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isRemoteUnlocking = false);
        _showError(AppLocalizations.of(context).unlockRemoteError);
      }
    }
  }

  bool get _isDesktopPlatform {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> _checkBiometrics() async {
    // En escritorio (Windows Hello) el desbloqueo puede ser por PIN, huella o
    // rostro: usamos isDeviceSupported() porque canCheckBiometrics solo detecta
    // hardware biometrico y ocultaria la opcion en equipos con solo PIN.
    final available = _isDesktopPlatform
        ? await _localAuth.isDeviceSupported()
        : await _localAuth.canCheckBiometrics;
    if (mounted) setState(() => _biometricAvailable = available);
    if (!available) return;

    // Test seam: integration tests can't drive the native local_auth dialog, so
    // `--dart-define=TEST_DISABLE_BIOMETRIC=1` skips ONLY the auto-prompt (the
    // biometric button stays available). Defaults off → no prod change.
    // (`bool.fromEnvironment` only accepts "true", so we accept 1 or true.)
    const biometricSeam = String.fromEnvironment('TEST_DISABLE_BIOMETRIC');
    if (biometricSeam == '1' || biometricSeam == 'true') return;

    try {
      final settings = await getIt<ISettingsRepository>().getSettings();
      if (settings.biometricEnabled) _tryBiometric();
    } catch (_) {
      // Settings unavailable (e.g. in tests) — skip the biometric auto-prompt
      // but keep the biometric button available.
    }
  }

  Future<void> _tryBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context).unlockBiometricReason,
        // En escritorio permitimos el PIN de Windows Hello (no solo biometria);
        // en movil exigimos biometria estricta.
        options: AuthenticationOptions(biometricOnly: !_isDesktopPlatform),
      );
      if (!authenticated || !mounted) return;

      await ref.read(vaultNotifierProvider.notifier).unlockWithBiometrics();
      if (!mounted) return;

      ref.read(vaultNotifierProvider).maybeWhen(
            unlocked: (_) => _navigateHome(),
            error: (kind, lockout, message) =>
                _showError(_localizeVaultError(kind, lockout, message)),
            orElse: () {},
          );
    } catch (_) {
      // Biometría cancelada — silenciar
    }
  }

  /// Opens the SecureKeyboard overlay and uses the result to unlock.
  Future<void> _openSecureKeyboard() async {
    if (_lockout > Duration.zero) return; // bloqueado por intentos fallidos
    final l10n = AppLocalizations.of(context);
    final password = await SecureKeyboardOverlay.show(
      context,
      mode: SecureKeyboardMode.password,
      hintText: l10n.unlockMasterPasswordHint,
      confirmLabel: l10n.unlockButton,
    );
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _charCount = password.length);

    await ref.read(vaultNotifierProvider.notifier).unlock(password);
    if (!mounted) return;
    ref.read(vaultNotifierProvider).maybeWhen(
          unlocked: (_) => _navigateHome(),
          error: (kind, lockout, message) {
            setState(() => _charCount = 0);
            _showError(_localizeVaultError(kind, lockout, message));
            // Actualiza el contador/lockout tras un intento fallido.
            _refreshLockout();
          },
          orElse: () {},
        );
  }

  /// Maps a semantic [VaultErrorKind] to a localized, user-facing message. The
  /// notifier reports the reason (no `BuildContext`); the screen localizes it.
  String _localizeVaultError(
    VaultErrorKind kind,
    Duration? lockout,
    String? message,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (kind) {
      case VaultErrorKind.wrongPassword:
        return lockout != null
            ? l10n.unlockWrongPasswordLocked(_formatLockout(lockout))
            : l10n.unlockWrongPassword;
      case VaultErrorKind.lockedOut:
        return l10n.unlockTooManyAttempts(
            _formatLockout(lockout ?? Duration.zero));
      case VaultErrorKind.wiped:
        return l10n.unlockVaultWiped;
      case VaultErrorKind.biometricFailed:
        return l10n.unlockBiometricFailed;
      case VaultErrorKind.remoteFailed:
        return l10n.unlockRemoteError;
      case VaultErrorKind.generic:
        return l10n.unlockGenericError;
    }
  }

  /// Desktop (M3): asks the connected phone(s) to approve unlocking this PC.
  /// The phone shows a local notification; approving sends back its DUK over the
  /// E2EE channel and the existing `remote_unlock_key:` listener unlocks here.
  Future<void> _requestPhoneApproval() async {
    final l10n = AppLocalizations.of(context);
    try {
      final sent = await getIt<SyncService>().requestApproval();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            sent > 0 ? l10n.unlockApprovalSent : l10n.unlockApprovalNoDevice),
        backgroundColor:
            sent > 0 ? context.palette.primary : context.palette.danger,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      // SyncService puede no estar disponible (p.ej. en tests).
    }
  }

  /// Primary-action label for the biometric unlock: "Windows Hello" on desktop
  /// (where `local_auth` also accepts the Hello PIN), "biometrics" on mobile.
  String _biometricLabel(AppLocalizations l10n) => _isDesktopPlatform
      ? l10n.unlockWithWindowsHello
      : l10n.unlockWithBiometrics;

  IconData get _biometricIcon =>
      _isDesktopPlatform ? Icons.verified_user_rounded : Icons.fingerprint_rounded;

  /// A subtle warning of how many attempts remain before a temporary lock (or,
  /// if wipe-on-failure is enabled, before the vault is wiped). Returns null
  /// while there are no failures yet or a lockout is already active.
  Widget? _attemptsHint(BuildContext context) {
    if (_failedAttempts <= 0 || _lockout > Duration.zero) return null;
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    if (_wipeThreshold > 0) {
      final left = _wipeThreshold - _failedAttempts;
      if (left > 0) {
        return _AttemptsHint(
            text: l10n.unlockAttemptsBeforeWipe(left), color: palette.danger);
      }
    }
    final freeLeft = BruteForceGuard.freeAttempts - _failedAttempts;
    if (freeLeft > 0) {
      return _AttemptsHint(
          text: l10n.unlockAttemptsBeforeLockout(freeLeft),
          color: palette.warning);
    }
    return null;
  }

  void _navigateHome() => context.go(AppRoutes.home);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: context.palette.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(vaultNotifierProvider).maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // Logo (flat, no glow)
                    Center(
                      child: Image.asset(
                        'assets/logo/solokey_mark.png',
                        height: 84,
                        width: 84,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/logo/SoloKey.png',
                          height: 84,
                          width: 84,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'SoloKey',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        l10n.unlockSubtitle,
                        style:
                            TextStyle(color: palette.textMuted, fontSize: 14),
                      ),
                    ),

                    const Spacer(),

                    // Remote unlock indicator (desktop only)
                    if (_isRemoteUnlocking) ...[
                      _RemoteUnlockBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Brute-force lockout banner (con cuenta regresiva)
                    if (_lockout > Duration.zero) ...[
                      _LockoutBanner(remainingText: _formatLockout(_lockout)),
                      const SizedBox(height: 16),
                    ],

                    // Remaining-attempts hint (before any lockout kicks in).
                    if (_attemptsHint(context) case final hint?) ...[
                      hint,
                      const SizedBox(height: 16),
                    ],

                    if (_biometricAvailable) ...[
                      // PRIMARY: biometric / Windows Hello (big button).
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isLoading || _isRemoteUnlocking
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: palette.accent))
                            : Semantics(
                                button: true,
                                label: _biometricLabel(l10n),
                                child: ElevatedButton.icon(
                                  onPressed: _lockout > Duration.zero
                                      ? null
                                      : _tryBiometric,
                                  icon: Icon(_biometricIcon),
                                  label: Text(_lockout > Duration.zero
                                      ? l10n.unlockLockedFor(
                                          _formatLockout(_lockout))
                                      : _biometricLabel(l10n)),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      // SECONDARY: master-password fallback.
                      Center(
                        child: Text(
                          l10n.unlockOrUseMasterPassword,
                          style:
                              TextStyle(color: palette.textMuted, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SecurePasswordTap(
                        charCount: _charCount,
                        onTap: _openSecureKeyboard,
                      ),
                    ] else ...[
                      // PRIMARY: master password (no biometric / Hello available).
                      _SecurePasswordTap(
                        charCount: _charCount,
                        onTap: _openSecureKeyboard,
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isLoading || _isRemoteUnlocking
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: palette.accent))
                            : ElevatedButton(
                                onPressed: _lockout > Duration.zero
                                    ? null
                                    : _openSecureKeyboard,
                                child: Text(_lockout > Duration.zero
                                    ? l10n.unlockLockedFor(
                                        _formatLockout(_lockout))
                                    : l10n.unlockButton),
                              ),
                      ),
                    ],

                    // Desktop (M3): pedir aprobacion de desbloqueo al celular.
                    if (_isDesktopPlatform) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed:
                              _isRemoteUnlocking ? null : _requestPhoneApproval,
                          icon: Icon(Icons.phonelink_lock_rounded,
                              color: palette.primary),
                          label: Text(
                            l10n.unlockWifiAvailable,
                            style: TextStyle(
                              color: palette.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.recovery),
                        child: Text(
                          l10n.unlockForgotPassword,
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: palette.textMuted,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _RemoteUnlockBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: palette.primary,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).unlockFromMobile,
              style: TextStyle(
                color: palette.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.phone_android_rounded,
            color: palette.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _LockoutBanner extends StatelessWidget {
  const _LockoutBanner({required this.remainingText});
  final String remainingText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: palette.danger, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).unlockTooManyAttempts(remainingText),
              style: TextStyle(
                color: palette.danger,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptsHint extends StatelessWidget {
  const _AttemptsHint({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurePasswordTap extends StatelessWidget {
  const _SecurePasswordTap({required this.charCount, required this.onTap});
  final int charCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: charCount > 0
                ? palette.accent.withValues(alpha: 0.6)
                : palette.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, color: palette.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: charCount == 0
                  ? Text(
                      AppLocalizations.of(context).unlockTapToEnter,
                      style: TextStyle(color: palette.textDisabled, fontSize: 14),
                    )
                  : Text(
                      '●' * charCount,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        letterSpacing: 3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Icon(
              Icons.keyboard_rounded,
              color: palette.accent.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
