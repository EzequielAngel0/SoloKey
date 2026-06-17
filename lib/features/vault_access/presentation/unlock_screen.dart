import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/di/injection.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/secure_keyboard/secure_keyboard.dart';
import '../../../shared/widgets/secure_keyboard/secure_keyboard_overlay.dart';
import '../../settings/domain/repositories/i_settings_repository.dart';
import '../../sync/infrastructure/sync_service.dart';
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

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _listenForRemoteUnlock();
  }

  @override
  void dispose() {
    _remoteUnlockSub?.cancel();
    super.dispose();
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

        if (event.startsWith('remote_unlock:')) {
          final password = event.replaceFirst('remote_unlock:', '');
          _handleRemoteUnlock(password);
        }
      });
    } catch (_) {
      // SyncService may not be registered in test environments
    }
  }

  /// Handles the remote unlock by using the received password to unlock
  /// the vault. The password string is wiped from memory immediately after
  /// it's consumed by the unlock use case.
  Future<void> _handleRemoteUnlock(String password) async {
    if (_isRemoteUnlocking || !mounted) return;

    setState(() => _isRemoteUnlocking = true);

    try {
      // Use the received password to unlock
      await ref.read(vaultNotifierProvider.notifier).unlock(password);

      if (!mounted) return;

      ref.read(vaultNotifierProvider).maybeWhen(
            unlocked: (_) => _navigateHome(),
            error: (msg) {
              setState(() => _isRemoteUnlocking = false);
              _showError('Desbloqueo remoto fallido: $msg');
            },
            orElse: () {
              setState(() => _isRemoteUnlocking = false);
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isRemoteUnlocking = false);
        _showError('Error en desbloqueo remoto');
      }
    }
  }

  bool get _isDesktopPlatform {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> _checkBiometrics() async {
    final available = await _localAuth.canCheckBiometrics;
    if (mounted) setState(() => _biometricAvailable = available);
    if (!available) return;

    final settings = await getIt<ISettingsRepository>().getSettings();
    if (settings.biometricEnabled) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Desbloquea tu bóveda',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!authenticated || !mounted) return;

      await ref.read(vaultNotifierProvider.notifier).unlockWithBiometrics();
      if (!mounted) return;

      ref.read(vaultNotifierProvider).maybeWhen(
            unlocked: (_) => _navigateHome(),
            error: (msg) => _showError(msg),
            orElse: () {},
          );
    } catch (_) {
      // Biometría cancelada — silenciar
    }
  }

  /// Opens the SecureKeyboard overlay and uses the result to unlock.
  Future<void> _openSecureKeyboard() async {
    final password = await SecureKeyboardOverlay.show(
      context,
      mode: SecureKeyboardMode.password,
      hintText: 'Contraseña maestra',
      confirmLabel: 'Desbloquear',
    );
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _charCount = password.length);

    await ref.read(vaultNotifierProvider.notifier).unlock(password);
    if (!mounted) return;
    ref.read(vaultNotifierProvider).maybeWhen(
          unlocked: (_) => _navigateHome(),
          error: (msg) {
            setState(() => _charCount = 0);
            _showError(msg);
          },
          orElse: () {},
        );
  }

  void _navigateHome() => context.go(AppRoutes.home);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFCF6679),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                    // Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3A3080)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF)
                                  .withValues(alpha: 0.4),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo/SoloKey.png',
                          height: 80,
                          width: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        'SoloKey',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Introduce tu contraseña maestra',
                        style:
                            TextStyle(color: Color(0xFF9E9EBF), fontSize: 14),
                      ),
                    ),

                    const Spacer(),

                    // Remote unlock indicator (desktop only)
                    if (_isRemoteUnlocking) ...[
                      _RemoteUnlockBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Tappable masked password display
                    _SecurePasswordTap(
                      charCount: _charCount,
                      onTap: _openSecureKeyboard,
                    ),

                    const SizedBox(height: 20),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isLoading || _isRemoteUnlocking
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6C63FF),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _openSecureKeyboard,
                              child: const Text('Desbloquear'),
                            ),
                    ),

                    if (_biometricAvailable) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: _tryBiometric,
                          icon: const Icon(
                            Icons.fingerprint_rounded,
                            color: Color(0xFF6C63FF),
                          ),
                          label: const Text(
                            'Usar biometría',
                            style: TextStyle(color: Color(0xFF6C63FF)),
                          ),
                        ),
                      ),
                    ],

                    // WiFi unlock hint for desktop
                    if (_isDesktopPlatform) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              color: const Color(0xFF39FF14).withValues(alpha: 0.5),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Desbloqueo WiFi disponible',
                              style: TextStyle(
                                color: const Color(0xFF39FF14).withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.recovery),
                        child: const Text(
                          '¿Olvidaste tu contraseña maestra?',
                          style: TextStyle(
                            color: Color(0xFF9E9EBF),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF9E9EBF),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF39FF14).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF39FF14).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: const Color(0xFF39FF14),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Desbloqueando desde dispositivo móvil...',
              style: TextStyle(
                color: Color(0xFF39FF14),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.phone_android_rounded,
            color: Color(0xFF39FF14),
            size: 18,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: charCount > 0
                ? const Color(0xFF6C63FF).withValues(alpha: 0.6)
                : const Color(0xFF2A2A4A),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Color(0xFF6C63FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: charCount == 0
                  ? const Text(
                      'Toca para ingresar tu contraseña',
                      style: TextStyle(color: Color(0xFF5C5C7A), fontSize: 14),
                    )
                  : Text(
                      '●' * charCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Icon(
              Icons.keyboard_rounded,
              color: const Color(0xFF6C63FF).withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
