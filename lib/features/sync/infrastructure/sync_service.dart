import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/domain/crypto_utils.dart';
import '../../../core/infrastructure/rust/api/error.dart';
import '../../../core/infrastructure/rust/api/sync.dart' as core;
import '../../../core/infrastructure/rust/api/vault.dart' as core;
import '../../../core/infrastructure/security/i_security_service.dart';
import '../../../core/infrastructure/security/session_manager.dart';
import '../../../core/infrastructure/vault/vault_store.dart';
import '../domain/connected_device.dart';
import '../domain/i_sync_service.dart';
import '../domain/pairing_payload.dart';
import '../domain/sync_network_utils.dart';
import '../domain/sync_summary.dart';

/// Sync v2 (NUC-3): el canal y el delta viven en el nucleo Rust (`api/sync.rs`: Noise IK y LWW); aqui va el
/// transporte (WebSocket binario en la LAN), el descubrimiento, el QR y lo que guarda cada equipo.
///
/// - Cada equipo tiene una identidad X25519 fija ([_kIdentity]). El QR del escritorio lleva su llave publica y un
///   token de un solo uso; el celular abre el canal con esa llave (si el QR es falso, el saludo no completa) y
///   manda el token cifrado. El escritorio fija la llave del celular y desde ahi lo reconoce sin QR.
/// - Dentro del canal viajan la sync (los registros de la boveda, cada equipo los guarda con su clave) y los
///   mensajes de control de la app (`op`: aprobacion, pedir sync, desbloqueo por WiFi).
/// - Una v1 habla JSON en texto: se detecta y se avisa ([kPeerV1Message]); no se mezclan datos.
///
/// Todo lo de una conexion pasa en orden por [_Link.serial]: el canal Noise exige ese orden.
@lazySingleton
class SyncService implements ISyncService {
  SyncService(
      this._storage, this._vault, this._securityService, this._sessionManager);

  final FlutterSecureStorage _storage;
  final VaultStore _vault;
  final ISecurityService _securityService;
  final SessionManager _sessionManager;

  static const String _serviceType = '_solokey-sync._tcp';
  static const String _kDeviceIdName = 'solokey_device_id';
  // Identidad X25519 de este equipo (la secreta, base64).
  static const String _kIdentity = 'solokey_sync2_identity';
  // Escritorio: celulares emparejados, {id: {name, pub}} con la llave fijada.
  static const String _kPeers = 'solokey_sync2_peers';
  // Celular: el escritorio emparejado, {ip, port, pub, name}.
  static const String _kDesktop = 'solokey_sync2_desktop';
  // Desbloqueo por WiFi: el escritorio guarda su clave envuelta con un token (DUK) que solo tiene el celular.
  static const String _kWrappedKeyName = 'solokey_remote_unlock_wrapped';
  static const String _kRemoteUnlockToken = 'solokey_remote_unlock_token';
  // Historial de las ultimas rondas aplicadas en ESTE equipo (titulos y contadores, nunca secretos).
  static const String _kSyncHistoryName = 'solokey_sync_history';
  static const int _kSyncHistoryMax = 20;
  // Lo de la sync v1 que puede quedar en un equipo migrado: se borra al desemparejar.
  static const List<String> _kV1Keys = [
    'solokey_sync_key',
    'solokey_sync_devices',
    'solokey_server_device_keys',
    'solokey_desktop_endpoint',
  ];

  // Escritorio
  HttpServer? _server;
  nsd.Registration? _registration;
  // Token del QR: un solo emparejamiento y caduca a los [_kPairingTokenLife] (AMENAZAS_V2).
  String? _pairingToken;
  DateTime? _pairingTokenExpires;
  static const Duration _kPairingTokenLife = Duration(minutes: 10);
  final Set<_Link> _peers = {};

  @override
  List<ConnectedDevice> get connectedDevices {
    final byId = <String, ConnectedDevice>{};
    for (final p in _peers) {
      if (p.session == null) continue;
      byId[p.id] = ConnectedDevice(id: p.id, name: p.name, status: p.status);
    }
    return byId.values.toList();
  }

  final StreamController<String> _serverEventController =
      StreamController<String>.broadcast();
  @override
  Stream<String> get serverEvents => _serverEventController.stream;

  final StreamController<SyncSummary> _vaultChangesController =
      StreamController<SyncSummary>.broadcast();
  @override
  Stream<SyncSummary> get vaultChanges => _vaultChangesController.stream;

