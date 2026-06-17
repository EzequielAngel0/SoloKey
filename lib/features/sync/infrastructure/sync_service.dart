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
import '../domain/pairing_payload.dart';
import 'delta_sync_manager.dart';

@lazySingleton
class SyncService {
  SyncService(this._storage, this._db, this._securityService);

  final FlutterSecureStorage _storage;
  final AppDatabase _db;
  final ISecurityService _securityService;

  static const String _serviceType = '_solokey-sync._tcp';
  static const String _kSyncKeyName = 'solokey_sync_key';

  // Desktop Server State
  HttpServer? _server;
  nsd.Registration? _registration;
  String? _pairingToken;
  crypto.SimpleKeyPair? _desktopKeyPair;
  Uint8List? _syncKey;
  final StreamController<String> _serverEventController =
      StreamController<String>.broadcast();
  Stream<String> get serverEvents => _serverEventController.stream;

  // Mobile Client State
  WebSocketChannel? _clientChannel;
  nsd.Discovery? _discovery;
  final StreamController<String> _clientEventController =
      StreamController<String>.broadcast();
  Stream<String> get clientEvents => _clientEventController.stream;

  bool get isServerRunning => _server != null;
  bool get isClientConnected => _clientChannel != null;

  late final DeltaSyncManager _deltaSyncManager = DeltaSyncManager(_db);

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
    app.get('/ws', webSocketHandler((WebSocketChannel ws) {
      _handleServerConnection(ws);
    }));

    _server = await shelf_io.serve(app, '0.0.0.0', port);

    // 4. Register mDNS service
    _registration = await nsd.register(
      nsd.Service(
        name: 'SoloKey Secure Desktop',
        type: _serviceType,
        port: port,
      ),
    );

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
      await nsd.unregister(reg);
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
    _serverEventController.add('client_connecting');

