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
import '../../sync/domain/i_sync_service.dart';
import '../../../shared/widgets/kit/kit.dart';
import '../application/vault_state_provider.dart';
import 'widgets/access_layout.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;

  final _passwordCtrl = SecretTextController();

  /// Último error, a la vista sobre los botones (no en un aviso que se va).
  String? _error;

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
    _passwordCtrl.dispose();
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
      final syncService = getIt<ISyncService>();
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
        biometricOnly: !_isDesktopPlatform,
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

  /// Desbloquea con la contraseña escrita en el campo (teclado del sistema).
  Future<void> _unlockFromField() async {
    final password = _passwordCtrl.text;
    if (password.isEmpty) return;
    // SEC-003: la maestra sale del controlador antes del await.
    _passwordCtrl.clear();
    await _unlock(password);
  }

  /// El teclado seguro, como opción (ADR-0013): no pasa por el teclado del
  /// sistema.
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
    await _unlock(password);
  }

  Future<void> _unlock(String password) async {
    if (_lockout > Duration.zero) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    await ref.read(vaultNotifierProvider.notifier).unlock(password);
    if (!mounted) return;
    ref.read(vaultNotifierProvider).maybeWhen(
          unlocked: (_) => _navigateHome(),
          error: (kind, lockout, message) {
            _showError(_localizeVaultError(kind, lockout, message));
            // Actualiza el contador y el bloqueo tras un intento fallido.
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

  /// Escritorio: pide al celular vinculado que apruebe abrir esta computadora.
  /// El celular muestra una notificación; al aprobar manda su llave por el
  /// canal cifrado y `remote_unlock_key:` desbloquea aquí.
  Future<void> _requestPhoneApproval() async {
    final l10n = AppLocalizations.of(context);
    try {
      final sent = await getIt<ISyncService>().requestApproval();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            sent > 0 ? l10n.unlockApprovalSent : l10n.unlockApprovalNoDevice),
      ));
    } catch (_) {
      // SyncService puede no estar disponible (p. ej. en pruebas).
    }
  }

  /// "Windows Hello" en escritorio (acepta también su PIN), biometría en el
  /// celular.
  String _biometricLabel(AppLocalizations l10n) => _isDesktopPlatform
      ? l10n.unlockWithWindowsHello
      : l10n.unlockWithBiometrics;

  IconData get _biometricIcon =>
      _isDesktopPlatform ? Icons.verified_user_outlined : Icons.fingerprint;

  /// Cuántos intentos quedan antes del bloqueo temporal (ámbar) o, si está
  /// activo el borrado tras fallos, antes de borrar la bóveda (rojo). `null`
  /// sin fallos o con un bloqueo ya activo.
  Widget? _attemptsHint(AppLocalizations l10n) {
    if (_failedAttempts <= 0 || _lockout > Duration.zero) return null;
    if (_wipeThreshold > 0) {
      final left = _wipeThreshold - _failedAttempts;
      if (left > 0) {
        return Notice(
          title: l10n.unlockAttemptsBeforeWipe(left),
          tone: SafetyTone.breach,
        );
      }
    }
    final freeLeft = BruteForceGuard.freeAttempts - _failedAttempts;
    if (freeLeft > 0) {
      return Notice(
        title: l10n.unlockAttemptsBeforeLockout(freeLeft),
        tone: SafetyTone.weak,
      );
    }
    return null;
  }

  void _navigateHome() => context.go(AppRoutes.home);

  void _showError(String msg) {
    if (mounted) setState(() => _error = msg);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final p = context.palette;
    final busy = _isRemoteUnlocking ||
        ref.watch(vaultNotifierProvider).maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
    final locked = _lockout > Duration.zero;
    final lockedLabel = l10n.unlockLockedFor(_formatLockout(_lockout));
    final hint = _attemptsHint(l10n);

    Widget gap([double h = AppSpace.lg]) => SizedBox(height: h);

    return AccessLayout(
      children: [
        AccessHeader(title: 'SoloKey', subtitle: l10n.unlockSubtitle),
        gap(AppSpace.xl),
        if (_isRemoteUnlocking) ...[
          Notice(
            title: l10n.unlockFromMobile,
            icon: Icons.phonelink_lock_outlined,
          ),
          gap(),
        ],
        if (locked) ...[
          Notice(
            title: l10n.unlockTooManyAttempts(_formatLockout(_lockout)),
            tone: SafetyTone.breach,
            icon: Icons.lock_clock_outlined,
          ),
          gap(),
        ],
        if (_error != null && !locked) ...[
          Notice(title: _error!, tone: SafetyTone.breach),
          gap(),
        ],
        if (hint != null) ...[hint, gap()],

        // Primero la biometría o Windows Hello (ADR-0013).
        if (_biometricAvailable) ...[
          PaperButton(
            label: locked ? lockedLabel : _biometricLabel(l10n),
            icon: _biometricIcon,
            onPressed: locked ? null : _tryBiometric,
            busy: busy,
            expand: true,
          ),
          gap(AppSpace.xl),
          Text(
            l10n.unlockOrUseMasterPassword,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: p.inkSoft),
          ),
          gap(AppSpace.md),
        ],

        // Después, la contraseña maestra.
        SecretField(
          controller: _passwordCtrl,
          label: l10n.unlockMasterPasswordHint,
          revealTooltip: l10n.commonShowPassword,
          hideTooltip: l10n.commonHidePassword,
          autofocus: !_biometricAvailable && _isDesktopPlatform,
          enabled: !locked,
          textInputAction: TextInputAction.go,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _unlockFromField(),
        ),
        gap(AppSpace.md),
        PaperButton(
          kind: _biometricAvailable
              ? PaperButtonKind.secondary
              : PaperButtonKind.primary,
          label: locked ? lockedLabel : l10n.unlockButton,
          onPressed: locked ? null : _unlockFromField,
          busy: busy && !_biometricAvailable,
          expand: true,
        ),
        gap(),

        // Lo demás, a la vista y discreto.
        PaperButton.quiet(
          label: l10n.unlockUseSecureKeyboard,
          icon: Icons.keyboard_outlined,
          onPressed: locked ? null : _openSecureKeyboard,
          expand: true,
        ),
        if (_isDesktopPlatform)
          PaperButton.quiet(
            label: l10n.unlockWifiAvailable,
            icon: Icons.phonelink_lock_outlined,
            onPressed: _isRemoteUnlocking ? null : _requestPhoneApproval,
            expand: true,
          ),
        PaperButton.quiet(
          label: l10n.unlockForgotPassword,
          icon: Icons.help_outline,
          onPressed: () => context.push(AppRoutes.recovery),
          expand: true,
        ),
      ],
    );
  }
}
