import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/presentation/layouts/responsive_layout.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';
import '../../credentials/presentation/qr_scanner_screen.dart';
import '../application/pairing_notifier.dart';
import '../domain/connected_device.dart';
import '../domain/i_sync_service.dart';
import 'widgets/sync_summary_card.dart';

class PairingScreen extends ConsumerWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: VaultAppBar(
        title: l10n.syncTitle,
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
  bool _hasPairingKey = false;
  String? _serverStatusMessage;
  StreamSubscription<String>? _serverEventsSubscription;

  @override
  void initState() {
    super.initState();
    _checkPairingKey();
    _subscribeToServerEvents();
    Future.microtask(() {
      final syncService = getIt<ISyncService>();
      if (!syncService.isServerRunning) {
        ref.read(pairingNotifierProvider.notifier).startDesktopServer();
      } else {
        setState(() {
          _serverStatusMessage = AppLocalizations.of(context).syncServerActive;
        });
      }
    });
  }

  Future<void> _checkPairingKey() async {
    final hasPairing = await getIt<ISyncService>().hasPairingKey();
    if (mounted) setState(() => _hasPairingKey = hasPairing);
  }

  void _subscribeToServerEvents() {
    _serverEventsSubscription = getIt<ISyncService>().serverEvents.listen((event) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        if (event == 'server_started') {
          _serverStatusMessage = l10n.syncServerActive;
        } else if (event == 'server_stopped') {
          _serverStatusMessage = l10n.syncServerOff;
        } else if (event == 'client_connecting') {
          _serverStatusMessage = l10n.syncClientConnecting;
        } else if (event == 'client_disconnected') {
          _serverStatusMessage = l10n.syncClientDisconnected;
        } else if (event == 'paired') {
          _hasPairingKey = true;
          _serverStatusMessage = l10n.syncPairedOk;
        } else if (event == 'sync_manifest_processed') {
          _serverStatusMessage = l10n.syncComparing;
        } else if (event == 'sync_completed') {
          final done = l10n.syncBidirOk;
          _serverStatusMessage = done;
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted && _serverStatusMessage == done) {
              setState(() => _serverStatusMessage =
                  AppLocalizations.of(context).syncServerActive);
            }
          });
        } else if (event == 'sync_error') {
          _serverStatusMessage = l10n.syncErrorGeneric;
        } else if (event.startsWith('remote_unlock')) {
          final msg = l10n.syncRemoteUnlockReceived;
          _serverStatusMessage = msg;
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted && _serverStatusMessage == msg) {
              setState(() => _serverStatusMessage =
                  AppLocalizations.of(context).syncServerActive);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _serverEventsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final state = ref.watch(pairingNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.status == PairingStatus.idle) ...[
              if (_hasPairingKey) ...[
                _buildDesktopConnectedSection(state),
              ] else ...[
                Icon(Icons.sync_rounded, size: 64, color: palette.primary),
                const SizedBox(height: 20),
                Text(
                  l10n.syncPairTitle,
                  style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.syncPairSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => ref.read(pairingNotifierProvider.notifier).startDesktopServer(),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: Text(l10n.syncGenerateQr),
                ),
              ],
            ] else if (state.status == PairingStatus.loading) ...[
              CircularProgressIndicator(color: palette.primary),
              const SizedBox(height: 20),
              Text(l10n.syncStartingServer, style: TextStyle(color: palette.textMuted)),
            ] else if (state.status == PairingStatus.serverReady && state.payload != null) ...[
              Text(
                l10n.syncScanThisQr,
                style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.syncScanThisQrSub,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 12),
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
                style: TextStyle(color: palette.textDisabled, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).stopDesktopServer(),
                icon: Icon(Icons.close_rounded, color: palette.error),
                label: Text(l10n.commonCancel, style: TextStyle(color: palette.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: palette.error),
                ),
              ),
            ] else if (state.status == PairingStatus.connecting) ...[
              CircularProgressIndicator(color: palette.primary),
              const SizedBox(height: 20),
              Text(l10n.syncConnectingDevice, style: TextStyle(color: palette.textMuted)),
            ] else if (state.status == PairingStatus.paired) ...[
              Icon(Icons.check_circle_rounded, size: 64, color: palette.primary),
              const SizedBox(height: 20),
              Text(
                l10n.syncLinkedTitle,
                style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.syncLinkedSub,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).reset(),
                child: Text(l10n.syncUnderstood),
              ),
            ] else if (state.status == PairingStatus.failed) ...[
              Icon(Icons.error_outline_rounded, size: 64, color: palette.error),
              const SizedBox(height: 20),
              Text(
                l10n.syncErrorTitle,
                style: TextStyle(color: palette.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? l10n.syncUnexpectedError,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => ref.read(pairingNotifierProvider.notifier).reset(),
                child: Text(l10n.syncRetryButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopConnectedSection(PairingState state) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 64, color: palette.primary),
        const SizedBox(height: 20),
        Text(
          l10n.syncComputerLinked,
          style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.syncComputerLinkedSub,
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        // Server status box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.primary,
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.syncServerE2eeActive,
                    style: TextStyle(color: palette.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDevicesList(palette),
              if (_serverStatusMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _serverStatusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // "Qué se sincronizó" + historial de las ultimas rondas.
        const SyncSummaryCard(),
        const SizedBox(height: 24),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                await getIt<ISyncService>().removePairingKey();
                await getIt<ISyncService>().stopServer();
                setState(() {
                  _hasPairingKey = false;
                  _serverStatusMessage = null;
                });
                ref.read(pairingNotifierProvider.notifier).reset();
              },
              icon: Icon(Icons.delete_outline_rounded, color: palette.error),
              label: Text(l10n.syncRemoveLink, style: TextStyle(color: palette.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                side: BorderSide(color: palette.error),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(pairingNotifierProvider.notifier).startDesktopServer();
              },
              icon: const Icon(Icons.qr_code_rounded),
              label: Text(l10n.syncShowQr),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 46),
                backgroundColor: palette.primary,
                foregroundColor: palette.background,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Live list of the mobile devices currently connected to the sync server,
  /// each with its own status (connected / syncing / synced).
  Widget _buildDevicesList(AppPalette palette) {
    final devices = getIt<ISyncService>().connectedDevices;
    if (devices.isEmpty) {
      return _statusChip(
        palette,
        palette.textMuted,
        Icon(Icons.hourglass_empty_rounded, color: palette.textMuted, size: 16),
        AppLocalizations.of(context).syncWaitingDevices,
      );
    }
    return Column(
      children: [
        for (var i = 0; i < devices.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _buildDeviceRow(palette, devices[i]),
        ],
      ],
    );
  }

  Widget _buildDeviceRow(AppPalette palette, ConnectedDevice device) {
    final l10n = AppLocalizations.of(context);
    final Color color;
    final Widget trailing;
    final String statusLabel;
    switch (device.status) {
      case DeviceSyncStatus.syncing:
        color = palette.accent;
        trailing = SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        );
        statusLabel = l10n.syncStatusSyncing;
      case DeviceSyncStatus.synced:
        color = palette.success;
        trailing = Icon(Icons.check_circle_rounded, color: color, size: 15);
        statusLabel = l10n.syncStatusSynced;
      case DeviceSyncStatus.connected:
        color = palette.success;
        trailing = Icon(Icons.bolt_rounded, color: color, size: 15);
        statusLabel = l10n.syncStatusConnected;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.smartphone_rounded, color: palette.textPrimary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              device.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
      AppPalette palette, Color color, Widget leading, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
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
  // Tipo del mensaje de estado (para color/icono) — reemplaza la deteccion por
  // prefijo de texto, que se rompia al localizar.
  bool _syncIsError = false;
  bool _syncIsSuccess = false;
  StreamSubscription<String>? _clientEventsSubscription;

  @override
  void initState() {
    super.initState();
    _checkPairingKey();
    _subscribeToClientEvents();
    _autoResume();
  }

  /// Reconnects automatically (resume, no QR) if this phone was paired before,
  /// so sync and login-approval work without re-scanning. Keep-alive starts on
  /// success (M1).
  Future<void> _autoResume() async {
    final sync = getIt<ISyncService>();
    if (sync.isClientConnected) return;
    if (await sync.canResume()) {
      await sync.resumeWithDesktop();
    }
  }

  void _subscribeToClientEvents() {
    _clientEventsSubscription = getIt<ISyncService>().clientEvents.listen((event) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        if (event == 'sync_started') {
          _isSyncing = true;
          _syncIsError = false;
          _syncIsSuccess = false;
          _syncStatusMessage = l10n.syncStarting;
        } else if (event == 'sync_response_processed') {
          _syncStatusMessage = l10n.syncSendingLocal;
        } else if (event.startsWith('sync_completed:')) {
          _isSyncing = false;
          _syncIsSuccess = true;
          final stats = event.replaceFirst('sync_completed:', '');
          _syncStatusMessage = l10n.syncSuccessStats(stats);
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _syncStatusMessage = null);
          });
        } else if (event.startsWith('error:')) {
          _isSyncing = false;
          _syncIsError = true;
          final detail = event.replaceFirst('error:', '').trim();
          _syncStatusMessage = '${l10n.syncErrorGeneric} ($detail)';
        }
      });
    });
  }

  @override
  void dispose() {
    _clientEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPairingKey() async {
    final hasPairing = await getIt<ISyncService>().hasPairingKey();
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
  /// 1. Verify this phone holds a WiFi-unlock token (DUK).
  /// 2. Prompt biometric authentication.
  /// 3. Send the DUK over the E2EE channel — the desktop decrypts its own master
  ///    key with it. The master PASSWORD never leaves this device.
  Future<void> _sendRemoteUnlock() async {
    // Capturamos l10n ANTES de cualquier await para no usar el context tras un
    // async gap (la razon biometrica se pasa luego de varios awaits).
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isSendingUnlock = true;
      _unlockResult = null;
    });

    try {
      final syncService = getIt<ISyncService>();

      // 1. Need a registered token (issued when pairing with vault unlocked).
      if (!await syncService.hasRemoteUnlockToken()) {
        if (mounted) {
          setState(() {
            _isSendingUnlock = false;
            _unlockResult = 'no_token';
          });
        }
        return;
      }

      // 2. Require biometric authentication
      final biometricService = getIt<BiometricAuthService>();
      final authenticated = await biometricService.authenticate(
        reason: l10n.syncBiometricReason,
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

      // 3. Send the unlock request (DUK token).
      final success = await syncService.sendRemoteUnlockRequest();

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
    final palette = context.palette;
    final state = ref.watch(pairingNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.status == PairingStatus.idle) ...[
              Icon(Icons.sync_rounded, size: 72, color: palette.accent),
              const SizedBox(height: 24),
              Text(
                l10n.syncLinkComputer,
                style: TextStyle(color: palette.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.syncLinkComputerSub,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: _scanQr,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(l10n.syncScanQrButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  minimumSize: const Size(240, 54),
                ),
              ),

              // ── WiFi Unlock Button ──────────────────────────────────────
              if (_hasPairingKey) ...[
                const SizedBox(height: 32),
                Divider(color: palette.divider, height: 1),
                const SizedBox(height: 28),
                _buildSyncSection(),
                const SizedBox(height: 16),
                const SyncSummaryCard(),
                const SizedBox(height: 24),
                _buildWifiUnlockSection(),
              ],
            ] else if (state.status == PairingStatus.connecting) ...[
              CircularProgressIndicator(color: palette.accent),
              const SizedBox(height: 24),
              Text(
                l10n.syncNegotiating,
                style: TextStyle(color: palette.textMuted, fontSize: 15),
              ),
            ] else if (state.status == PairingStatus.paired) ...[
              Icon(Icons.check_circle_rounded, size: 72, color: palette.success),
              const SizedBox(height: 24),
              Text(
                l10n.syncComputerLinkedExcl,
                style: TextStyle(color: palette.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.syncComputerLinkedExclSub,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  ref.read(pairingNotifierProvider.notifier).reset();
                  _checkPairingKey();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.success,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(l10n.syncBack),
              ),
            ] else if (state.status == PairingStatus.failed) ...[
              Icon(Icons.error_outline_rounded, size: 72, color: palette.danger),
              const SizedBox(height: 24),
              Text(
                l10n.syncErrorTitle,
                style: TextStyle(color: palette.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  state.errorMessage ?? l10n.syncCouldNotConnect,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _scanQr,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.danger,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(l10n.syncRetryButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWifiUnlockSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_rounded,
              color: palette.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.syncRemoteUnlockTitle,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.syncRemoteUnlockSub,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.3),
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
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text(
                          l10n.syncSending,
                          style: TextStyle(color: palette.primary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _sendRemoteUnlock,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: Text(l10n.syncUnlockComputer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.background,
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    late final IconData icon;
    late final Color color;
    late final String message;

    switch (_unlockResult) {
      case 'sent':
        icon = Icons.check_circle_rounded;
        color = palette.success;
        message = l10n.syncUnlockSentBanner;
        break;
      case 'auth_cancelled':
        icon = Icons.fingerprint_rounded;
        color = palette.textMuted;
        message = l10n.syncAuthCancelled;
        break;
      case 'no_token':
        icon = Icons.warning_amber_rounded;
        color = palette.warning;
        message = l10n.syncNoToken;
        break;
      case 'failed':
      case 'error':
      default:
        icon = Icons.error_outline_rounded;
        color = palette.danger;
        message = l10n.syncCouldNotConnect;
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
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sync_alt_rounded,
              color: palette.accent,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.syncVaultTitle,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.syncVaultSub,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textMuted, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 20),

          if (_syncStatusMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (_syncIsError
                    ? palette.danger
                    : palette.accent).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (_syncIsError
                      ? palette.danger
                      : palette.accent).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _syncIsError
                        ? Icons.error_outline_rounded
                        : (_syncIsSuccess ? Icons.check_circle_rounded : Icons.sync_rounded),
                    color: _syncIsError
                        ? palette.danger
                        : (_syncIsSuccess ? palette.success : palette.accent),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _syncStatusMessage!,
                      style: TextStyle(
                        color: _syncIsError
                            ? palette.danger
                            : (_syncIsSuccess ? palette.success : palette.textMuted),
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
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: palette.accent,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.syncStatusSyncing,
                          style: TextStyle(color: palette.accent, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      final syncService = getIt<ISyncService>();
                      // Ya conectado: dispara una sincronizacion.
                      if (syncService.isClientConnected) {
                        await syncService.requestSync();
                        return;
                      }
                      // Reconexion (resume) sin re-escanear el QR, usando la
                      // clave persistida del emparejamiento previo.
                      if (!await syncService.canResume()) {
                        if (mounted) {
                          setState(() {
                            _isSyncing = false;
                            _syncIsError = true;
                            _syncIsSuccess = false;
                            _syncStatusMessage =
                                AppLocalizations.of(context).syncNotPairedYet;
                          });
                        }
                        return;
                      }
                      setState(() {
                        _isSyncing = true;
                        _syncIsError = false;
                        _syncIsSuccess = false;
                        _syncStatusMessage =
                            AppLocalizations.of(context).syncConnectingComputer;
                      });
                      final ok = await syncService.resumeWithDesktop();
                      if (!mounted) return;
                      if (ok) {
                        await syncService.requestSync();
                      } else {
                        setState(() {
                          _isSyncing = false;
                          _syncIsError = true;
                          _syncStatusMessage =
                              AppLocalizations.of(context).syncConnectFailCheck;
                        });
                      }
                    },
                    icon: const Icon(Icons.sync_rounded),
                    label: Text(l10n.syncVaultTitle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: palette.onPrimary,
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