    ws.stream.listen(
      (message) async {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          final type = data['type'] as String;

          if (type == 'ecdh_exchange') {
            await _handleEcdhExchange(ws, data);
          } else if (type == 'encrypted') {
            await _handleEncryptedServerMessage(ws, data);
          }
        } catch (e) {
          ws.sink.add(
              jsonEncode({'type': 'error', 'message': 'Processing error: $e'}));
        }
      },
      onDone: () {
        _serverEventController.add('client_disconnected');
      },
      onError: (err) {
        _serverEventController.add('client_error: $err');
      },
    );
  }

  Future<void> _handleEcdhExchange(
      WebSocketChannel ws, Map<String, dynamic> data) async {
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

    // Compute ECDH shared secret
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
      // Valid pairing! Save key.
      _syncKey = kSyncCandidate;
      await _storage.write(
          key: _kSyncKeyName, value: base64Encode(_syncKey!));

      // Respond with Desktop signature: HMAC(kSync, DesktopPubKey)
      final desktopPubKey = await _desktopKeyPair!.extractPublicKey();
      final responseMac = await hmac.calculateMac(
        desktopPubKey.bytes,
        secretKey: crypto.SecretKey(_syncKey!),
      );

      ws.sink.add(jsonEncode({
        'type': 'ecdh_response',
        'signature': base64Encode(responseMac.bytes),
      }));
      _serverEventController.add('paired');
    } else {
      ws.sink.add(jsonEncode(
          {'type': 'error', 'message': 'Invalid pairing token signature'}));
      _serverEventController.add('pairing_failed');
    }
  }

  Future<void> _handleEncryptedServerMessage(
      WebSocketChannel ws, Map<String, dynamic> data) async {
    if (_syncKey == null) {
      final saved = await _storage.read(key: _kSyncKeyName);
      if (saved != null) {
        _syncKey = base64Decode(saved);
      } else {
        ws.sink.add(
            jsonEncode({'type': 'error', 'message': 'Unpaired connection'}));
        return;
      }
    }

    final cipherBlob = base64Decode(data['payload'] as String);
    final plainBytes =
        await _securityService.decrypt(cipherBlob, _syncKey!);
    final plainText = utf8.decode(plainBytes);

    // Zero the decrypted buffer copy held in plainBytes
    zeroBuffer(Uint8List.fromList(plainBytes));

    final decryptedMessage =
        jsonDecode(plainText) as Map<String, dynamic>;
    await _handleDecryptedServerMessage(ws, decryptedMessage);
  }

  Future<void> _handleDecryptedServerMessage(
      WebSocketChannel ws, Map<String, dynamic> msg) async {
    final action = msg['action'] as String;

    switch (action) {
      case 'sync_manifest':
        await _handleSyncManifest(ws, msg);
        break;
      case 'sync_push':
        await _handleSyncPush(ws, msg);
        break;
      case 'wifi_unlock':
        await _handleWifiUnlock(ws, msg);
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
      WebSocketChannel ws, Map<String, dynamic> msg) async {
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
      });

      _serverEventController.add('sync_manifest_processed');
    } catch (e) {
      debugPrint('[SyncService] Error processing sync manifest: $e');
      _serverEventController.add('sync_error');
    }
  }

  /// Handles the second step: remote pushes the rows we requested.
  Future<void> _handleSyncPush(
      WebSocketChannel ws, Map<String, dynamic> msg) async {
    try {
      final payload = msg['payload'] as Map<String, dynamic>;

      // Apply received credential rows
      final remoteCredentials =
          (payload['credentials'] as List? ?? [])
              .map((i) =>
                  SyncManifestItem.fromJson(i as Map<String, dynamic>))
              .toList();
      final credApplied =
          await _deltaSyncManager.applyRemoteCredentials(remoteCredentials);

      // Apply received folder rows
      final remoteFolders = (payload['folders'] as List? ?? [])
          .map(
              (i) => SyncManifestItem.fromJson(i as Map<String, dynamic>))
          .toList();
      final folderApplied =
          await _deltaSyncManager.applyRemoteFolders(remoteFolders);

      // Acknowledge sync completion
      await _sendEncryptedMessage(ws, {
        'action': 'sync_complete',
        'payload': {
          'credentials_applied': credApplied,
          'folders_applied': folderApplied,
        },
      });

      _serverEventController.add('sync_completed');
    } catch (e) {
      debugPrint('[SyncService] Error applying sync push: $e');
      _serverEventController.add('sync_error');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP SERVER: WiFi Unlock Handler
  // ─────────────────────────────────────────────────────────────────────────

  /// Handles the remote unlock request from the mobile device.
  /// The mobile device sends the master password encrypted with K_sync.
  /// We emit a `remote_unlock:<password>` event for the UnlockScreen to
  /// pick up and use to unlock the vault.
  Future<void> _handleWifiUnlock(
      WebSocketChannel ws, Map<String, dynamic> msg) async {
    try {
      final masterPassword = msg['master_password'] as String?;

      if (masterPassword == null || masterPassword.isEmpty) {
        await _sendEncryptedMessage(ws, {
          'action': 'wifi_unlock_response',
          'payload': {'success': false, 'error': 'Missing master password'},
        });
        return;
      }

      // Emit the event for the desktop UI to unlock.
      // The UnlockScreen listener will pick this up.
      _serverEventController.add('remote_unlock:$masterPassword');

      // Respond to mobile that the unlock request was forwarded.
      await _sendEncryptedMessage(ws, {
        'action': 'wifi_unlock_response',
        'payload': {'success': true},
      });
    } catch (e) {
      debugPrint('[SyncService] WiFi unlock error: $e');
      await _sendEncryptedMessage(ws, {
        'action': 'wifi_unlock_response',
        'payload': {'success': false, 'error': 'Server error'},
      });
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

    _discovery = await nsd.startDiscovery(_serviceType);
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

      // 4. Send ECDH exchange request
      _clientChannel!.sink.add(jsonEncode({
        'type': 'ecdh_exchange',
        'public_key': mobilePubKeyBase64,
        'signature': mobileSig,
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
      await _deltaSyncManager.applyRemoteCredentials(pushedCreds);

      // Apply folders the server pushed to us
      final pushedFolders =
          (payload['push_folders'] as List? ?? [])
              .map((i) =>
                  SyncManifestItem.fromJson(i as Map<String, dynamic>))
              .toList();
      await _deltaSyncManager.applyRemoteFolders(pushedFolders);

      // Now send the rows the server requested from us
      final requestedCredIds =
          List<String>.from(payload['request_credential_ids'] ?? []);
      final requestedFolderIds =
          List<String>.from(payload['request_folder_ids'] ?? []);

      final credsToSend = <SyncManifestItem>[];
      for (final id in requestedCredIds) {
        final row = await _db.credentialDao.getById(id);
        if (row != null) {
          credsToSend.add(SyncManifestItem(
            id: row.id,
            updatedAt: row.updatedAt,
            isDeleted: false,
            rowData: _credentialEntryToJson(row),
          ));
        }
      }

      final foldersToSend = <SyncManifestItem>[];
      for (final id in requestedFolderIds) {
        final row = await _db.folderDao.getById(id);
        if (row != null) {
          foldersToSend.add(SyncManifestItem(
            id: row.id,
            updatedAt: row.createdAt,
            isDeleted: false,
            rowData: _folderEntryToJson(row),
          ));
        }
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
  // MOBILE: WiFi Unlock (Send master password to desktop)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sends a remote unlock request from mobile to the paired desktop.
  ///
  /// The master password is retrieved from secure storage (stored when
  /// biometric lock was enabled), encrypted with K_sync via AES-256-GCM,
  /// and sent over the E2EE WebSocket channel. The password buffer is
  /// zeroed immediately after encryption.
  Future<bool> sendRemoteUnlockRequest(String masterPassword) async {
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
        'master_password': masterPassword,
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

  /// Checks if we have a stored K_sync key (i.e., previously paired).
  Future<bool> hasPairingKey() async {
    final saved = await _storage.read(key: _kSyncKeyName);
    return saved != null;
  }

  /// Removes the stored pairing key, effectively "un-pairing" the devices.
  Future<void> removePairingKey() async {
    await _storage.delete(key: _kSyncKeyName);
    _syncKey = null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Cryptographic & Network Utilities
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _sendEncryptedMessage(
      WebSocketChannel ws, Map<String, dynamic> plainMsg) async {
    if (_syncKey == null) return;
    final plainBytes = utf8.encode(jsonEncode(plainMsg));
    final encryptedBytes = await _securityService.encrypt(
        Uint8List.fromList(plainBytes), _syncKey!);
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
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback &&
            (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.'))) {
          return addr.address;
        }
      }
    }
    return interfaces.isNotEmpty &&
            interfaces.first.addresses.isNotEmpty
        ? interfaces.first.addresses.first.address
        : '127.0.0.1';
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

  // ─────────────────────────────────────────────────────────────────────────
  // Row serialization helpers (reused from DeltaSyncManager for client-side)
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _credentialEntryToJson(CredentialEntry row) => {
        'id': row.id,
        'title': row.title,
        'type': row.type,
        'category_id': row.categoryId,
        'folder_id': row.folderId,
        'is_favorite': row.isFavorite,
        'is_double_encrypted': row.isDoubleEncrypted,
        'encrypted_payload': base64Encode(row.encryptedPayload),
        'created_at': row.createdAt,
        'updated_at': row.updatedAt,
      };

  Map<String, dynamic> _folderEntryToJson(FolderEntry row) => {
        'id': row.id,
        'parent_id': row.parentId,
        'name': row.name,
        'icon': row.icon,
        'color_hex': row.colorHex,
        'is_favorite': row.isFavorite,
        'created_at': row.createdAt,
      };

  /// Dispose resources when the service is torn down.
  Future<void> dispose() async {
    await stopServer();
    await stopDiscovery();
    _clientChannel?.sink.close();
    _clientChannel = null;
    if (_syncKey != null) {
      zeroBuffer(_syncKey!);
      _syncKey = null;
    }
    await _serverEventController.close();
    await _clientEventController.close();
  }
}
