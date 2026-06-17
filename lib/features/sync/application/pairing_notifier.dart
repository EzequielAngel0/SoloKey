import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/injection.dart';
import '../domain/pairing_payload.dart';
import '../infrastructure/sync_service.dart';

enum PairingStatus {
  idle,
  loading,
  serverReady,
  connecting,
  paired,
  failed,
}

class PairingState {
  const PairingState({
    required this.status,
    this.payload,
    this.errorMessage,
  });

  final PairingStatus status;
  final PairingPayload? payload;
  final String? errorMessage;

  factory PairingState.idle() => const PairingState(status: PairingStatus.idle);
  factory PairingState.loading() => const PairingState(status: PairingStatus.loading);
  factory PairingState.serverReady(PairingPayload p) =>
      PairingState(status: PairingStatus.serverReady, payload: p);
  factory PairingState.connecting() => const PairingState(status: PairingStatus.connecting);
  factory PairingState.paired() => const PairingState(status: PairingStatus.paired);
  factory PairingState.failed(String err) =>
      PairingState(status: PairingStatus.failed, errorMessage: err);
}

class PairingNotifier extends StateNotifier<PairingState> {
  PairingNotifier() : super(PairingState.idle()) {
    final syncService = getIt<SyncService>();
    // Listen to server events
    syncService.serverEvents.listen((event) {
      if (event == 'paired') {
        state = PairingState.paired();
      } else if (event == 'pairing_failed') {
        state = PairingState.failed('El emparejamiento falló. Verifica el token.');
      }
    });

    // Listen to client events
    syncService.clientEvents.listen((event) {
      if (event == 'paired') {
        state = PairingState.paired();
      } else if (event.startsWith('error:')) {
        state = PairingState.failed(event.replaceFirst('error:', '').trim());
      }
    });
  }

  // DESKTOP: Start the P2P server and output the pairing QR payload
  Future<void> startDesktopServer() async {
    state = PairingState.loading();
    try {
      final payload = await getIt<SyncService>().startServer();
      state = PairingState.serverReady(payload);
    } catch (e) {
      state = PairingState.failed('No se pudo iniciar el servidor local: $e');
    }
  }

  Future<void> stopDesktopServer() async {
    await getIt<SyncService>().stopServer();
    state = PairingState.idle();
  }

  // MOBILE: Submit the scanned QR payload to pair with the PC
  Future<void> pairWithPc(String qrData) async {
    state = PairingState.connecting();
    try {
      final payload = PairingPayload.fromQrString(qrData);
      final success = await getIt<SyncService>().pairWithDesktop(payload);
      if (success) {
        state = PairingState.paired();
      } else {
        state = PairingState.failed('Fallo al acordar la clave de encriptación.');
      }
    } catch (e) {
      state = PairingState.failed('Formato de código QR no válido: $e');
    }
  }

  void reset() {
    state = PairingState.idle();
  }
}

final pairingNotifierProvider =
    StateNotifierProvider<PairingNotifier, PairingState>((ref) {
  return PairingNotifier();
});