  SyncSummary? _lastSummary;
  SyncSummary? get lastSummary => _lastSummary;

  // Celular
  _Link? _client;
  nsd.Discovery? _discovery;
  Timer? _heartbeatTimer;
  Timer? _autoSyncTimer;
  bool _autoReconnect = false;
  int _reconnectAttempts = 0;
  final StreamController<String> _clientEventController =
      StreamController<String>.broadcast();
  @override
  Stream<String> get clientEvents => _clientEventController.stream;

  @override
  bool get isServerRunning => _server != null;
  @override
  bool get isClientConnected => _client?.session != null;

  @override
  int get connectedDeviceCount => connectedDevices.length;

  // ───────────────────────────────────────────────────────────────────────────
  // ESCRITORIO
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Future<PairingPayload> startServer() async {
    if (_server != null) await stopServer();

    final ip = await _getLocalIp();
    final port = await _findAvailablePort(8283);
    _pairingToken = _hex(_cryptoRandomBytes(16));
    _pairingTokenExpires = DateTime.now().add(_kPairingTokenLife);
    final publicKey = await _publicKey();

    final app = Router();
    app.get('/ws', webSocketHandler(_handleServerConnection));
    _server = await shelf_io.serve(app.call, '0.0.0.0', port);

    // mDNS es opcional (en Windows sin Bonjour falla): el QR ya lleva IP y puerto.
    try {
      _registration = await nsd.register(
        nsd.Service(name: 'SoloKey Secure Desktop', type: _serviceType, port: port),
      );
    } catch (e) {
      _registration = null;
      debugPrint('[SyncService] mDNS no disponible (el QR sigue funcionando): $e');
    }

    _serverEventController.add('server_started');
    return PairingPayload(
      ip: ip,
      port: port,
      pairingToken: _pairingToken!,
      desktopPublicKey: base64Encode(publicKey),
    );
  }

  @override
  Future<void> stopServer() async {
    _serverEventController.add('server_stopped');
    final reg = _registration;
    if (reg != null) {
      try {
        await nsd.unregister(reg);
      } catch (_) {}
    }
    _registration = null;
    await _server?.close(force: true);
    _server = null;
    _pairingToken = null;
    _pairingTokenExpires = null;
  }

  void _handleServerConnection(WebSocketChannel ws) {
    final link = _Link(ws);
    _peers.add(link);
    _serverEventController.add('client_connecting');
    ws.stream.listen(
      (message) => link.serial(() => _onServerMessage(link, message)).ignore(),
      onDone: () => _removePeer(link),
      onError: (_) => _removePeer(link),
    );
  }

  void _removePeer(_Link link) {
    _peers.remove(link);
    _serverEventController.add('client_disconnected');
    _serverEventController.add('devices_changed');
  }

  Future<void> _onServerMessage(_Link link, Object? message) async {
    try {
      if (message is String) {
        // Un celular con la v1 (JSON en texto): se le contesta en su formato y se corta.
        link.ws.sink.add(jsonEncode({'type': 'error', 'message': kPeerV2Message}));
        _serverEventController.add('error: $kPeerV1Message');
        await link.ws.sink.close();
        return;
      }
      final frame = message as List<int>;
      if (link.session == null) {
        await _serverHandshake(link, frame);
      } else {
        await _onFrame(link, frame, isServer: true);
      }
    } catch (e) {
      debugPrint('[SyncService] error con un par: $e');
      await link.session?.resetRound();
      link.status = DeviceSyncStatus.connected;
      _serverEventController.add('devices_changed');
      _serverEventController.add('sync_error');
    }
  }

