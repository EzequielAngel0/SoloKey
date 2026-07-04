import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/domain/crypto_utils.dart';
import '../../../core/infrastructure/database/app_database.dart';
import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../domain/pairing_payload.dart';
import '../domain/sync_events_source.dart';
import '../domain/sync_network_utils.dart';
import '../domain/sync_summary.dart';
import 'delta_sync_manager.dart';

@lazySingleton
class SyncService implements SyncEventsSource {
  SyncService(
      this._storage, this._db, this._securityService, this._sessionManager);

  final FlutterSecureStorage _storage;
  final AppDatabase _db;
  final ISecurityService _securityService;
  final SessionManager _sessionManager;

  static const String _serviceType = '_solokey-sync._tcp';
  static const String _kSyncKeyName = 'solokey_sync_key';
  static const String _kSyncDevicesName = 'solokey_sync_devices';
  static const String _kDeviceIdName = 'solokey_device_id';
  // Escritorio: K_sync persistida por dispositivo, para que un celular pueda
  // RECONECTARSE (resume) sin re-escanear el QR. Mapa {deviceId: base64(K_sync)}.
  static const String _kServerDeviceKeysName = 'solokey_server_device_keys';
  // Movil: ultimo endpoint conocido del escritorio (ip:port) para reconectar.
  static const String _kDesktopEndpointName = 'solokey_desktop_endpoint';
  // WiFi-unlock (token DUK): el escritorio guarda su master key CIFRADA con el
  // DUK; el movil guarda el DUK que la desbloquea. Asi nunca viaja ni se
  // almacena la contrasena maestra en texto plano.
  static const String _kWrappedKeyName = 'solokey_remote_unlock_wrapped';
  static const String _kRemoteUnlockToken = 'solokey_remote_unlock_token';
  // Historial de las ultimas rondas de sync aplicadas en ESTE dispositivo
  // (fecha, dispositivo, cambios con nombre). Guardado cifrado en Keystore/DPAPI
  // porque los titulos de credenciales son datos del usuario. Solo nombres +
  // contadores: nunca secretos ni la clave de sesion.
  static const String _kSyncHistoryName = 'solokey_sync_history';
  static const int _kSyncHistoryMax = 20;

  // Desktop Server State
  HttpServer? _server;
  nsd.Registration? _registration;
  String? _pairingToken;
  crypto.SimpleKeyPair? _desktopKeyPair;
  Uint8List? _syncKey;

  /// Live registry of mobile devices currently connected to the desktop server.
  /// Each WebSocket connection has its OWN per-connection sync key, so several
  /// phones can pair and sync at the same time without overwriting each other.
  final Set<_ServerPeer> _peers = {};

  /// Snapshot of connected (paired) devices, de-duplicated by id.
  List<ConnectedDevice> get connectedDevices {
    final byId = <String, ConnectedDevice>{};
    for (final p in _peers) {
      if (p.key == null) continue; // handshake not finished yet
      byId[p.id] =
          ConnectedDevice(id: p.id, name: p.name, status: p.status);
    }
    return byId.values.toList();
  }

  final StreamController<String> _serverEventController =
      StreamController<String>.broadcast();
  @override
  Stream<String> get serverEvents => _serverEventController.stream;

  /// Fires once per applied delta with what changed in the LOCAL vault, so the
  /// Riverpod layer can refresh the lists and show a "what synced" summary.
  final StreamController<SyncSummary> _vaultChangesController =
      StreamController<SyncSummary>.broadcast();
  @override
  Stream<SyncSummary> get vaultChanges => _vaultChangesController.stream;

  /// Most recent applied summary (may be empty when the last round changed
  /// nothing). Exposed so a screen opened after a sync can show the last result.
  SyncSummary? _lastSummary;
  SyncSummary? get lastSummary => _lastSummary;

  // Mobile Client State
  WebSocketChannel? _clientChannel;
  nsd.Discovery? _discovery;
  // M1: keep-alive + periodic auto-sync while connected, and one-shot
  // auto-reconnect when the link drops.
  Timer? _heartbeatTimer;
  Timer? _autoSyncTimer;
  bool _autoReconnect = false;
  final StreamController<String> _clientEventController =
      StreamController<String>.broadcast();
  @override
  Stream<String> get clientEvents => _clientEventController.stream;

  @override
  bool get isServerRunning => _server != null;
  @override
  bool get isClientConnected => _clientChannel != null;

  @override
  int get connectedDeviceCount => connectedDevices.length;

  late final DeltaSyncManager _deltaSyncManager =
      DeltaSyncManager(_db, _securityService, _sessionManager);

  // ───────────────────────────────────────────────────────────────────────────
  // DESKTOP: Server Operations
  // ───────────────────────────────────────────────────────────────────────────

  Future<PairingPayload> startServer() async {
    if (_server != null) {
      await stopServer();
    }

    final ip = await _getLocalIp();
    final port = await _findAvailablePort(8283);

    // 1. Generate pairing token (32 random bytes in hex)
    final random = _cryptoRandomBytes(16);
    _pairingToken =
        random.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // 2. Generate ECDH Keypair for Desktop
    final algorithm = crypto.X25519();
    _desktopKeyPair = await algorithm.newKeyPair();
    final desktopPubKey = await _desktopKeyPair!.extractPublicKey();
    final desktopPubKeyHex = base64Encode(desktopPubKey.bytes);

    // 3. Start Shelf router with WebSocket
    final app = Router();
    app.get('/ws', webSocketHandler(_handleServerConnection));

    _server = await shelf_io.serve(app.call, '0.0.0.0', port);

    // 4. Register mDNS service. mDNS is OPTIONAL — it only enables later
    //    auto-discovery for re-sync. On Windows `nsd` needs Bonjour/dnssd.dll,
    //    which is NOT present by default and makes register() throw. That must
    //    never abort pairing: the QR already carries IP+port+token, so we
    //    swallow the failure and still return the payload / show the QR.
    try {
      _registration = await nsd.register(
        nsd.Service(
          name: 'SoloKey Secure Desktop',
          type: _serviceType,
          port: port,
        ),
      );
    } catch (e) {
      _registration = null;
      debugPrint(
          '[SyncService] mDNS no disponible (la vinculacion por QR sigue funcionando): $e');
    }

    _serverEventController.add('server_started');

    return PairingPayload(
      ip: ip,
      port: port,
      pairingToken: _pairingToken!,
      desktopPublicKeyHex: desktopPubKeyHex,
    );
  }

