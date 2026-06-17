import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/di/injection.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../credentials/presentation/qr_scanner_screen.dart';
import '../application/pairing_notifier.dart';
import '../infrastructure/sync_service.dart';

class PairingScreen extends ConsumerWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: VaultAppBar(
        title: 'Sincronizar Dispositivo',
        leading: isDesktop ? const SizedBox.shrink() : null,
      ),
      body: isDesktop ? const _DesktopPairingView() : const _MobilePairingView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopPairingView extends ConsumerStatefulWidget {
  const _DesktopPairingView();

  @override
  ConsumerState<_DesktopPairingView> createState() => _DesktopPairingViewState();
}

class _DesktopPairingViewState extends ConsumerState<_DesktopPairingView> {
  @override
  void dispose() {
    // Stop the server when leaving the screen to clean up resources
    Future.microtask(() {
      ref.read(pairingNotifierProvider.notifier).stopDesktopServer();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingNotifierProvider);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF161622),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF222232)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.status == PairingStatus.idle) ...[
              const Icon(Icons.sync_rounded, size: 64, color: Color(0xFF39FF14)),
              const SizedBox(height: 20),
              const Text(
                'Vincular con App Móvil',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sincroniza tus contraseñas en tiempo real de forma segura y desbloquea esta bóveda usando la biometría de tu celular.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E8E9F), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).startDesktopServer(),
                icon: const Icon(Icons.qr_code_rounded),
                label: const Text('Generar Código QR'),
              ),
            ] else if (state.status == PairingStatus.loading) ...[
              const CircularProgressIndicator(color: Color(0xFF39FF14)),
              const SizedBox(height: 20),
              const Text('Iniciando servidor local...', style: TextStyle(color: Colors.white70)),
            ] else if (state.status == PairingStatus.serverReady && state.payload != null) ...[
              const Text(
                'Escanea este código QR',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Abre SoloKey en tu móvil, ve a Sincronizar y escanea este código.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E8E9F), fontSize: 12),
              ),
              const SizedBox(height: 24),
              // QR Code container with light background to make it scannable
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: state.payload!.toQrString(),
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'IP: ${state.payload!.ip}  ·  Puerto: ${state.payload!.port}',
                style: const TextStyle(color: Color(0xFF5C5C7A), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).stopDesktopServer(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFFFF3366)),
                label: const Text('Cancelar', style: TextStyle(color: Color(0xFFFF3366))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF3366)),
                ),
              ),
            ] else if (state.status == PairingStatus.connecting) ...[
              const CircularProgressIndicator(color: Color(0xFF39FF14)),
              const SizedBox(height: 20),
              const Text('Conectando con el dispositivo móvil...', style: TextStyle(color: Colors.white70)),
            ] else if (state.status == PairingStatus.paired) ...[
              const Icon(Icons.check_circle_rounded, size: 64, color: Color(0xFF39FF14)),
              const SizedBox(height: 20),
              const Text(
                '¡Vinculado Exitosamente!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Los dispositivos ahora están enlazados de forma segura.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E8E9F), fontSize: 13),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).reset(),
                child: const Text('Entendido'),
              ),
            ] else if (state.status == PairingStatus.failed) ...[
              const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFFF3366)),
              const SizedBox(height: 20),
              const Text(
                'Error de Vinculación',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8E8E9F), fontSize: 13),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).reset(),
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _MobilePairingView extends ConsumerStatefulWidget {
  const _MobilePairingView();

  @override
  ConsumerState<_MobilePairingView> createState() => _MobilePairingViewState();
}

class _MobilePairingViewState extends ConsumerState<_MobilePairingView> {
  bool _hasPairingKey = false;
  bool _isSendingUnlock = false;
  String? _unlockResult;
  bool _isSyncing = false;
  String? _syncStatusMessage;
  StreamSubscription<String>? _clientEventsSubscription;

  @override
  void initState() {
    super.initState();
    _checkPairingKey();
    _subscribeToClientEvents();
  }