  Future<void> _serverHandshake(_Link link, List<int> frame) async {
    final version = core.syncPeerVersion(frame: frame);
    if (version != core.SyncPeerVersion.v2) {
      _serverEventController.add(
          'error: ${version == core.SyncPeerVersion.v1 ? kPeerV1Message : kPeerOtherVersionMessage}');
      await link.ws.sink.close();
      return;
    }
    final secret = await _identitySecret();
    final core.SyncResponder responder;
    try {
      responder =
          await core.syncResponderAccept(localSecret: secret, frame: frame);
    } on CoreFailure {
      _serverEventController.add('pairing_failed');
      await link.ws.sink.close();
      return;
    } finally {
      zeroBuffer(secret);
    }
    final remote = base64Encode(await responder.remotePublic());
    final hello = jsonDecode(utf8.decode(await responder.payload()))
        as Map<String, dynamic>;
    final token = hello['token'] as String?;
    final peers = await _loadPeers();
    var id = '';
    for (final e in peers.entries) {
      if (e.value['pub'] == remote) id = e.key;
    }
    final isNew = id.isEmpty;
    if (isNew) {
      final expected = _pairingToken;
      final expires = _pairingTokenExpires;
      if (token == null ||
          expected == null ||
          expires == null ||
          DateTime.now().isAfter(expires) ||
          !_sameText(token, expected)) {
        _serverEventController.add('pairing_failed');
        await link.ws.sink.close();
        return;
      }
      // Un solo uso: otro celular necesita un QR nuevo (`startServer`).
      _pairingToken = null;
      _pairingTokenExpires = null;
      _serverEventController.add('pairing_token_used');
      id = _nonEmpty(hello['id'], 'device-${peers.length + 1}');
      peers[id] = {
        'name': _nonEmpty(hello['name'], 'Dispositivo móvil'),
        'pub': remote,
      };
      await _storage.write(key: _kPeers, value: jsonEncode(peers));
    }
    final done = await responder.respond(
        payload: utf8.encode(jsonEncode(
            {'id': await _localDeviceId(), 'name': _localDeviceName()})));
    link
      ..session = done.session
      ..id = id
      ..name = peers[id]!['name'] as String
      ..status = DeviceSyncStatus.connected;
    link.send([done.frame]);
    _serverEventController.add(isNew ? 'paired' : 'client_resumed');
    _serverEventController.add('devices_changed');
    if (isNew) {
      final duk = await _registerRemoteUnlock();
      if (duk != null) {
        await _sendControl(link, {'op': 'remote_unlock_token', 'duk': duk});
      }
    }
  }

  /// True cuando hay al menos un celular conectado.
  bool get hasConnectedDevices => _peers.any((p) => p.session != null);

  @override
  Future<int> requestApproval() async {
    final sent = await _broadcast({'op': 'approval_request', 'desktop': _localDeviceName()});
    if (sent > 0) _serverEventController.add('approval_requested');
    return sent;
  }

  @override
  Future<int> requestSyncFromDevices() async {
    final sent = await _broadcast({'op': 'sync_request'});
    if (sent > 0) _serverEventController.add('sync_requested');
    return sent;
  }

  Future<int> _broadcast(Map<String, dynamic> msg) async {
    var sent = 0;
    for (final peer in _peers.toList()) {
      if (peer.session == null) continue;
      try {
        await peer.serial(() => _sendControl(peer, msg));
        sent++;
      } catch (e) {
        debugPrint('[SyncService] no se pudo avisar a un par: $e');
      }
    }
    return sent;
  }

  /// Envuelve la clave de la boveda con un DUK nuevo y guarda solo lo envuelto; el DUK va al celular. Null si la
  /// boveda esta bloqueada.
  Future<String?> _registerRemoteUnlock() async {
    final key = await _sessionManager.keyCopy();
    if (key == null) return null;
    final duk = _cryptoRandomBytes(32);
    try {
      final wrapped = await _securityService.encrypt(key, duk);
      await _storage.write(key: _kWrappedKeyName, value: base64Encode(wrapped));
      return base64Encode(duk);
    } finally {
      zeroBuffer(key);
      zeroBuffer(duk);
    }
  }

