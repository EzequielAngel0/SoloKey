//! Sync v2 para Flutter (NUC-3). Flutter mueve los bytes (WebSocket binario, descubrimiento, QR) y guarda la
//! identidad del equipo y las llaves fijadas de sus pares en el almacen seguro; aqui va el canal y el delta.
//!
//! Flujo del que escanea (iniciador): `sync_initiator_start` -> manda la trama -> `finish` con la respuesta ->
//! `SyncSession`. Flujo del que muestra el QR (respondedor): `sync_responder_accept` con la primera trama ->
//! mira `remote_public` y `payload` (token del QR o llave ya fijada) -> `respond` -> `SyncSession`.
//! Con la sesion, por cada trama recibida: `on_frame`. Si trae un mensaje de control (JSON de la app: pedir
//! aprobacion, pedir sync, desbloqueo por WiFi), lo devuelve; si trae uno de la sync, `process` con la boveda
//! abierta y mandar lo que devuelva. Una ronda la arranca cualquiera de los dos con `start`; el otro contesta
//! con su resumen al recibir el primero. En una misma sesion caben rondas seguidas.
//!
//! Dentro del canal cada mensaje lleva un byte de sobre: 0 = sync, 1 = control.

use std::sync::Mutex;

use flutter_rust_bridge::frb;
use zeroize::Zeroizing;

use crate::api::error::{CoreFailure, FailureCode};
use crate::api::vault::VaultHandle;
use crate::error::CoreError;
use crate::sync::channel::{self, Channel, Initiator, PeerVersion, PendingResponder};
use crate::sync::protocol::SyncEngine;

/// Identidad X25519 del equipo. La secreta va al almacen seguro y se borra de la RAM tras usarla.
pub struct SyncIdentity {
    pub public_key: Vec<u8>,
    pub secret_key: Vec<u8>,
}

/// Version del otro segun su primera trama.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SyncPeerVersion {
    V2,
    V1,
    Other,
    Unknown,
}

/// Lo que cambio en una ronda.
pub struct SyncRoundReport {
    pub received: Vec<String>,
    pub sent: Vec<String>,
}

/// Saludo a medias del iniciador.
#[frb(opaque)]
pub struct SyncInitiator {
    inner: Mutex<Option<Initiator>>,
}

/// Saludo a medias del respondedor: falta aceptar o rechazar.
#[frb(opaque)]
pub struct SyncResponder {
    inner: Mutex<Option<PendingResponder>>,
}

/// Canal establecido y su ronda de sync.
#[frb(opaque)]
pub struct SyncSession {
    channel: Mutex<Channel>,
    round: Mutex<Round>,
}

/// La ronda en curso y los mensajes de la sync que esperan la boveda.
#[frb(ignore)]
#[derive(Default)]
struct Round {
    engine: SyncEngine,
    /// Ya mando su resumen en esta ronda.
    started: bool,
    pending: Vec<Zeroizing<Vec<u8>>>,
}

/// Lo que trajo una trama.
#[frb(non_opaque)]
pub struct SyncInbound {
    /// Mensaje de control completo (JSON de la app), si lo hubo.
    pub control: Option<Vec<u8>>,
    /// Llego un mensaje de la sync: llamar a `process` con la boveda abierta (o `reset_round` si esta bloqueada).
    pub sync_pending: bool,
}

/// Lo que hay que mandar tras procesar la sync.
#[frb(non_opaque)]
pub struct SyncStep {
    pub frames: Vec<Vec<u8>>,
    /// La ronda termino: mando y recibio todo.
    pub round_done: bool,
}

const ENVELOPE_SYNC: u8 = 0;
const ENVELOPE_CONTROL: u8 = 1;

fn envelope(kind: u8, body: &[u8]) -> Zeroizing<Vec<u8>> {
    let mut v = Zeroizing::new(Vec::with_capacity(body.len() + 1));
    v.push(kind);
    v.extend_from_slice(body);
    v
}

fn lock_failed() -> CoreFailure {
    CoreFailure::from(CoreError::Protocol)
}

/// El iniciador y su primera trama.
#[frb(non_opaque)]
pub struct InitiatorStart {
    pub initiator: SyncInitiator,
    pub frame: Vec<u8>,
}

/// La sesion del iniciador y lo que mando el otro en su respuesta.
#[frb(non_opaque)]
pub struct InitiatorDone {
    pub session: SyncSession,
    pub payload: Vec<u8>,
}

/// La sesion del respondedor y la trama de respuesta.
#[frb(non_opaque)]
pub struct ResponderDone {
    pub session: SyncSession,
    pub frame: Vec<u8>,
}

