//! Sync v2 para Flutter (NUC-3). Flutter mueve los bytes (WebSocket binario, descubrimiento, QR) y guarda la
//! identidad del equipo y las llaves fijadas de sus pares en el almacen seguro; aqui va el canal y el delta.
//!
//! Flujo del que escanea (iniciador): `sync_initiator_start` -> manda la trama -> `finish` con la respuesta ->
//! `SyncSession`. Flujo del que muestra el QR (respondedor): `sync_responder_accept` con la primera trama ->
//! mira `remote_public` y `payload` (token del QR o llave ya fijada) -> `respond` -> `SyncSession`.
//! Con la sesion: `start` y despues `on_frame` por cada trama recibida, mandando lo que devuelvan, hasta
//! `is_complete`.

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
    engine: Mutex<SyncEngine>,
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
        engine: Mutex::new(SyncEngine::new()),
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
        let mut ch = self
            .channel
            .lock()
            .map_err(|_| CoreFailure::from(CoreError::Protocol))?;
        let mut frames = Vec::new();
        for m in msgs {
            frames.extend(ch.seal(&m)?);
        }
        Ok(frames)
    }

    /// Primeras tramas de la ronda (el resumen de esta boveda).
    pub fn start(&self, vault: &VaultHandle) -> Result<Vec<Vec<u8>>, CoreFailure> {
        let engine = self
            .engine
            .lock()
            .map_err(|_| CoreFailure::from(CoreError::Protocol))?;
        let msg = vault.with_vault(|v| engine.start(v))?;
        drop(engine);
        self.seal_all(vec![msg])
    }

    /// Procesa una trama del otro y devuelve las tramas a mandar (puede ser ninguna).
    pub fn on_frame(
        &self,
        vault: &VaultHandle,
        frame: Vec<u8>,
    ) -> Result<Vec<Vec<u8>>, CoreFailure> {
        let msg = {
            let mut ch = self
                .channel
                .lock()
                .map_err(|_| CoreFailure::from(CoreError::Protocol))?;
            ch.open(&frame)?
        };
        let Some(msg) = msg else { return Ok(vec![]) };
        let out = {
            let mut engine = self
                .engine
                .lock()
                .map_err(|_| CoreFailure::from(CoreError::Protocol))?;
            vault.with_vault(|v| engine.handle(v, &msg))?
        };
        self.seal_all(out)
    }

    pub fn is_complete(&self) -> bool {
        self.engine.lock().map(|e| e.is_complete()).unwrap_or(false)
    }

    pub fn report(&self) -> SyncRoundReport {
        let e = self.engine.lock();
        match e {
            Ok(e) => SyncRoundReport {
                received: e.report().received.clone(),
                sent: e.report().sent.clone(),
            },
            Err(_) => SyncRoundReport {
                received: vec![],
                sent: vec![],
            },
        }
    }
}