  Future<void> _handleWifiUnlock(_Link link, Map<String, dynamic> msg) async {
    final dukB64 = msg['duk'] as String?;
    final wrappedB64 = await _storage.read(key: _kWrappedKeyName);
    if (dukB64 == null || dukB64.isEmpty || wrappedB64 == null) {
      await _sendControl(link,
          {'op': 'wifi_unlock_response', 'success': false, 'error': 'not_registered'});
      return;
    }
    try {
      final duk = base64Decode(dukB64);
      final key = await _securityService.decrypt(base64Decode(wrappedB64), duk);
      zeroBuffer(duk);
      _serverEventController.add('remote_unlock_key:${base64Encode(key)}');
      zeroBuffer(key);
      await _sendControl(link, {'op': 'wifi_unlock_response', 'success': true});
    } catch (e) {
      debugPrint('[SyncService] desbloqueo por WiFi: $e');
      await _sendControl(link,
          {'op': 'wifi_unlock_response', 'success': false, 'error': 'server_error'});
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CELULAR
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> startDiscovery(
      void Function(PairingPayload) onDeviceFound) async {
    if (_discovery != null) await stopDiscovery();
    try {
      _discovery = await nsd.startDiscovery(_serviceType);
    } catch (e) {
      _discovery = null;
      _clientEventController.add('error: discovery_unavailable');
      return;
    }
    _discovery!.addListener(() {
      for (final service in _discovery!.services) {
        final addresses = service.addresses;
        final port = service.port;
        if (addresses != null && addresses.isNotEmpty && port != null) {
          onDeviceFound(PairingPayload(
            ip: addresses.first.address,
            port: port,
            pairingToken: '', // el token y la llave solo van en el QR
            desktopPublicKey: '',
          ));
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

  @override
  Future<bool> pairWithDesktop(PairingPayload payload) async {
    if (payload.version != kSyncProtocolVersion) {
      _clientEventController.add('error: $kPeerV1Message');
      return false;
    }
    _clientEventController.add('connecting');
    final ok = await _connect(
      host: payload.ip,
      port: payload.port,
      desktopPublic: payload.desktopPublicKey,
      token: payload.pairingToken,
    );
    if (ok) _clientEventController.add('paired');
    return ok;
  }

  @override
  Future<bool> canResume() async =>
      (await _storage.read(key: _kDesktop)) != null &&
      (await _storage.read(key: _kIdentity)) != null;

  @override
  Future<bool> resumeWithDesktop({String? ip, int? port}) async {
    final desk = await _loadDesktop();
    if (desk == null) {
      _clientEventController.add('error: not_paired');
      return false;
    }
    _autoReconnect = true;
    final ok = await _connect(
      host: ip ?? desk['ip'] as String,
      port: port ?? desk['port'] as int,
      desktopPublic: desk['pub'] as String,
    );
    if (ok) {
      _reconnectAttempts = 0;
      _clientEventController.add('connected');
      _startClientKeepAlive();
    }
    return ok;
  }

  /// Abre el canal con el escritorio. Con [token] es un emparejamiento nuevo (QR); sin el, una reconexion.
  Future<bool> _connect({
    required String host,
    required int port,
    required String desktopPublic,
    String? token,
  }) async {
    try {
      await _closeClient();
      final ws = WebSocketChannel.connect(Uri.parse('ws://$host:$port/ws'));
      await ws.ready;
      final link = _Link(ws);
      _client = link;
      final secret = await _identitySecret();
      final core.InitiatorStart start;
      try {
        start = await core.syncInitiatorStart(
          localSecret: secret,
          remotePublic: base64Decode(desktopPublic),
          payload: utf8.encode(jsonEncode({
            'id': await _localDeviceId(),
            'name': _localDeviceName(),
            'token': ?token,
          })),
        );
      } finally {
        zeroBuffer(secret);
      }
      final done = Completer<bool>();
      ws.stream.listen(
        (message) => link.serial(() async {
          if (link.session == null) {
            await _clientHandshake(link, start.initiator, message, done,
                host: host, port: port, desktopPublic: desktopPublic);
          } else {
            await _onClientMessage(link, message);
          }
        }).ignore(),
        onDone: () {
          if (!done.isCompleted) done.complete(false);
          _onClientDisconnected(link);
        },
        onError: (Object err) {
          _clientEventController.add('error: $err');
          if (!done.isCompleted) done.complete(false);
          _onClientDisconnected(link);
        },
      );
      link.send([start.frame]);
      return await done.future
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
    } catch (e) {
      _clientEventController.add('error: $e');
      return false;
    }
  }

  Future<void> _clientHandshake(
    _Link link,
    core.SyncInitiator initiator,
    Object? message,
    Completer<bool> done, {
    required String host,
    required int port,
    required String desktopPublic,
  }) async {
    if (message is String) {
      // Un escritorio con la v1 contesta JSON en texto.
      _clientEventController.add('error: $kPeerV1Message');
      done.complete(false);
      await link.ws.sink.close();
      return;
    }
    try {
      final fin = await initiator.finish(frame: message as List<int>);
      final hello =
          jsonDecode(utf8.decode(fin.payload)) as Map<String, dynamic>;
      link
        ..session = fin.session
        ..id = _nonEmpty(hello['id'], 'desktop')
        ..name = _nonEmpty(hello['name'], 'PC');
      await _storage.write(
        key: _kDesktop,
        value: jsonEncode(
            {'ip': host, 'port': port, 'pub': desktopPublic, 'name': link.name}),
      );
      done.complete(true);
    } catch (_) {
      _clientEventController.add('pairing_failed');
      if (!done.isCompleted) done.complete(false);
      await link.ws.sink.close();
    }
  }

  Future<void> _onClientMessage(_Link link, Object? message) async {
    try {
      if (message is String) return; // nada de texto despues del saludo
      await _onFrame(link, message as List<int>, isServer: false);
    } catch (e) {
      await link.session?.resetRound();
      _clientEventController.add('error: Sync failed: $e');
    }
  }

  @override
  Future<bool> requestSync() async {
    final link = _client;
    final session = link?.session;
    if (link == null || session == null) {
      _clientEventController.add('error: Not connected or unpaired');
      return false;
    }
    if (!_sessionManager.hasActiveKey) {
      _clientEventController.add('error: locked');
      return false;
    }
    try {
      await link.serial(() async {
        link.before = await _snapshot();
        link.send(await session.start(vault: _sessionManager.handle));
      });
      _clientEventController.add('sync_started');
      return true;
    } catch (e) {
      _clientEventController.add('error: Sync failed: $e');
      return false;
    }
  }

  @override
  Future<bool> hasRemoteUnlockToken() async =>
      (await _storage.read(key: _kRemoteUnlockToken)) != null;

  @override
  Future<bool> sendRemoteUnlockRequest() async {
    final duk = await _storage.read(key: _kRemoteUnlockToken);
    if (duk == null) {
      _clientEventController.add('error: no_token');
      return false;
    }
    final link = _client;
    if (link == null || link.session == null) {
      _clientEventController.add('error: Not connected to desktop');
      return false;
    }
    try {
      await link.serial(() => _sendControl(link, {'op': 'wifi_unlock', 'duk': duk}));
      return true;
    } catch (e) {
      _clientEventController.add('error: WiFi unlock failed: $e');
      return false;
    }
  }

  void _startClientKeepAlive() {
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      final link = _client;
      if (link?.session == null) return;
      link!.serial(() => _sendControl(link, {'op': 'ping'})).ignore();
    });
    _autoSyncTimer = Timer.periodic(
        const Duration(seconds: 60), (_) => unawaited(requestSync()));
    unawaited(requestSync());
  }

  void _onClientDisconnected(_Link link) {
    if (!identical(_client, link)) return;
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = null;
    _autoSyncTimer = null;
    _client = null;
    _clientEventController.add('disconnected');
    if (_autoReconnect && _reconnectAttempts < 5) {
      final attempt = ++_reconnectAttempts;
      Future.delayed(Duration(seconds: 5 * attempt), () {
        if (_client == null && _autoReconnect) unawaited(resumeWithDesktop());
      });
    }
  }

  Future<void> _closeClient() async {
    final link = _client;
    _client = null;
    if (link != null) await link.ws.sink.close();
  }

  void stopAutoReconnect() {
    _autoReconnect = false;
    _heartbeatTimer?.cancel();
    _autoSyncTimer?.cancel();
    _heartbeatTimer = null;
    _autoSyncTimer = null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOS DOS: tramas, control y resumen de la ronda
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _onFrame(_Link link, List<int> frame,
      {required bool isServer}) async {
    final session = link.session!;
    final inbound = await session.onFrame(frame: frame);
    final control = inbound.control;
    if (control != null) {
      final msg = jsonDecode(utf8.decode(control)) as Map<String, dynamic>;
      await (isServer ? _onServerControl(link, msg) : _onClientControl(msg));
    }
    if (inbound.syncPending) await _processSync(link, isServer: isServer);
  }

  Future<void> _processSync(_Link link, {required bool isServer}) async {
    final session = link.session!;
    if (!_sessionManager.hasActiveKey) {
      // Bloqueado: no hay boveda que leer ni escribir. Se descarta la ronda y se avisa al otro.
      await session.resetRound();
      await _sendControl(link, {'op': 'sync_refused', 'reason': 'locked'});
      return;
    }
    if (link.before == null) {
      link.before = await _snapshot();
      if (isServer) {
        link.status = DeviceSyncStatus.syncing;
        _serverEventController.add('devices_changed');
        _serverEventController.add('sync_manifest_processed');
      }
    }
    final step = await session.process(vault: _sessionManager.handle);
    link.send(step.frames);
    if (!step.roundDone) {
      if (!isServer) _clientEventController.add('sync_response_processed');
      return;
    }
    final report = await session.report();
    final changes = await _changes(link.before ?? const {}, report.received);
    link.before = null;
    await _recordApplied(changes, isServer ? link.name : null);
    if (isServer) {
      link.status = DeviceSyncStatus.synced;
      _serverEventController.add('devices_changed');
      _serverEventController.add('sync_completed');
    } else {
      int count(SyncEntityKind k) => changes.where((c) => c.kind == k).length;
      _clientEventController.add('sync_completed:creds=${count(SyncEntityKind.credential)},'
          'folders=${count(SyncEntityKind.folder)},files=${count(SyncEntityKind.file)}');
    }
  }

  Future<void> _onServerControl(_Link link, Map<String, dynamic> msg) async {
    switch (msg['op']) {
      case 'wifi_unlock':
        await _handleWifiUnlock(link, msg);
      case 'sync_refused':
        link.before = null;
        link.status = DeviceSyncStatus.connected;
        _serverEventController.add('devices_changed');
        _serverEventController.add('sync_error');
      case 'ping':
        break;
      default:
        debugPrint('[SyncService] control desconocido: ${msg['op']}');
    }
  }

  Future<void> _onClientControl(Map<String, dynamic> msg) async {
    switch (msg['op']) {
      case 'remote_unlock_token':
        final duk = msg['duk'] as String?;
        if (duk != null && duk.isNotEmpty) {
          await _storage.write(key: _kRemoteUnlockToken, value: duk);
        }
      case 'approval_request':
        _clientEventController.add('approval_request');
      case 'sync_request':
        unawaited(requestSync());
      case 'wifi_unlock_response':
        if (msg['success'] == true) {
          _clientEventController.add('wifi_unlock_sent');
        } else {
          _clientEventController
              .add('wifi_unlock_failed:${msg['error'] ?? 'Unknown error'}');
        }
      case 'sync_refused':
        _client?.before = null;
        _clientEventController.add('error: ${msg['reason'] ?? 'refused'}');
      case 'ping':
        break;
      default:
        debugPrint('[SyncService] control desconocido: ${msg['op']}');
    }
  }

  Future<void> _sendControl(_Link link, Map<String, dynamic> msg) async {
    final session = link.session;
    if (session == null) return;
    link.send(await session.sendControl(msg: utf8.encode(jsonEncode(msg))));
  }

  static const _summaryKinds = {
    RecordKind.credential: (SyncEntityKind.credential, 'title'),
    RecordKind.folder: (SyncEntityKind.folder, 'name'),
    RecordKind.file: (SyncEntityKind.file, 'name'),
  };

  /// Lo que hay antes de la ronda, para decir despues que se agrego, cambio o borro.
  Future<Map<String, core.VaultRecord>> _snapshot() async => {
        for (final kind in _summaryKinds.keys)
          for (final r in await _vault.records(kind)) r.id: r,
      };

  Future<List<SyncItemChange>> _changes(
      Map<String, core.VaultRecord> before, List<String> received) async {
    final changes = <SyncItemChange>[];
    for (final id in received) {
      final r = await _vault.record(id);
      final meta = r == null ? null : _summaryKinds[r.kind];
      if (r == null || meta == null) continue;
      final prev = before[id];
      final action = r.deleted
          ? SyncChangeAction.deleted
          : (prev == null || prev.deleted
              ? SyncChangeAction.added
              : SyncChangeAction.updated);
      final source = r.deleted ? prev : r;
      var name = id;
      if (source != null) {
        try {
          name = (jsonDecode(source.data) as Map<String, dynamic>)[meta.$2]
                  as String? ??
              id;
        } catch (_) {}
      }
      changes.add(
          SyncItemChange(id: id, name: name, kind: meta.$1, action: action));
    }
    return changes;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Emparejamiento guardado e historial
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Future<bool> hasPairingKey() async =>
      (await _storage.read(key: _kDesktop)) != null ||
      (await _loadPeers()).isNotEmpty;

  @override
  Future<void> removePairingKey() async {
    for (final k in [
      _kPeers,
      _kDesktop,
      _kWrappedKeyName,
      _kRemoteUnlockToken,
      _kSyncHistoryName,
      ..._kV1Keys,
    ]) {
      await _storage.delete(key: k);
    }
    _lastSummary = null;
    for (final p in _peers.toList()) {
      await p.ws.sink.close();
    }
    _peers.clear();
    stopAutoReconnect();
    await _closeClient();
    _serverEventController.add('devices_changed');
  }

  Future<Map<String, Map<String, dynamic>>> _loadPeers() async {
    final raw = await _storage.read(key: _kPeers);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>?> _loadDesktop() async {
    final raw = await _storage.read(key: _kDesktop);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _recordApplied(
      List<SyncItemChange> changes, String? deviceName) async {
    final summary = SyncSummary(
        timestamp: DateTime.now(), changes: changes, deviceName: deviceName);
    _lastSummary = summary;
    if (summary.isNotEmpty) await _appendHistory(summary);
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
    final history = await loadHistory()..insert(0, summary);
    await _storage.write(
      key: _kSyncHistoryName,
      value: jsonEncode(
          history.take(_kSyncHistoryMax).map((e) => e.toJson()).toList()),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Identidad y utilidades
  // ───────────────────────────────────────────────────────────────────────────

  /// La secreta de la identidad de este equipo (la crea la primera vez). Quien la pide la borra tras usarla.
  Future<Uint8List> _identitySecret() async {
    final saved = await _storage.read(key: _kIdentity);
    if (saved != null) return base64Decode(saved);
    final id = await core.syncGenerateIdentity();
    await _storage.write(key: _kIdentity, value: base64Encode(id.secretKey));
    return id.secretKey;
  }

  Future<Uint8List> _publicKey() async {
    final secret = await _identitySecret();
    try {
      return await core.syncPublicKey(secretKey: secret);
    } finally {
      zeroBuffer(secret);
    }
  }

  Future<String> _localDeviceId() async {
    var id = await _storage.read(key: _kDeviceIdName);
    if (id == null) {
      id = _hex(_cryptoRandomBytes(8));
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

  static String _nonEmpty(Object? v, String fallback) =>
      v is String && v.trim().isNotEmpty ? v : fallback;

  /// Compara sin cortar en la primera diferencia.
  static bool _sameText(String a, String b) {
    final x = utf8.encode(a), y = utf8.encode(b);
    if (x.length != y.length) return false;
    var diff = 0;
    for (var i = 0; i < x.length; i++) {
      diff |= x[i] ^ y[i];
    }
    return diff == 0;
  }

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLoopback: false);
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
    for (var port = startPort; port < startPort + 100; port++) {
      try {
        final socket = await ServerSocket.bind('0.0.0.0', port);
        await socket.close();
        return port;
      } catch (_) {}
    }
    return startPort;
  }

  Uint8List _cryptoRandomBytes(int size) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(size, (_) => random.nextInt(256)));
  }

  Future<void> dispose() async {
    stopAutoReconnect();
    await stopServer();
    await stopDiscovery();
    await _closeClient();
    _peers.clear();
    await _serverEventController.close();
    await _clientEventController.close();
    await _vaultChangesController.close();
  }
}

/// Lo que le contesta el escritorio a un celular con la v1, en el formato de error de la v1.
const String kPeerV2Message =
    'El escritorio tiene SoloKey 2. Actualiza este equipo a SoloKey 2 para sincronizar.';

/// Una conexion: el socket, el canal Noise y el estado de su ronda.
class _Link {
  _Link(this.ws);

  final WebSocketChannel ws;
  core.SyncSession? session;
  String id = '';
  String name = 'Dispositivo móvil';
  DeviceSyncStatus status = DeviceSyncStatus.connected;

  /// Los registros antes de la ronda en curso (para el resumen); null fuera de una ronda.
  Map<String, core.VaultRecord>? before;

  Future<void> _tail = Future.value();

  /// Corre [f] despues de lo anterior de esta conexion: el canal exige el orden de las tramas.
  Future<void> serial(Future<void> Function() f) {
    final next = _tail.then((_) => f());
    _tail = next.catchError((Object e) {
      debugPrint('[SyncService] $e');
    });
    return next;
  }

  void send(List<Uint8List> frames) {
    for (final f in frames) {
      ws.sink.add(f);
    }
  }
}