fn used() -> CoreFailure {
    CoreFailure {
        code: FailureCode::Other,
        message: "saludo ya usado".into(),
    }
}

fn session(c: Channel) -> SyncSession {
    SyncSession {
        channel: Mutex::new(c),
        round: Mutex::new(Round::default()),
    }
}

/// Genera la identidad del equipo (una vez).
pub fn sync_generate_identity() -> SyncIdentity {
    let kp = channel::generate_keypair();
    SyncIdentity {
        public_key: kp.public.to_vec(),
        secret_key: kp.secret.to_vec(),
    }
}

/// Llave publica desde la secreta guardada (para el QR).
pub fn sync_public_key(secret_key: Vec<u8>) -> Result<Vec<u8>, CoreFailure> {
    let secret_key = Zeroizing::new(secret_key);
    Ok(channel::public_key(&secret_key)?.to_vec())
}

/// Que version habla el otro, sin descifrar nada.
#[frb(sync)]
pub fn sync_peer_version(frame: Vec<u8>) -> SyncPeerVersion {
    match channel::peer_version(&frame) {
        PeerVersion::V2 => SyncPeerVersion::V2,
        PeerVersion::V1 => SyncPeerVersion::V1,
        PeerVersion::Other(_) => SyncPeerVersion::Other,
        PeerVersion::Unknown => SyncPeerVersion::Unknown,
    }
}

/// Version del protocolo que va en el QR.
#[frb(sync)]
pub fn sync_protocol_version() -> u8 {
    channel::PROTOCOL_VERSION
}

/// Primer mensaje del iniciador. `payload` va cifrado (id y nombre del equipo, token del QR al emparejar).
pub fn sync_initiator_start(
    local_secret: Vec<u8>,
    remote_public: Vec<u8>,
    payload: Vec<u8>,
) -> Result<InitiatorStart, CoreFailure> {
    let (local_secret, payload) = (Zeroizing::new(local_secret), Zeroizing::new(payload));
    let (i, frame) = Initiator::start(&local_secret, &remote_public, &payload)?;
    Ok(InitiatorStart {
        initiator: SyncInitiator {
            inner: Mutex::new(Some(i)),
        },
        frame,
    })
}

impl SyncInitiator {
    /// Recibe la respuesta del otro. Falla si no tiene la llave del QR.
    pub fn finish(&self, frame: Vec<u8>) -> Result<InitiatorDone, CoreFailure> {
        let i = self
            .inner
            .lock()
            .map_err(|_| used())?
            .take()
            .ok_or_else(used)?;
        let (c, payload) = i.finish(&frame)?;
        Ok(InitiatorDone {
            session: session(c),
            payload: payload.to_vec(),
        })
    }
}

/// Lee el primer mensaje del iniciador.
pub fn sync_responder_accept(
    local_secret: Vec<u8>,
    frame: Vec<u8>,
) -> Result<SyncResponder, CoreFailure> {
    let local_secret = Zeroizing::new(local_secret);
    let p = PendingResponder::accept(&local_secret, &frame)?;
    Ok(SyncResponder {
        inner: Mutex::new(Some(p)),
    })
}

impl SyncResponder {
    /// Llave estatica del iniciador: fijarla al emparejar, compararla al reconectar.
    pub fn remote_public(&self) -> Result<Vec<u8>, CoreFailure> {
        let g = self.inner.lock().map_err(|_| used())?;
        Ok(g.as_ref().ok_or_else(used)?.remote_public().to_vec())
    }

    /// Lo que mando el iniciador (cifrado en la red).
    pub fn payload(&self) -> Result<Vec<u8>, CoreFailure> {
        let g = self.inner.lock().map_err(|_| used())?;
        Ok(g.as_ref().ok_or_else(used)?.payload().to_vec())
    }

    /// Acepta y responde.
    pub fn respond(&self, payload: Vec<u8>) -> Result<ResponderDone, CoreFailure> {
        let payload = Zeroizing::new(payload);
        let p = self
            .inner
            .lock()
            .map_err(|_| used())?
            .take()
            .ok_or_else(used)?;
        let (c, frame) = p.respond(&payload)?;
        Ok(ResponderDone {
            session: session(c),
            frame,
        })
    }
}

impl SyncSession {
    fn seal_all(&self, msgs: Vec<Zeroizing<Vec<u8>>>) -> Result<Vec<Vec<u8>>, CoreFailure> {
        let mut ch = self.channel.lock().map_err(|_| lock_failed())?;
        let mut frames = Vec::new();
        for m in msgs {
            frames.extend(ch.seal(&m)?);
        }
        Ok(frames)
    }

