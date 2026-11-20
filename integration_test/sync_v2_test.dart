import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solokey/app/di/injection.dart';
import 'package:solokey/core/infrastructure/rust/api/sync.dart' as core;
import 'package:solokey/core/infrastructure/rust/api/vault.dart' as core;
import 'package:solokey/core/infrastructure/security/session_manager.dart';
import 'package:solokey/core/infrastructure/vault/vault_store.dart';
import 'package:solokey/features/sync/domain/pairing_payload.dart';
import 'package:solokey/features/sync/infrastructure/sync_service.dart';
import 'package:solokey/features/vault_access/application/setup_vault_use_case.dart';
import 'package:web_socket_channel/io.dart';

import 'support/e2e_helpers.dart';

/// Sync v2 (NUC-3) de punta a punta: el [SyncService] de la app (DLL o `.so` real, WebSocket real en loopback)
/// contra un par hecho con la API cruda del nucleo y una segunda boveda en una carpeta temporal.
///
/// - Escritorio: el par hace de celular. El QR con el token empareja una vez; con otro token o reusado, no; reconecta sin QR
///   con la llave fijada; la ronda cruza registros en los dos sentidos; control (pedir sync, aprobacion, desbloqueo
///   por WiFi con la clave de la boveda); un celular con la v1 recibe el aviso.
/// - Celular: el par hace de escritorio. Empareja con el QR, sincroniza y avisa si el escritorio tiene la v1.
///
/// Borra la carpeta aislada: corre solo con `E2E_ALLOW_WIPE=1` y `SOLOKEY_DATA_DIR`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const master = 'Maestra de prueba sync v2';
  final now = DateTime.now().millisecondsSinceEpoch;

  Future<void> freshVault() async {
    // Cerrar antes de borrar: en Windows un archivo abierto no se borra.
    if (!getIt.isRegistered<SyncService>()) await configureDependencies();
    final session = getIt<SessionManager>();
    if (session.hasActiveKey) session.lock();
    await resetVault();
    await getIt<SetupVaultUseCase>().execute(master);
  }

  Future<core.VaultHandle> peerVault(String id, String title) async {
    final dir = Directory.systemTemp.createTempSync('solokey-e2e-par');
    addTearDown(() => dir.deleteSync(recursive: true));
    final v = (await core.vaultCreate(
      dataDir: dir.path,
      password: utf8.encode('par'),
      // La biblioteca real exige el KDF de la boveda (el barato solo existe en `cargo test`).
      kdf: const core.KdfConfig(memoryKib: 65536, iterations: 3, parallelism: 4),
    ))
        .vault;
    addTearDown(v.close); // corre antes que el borrado de la carpeta (orden inverso)
    await v.put(records: [
      core.VaultRecord(
          id: id,
          kind: 'credential',
          updatedAt: now,
          deleted: false,
          data: jsonEncode({'title': title})),
    ]);
    return v;
  }

  testWidgets('escritorio: empareja con el QR, sincroniza, control y reconexion',
      (tester) async {
    await freshVault();
    final store = getIt<VaultStore>();
    await store.put(RecordKind.credential, {
      'd1': {'title': 'Del escritorio'}
    });
    final sync = getIt<SyncService>();
    final events = <String>[];
    final sub = sync.serverEvents.listen(events.add);
    addTearDown(sub.cancel);
    final qr = await sync.startServer();
    addTearDown(sync.stopServer);
    final phoneVault = await peerVault('p1', 'Del celular');
    final phoneId = await core.syncGenerateIdentity();

    // Token equivocado: el escritorio corta sin contestar.
    final bad = await _Peer.connect(qr.port);
    await bad.hello(phoneId, qr.desktopPublicKey, token: 'malo');
    expect(await bad.inbox.next(), isNull);

    // Con el token del QR: empareja.
    final phone = await _Peer.connect(qr.port);
    final session = await phone.handshake(phoneId, qr.desktopPublicKey,
        token: qr.pairingToken);
    expect(session, isNotNull);
    await _until(() => events.contains('paired')); // los eventos llegan despues
    expect(events, containsAll(['pairing_token_used', 'paired']));

    // El escritorio le da el token del desbloqueo por WiFi.
    final unlockToken = await phone.control(session!);
    expect(unlockToken['op'], 'remote_unlock_token');
    expect((unlockToken['duk'] as String).isNotEmpty, isTrue);

    // Ronda que arranca el celular: cada lado recibe lo del otro.
    await phone.round(session, phoneVault);
    expect(await phoneVault.get_(id: 'd1'), isNotNull);
    expect((await store.get(RecordKind.credential, 'p1'))?['title'],
        'Del celular');
    // El escritorio manda su ultima trama antes de anotar el resumen.
    await _until(() => sync.lastSummary != null);
    expect(sync.lastSummary?.changes.map((c) => c.name), ['Del celular']);

    // Pedir sync y aprobacion desde el escritorio.
    await sync.requestSyncFromDevices();
    expect((await phone.control(session))['op'], 'sync_request');
    await sync.requestApproval();
    expect((await phone.control(session))['op'], 'approval_request');

    // Desbloqueo por WiFi: con el DUK, el escritorio recupera la clave de su boveda.
    final key = await getIt<SessionManager>().keyCopy();
    phone.send(await session.sendControl(
        msg: utf8.encode(jsonEncode(
            {'op': 'wifi_unlock', 'duk': unlockToken['duk']}))));
    final reply = await phone.control(session);
    expect(reply, {'op': 'wifi_unlock_response', 'success': true});
    await _until(() => events.any((e) => e.startsWith('remote_unlock_key:')));
    expect(events.where((e) => e.startsWith('remote_unlock_key:')).single,
        'remote_unlock_key:${base64Encode(key!)}');
    phone.close();

    // Reconexion sin QR: la llave ya esta fijada.
    events.clear();
    final again = await _Peer.connect(qr.port);
    expect(await again.handshake(phoneId, qr.desktopPublicKey), isNotNull);
    await _until(() => events.contains('client_resumed'));
    expect(events, contains('client_resumed'));
    again.close();

    // Otra identidad con el mismo QR: no, el token es de un solo uso.
    final stranger = await _Peer.connect(qr.port);
    await stranger.hello(
        await core.syncGenerateIdentity(), qr.desktopPublicKey,
        token: qr.pairingToken);
    expect(await stranger.inbox.next(), isNull);

    // Un celular con la v1 (JSON en texto) recibe el aviso en su formato.
    final v1 = await _Peer.connect(qr.port);
    v1.ws.sink.add(jsonEncode({'type': 'ecdh_exchange'}));
    final v1Reply =
        jsonDecode(await v1.inbox.next() as String) as Map<String, dynamic>;
    expect(v1Reply, {'type': 'error', 'message': kPeerV2Message});
    await _until(() => events.contains('error: $kPeerV1Message'));
    expect(events, contains('error: $kPeerV1Message'));
  }, skip: !e2eCanWipe);

  testWidgets('celular: empareja con un escritorio, sincroniza y avisa de la v1',
      (tester) async {
    await freshVault();
    final store = getIt<VaultStore>();
    await store.put(RecordKind.credential, {
      'm1': {'title': 'Del celular de la app'}
    });
    final sync = getIt<SyncService>();
    final events = <String>[];
    final sub = sync.clientEvents.listen(events.add);
    addTearDown(sub.cancel);

    // El QR de la v1 no trae version: aviso, sin conectar.
    expect(
        () => PairingPayload.fromQrString(jsonEncode({
              'ip': '127.0.0.1',
              'port': 1,
              'pairing_token': 'x',
              'desktop_public_key': 'x',
            })),
        throwsA(isA<PeerVersionException>()
            .having((e) => e.isV1, 'isV1', isTrue)));

    // Un escritorio hecho con la API cruda.
    final deskVault = await peerVault('w1', 'Del escritorio crudo');
    final desk = await _RawDesktop.start(deskVault, token: 'token-qr');
    addTearDown(desk.close);

    final ok = await sync.pairWithDesktop(PairingPayload(
      ip: '127.0.0.1',
      port: desk.port,
      pairingToken: 'token-qr',
      desktopPublicKey: base64Encode(desk.identity.publicKey),
    ));
    expect(ok, isTrue);
    await _until(() => events.contains('paired'));
    expect(events, contains('paired'));

    expect(await sync.requestSync(), isTrue);
    await desk.roundDone.future.timeout(const Duration(seconds: 20));
    await _until(() => events.any((e) => e.startsWith('sync_completed:')));
    expect(events.firstWhere((e) => e.startsWith('sync_completed:')),
        'sync_completed:creds=1,folders=0,files=0');
    expect((await store.get(RecordKind.credential, 'w1'))?['title'],
        'Del escritorio crudo');
    expect(await deskVault.get_(id: 'm1'), isNotNull);
    sync.stopAutoReconnect();

    // Un escritorio con la v1 contesta JSON en texto: aviso.
    final old = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => old.close(force: true));
    old.listen((req) async {
      final ws = await WebSocketTransformer.upgrade(req);
      ws.listen((_) => ws.add(jsonEncode({'type': 'error', 'message': 'x'})));
    });
    events.clear();
    expect(
        await sync.pairWithDesktop(PairingPayload(
          ip: '127.0.0.1',
          port: old.port,
          pairingToken: 't',
          desktopPublicKey: base64Encode(desk.identity.publicKey),
        )),
        isFalse);
    await _until(() => events.contains('error: $kPeerV1Message'));
    expect(events, contains('error: $kPeerV1Message'));
  }, skip: !e2eCanWipe);
}