  void _subscribeToClientEvents() {
    _clientEventsSubscription = getIt<SyncService>().clientEvents.listen((event) {
      if (mounted) {
        setState(() {
          if (event == 'sync_started') {
            _isSyncing = true;
            _syncStatusMessage = 'Iniciando sincronización...';
          } else if (event == 'sync_response_processed') {
            _syncStatusMessage = 'Enviando cambios locales...';
          } else if (event.startsWith('sync_completed:')) {
            _isSyncing = false;
            final stats = event.replaceFirst('sync_completed:', '');
            _syncStatusMessage = '¡Sincronización exitosa! ($stats)';
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) setState(() => _syncStatusMessage = null);
            });
          } else if (event.startsWith('error:')) {
            _isSyncing = false;
            _syncStatusMessage = 'Error: ${event.replaceFirst('error:', '')}';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _clientEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPairingKey() async {
    final hasPairing = await getIt<SyncService>().hasPairingKey();
    if (mounted) setState(() => _hasPairingKey = hasPairing);
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(pairingNotifierProvider.notifier).pairWithPc(result);
      await _checkPairingKey();
    }
  }

  /// Sends a WiFi unlock request to the paired desktop.
  ///
  /// Flow:
  /// 1. Prompt biometric authentication.
  /// 2. Retrieve the stored master password from flutter_secure_storage.
  /// 3. Send it encrypted to the desktop via the E2EE WebSocket channel.
  /// 4. Zero the password buffer immediately after sending.
  Future<void> _sendRemoteUnlock() async {
    setState(() {
      _isSendingUnlock = true;
      _unlockResult = null;
    });

    try {
      // 1. Require biometric authentication
      final biometricService = getIt<BiometricAuthService>();
      final authenticated = await biometricService.authenticate(
        reason: 'Autentícate para desbloquear tu computadora',
      );

      if (!authenticated) {
        if (mounted) {
          setState(() {
            _isSendingUnlock = false;
            _unlockResult = 'auth_cancelled';
          });
        }
        return;
      }

      // 2. Retrieve the master password from secure storage
      final storage = getIt<FlutterSecureStorage>();
      final masterPassword = await storage.read(key: 'master_password');

      if (masterPassword == null || masterPassword.isEmpty) {
        if (mounted) {
          setState(() {
            _isSendingUnlock = false;
            _unlockResult = 'no_password';
          });
        }
        return;
      }

      // 3. Send the unlock request
      final syncService = getIt<SyncService>();
      final success =
          await syncService.sendRemoteUnlockRequest(masterPassword);

      if (mounted) {
        setState(() {
          _isSendingUnlock = false;
          _unlockResult = success ? 'sent' : 'failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingUnlock = false;
          _unlockResult = 'error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingNotifierProvider);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.status == PairingStatus.idle) ...[
              const Icon(Icons.sync_rounded, size: 72, color: Color(0xFF6C63FF)),
              const SizedBox(height: 24),
              const Text(
                'Vincular Computadora',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escanea el código QR generado por la aplicación SoloKey en tu computadora para sincronizar los datos locales.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: _scanQr,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Escanear Código QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  minimumSize: const Size(240, 54),
                ),
              ),

              // ── WiFi Unlock Button ──────────────────────────────────────
              if (_hasPairingKey) ...[
                const SizedBox(height: 32),
                const Divider(color: Color(0xFF2A2A4A), height: 1),
                const SizedBox(height: 28),
                _buildSyncSection(),
                const SizedBox(height: 24),
                _buildWifiUnlockSection(),
              ],
            ] else if (state.status == PairingStatus.connecting) ...[
              const CircularProgressIndicator(color: Color(0xFF6C63FF)),
              const SizedBox(height: 24),
              const Text(
                'Negociando claves de encriptación...',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ] else if (state.status == PairingStatus.paired) ...[
              const Icon(Icons.check_circle_rounded, size: 72, color: Color(0xFF4CAF50)),
              const SizedBox(height: 24),
              const Text(
                '¡Computadora Vinculada!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Los datos ahora se sincronizarán de forma segura entre dispositivos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  ref.read(pairingNotifierProvider.notifier).reset();
                  _checkPairingKey();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Volver'),
              ),
            ] else if (state.status == PairingStatus.failed) ...[
              const Icon(Icons.error_outline_rounded, size: 72, color: Color(0xFFCF6679)),
              const SizedBox(height: 24),
              const Text(
                'Error de Vinculación',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  state.errorMessage ?? 'No se pudo conectar con la computadora.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9E9EBF), fontSize: 14),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _scanQr,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCF6679),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Volver a Intentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWifiUnlockSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF39FF14).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF39FF14).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_rounded,
              color: Color(0xFF39FF14),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Desbloqueo Remoto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Desbloquea la bóveda de tu computadora usando la biometría de este dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 20),

          // Result feedback
          if (_unlockResult != null) ...[
            _buildUnlockResultBanner(),
            const SizedBox(height: 16),
          ],

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSendingUnlock
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF39FF14),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Enviando...',
                          style: TextStyle(color: Color(0xFF39FF14), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _sendRemoteUnlock,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Desbloquear Computadora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF39FF14),
                      foregroundColor: const Color(0xFF0C0C14),
                      minimumSize: const Size(240, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockResultBanner() {
    late final IconData icon;
    late final Color color;
    late final String message;

    switch (_unlockResult) {
      case 'sent':
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF4CAF50);
        message = '¡Solicitud enviada! La bóveda debería desbloquearse.';
        break;
      case 'auth_cancelled':
        icon = Icons.fingerprint_rounded;
        color = const Color(0xFF9E9EBF);
        message = 'Autenticación biométrica cancelada.';
        break;
      case 'no_password':
        icon = Icons.warning_amber_rounded;
        color = const Color(0xFFFF9800);
        message = 'Activa el bloqueo biométrico primero en Ajustes.';
        break;
      case 'failed':
      case 'error':
      default:
        icon = Icons.error_outline_rounded;
        color = const Color(0xFFCF6679);
        message = 'No se pudo conectar con la computadora.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_alt_rounded,
              color: Color(0xFF6C63FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sincronizar Bóveda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Intercambia y actualiza tus credenciales bidireccionalmente en red local.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 20),

          if (_syncStatusMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (_syncStatusMessage!.startsWith('Error') 
                    ? const Color(0xFFCF6679) 
                    : const Color(0xFF6C63FF)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (_syncStatusMessage!.startsWith('Error') 
                      ? const Color(0xFFCF6679) 
                      : const Color(0xFF6C63FF)).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _syncStatusMessage!.startsWith('Error') 
                        ? Icons.error_outline_rounded 
                        : (_syncStatusMessage!.startsWith('¡Sincronización') ? Icons.check_circle_rounded : Icons.sync_rounded),
                    color: _syncStatusMessage!.startsWith('Error') 
                        ? const Color(0xFFCF6679) 
                        : (_syncStatusMessage!.startsWith('¡Sincronización') ? const Color(0xFF4CAF50) : const Color(0xFF6C63FF)),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _syncStatusMessage!,
                      style: TextStyle(
                        color: _syncStatusMessage!.startsWith('Error') 
                            ? const Color(0xFFCF6679) 
                            : (_syncStatusMessage!.startsWith('¡Sincronización') ? const Color(0xFF4CAF50) : Colors.white70),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSyncing
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sincronizando...',
                          style: TextStyle(color: Color(0xFF6C63FF), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      final syncService = getIt<SyncService>();
                      if (!syncService.isClientConnected) {
                        setState(() {
                          _isSyncing = true;
                          _syncStatusMessage = 'Buscando computadora en la red...';
                        });
                        await syncService.startDiscovery((payload) async {
                          await syncService.stopDiscovery();
                          final connected = await syncService.pairWithDesktop(payload);
                          if (connected) {
                            await syncService.requestSync();
                          } else {
                            if (mounted) {
                              setState(() {
                                _isSyncing = false;
                                _syncStatusMessage = 'Error: No se pudo conectar a la computadora.';
                              });
                            }
                          }
                        });
                        Future.delayed(const Duration(seconds: 8), () async {
                          if (mounted && _isSyncing && _syncStatusMessage == 'Buscando computadora en la red...') {
                            await syncService.stopDiscovery();
                            setState(() {
                              _isSyncing = false;
                              _syncStatusMessage = 'Error: No se encontró la computadora en la red local.';
                            });
                          }
                        });
                      } else {
                        await syncService.requestSync();
                      }
                    },
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sincronizar Bóveda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(240, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