    /// Arranca una ronda nueva: las tramas con el resumen de esta boveda.
    pub fn start(&self, vault: &VaultHandle) -> Result<Vec<Vec<u8>>, CoreFailure> {
        let mut r = self.round.lock().map_err(|_| lock_failed())?;
        *r = Round::default();
        let msg = vault.with_vault(|v| r.engine.start(v))?;
        r.started = true;
        drop(r);
        self.seal_all(vec![envelope(ENVELOPE_SYNC, &msg)])
    }

    /// Tramas con un mensaje de control de la app.
    pub fn send_control(&self, msg: Vec<u8>) -> Result<Vec<Vec<u8>>, CoreFailure> {
        let msg = Zeroizing::new(msg);
        self.seal_all(vec![envelope(ENVELOPE_CONTROL, &msg)])
    }

    /// Descifra una trama del otro. No necesita la boveda (el escritorio bloqueado recibe el desbloqueo por WiFi).
    pub fn on_frame(&self, frame: Vec<u8>) -> Result<SyncInbound, CoreFailure> {
        let msg = {
            let mut ch = self.channel.lock().map_err(|_| lock_failed())?;
            ch.open(&frame)?
        };
        let nothing = SyncInbound {
            control: None,
            sync_pending: false,
        };
        let Some(msg) = msg else { return Ok(nothing) };
        match msg.split_first() {
            Some((&ENVELOPE_CONTROL, body)) => Ok(SyncInbound {
                control: Some(body.to_vec()),
                sync_pending: false,
            }),
            Some((&ENVELOPE_SYNC, body)) => {
                let mut r = self.round.lock().map_err(|_| lock_failed())?;
                r.pending.push(Zeroizing::new(body.to_vec()));
                Ok(SyncInbound {
                    control: None,
                    sync_pending: true,
                })
            }
            _ => Err(CoreError::Protocol.into()),
        }
    }

    /// Procesa los mensajes de la sync pendientes. Si el otro arranco la ronda, contesta primero con el resumen
    /// de esta boveda.
    pub fn process(&self, vault: &VaultHandle) -> Result<SyncStep, CoreFailure> {
        let mut guard = self.round.lock().map_err(|_| lock_failed())?;
        let r = &mut *guard;
        let pending = std::mem::take(&mut r.pending);
        let mut out = Vec::new();
        for msg in pending {
            if SyncEngine::is_summary(&msg) && (!r.started || r.engine.is_complete()) {
                r.engine = SyncEngine::new();
                r.started = true;
                out.push(vault.with_vault(|v| r.engine.start(v))?);
            }
            out.extend(vault.with_vault(|v| r.engine.handle(v, &msg))?);
        }
        let round_done = r.engine.is_complete();
        drop(guard);
        let frames = self.seal_all(out.iter().map(|m| envelope(ENVELOPE_SYNC, m)).collect())?;
        Ok(SyncStep { frames, round_done })
    }

    /// Descarta la ronda en curso y lo pendiente (la boveda esta bloqueada o algo fallo).
    pub fn reset_round(&self) {
        if let Ok(mut r) = self.round.lock() {
            *r = Round::default();
        }
    }

    /// La ronda en curso ya mando y recibio todo.
    pub fn is_complete(&self) -> bool {
        self.round
            .lock()
            .map(|r| r.engine.is_complete())
            .unwrap_or(false)
    }