Future<void> _until(bool Function() ok) async {
  for (var i = 0; i < 100 && !ok(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Lo que llega por un socket, en orden; null si se cerro.
class _Inbox {
  _Inbox(Stream<dynamic> stream) {
    stream.listen((m) {
      final w = _waiter;
      if (w != null) {
        _waiter = null;
        w.complete(m);
      } else {
        _queue.add(m);
      }
    }, onDone: () {
      _closed = true;
      _waiter?.complete(null);
      _waiter = null;
    });
  }

  final _queue = <Object?>[];
  Completer<Object?>? _waiter;
  bool _closed = false;

  Future<Object?> next() {
    if (_queue.isNotEmpty) return Future.value(_queue.removeAt(0));
    if (_closed) return Future.value(null);
    _waiter = Completer<Object?>();
    return _waiter!.future.timeout(const Duration(seconds: 15));
  }
}

/// Un celular hecho con la API cruda del nucleo.
class _Peer {
  _Peer(this.ws) : inbox = _Inbox(ws.stream);

  final IOWebSocketChannel ws;
  final _Inbox inbox;
  core.SyncInitiator? _initiator;

  static Future<_Peer> connect(int port) async {
    final ws = IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:$port/ws'));
    await ws.ready;
    return _Peer(ws);
  }

  void send(List<Uint8List> frames) => frames.forEach(ws.sink.add);

  void close() => ws.sink.close();

  Future<void> hello(core.SyncIdentity id, String desktopPublic,
      {String? token}) async {
    final start = await core.syncInitiatorStart(
      localSecret: id.secretKey,
      remotePublic: base64Decode(desktopPublic),
      payload: utf8.encode(
          jsonEncode({'id': 'cel-e2e', 'name': 'Celular E2E', 'token': ?token})),
    );
    _initiator = start.initiator;
    ws.sink.add(start.frame);
  }

  Future<core.SyncSession?> handshake(core.SyncIdentity id, String desktopPublic,
      {String? token}) async {
    await hello(id, desktopPublic, token: token);
    final frame = await inbox.next();
    if (frame is! List<int>) return null;
    return (await _initiator!.finish(frame: frame)).session;
  }

  /// El siguiente mensaje de control (ignora lo demas).
  Future<Map<String, dynamic>> control(core.SyncSession session) async {
    while (true) {
      final frame = await inbox.next();
      if (frame == null) throw StateError('socket cerrado');
      final inb = await session.onFrame(frame: frame as List<int>);
      if (inb.control != null) {
        return jsonDecode(utf8.decode(inb.control!)) as Map<String, dynamic>;
      }
    }
  }

  /// Una ronda que arranca el celular, hasta que termina.
  Future<void> round(core.SyncSession session, core.VaultHandle vault) async {
    send(await session.start(vault: vault));
    while (true) {
      final frame = await inbox.next();
      if (frame == null) throw StateError('socket cerrado');
      final inb = await session.onFrame(frame: frame as List<int>);
      if (!inb.syncPending) continue;
      final step = await session.process(vault: vault);
      send(step.frames);
      if (step.roundDone) return;
    }
  }
}

/// Un escritorio hecho con la API cruda del nucleo: acepta un celular con el token y contesta las rondas.
class _RawDesktop {
  _RawDesktop._(this._server, this.identity, this.vault, this.token);

  final HttpServer _server;
  final core.SyncIdentity identity;
  final core.VaultHandle vault;
  final String token;
  final roundDone = Completer<void>();

  int get port => _server.port;

  static Future<_RawDesktop> start(core.VaultHandle vault,
      {required String token}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final d =
        _RawDesktop._(server, await core.syncGenerateIdentity(), vault, token);
    server.listen((req) async {
      final ws = await WebSocketTransformer.upgrade(req);
      core.SyncSession? session;
      var tail = Future<void>.value();
      ws.listen((m) {
        tail = tail.then((_) async {
          final frame = m as List<int>;
          if (session == null) {
            final r = await core.syncResponderAccept(
                localSecret: d.identity.secretKey, frame: frame);
            final hello = jsonDecode(utf8.decode(await r.payload()))
                as Map<String, dynamic>;
            if (hello['token'] != d.token) {
              await ws.close();
              return;
            }
            final done = await r.respond(
                payload: utf8.encode(
                    jsonEncode({'id': 'pc-crudo', 'name': 'PC cruda'})));
            session = done.session;
            ws.add(done.frame);
            return;
          }
          final inb = await session!.onFrame(frame: frame);
          if (!inb.syncPending) return;
          final step = await session!.process(vault: d.vault);
          step.frames.forEach(ws.add);
          if (step.roundDone && !d.roundDone.isCompleted) d.roundDone.complete();
        });
      });
    });
    return d;
  }

  Future<void> close() => _server.close(force: true);
}