  Future<void> stopServer() async {
    _serverEventController.add('server_stopped');
    final reg = _registration;
    if (reg != null) {
      try {
        await nsd.unregister(reg);
      } catch (_) {
        // mDNS puede no estar disponible (Windows sin Bonjour); ignorar.
      }
    }
    _registration = null;
    await _server?.close(force: true);
    _server = null;
    _pairingToken = null;
    if (_desktopKeyPair != null) {
      _desktopKeyPair = null;
    }
  }

  void _handleServerConnection(WebSocketChannel ws) {
    final peer = _ServerPeer();
    peer.channel = ws;
    _peers.add(peer);
    _serverEventController.add('client_connecting');

    ws.stream.listen(
      (message) async {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'] as String;

          if (type == 'ecdh_exchange') {
            await _handleEcdhExchange(ws, data, peer);
          } else if (type == 'resume') {
            await _handleResume(ws, data, peer);
          } else if (type == 'resume_response') {
            await _handleResumeResponse(ws, data, peer);
          } else if (type == 'ping') {
            ws.sink.add(jsonEncode({'type': 'pong'}));
          } else if (type == 'encrypted') {
            await _handleEncryptedServerMessage(ws, data, peer);
          }
        } catch (e) {
          ws.sink.add(
              jsonEncode({'type': 'error', 'message': 'Processing error: $e'}));
        }
      },
      onDone: () => _removePeer(peer),
      onError: (_) => _removePeer(peer),
    );
  }

  void _removePeer(_ServerPeer peer) {
    if (peer.key != null) zeroBuffer(peer.key!);
    _peers.remove(peer);
    _serverEventController.add('client_disconnected');
    _serverEventController.add('devices_changed');
  }

  Future<void> _handleEcdhExchange(
      WebSocketChannel ws, Map<String, dynamic> data, _ServerPeer peer) async {
    final mobilePubKeyBase64 = data['public_key'] as String;
    final signature = data['signature'] as String;

    if (_pairingToken == null || _desktopKeyPair == null) {
      ws.sink.add(
          jsonEncode({'type': 'error', 'message': 'Pairing session expired'}));
      return;
    }

    final mobilePubKeyBytes = base64Decode(mobilePubKeyBase64);
    final mobilePubKey = crypto.SimplePublicKey(mobilePubKeyBytes,
        type: crypto.KeyPairType.x25519);

    // Compute ECDH shared secret. Each mobile keypair yields a distinct shared
    // secret (and therefore a distinct K_sync) even off the same pairing QR, so
    // multiple phones can pair simultaneously.
    final algorithm = crypto.X25519();
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: _desktopKeyPair!,
      remotePublicKey: mobilePubKey,
    );
    final sharedBytes =
        Uint8List.fromList(await sharedSecret.extractBytes());

    // Derive K_sync candidate
    final kSyncCandidate =
        await _deriveKSync(sharedBytes, _pairingToken!);

    // Zero the intermediate shared secret
    zeroBuffer(sharedBytes);

    // Verify Mobile signature: HMAC(kSyncCandidate, MobilePubKey)
    final hmac = crypto.Hmac.sha256();
    final expectedMac = await hmac.calculateMac(
      mobilePubKeyBytes,
      secretKey: crypto.SecretKey(kSyncCandidate),
    );
    final expectedSig = base64Encode(expectedMac.bytes);

    if (signature == expectedSig) {
      // Valid pairing! Bind the key to THIS connection (not a global field).
      peer.key = kSyncCandidate;
      peer.id = (data['device_id'] as String?)?.trim().isNotEmpty == true
          ? data['device_id'] as String
          : 'device-${_peers.length}';
      peer.name = (data['device_name'] as String?)?.trim().isNotEmpty == true
          ? data['device_name'] as String
          : 'Dispositivo móvil';
      peer.status = DeviceSyncStatus.connected;
      await _savePairedDevice(peer.id, peer.name);
      // Persistir K_sync de ESTE dispositivo para permitir reconexion (resume)
      // sin re-escanear el QR en futuras sesiones del escritorio.
      await _saveServerDeviceKey(peer.id, peer.key!);

      // Respond with Desktop signature: HMAC(kSync, DesktopPubKey)
      final desktopPubKey = await _desktopKeyPair!.extractPublicKey();
      final responseMac = await hmac.calculateMac(
        desktopPubKey.bytes,
        secretKey: crypto.SecretKey(peer.key!),
      );

      // NOTE: We intentionally DO NOT share the MasterKeyConfig. Each device
      // keeps its own salt/master key; credential payloads are re-keyed in
      // transit (see DeltaSyncManager). Adopting a foreign salt would make the
      // device's pre-existing credentials undecryptable.
      final response = <String, dynamic>{
        'type': 'ecdh_response',
        'signature': base64Encode(responseMac.bytes),
      };

      // WiFi-unlock: si la boveda esta desbloqueada, registra un DUK para que
      // ESTE telefono pueda desbloquear el escritorio remotamente sin la
      // contrasena. Devolvemos el DUK; el escritorio solo guarda la key envuelta.
      final duk = await _registerRemoteUnlock();
      if (duk != null) response['duk'] = duk;

      ws.sink.add(jsonEncode(response));
      _serverEventController.add('paired');
      _serverEventController.add('devices_changed');
    } else {
      ws.sink.add(jsonEncode(
          {'type': 'error', 'message': 'Invalid pairing token signature'}));
      _serverEventController.add('pairing_failed');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP SERVER: Resume (reconnect with persisted K_sync, no QR re-scan)
  // ─────────────────────────────────────────────────────────────────────────

  /// Resume step 1: the phone announces its device id. If we hold a stored
  /// K_sync for it, we reply with a random challenge nonce it must HMAC.
  Future<void> _handleResume(
      WebSocketChannel ws, Map<String, dynamic> data, _ServerPeer peer) async {
    final deviceId = (data['device_id'] as String?)?.trim() ?? '';
    final storedKey =
        deviceId.isEmpty ? null : await _loadServerDeviceKey(deviceId);
    if (storedKey == null) {
      ws.sink.add(
          jsonEncode({'type': 'error', 'message': 'resume_unknown_device'}));
      return;
    }
    peer.id = deviceId;
    final devices = await _loadPairedDevices();
    peer.name = devices[deviceId] ?? 'Dispositivo móvil';
    peer.resumeKey = storedKey;
    peer.resumeChallenge = _cryptoRandomBytes(32);
    ws.sink.add(jsonEncode({
      'type': 'resume_challenge',
      'nonce': base64Encode(peer.resumeChallenge!),
    }));
  }

  /// Resume step 2: verify HMAC(K_sync, nonce). On success the connection is
  /// authenticated and bound to the stored key — encrypted messages flow as if
  /// freshly paired, without re-deriving or transmitting the key.
  Future<void> _handleResumeResponse(
      WebSocketChannel ws, Map<String, dynamic> data, _ServerPeer peer) async {
    final mac = data['mac'] as String?;
    if (peer.resumeKey == null || peer.resumeChallenge == null || mac == null) {
      ws.sink.add(jsonEncode({'type': 'error', 'message': 'resume_failed'}));
      return;
    }
    final hmac = crypto.Hmac.sha256();
    final expected = await hmac.calculateMac(
      peer.resumeChallenge!,
      secretKey: crypto.SecretKey(peer.resumeKey!),
    );
    if (base64Encode(expected.bytes) != mac) {
      ws.sink.add(jsonEncode({'type': 'error', 'message': 'resume_failed'}));
      _serverEventController.add('pairing_failed');
      return;
    }
    peer.key = peer.resumeKey;
    peer.resumeKey = null;
    peer.resumeChallenge = null;
    peer.status = DeviceSyncStatus.connected;
    ws.sink.add(jsonEncode({'type': 'resumed'}));
    _serverEventController.add('client_resumed');
    _serverEventController.add('devices_changed');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP SERVER: Push login-approval request to connected phones (M3)
  // ─────────────────────────────────────────────────────────────────────────

  /// True when at least one phone is connected (a remote approval can be sent).
  bool get hasConnectedDevices => _peers.any((p) => p.key != null);

  /// Asks every connected phone to approve unlocking this desktop. The phone
  /// shows a LOCAL notification (no FCM); approving sends back its DUK over the
  /// existing E2EE channel, which decrypts the locally-wrapped master key.
  /// Returns how many phones the request reached.
  Future<int> requestApproval() async {
    var sent = 0;
    for (final peer in _peers) {
      if (peer.key == null) continue;
      await _sendEncryptedToPeer(peer, {
        'action': 'approval_request',
        'payload': {'desktop': _localDeviceName()},
      });
      sent++;
    }
    if (sent > 0) _serverEventController.add('approval_requested');
    return sent;
  }

  Future<void> _sendEncryptedToPeer(
      _ServerPeer peer, Map<String, dynamic> plainMsg) async {
    final ch = peer.channel;
    if (peer.key == null || ch == null) return;
    final plainBytes = utf8.encode(jsonEncode(plainMsg));
    final encryptedBytes = await _securityService.encrypt(
        Uint8List.fromList(plainBytes), peer.key!);
    ch.sink.add(jsonEncode({
      'type': 'encrypted',
      'payload': base64Encode(encryptedBytes),
    }));
  }

  Future<void> _handleEncryptedServerMessage(
      WebSocketChannel ws, Map<String, dynamic> data, _ServerPeer peer) async {
    if (peer.key == null) {
      ws.sink.add(
          jsonEncode({'type': 'error', 'message': 'Unpaired connection'}));
      return;
    }

    final cipherBlob = base64Decode(data['payload'] as String);
    final plainBytes =
        await _securityService.decrypt(cipherBlob, peer.key!);
    final plainText = utf8.decode(plainBytes);

    // Zero the decrypted buffer copy held in plainBytes
    zeroBuffer(Uint8List.fromList(plainBytes));

    final decryptedMessage =
        jsonDecode(plainText) as Map<String, dynamic>;
    await _handleDecryptedServerMessage(ws, decryptedMessage, peer);
  }

  Future<void> _handleDecryptedServerMessage(
      WebSocketChannel ws, Map<String, dynamic> msg, _ServerPeer peer) async {
    final action = msg['action'] as String;

    switch (action) {
      case 'sync_manifest':
        peer.status = DeviceSyncStatus.syncing;
        _serverEventController.add('devices_changed');
        await _handleSyncManifest(ws, msg, peer);
        break;
      case 'sync_push':
        await _handleSyncPush(ws, msg, peer);
        break;
      case 'wifi_unlock':
        await _handleWifiUnlock(ws, msg, peer);
        break;
      default:
        debugPrint('[SyncService] Unknown action: $action');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP SERVER: Delta-Sync Protocol Handlers
  // ─────────────────────────────────────────────────────────────────────────

  /// Handles the first step of delta sync: remote sends its manifest.
  /// We compare, compute what we need and what we can push, and respond.
  Future<void> _handleSyncManifest(
      WebSocketChannel ws, Map<String, dynamic> msg, _ServerPeer peer) async {
    try {
      final payload = msg['payload'] as Map<String, dynamic>;

      // Parse remote credential manifest
      final remoteCredManifest = (payload['credentials'] as List? ?? [])
          .map((i) =>
              SyncManifestItem.fromJson(i as Map<String, dynamic>))
          .toList();

      // Parse remote folder manifest
      final remoteFolderManifest = (payload['folders'] as List? ?? [])
          .map((i) =>
              SyncManifestItem.fromJson(i as Map<String, dynamic>))
          .toList();

      // Compute credential deltas
      final credDeltas =
          await _deltaSyncManager.computeCredentialDeltas(remoteCredManifest);

      // Compute folder deltas
      final folderDeltas =
          await _deltaSyncManager.computeFolderDeltas(remoteFolderManifest);

      // Send response: our items to push + list of IDs we need
      await _sendEncryptedMessage(ws, {
        'action': 'sync_response',
        'payload': {
          'request_credential_ids': credDeltas.toRequest,
          'request_folder_ids': folderDeltas.toRequest,
          'push_credentials':
              credDeltas.toPush.map((i) => i.toJson()).toList(),
          'push_folders':
              folderDeltas.toPush.map((i) => i.toJson()).toList(),
        },
      }, peer);

      _serverEventController.add('sync_manifest_processed');
    } catch (e) {
      debugPrint('[SyncService] Error processing sync manifest: $e');
      peer.status = DeviceSyncStatus.connected;
      _serverEventController.add('devices_changed');
      _serverEventController.add('sync_error');
    }
  }

  /// Handles the second step: remote pushes the rows we requested.
  Future<void> _handleSyncPush(
      WebSocketChannel ws, Map<String, dynamic> msg, _ServerPeer peer) async {
    try {
      final payload = msg['payload'] as Map<String, dynamic>;

      // Apply received credential rows
      final remoteCredentials =
          (payload['credentials'] as List? ?? [])
              .map((i) =>
                  SyncManifestItem.fromJson(i as Map<String, dynamic>))
              .toList();
      final credChanges =
          await _deltaSyncManager.applyRemoteCredentials(remoteCredentials);

      // Apply received folder rows
      final remoteFolders = (payload['folders'] as List? ?? [])
          .map(
              (i) => SyncManifestItem.fromJson(i as Map<String, dynamic>))
          .toList();
      final folderChanges =
          await _deltaSyncManager.applyRemoteFolders(remoteFolders);

      // Acknowledge sync completion (wire format unchanged: counts only).
      await _sendEncryptedMessage(ws, {
        'action': 'sync_complete',
        'payload': {
          'credentials_applied': credChanges.length,
          'folders_applied': folderChanges.length,
        },
      }, peer);

      // Record what changed on THIS (desktop) vault and refresh the UI.
      await _recordApplied([...credChanges, ...folderChanges], peer.name);

      peer.status = DeviceSyncStatus.synced;
      _serverEventController.add('devices_changed');
      _serverEventController.add('sync_completed');
    } catch (e) {
      debugPrint('[SyncService] Error applying sync push: $e');
      peer.status = DeviceSyncStatus.connected;
      _serverEventController.add('devices_changed');
      _serverEventController.add('sync_error');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP SERVER: WiFi Unlock Handler
  // ─────────────────────────────────────────────────────────────────────────

  /// Registers WiFi-unlock for the currently-connected phone: wraps the desktop
  /// master key with a fresh random DUK, persists ONLY the wrapped key, and
  /// returns the DUK (base64) to hand to the phone. Returns null if the vault is
  /// locked (nothing to wrap). The desktop never stores the DUK.
  Future<String?> _registerRemoteUnlock() async {
    final masterKey = _sessionManager.getKeyCopy();
    if (masterKey == null) return null;
    final duk = _cryptoRandomBytes(32);
    final wrapped = await _securityService.encrypt(masterKey, duk);
    await _storage.write(
        key: _kWrappedKeyName, value: base64Encode(wrapped));
    zeroBuffer(masterKey);
    final dukB64 = base64Encode(duk);
    zeroBuffer(duk);
    return dukB64;
  }

  /// Handles the remote unlock request from the mobile device. The phone sends
  /// its DUK (one-time unlock token); we use it to decrypt the stored wrapped
  /// master key and emit `remote_unlock_key:<base64 key>` for the UnlockScreen.
  /// The master PASSWORD never travels nor is stored.
  Future<void> _handleWifiUnlock(
      WebSocketChannel ws, Map<String, dynamic> msg, _ServerPeer peer) async {
    try {
      final dukB64 = msg['duk'] as String?;
      final wrappedB64 = await _storage.read(key: _kWrappedKeyName);

      if (dukB64 == null || dukB64.isEmpty || wrappedB64 == null) {
        await _sendEncryptedMessage(ws, {
          'action': 'wifi_unlock_response',
          'payload': {'success': false, 'error': 'not_registered'},
        }, peer);
        return;
      }

      final duk = base64Decode(dukB64);
      final wrapped = base64Decode(wrappedB64);
      final masterKey = await _securityService.decrypt(wrapped, duk);
      zeroBuffer(duk);

      // Emit the event for the desktop UI to unlock with the raw key.
      _serverEventController.add('remote_unlock_key:${base64Encode(masterKey)}');
      zeroBuffer(masterKey);

      await _sendEncryptedMessage(ws, {
        'action': 'wifi_unlock_response',
        'payload': {'success': true},
      }, peer);
    } catch (e) {
      debugPrint('[SyncService] WiFi unlock error: $e');
      await _sendEncryptedMessage(ws, {
        'action': 'wifi_unlock_response',
        'payload': {'success': false, 'error': 'server_error'},
      }, peer);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MOBILE: Client Operations
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> startDiscovery(
      void Function(PairingPayload) onDeviceFound) async {
    if (_discovery != null) {
      await stopDiscovery();
    }

    try {
      _discovery = await nsd.startDiscovery(_serviceType);
    } catch (e) {
      // mDNS no disponible (p.ej. Windows sin Bonjour). La auto-deteccion no
      // puede correr; el usuario debe re-vincular por QR. Lo exponemos para que
      // la UI lo refleje en vez de quedarse "buscando" para siempre.
      _discovery = null;
      _clientEventController.add('error: discovery_unavailable');
      return;
    }
    _discovery!.addListener(() {
      for (final service in _discovery!.services) {
        final addresses = service.addresses;
        if (addresses != null && addresses.isNotEmpty) {
          final ip = addresses.first.address;
          final port = service.port;
          if (port != null) {
            onDeviceFound(
              PairingPayload(
                ip: ip,
                port: port,
                pairingToken: '', // Token is scanned via QR, not mDNS
                desktopPublicKeyHex: '',
              ),
            );
          }
        }
      }
    });
  }

  Future<void> stopDiscovery() async {
    if (_discovery != null) {
      await nsd.stopDiscovery(_discovery!);
      _discovery = null;
    }
  }

  Future<bool> pairWithDesktop(PairingPayload payload) async {
    try {
      _clientEventController.add('connecting');
      final uri = Uri.parse('ws://${payload.ip}:${payload.port}/ws');
      _clientChannel = WebSocketChannel.connect(uri);

      // 1. Generate Mobile ECDH Keypair
      final algorithm = crypto.X25519();
      final mobileKeyPair = await algorithm.newKeyPair();
      final mobilePubKey = await mobileKeyPair.extractPublicKey();
      final mobilePubKeyBase64 = base64Encode(mobilePubKey.bytes);

      // 2. Derive K_sync
      final desktopPubKeyBytes =
          base64Decode(payload.desktopPublicKeyHex);
      final desktopPubKey = crypto.SimplePublicKey(desktopPubKeyBytes,
          type: crypto.KeyPairType.x25519);

      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: mobileKeyPair,
        remotePublicKey: desktopPubKey,
      );
      final sharedBytes =
          Uint8List.fromList(await sharedSecret.extractBytes());
      final kSync =
          await _deriveKSync(sharedBytes, payload.pairingToken);

      // Zero intermediate shared secret
      zeroBuffer(sharedBytes);

      // 3. Compute Mobile signature: HMAC(kSync, MobilePubKey)
      final hmac = crypto.Hmac.sha256();
      final mobileMac = await hmac.calculateMac(
        mobilePubKey.bytes,
        secretKey: crypto.SecretKey(kSync),
      );
      final mobileSig = base64Encode(mobileMac.bytes);

      // 4. Send ECDH exchange request (with this device's identity so the
      //    desktop can list it among connected devices).
      _clientChannel!.sink.add(jsonEncode({
        'type': 'ecdh_exchange',
        'public_key': mobilePubKeyBase64,
        'signature': mobileSig,
        'device_id': await _localDeviceId(),
        'device_name': _localDeviceName(),
      }));

      // 5. Wait for server response
      final responseCompleter = Completer<bool>();
      _clientChannel!.stream.listen((message) async {
        try {
          final data =
              jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'] as String;

          if (type == 'ecdh_response') {
            final desktopSig = data['signature'] as String;

            // Verify server signature: HMAC(kSync, DesktopPubKey)
            final expectedServerMac = await hmac.calculateMac(
              desktopPubKeyBytes,
              secretKey: crypto.SecretKey(kSync),
            );
            final expectedServerSig =
                base64Encode(expectedServerMac.bytes);

            if (desktopSig == expectedServerSig) {
              _syncKey = kSync;
              await _storage.write(
                  key: _kSyncKeyName,
                  value: base64Encode(_syncKey!));
              // Guarda el endpoint del escritorio para poder reconectar (resume)
              // sin re-escanear el QR en futuras sesiones.
              await _storage.write(
                  key: _kDesktopEndpointName,
                  value: '${payload.ip}:${payload.port}');

              // NOTE: We no longer adopt the remote MasterKeyConfig. Each device
              // keeps its own salt/master key; payloads are re-keyed in transit
              // (DeltaSyncManager). Adopting a foreign salt corrupted local data.

              // WiFi-unlock: store the DUK (one-time unlock token) the desktop
              // issued, so this phone can later unlock it without the password.
              final duk = data['duk'] as String?;
              if (duk != null && duk.isNotEmpty) {
                await _storage.write(key: _kRemoteUnlockToken, value: duk);
              }

              _clientEventController.add('paired');
              responseCompleter.complete(true);
            } else {
              _clientEventController.add('pairing_failed');
              responseCompleter.complete(false);
            }
          } else if (type == 'encrypted') {
            // Handle encrypted responses from server during client operations
            await _handleEncryptedClientMessage(data);
          } else if (type == 'error') {
            _clientEventController.add('error: ${data['message']}');
            if (!responseCompleter.isCompleted) {
              responseCompleter.complete(false);
            }
          }
        } catch (e) {
          _clientEventController.add('error: $e');
          if (!responseCompleter.isCompleted) {
            responseCompleter.complete(false);
          }
        }
      });

      return await responseCompleter.future
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
    } catch (e) {
      _clientEventController.add('error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE: Delta-Sync Client Operations
  // ─────────────────────────────────────────────────────────────────────────

  /// Initiates a delta sync from the mobile device.
  /// Sends the local manifest to the desktop server and waits for the response.
  Future<bool> requestSync() async {
    if (_clientChannel == null || _syncKey == null) {
      _clientEventController.add('error: Not connected or unpaired');
      return false;
    }

    try {
      _clientEventController.add('sync_started');

      // Build local manifests
      final credManifest =
          await _deltaSyncManager.buildCredentialManifest();
      final folderManifest =
          await _deltaSyncManager.buildFolderManifest();

      // Send manifest to server
      await _sendEncryptedClientMessage({
        'action': 'sync_manifest',
        'payload': {
          'credentials':
              credManifest.map((i) => i.toJson()).toList(),
          'folders':
              folderManifest.map((i) => i.toJson()).toList(),
        },
      });

      return true;
    } catch (e) {
      _clientEventController.add('error: Sync failed: $e');
      return false;
    }
  }

  /// Handles encrypted messages received by the mobile client from the server.
  Future<void> _handleEncryptedClientMessage(
      Map<String, dynamic> data) async {
    if (_syncKey == null) {
      final saved = await _storage.read(key: _kSyncKeyName);
      if (saved != null) {
        _syncKey = base64Decode(saved);
      } else {
        return;
      }
    }

    final cipherBlob = base64Decode(data['payload'] as String);
    final plainBytes =
        await _securityService.decrypt(cipherBlob, _syncKey!);
    final plainText = utf8.decode(plainBytes);
    zeroBuffer(Uint8List.fromList(plainBytes));

    final msg = jsonDecode(plainText) as Map<String, dynamic>;
    final action = msg['action'] as String;

    switch (action) {
      case 'sync_response':
        await _handleSyncResponse(msg);
        break;
      case 'sync_complete':
        _handleSyncComplete(msg);
        break;
      case 'wifi_unlock_response':
        _handleWifiUnlockResponse(msg);
        break;
      case 'approval_request':
        // M3: el escritorio pide aprobacion de desbloqueo. Lo exponemos para que
        // la UI muestre una notificacion local y el usuario apruebe (biometria +
        // envio del DUK). No se usa FCM: requiere la app conectada.
        _clientEventController.add('approval_request');
        break;
      default:
        debugPrint('[SyncService Client] Unknown action: $action');
    }
  }

  /// Processes the server's sync response: applies pushed rows and sends
  /// requested rows back to the server.
  Future<void> _handleSyncResponse(Map<String, dynamic> msg) async {
    try {
      final payload = msg['payload'] as Map<String, dynamic>;

      // Apply credentials the server pushed to us
      final pushedCreds = (payload['push_credentials'] as List? ?? [])
          .map((i) =>
              SyncManifestItem.fromJson(i as Map<String, dynamic>))
          .toList();
      final credChanges =
          await _deltaSyncManager.applyRemoteCredentials(pushedCreds);

      // Apply folders the server pushed to us
      final pushedFolders =
          (payload['push_folders'] as List? ?? [])
              .map((i) =>
                  SyncManifestItem.fromJson(i as Map<String, dynamic>))
              .toList();
      final folderChanges =
          await _deltaSyncManager.applyRemoteFolders(pushedFolders);

      // Record what changed on THIS (mobile) vault and refresh the UI. The
      // desktop's name is not known on the client side, so leave it null.
      await _recordApplied([...credChanges, ...folderChanges], null);

      // Now send the rows the server requested from us
      final requestedCredIds =
          List<String>.from(payload['request_credential_ids'] ?? []);
      final requestedFolderIds =
          List<String>.from(payload['request_folder_ids'] ?? []);

      final credsToSend = <SyncManifestItem>[];
      for (final id in requestedCredIds) {
        final item = await _deltaSyncManager.buildCredentialPushItem(id);
        if (item != null) credsToSend.add(item);
      }

      final foldersToSend = <SyncManifestItem>[];
      for (final id in requestedFolderIds) {
        final item = await _deltaSyncManager.buildFolderPushItem(id);
        if (item != null) foldersToSend.add(item);
      }

      // Push the requested rows to the server
      await _sendEncryptedClientMessage({
        'action': 'sync_push',
        'payload': {
          'credentials':
              credsToSend.map((i) => i.toJson()).toList(),
          'folders':
              foldersToSend.map((i) => i.toJson()).toList(),
        },
      });

      _clientEventController.add('sync_response_processed');
    } catch (e) {
      _clientEventController.add('error: Sync response error: $e');
    }
  }

  void _handleSyncComplete(Map<String, dynamic> msg) {
    final payload = msg['payload'] as Map<String, dynamic>? ?? {};
    final credsApplied = payload['credentials_applied'] ?? 0;
    final foldersApplied = payload['folders_applied'] ?? 0;
    _clientEventController.add(
        'sync_completed:creds=$credsApplied,folders=$foldersApplied');
  }

  void _handleWifiUnlockResponse(Map<String, dynamic> msg) {
    final payload = msg['payload'] as Map<String, dynamic>? ?? {};
    final success = payload['success'] as bool? ?? false;
    if (success) {
      _clientEventController.add('wifi_unlock_sent');
    } else {
      final error = payload['error'] as String? ?? 'Unknown error';
      _clientEventController.add('wifi_unlock_failed:$error');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE: WiFi Unlock (send the one-time DUK token, never the password)
  // ─────────────────────────────────────────────────────────────────────────

  /// True if this phone holds a WiFi-unlock token (DUK) for the paired desktop.
  Future<bool> hasRemoteUnlockToken() async =>
      (await _storage.read(key: _kRemoteUnlockToken)) != null;

  /// Sends a remote unlock request: transmits the stored DUK over the E2EE
  /// channel so the desktop can decrypt its own master key. The master password
  /// is never sent nor stored on the phone.
  Future<bool> sendRemoteUnlockRequest() async {
    final duk = await _storage.read(key: _kRemoteUnlockToken);
    if (duk == null) {
      _clientEventController.add('error: no_token');
      return false;
    }

    if (_syncKey == null) {
      final saved = await _storage.read(key: _kSyncKeyName);
      if (saved != null) {
        _syncKey = base64Decode(saved);
      } else {
        _clientEventController.add('error: Not paired');
        return false;
      }
    }

    // Ensure we have a connection to the desktop
    if (_clientChannel == null) {
      _clientEventController.add('error: Not connected to desktop');
      return false;
    }

    try {
      await _sendEncryptedClientMessage({
        'action': 'wifi_unlock',
        'duk': duk,
      });
      return true;
    } catch (e) {
      _clientEventController.add('error: WiFi unlock failed: $e');
      return false;
    }
  }

  /// Connects to a previously-paired desktop using stored connection info.
  /// Returns true if a WebSocket connection was established successfully.
  Future<bool> connectToPairedDesktop(String ip, int port) async {
    try {
      if (_syncKey == null) {
        final saved = await _storage.read(key: _kSyncKeyName);
        if (saved != null) {
          _syncKey = base64Decode(saved);
        } else {
          return false;
        }
      }

      final uri = Uri.parse('ws://$ip:$port/ws');
      _clientChannel = WebSocketChannel.connect(uri);

      _clientChannel!.stream.listen(
        (message) async {
          try {
            final data =
                jsonDecode(message as String) as Map<String, dynamic>;
            if (data['type'] == 'encrypted') {
              await _handleEncryptedClientMessage(data);
            }
          } catch (e) {
            _clientEventController.add('error: $e');
          }
        },
        onDone: () {
          _clientChannel = null;
          _clientEventController.add('disconnected');
        },
        onError: (err) {
          _clientChannel = null;
          _clientEventController.add('error: $err');
        },
      );

      _clientEventController.add('connected');
      return true;
    } catch (e) {
      _clientEventController.add('error: Connection failed: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE: Resume (reconnect without QR) + keep-alive auto-sync (M1)
  // ─────────────────────────────────────────────────────────────────────────

  int _reconnectAttempts = 0;

  /// True once this phone has resume data (endpoint + K_sync) to reconnect.
  Future<bool> canResume() async =>
      (await _storage.read(key: _kDesktopEndpointName)) != null &&
      (await _storage.read(key: _kSyncKeyName)) != null;

  /// Reconnects to the paired desktop using the persisted endpoint + K_sync,
  /// authenticating via the resume challenge (no QR). On success it starts the
  /// keep-alive + periodic auto-sync loop. Returns true when the link is up.
  Future<bool> resumeWithDesktop({String? ip, int? port}) async {
    try {
      var endpoint = (ip != null && port != null) ? '$ip:$port' : null;
      endpoint ??= await _storage.read(key: _kDesktopEndpointName);
      final parsed = endpoint == null ? null : parseEndpoint(endpoint);
      if (parsed == null) {
        _clientEventController.add('error: no_endpoint');
        return false;
      }
      final host = parsed.host;
      final p = parsed.port;

      if (_syncKey == null) {
        final saved = await _storage.read(key: _kSyncKeyName);
        if (saved == null) {
          _clientEventController.add('error: not_paired');
          return false;
        }
        _syncKey = base64Decode(saved);
      }
      final deviceId = await _localDeviceId();
      final hmac = crypto.Hmac.sha256();
      final done = Completer<bool>();

      _clientChannel = WebSocketChannel.connect(Uri.parse('ws://$host:$p/ws'));
      _clientChannel!.stream.listen(
        (message) async {
          try {
            final data = jsonDecode(message as String) as Map<String, dynamic>;
            final type = data['type'] as String?;
            if (type == 'resume_challenge') {
              final nonce = base64Decode(data['nonce'] as String);
              final mac = await hmac.calculateMac(nonce,
                  secretKey: crypto.SecretKey(_syncKey!));
              _clientChannel!.sink.add(jsonEncode({
                'type': 'resume_response',
                'mac': base64Encode(mac.bytes),
              }));
            } else if (type == 'resumed') {
              _reconnectAttempts = 0;
              _clientEventController.add('connected');
              _startClientKeepAlive();
              if (!done.isCompleted) done.complete(true);
            } else if (type == 'encrypted') {
              await _handleEncryptedClientMessage(data);
            } else if (type == 'pong') {
              // keep-alive ack — nothing to do.
            } else if (type == 'error') {
              _clientEventController.add('error: ${data['message']}');
              if (!done.isCompleted) done.complete(false);
            }
          } catch (e) {
            _clientEventController.add('error: $e');
            if (!done.isCompleted) done.complete(false);
          }
        },
        onDone: _onClientDisconnected,
        onError: (err) {
          _clientEventController.add('error: $err');
          _onClientDisconnected();
          if (!done.isCompleted) done.complete(false);
        },
      );

      _autoReconnect = true;
      _clientChannel!.sink
          .add(jsonEncode({'type': 'resume', 'device_id': deviceId}));

      return await done.future
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
    } catch (e) {
      _clientEventController.add('error: $e');
      return false;
    }
  }

  /// Keep-alive ping + periodic delta-sync while connected (M1). Delta-sync only
  /// moves diffs, so a 60s cadence is cheap.
  void _startClientKeepAlive() {
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _clientChannel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
    _autoSyncTimer =
        Timer.periodic(const Duration(seconds: 60), (_) => unawaited(requestSync()));
    unawaited(requestSync()); // immediate sync on (re)connect
  }

  void _onClientDisconnected() {
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = null;
    _autoSyncTimer = null;
    _clientChannel = null;
    _clientEventController.add('disconnected');
    // One-shot auto-reconnect with capped backoff (avoids battery-draining loop).
    if (_autoReconnect && _reconnectAttempts < 5) {
      final attempt = ++_reconnectAttempts;
      Future.delayed(Duration(seconds: 5 * attempt), () {
        if (_clientChannel == null && _autoReconnect) {
          unawaited(resumeWithDesktop());
        }
      });
    }
  }

  /// Stops keeping the connection alive (e.g. user left the sync screen / unpaired).
  void stopAutoReconnect() {
    _autoReconnect = false;
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = null;
    _autoSyncTimer = null;
  }

  /// Checks if this device has paired before — either as a mobile client
  /// (single stored K_sync) or as a desktop server (one or more known devices).
  Future<bool> hasPairingKey() async {
    final saved = await _storage.read(key: _kSyncKeyName);
    if (saved != null) return true;
    final devices = await _loadPairedDevices();
    return devices.isNotEmpty;
  }

  /// Removes all pairing state, effectively "un-pairing" the devices.
  Future<void> removePairingKey() async {
    await _storage.delete(key: _kSyncKeyName);
    await _storage.delete(key: _kSyncDevicesName);
    await _storage.delete(key: _kWrappedKeyName);
    await _storage.delete(key: _kRemoteUnlockToken);
    await _storage.delete(key: _kServerDeviceKeysName);
    await _storage.delete(key: _kDesktopEndpointName);
    await _storage.delete(key: _kSyncHistoryName);
    _lastSummary = null;
    for (final p in _peers) {
      if (p.key != null) zeroBuffer(p.key!);
    }
    _peers.clear();
    _syncKey = null;
    _serverEventController.add('devices_changed');
  }

  /// Loads the persisted `{deviceId: deviceName}` map of paired mobile devices.
  Future<Map<String, String>> _loadPairedDevices() async {
    final raw = await _storage.read(key: _kSyncDevicesName);
    if (raw == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _savePairedDevice(String id, String name) async {
    final devices = await _loadPairedDevices();
    devices[id] = name;
    await _storage.write(key: _kSyncDevicesName, value: jsonEncode(devices));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sync summary + history (what changed on THIS device each round)
  // ─────────────────────────────────────────────────────────────────────────

  /// Records the changes applied in the current round: keeps the last summary,
  /// appends non-empty rounds to the persisted history, and notifies the UI via
  /// [vaultChanges] so the credential/folder lists refresh without reopening.
  Future<void> _recordApplied(
      List<SyncItemChange> changes, String? deviceName) async {
    final summary = SyncSummary(
      timestamp: DateTime.now(),
      changes: changes,
      deviceName: deviceName,
    );
    _lastSummary = summary;
    if (summary.isNotEmpty) {
      await _appendHistory(summary);
    }
    _vaultChangesController.add(summary);
  }

  @override
  Future<List<SyncSummary>> loadHistory() async {
    final raw = await _storage.read(key: _kSyncHistoryName);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => SyncSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _appendHistory(SyncSummary summary) async {
    final history = await loadHistory();
    history.insert(0, summary);
    final trimmed = history.take(_kSyncHistoryMax).toList();
    await _storage.write(
      key: _kSyncHistoryName,
      value: jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  /// Persisted per-device K_sync map for the desktop server (resume support).
  Future<Map<String, String>> _loadServerDeviceKeys() async {
    final raw = await _storage.read(key: _kServerDeviceKeysName);
    if (raw == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveServerDeviceKey(String id, Uint8List key) async {
    final map = await _loadServerDeviceKeys();
    map[id] = base64Encode(key);
    await _storage.write(key: _kServerDeviceKeysName, value: jsonEncode(map));
  }

  Future<Uint8List?> _loadServerDeviceKey(String id) async {
    final b64 = (await _loadServerDeviceKeys())[id];
    return b64 == null ? null : base64Decode(b64);
  }

  /// Stable random id for THIS device, used to label it on the peer. Persisted.
  Future<String> _localDeviceId() async {
    var id = await _storage.read(key: _kDeviceIdName);
    if (id == null) {
      id = _cryptoRandomBytes(8)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await _storage.write(key: _kDeviceIdName, value: id);
    }
    return id;
  }

  String _localDeviceName() {
    if (Platform.isAndroid) return 'Celular Android';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isWindows) return 'PC Windows';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isLinux) return 'Equipo Linux';
    return 'Dispositivo móvil';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Cryptographic & Network Utilities
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _sendEncryptedMessage(
      WebSocketChannel ws, Map<String, dynamic> plainMsg, _ServerPeer peer) async {
    if (peer.key == null) return;
    final plainBytes = utf8.encode(jsonEncode(plainMsg));
    final encryptedBytes = await _securityService.encrypt(
        Uint8List.fromList(plainBytes), peer.key!);
    ws.sink.add(jsonEncode({
      'type': 'encrypted',
      'payload': base64Encode(encryptedBytes),
    }));
  }

  Future<void> _sendEncryptedClientMessage(
      Map<String, dynamic> plainMsg) async {
    if (_clientChannel == null || _syncKey == null) return;
    final plainBytes = utf8.encode(jsonEncode(plainMsg));
    final encryptedBytes = await _securityService.encrypt(
        Uint8List.fromList(plainBytes), _syncKey!);
    _clientChannel!.sink.add(jsonEncode({
      'type': 'encrypted',
      'payload': base64Encode(encryptedBytes),
    }));
  }

  Future<Uint8List> _deriveKSync(
      Uint8List sharedSecret, String token) async {
    final tokenBytes = utf8.encode(token);
    final input =
        Uint8List.fromList([...sharedSecret, ...tokenBytes]);
    final result = await _securityService.sha256(input);
    // Zero intermediate
    zeroBuffer(input);
    return result;
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    // Reduce to the pure model and delegate the (behavior-preserving) choice to
    // `selectPairingIp` (unit-tested in sync_network_utils_test.dart).
    final adapters = [
      for (final interface in interfaces)
        NetworkAdapter(
          name: interface.name,
          ipv4Addresses: [
            for (final addr in interface.addresses)
              if (!addr.isLoopback) addr.address,
          ],
        ),
    ];
    return selectPairingIp(adapters);
  }

  Future<int> _findAvailablePort(int startPort) async {
    var port = startPort;
    while (port < startPort + 100) {
      try {
        final socket = await ServerSocket.bind('0.0.0.0', port);
        await socket.close();
        return port;
      } catch (_) {
        port++;
      }
    }
    return startPort;
  }

  Uint8List _cryptoRandomBytes(int size) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(size, (_) => random.nextInt(256)));
  }

  /// Dispose resources when the service is torn down.
  Future<void> dispose() async {
    stopAutoReconnect();
    await stopServer();
    await stopDiscovery();
    _clientChannel?.sink.close();
    _clientChannel = null;
    for (final p in _peers) {
      if (p.key != null) zeroBuffer(p.key!);
    }
    _peers.clear();
    if (_syncKey != null) {
      zeroBuffer(_syncKey!);
      _syncKey = null;
    }
    await _serverEventController.close();
    await _clientEventController.close();
    await _vaultChangesController.close();
  }
}

/// Sync status of a connected device, surfaced in the desktop UI.
enum DeviceSyncStatus { connected, syncing, synced }

/// Immutable snapshot of a mobile device currently connected to the desktop
/// sync server. Exposed via [SyncService.connectedDevices].
class ConnectedDevice {
  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final DeviceSyncStatus status;
}

/// Per-connection server state. Each WebSocket gets its own [_ServerPeer] so the
/// desktop can serve several phones at once, each with its own [key].
class _ServerPeer {
  Uint8List? key;
  String id = '';
  String name = 'Dispositivo móvil';
  DeviceSyncStatus status = DeviceSyncStatus.connected;

  /// The live socket, so the desktop can PUSH messages (e.g. approval requests).
  WebSocketChannel? channel;

  /// Transient state during the resume (reconnect) handshake.
  Uint8List? resumeKey;
  Uint8List? resumeChallenge;
}