    /// Lo que cambio en la ultima ronda.
    pub fn report(&self) -> SyncRoundReport {
        match self.round.lock() {
            Ok(r) => SyncRoundReport {
                received: r.engine.report().received.clone(),
                sent: r.engine.report().sent.clone(),
            },
            Err(_) => SyncRoundReport {
                received: vec![],
                sent: vec![],
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::vault::{vault_create, KdfConfig, VaultRecord};

    fn fast() -> KdfConfig {
        KdfConfig {
            memory_kib: 64,
            iterations: 1,
            parallelism: 1,
        }
    }

    fn rec(id: &str, t: i64, data: &str) -> VaultRecord {
        VaultRecord {
            id: id.into(),
            kind: "credential".into(),
            updated_at: t,
            deleted: false,
            data: data.into(),
        }
    }

    /// Celular (iniciador) y escritorio (respondedor), con el token del QR en el saludo.
    fn pair() -> (SyncSession, SyncSession) {
        let phone = sync_generate_identity();
        let desk = sync_generate_identity();
        let start = sync_initiator_start(
            phone.secret_key.clone(),
            desk.public_key.clone(),
            b"token".to_vec(),
        )
        .unwrap();
        let resp = sync_responder_accept(desk.secret_key.clone(), start.frame).unwrap();
        assert_eq!(resp.remote_public().unwrap(), phone.public_key);
        assert_eq!(resp.payload().unwrap(), b"token");
        let done = resp.respond(b"escritorio".to_vec()).unwrap();
        let fin = start.initiator.finish(done.frame).unwrap();
        assert_eq!(fin.payload, b"escritorio");
        (fin.session, done.session)
    }

    /// Entrega tramas al otro hasta que no haya nada que mandar. Devuelve los mensajes de control recibidos.
    fn deliver(
        mut frames: Vec<Vec<u8>>,
        from_a: bool,
        a: (&SyncSession, &VaultHandle),
        b: (&SyncSession, &VaultHandle),
    ) -> Vec<Vec<u8>> {
        let mut controls = Vec::new();
        let mut to_b = from_a;
        while !frames.is_empty() {
            let (s, v) = if to_b { b } else { a };
            let mut reply = Vec::new();
            for f in frames {
                let inb = s.on_frame(f).unwrap();
                if let Some(c) = inb.control {
                    controls.push(c);
                }
                if inb.sync_pending {
                    reply.extend(s.process(v).unwrap().frames);
                }
            }
            frames = reply;
            to_b = !to_b;
        }
        controls
    }

    #[test]
    fn rondas_seguidas_desde_cualquier_lado_y_control() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let va = vault_create(da.path().to_string_lossy().into(), b"a".to_vec(), fast())
            .unwrap()
            .vault;
        let vb = vault_create(db.path().to_string_lossy().into(), b"b".to_vec(), fast())
            .unwrap()
            .vault;
        va.put(vec![rec("1", 10, "{\"t\":\"a\"}")]).unwrap();
        vb.put(vec![rec("2", 20, "{\"t\":\"b\"}")]).unwrap();
        let (sa, sb) = pair();

        // Ronda 1, la arranca el celular.
        let f = sa.start(&va).unwrap();
        deliver(f, true, (&sa, &va), (&sb, &vb));
        assert!(sa.is_complete() && sb.is_complete());
        assert_eq!(sa.report().received, vec!["2".to_string()]);
        assert_eq!(sb.report().received, vec!["1".to_string()]);
        assert!(va.get("2".into()).unwrap().is_some());
        assert!(vb.get("1".into()).unwrap().is_some());

        // Ronda 2 en la misma sesion, la arranca el escritorio con un cambio nuevo.
        vb.put(vec![rec("1", 30, "{\"t\":\"nuevo\"}")]).unwrap();
        let f = sb.start(&vb).unwrap();
        deliver(f, false, (&sa, &va), (&sb, &vb));
        assert!(sa.is_complete() && sb.is_complete());
        assert_eq!(sa.report().received, vec!["1".to_string()]);
        assert_eq!(
            va.get("1".into()).unwrap().unwrap().data,
            "{\"t\":\"nuevo\"}"
        );

        // Control en los dos sentidos, sin boveda de por medio.
        let c = sb
            .send_control(b"{\"op\":\"approval_request\"}".to_vec())
            .unwrap();
        assert_eq!(
            deliver(c, false, (&sa, &va), (&sb, &vb)),
            vec![b"{\"op\":\"approval_request\"}".to_vec()]
        );
        let c = sa.send_control(b"x".to_vec()).unwrap();
        assert_eq!(
            deliver(c, true, (&sa, &va), (&sb, &vb)),
            vec![b"x".to_vec()]
        );
    }

    #[test]
    fn bloqueado_descarta_la_ronda_y_la_siguiente_funciona() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let va = vault_create(da.path().to_string_lossy().into(), b"a".to_vec(), fast())
            .unwrap()
            .vault;
        let vb = vault_create(db.path().to_string_lossy().into(), b"b".to_vec(), fast())
            .unwrap()
            .vault;
        va.put(vec![rec("1", 10, "{}")]).unwrap();
        let (sa, sb) = pair();

        // El escritorio esta bloqueado: recibe el resumen y descarta.
        for f in sa.start(&va).unwrap() {
            assert!(sb.on_frame(f).unwrap().sync_pending);
        }
        sb.reset_round();
        assert!(!sb.is_complete());

        // Ya desbloqueado, una ronda nueva completa.
        let f = sa.start(&va).unwrap();
        deliver(f, true, (&sa, &va), (&sb, &vb));
        assert!(sa.is_complete() && sb.is_complete());
        assert!(vb.get("1".into()).unwrap().is_some());
    }

    #[test]
    fn sobre_desconocido_se_rechaza() {
        let (sa, sb) = pair();
        let mut ch = sa.channel.lock().unwrap();
        let frames = ch.seal(&[7u8, 1, 2]).unwrap();
        drop(ch);
        let mut err = None;
        for f in frames {
            if let Err(e) = sb.on_frame(f) {
                err = Some(e);
            }
        }
        assert!(err.is_some());
    }
}
