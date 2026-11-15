//! Canal cifrado de la sync v2 (ADR-0010, NUC-3): Noise `IK` con la llave del par fijada en el QR.
//!
//! Por que `IK`: quien escanea el QR (el iniciador) ya conoce la llave estatica del otro, asi que lo autentica
//! desde el primer mensaje y nadie en medio puede hacerse pasar por el. Su propia llave viaja cifrada en ese
//! primer mensaje; el que responde la acepta si trae el token de un uso del QR (emparejar) o si ya la tiene
//! fijada (reconectar). Un solo patron para los dos casos, sin certificados.
//!
//! Sin E/S: quien llama mueve los bytes (WebSocket binario en Dart). Las tramas del saludo llevan delante
//! `SKS2` + version en claro, para reconocer a un par de otra version antes de tocar ningun dato.

use snow::{Builder, HandshakeState, TransportState};
use zeroize::Zeroizing;

use crate::error::CoreError;

/// Marca de las tramas del saludo.
pub const MAGIC: &[u8; 4] = b"SKS2";
/// Version del protocolo de sync.
pub const PROTOCOL_VERSION: u8 = 2;
/// Patron y primitivas de Noise.
pub const NOISE_PARAMS: &str = "Noise_IK_25519_ChaChaPoly_SHA256";
const PROLOGUE: &[u8] = b"SoloKey sync v2";
/// Largo maximo de un mensaje de Noise.
const NOISE_MAX: usize = 65_535;
const TAG: usize = 16;
/// Lo que cabe de mensaje en cada trama (1 byte de bandera + datos + etiqueta).
const CHUNK: usize = NOISE_MAX - TAG - 1;
/// Tope de un mensaje reensamblado: un par no puede llenar la RAM.
pub const MAX_MESSAGE: usize = 256 * 1024 * 1024;

/// Que hay al otro lado, segun su primera trama.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PeerVersion {
    /// Habla la v2: seguir.
    V2,
    /// La v1 manda JSON en texto: hay que actualizar los dos equipos.
    V1,
    /// Otra version de SoloKey (mas nueva o mas vieja que la v2).
    Other(u8),
    /// No es SoloKey.
    Unknown,
}

/// Mira la primera trama del otro sin descifrar nada.
pub fn peer_version(frame: &[u8]) -> PeerVersion {
    if frame.len() > MAGIC.len() && &frame[..4] == MAGIC {
        return if frame[4] == PROTOCOL_VERSION {
            PeerVersion::V2
        } else {
            PeerVersion::Other(frame[4])
        };
    }
    match frame.iter().find(|b| !b.is_ascii_whitespace()) {
        Some(b'{') => PeerVersion::V1,
        _ => PeerVersion::Unknown,
    }
}

/// Par de llaves X25519 del equipo. La secreta se pone a cero al soltarse.
pub struct Keypair {
    pub public: [u8; 32],
    pub secret: Zeroizing<[u8; 32]>,
}

fn builder() -> Builder<'static> {
    Builder::new(NOISE_PARAMS.parse().expect("parametros de Noise validos"))
}

fn key32(b: &[u8]) -> Result<[u8; 32], CoreError> {
    b.try_into().map_err(|_| CoreError::KeyLength)
}

fn noise(_: snow::Error) -> CoreError {
    CoreError::Handshake
}

/// Genera la identidad del equipo (una vez; se guarda en el almacen seguro del SO).
pub fn generate_keypair() -> Keypair {
    let kp = builder().generate_keypair().expect("generar llaves X25519");
    let mut secret = Zeroizing::new([0u8; 32]);
    secret.copy_from_slice(&kp.private);
    let mut private = kp.private;
    zeroize::Zeroize::zeroize(&mut private);
    Keypair {
        public: key32(&kp.public).expect("32 bytes"),
        secret,
    }
}

/// Llave publica de una secreta guardada.
pub fn public_key(secret: &[u8]) -> Result<[u8; 32], CoreError> {
    let s: [u8; 32] = key32(secret)?;
    Ok(x25519_dalek::PublicKey::from(&x25519_dalek::StaticSecret::from(s)).to_bytes())
}

fn framed(body: &[u8]) -> Vec<u8> {
    let mut f = Vec::with_capacity(5 + body.len());
    f.extend_from_slice(MAGIC);
    f.push(PROTOCOL_VERSION);
    f.extend_from_slice(body);
    f
}

fn unframe(frame: &[u8]) -> Result<&[u8], CoreError> {
    match peer_version(frame) {
        PeerVersion::V2 => Ok(&frame[5..]),
        PeerVersion::V1 => Err(CoreError::PeerIsV1),
        PeerVersion::Other(v) => Err(CoreError::PeerVersion(v)),
        PeerVersion::Unknown => Err(CoreError::Handshake),
    }
}

/// Iniciador: el equipo que escaneo el QR (o que reconecta con el par ya fijado).
pub struct Initiator {
    hs: HandshakeState,
}

impl Initiator {
    /// Primer mensaje. `payload` va cifrado (id y nombre del equipo, y el token del QR si es emparejar).
    pub fn start(
        local_secret: &[u8],
        remote_public: &[u8],
        payload: &[u8],
    ) -> Result<(Initiator, Vec<u8>), CoreError> {
        let mut hs = builder()
            .local_private_key(local_secret)
            .remote_public_key(remote_public)
            .prologue(PROLOGUE)
            .build_initiator()
            .map_err(noise)?;
        let mut buf = vec![0u8; NOISE_MAX];
        let n = hs.write_message(payload, &mut buf).map_err(noise)?;
        Ok((Initiator { hs }, framed(&buf[..n])))
    }

    /// Recibe la respuesta: el otro probo que tiene la llave del QR. Devuelve el canal y su payload.
    pub fn finish(mut self, frame: &[u8]) -> Result<(Channel, Zeroizing<Vec<u8>>), CoreError> {
        let body = unframe(frame)?;
        let mut buf = Zeroizing::new(vec![0u8; NOISE_MAX]);
        let n = self.hs.read_message(body, &mut buf).map_err(noise)?;
        let payload = Zeroizing::new(buf[..n].to_vec());
        let ts = self.hs.into_transport_mode().map_err(noise)?;
        Ok((Channel::new(ts), payload))
    }
}

/// Respondedor tras leer el primer mensaje: ya sabe quien es el otro, falta decidir si se acepta.
pub struct PendingResponder {
    hs: HandshakeState,
    remote_public: [u8; 32],
    payload: Zeroizing<Vec<u8>>,
}

impl PendingResponder {
    /// Lee el primer mensaje del iniciador.
    pub fn accept(local_secret: &[u8], frame: &[u8]) -> Result<PendingResponder, CoreError> {
        let body = unframe(frame)?;
        let mut hs = builder()
            .local_private_key(local_secret)
            .prologue(PROLOGUE)
            .build_responder()
            .map_err(noise)?;
        let mut buf = Zeroizing::new(vec![0u8; NOISE_MAX]);
        let n = hs.read_message(body, &mut buf).map_err(noise)?;
        let remote_public = key32(hs.get_remote_static().ok_or(CoreError::Handshake)?)?;
        Ok(PendingResponder {
            hs,
            remote_public,
            payload: Zeroizing::new(buf[..n].to_vec()),
        })
    }

    /// Llave estatica del iniciador: fijarla al emparejar, compararla al reconectar.
    pub fn remote_public(&self) -> [u8; 32] {
        self.remote_public
    }

    pub fn payload(&self) -> &[u8] {
        &self.payload
    }

    /// Acepta: segundo mensaje y canal listo.
    pub fn respond(mut self, payload: &[u8]) -> Result<(Channel, Vec<u8>), CoreError> {
        let mut buf = vec![0u8; NOISE_MAX];
        let n = self.hs.write_message(payload, &mut buf).map_err(noise)?;
        let ts = self.hs.into_transport_mode().map_err(noise)?;
        Ok((Channel::new(ts), framed(&buf[..n])))
    }
}

/// Canal establecido. Parte los mensajes largos en tramas y los vuelve a juntar.
pub struct Channel {
    ts: TransportState,
    pending: Zeroizing<Vec<u8>>,
}

impl Channel {
    fn new(ts: TransportState) -> Channel {
        Channel {
            ts,
            pending: Zeroizing::new(Vec::new()),
        }
    }

    /// Cifra un mensaje en una o varias tramas.
    pub fn seal(&mut self, msg: &[u8]) -> Result<Vec<Vec<u8>>, CoreError> {
        if msg.len() > MAX_MESSAGE {
            return Err(CoreError::TooLarge);
        }
        let mut frames = Vec::new();
        let mut chunks = msg.chunks(CHUNK).peekable();
        if chunks.peek().is_none() {
            return self.seal_chunk(&[], true).map(|f| vec![f]);
        }
        while let Some(c) = chunks.next() {
            frames.push(self.seal_chunk(c, chunks.peek().is_none())?);
        }
        Ok(frames)
    }

    fn seal_chunk(&mut self, chunk: &[u8], last: bool) -> Result<Vec<u8>, CoreError> {
        let mut pt = Zeroizing::new(Vec::with_capacity(chunk.len() + 1));
        pt.push(u8::from(last));
        pt.extend_from_slice(chunk);
        let mut out = vec![0u8; pt.len() + TAG];
        let n = self.ts.write_message(&pt, &mut out).map_err(noise)?;
        out.truncate(n);
        Ok(out)
    }

    /// Descifra una trama. Devuelve el mensaje cuando llega su ultima trama.
    pub fn open(&mut self, frame: &[u8]) -> Result<Option<Zeroizing<Vec<u8>>>, CoreError> {
        let mut pt = Zeroizing::new(vec![0u8; frame.len()]);
        let n = self
            .ts
            .read_message(frame, &mut pt)
            .map_err(|_| CoreError::Decrypt)?;
        if n == 0 {
            return Err(CoreError::Format);
        }
        if self.pending.len() + n - 1 > MAX_MESSAGE {
            return Err(CoreError::TooLarge);
        }
        self.pending.extend_from_slice(&pt[1..n]);
        if pt[0] == 1 {
            Ok(Some(std::mem::replace(
                &mut self.pending,
                Zeroizing::new(Vec::new()),
            )))
        } else {
            Ok(None)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn pair() -> (Channel, Channel) {
        let a = generate_keypair();
        let b = generate_keypair();
        let (i, m1) = Initiator::start(a.secret.as_ref(), &b.public, b"hola").unwrap();
        let pr = PendingResponder::accept(b.secret.as_ref(), &m1).unwrap();
        assert_eq!(
            pr.remote_public(),
            a.public,
            "el respondedor ve la llave real del iniciador"
        );
        assert_eq!(pr.payload(), b"hola");
        let (cb, m2) = pr.respond(b"ok").unwrap();
        let (ca, p2) = i.finish(&m2).unwrap();
        assert_eq!(p2.as_slice(), b"ok");
        (ca, cb)
    }

    #[test]
    fn saludo_y_mensajes_en_los_dos_sentidos() {
        let (mut a, mut b) = pair();
        for f in a.seal(b"de a").unwrap() {
            if let Some(m) = b.open(&f).unwrap() {
                assert_eq!(m.as_slice(), b"de a");
            }
        }
        let f = b.seal(b"").unwrap();
        assert_eq!(f.len(), 1);
        assert_eq!(a.open(&f[0]).unwrap().unwrap().as_slice(), b"");
    }

    #[test]
    fn mensaje_largo_se_parte_y_se_junta() {
        let (mut a, mut b) = pair();
        let big: Vec<u8> = (0..200_000u32).map(|i| i as u8).collect();
        let frames = a.seal(&big).unwrap();
        assert_eq!(frames.len(), 4);
        assert!(frames.iter().all(|f| f.len() <= NOISE_MAX));
        let mut got = None;
        for f in frames {
            got = b.open(&f).unwrap();
        }
        assert_eq!(got.unwrap().as_slice(), big.as_slice());
    }

    #[test]
    fn la_llave_del_qr_equivocada_no_completa_el_saludo() {
        let a = generate_keypair();
        let b = generate_keypair();
        let impostor = generate_keypair();
        // A escaneo el QR de B, pero contesta un impostor sin la llave secreta de B.
        let (_i, m1) = Initiator::start(a.secret.as_ref(), &b.public, b"").unwrap();
        assert!(PendingResponder::accept(impostor.secret.as_ref(), &m1).is_err());
    }

    #[test]
    fn trama_alterada_o_repetida_se_rechaza() {
        let (mut a, mut b) = pair();
        let mut f = a.seal(b"dato").unwrap().remove(0);
        let ok = f.clone();
        f[3] ^= 1;
        assert_eq!(b.open(&f).err(), Some(CoreError::Decrypt));
        let (mut a, mut b) = pair();
        let f = a.seal(b"dato").unwrap().remove(0);
        b.open(&f).unwrap();
        assert!(b.open(&f).is_err(), "repetir una trama no se acepta");
        let _ = ok;
    }

    #[test]
    fn en_la_red_no_viaja_nada_en_claro() {
        let a = generate_keypair();
        let b = generate_keypair();
        let (_i, m1) =
            Initiator::start(a.secret.as_ref(), &b.public, b"Laptop de Ana TOKEN123").unwrap();
        assert!(!m1.windows(8).any(|w| w == b"TOKEN123"));
        assert!(
            !m1.windows(32).any(|w| w == a.public),
            "la llave del iniciador va cifrada"
        );
        let (mut ca, _) = pair();
        let f = ca.seal(b"contrasena-secreta").unwrap();
        assert!(!f[0].windows(10).any(|w| w == b"contrasena"));
    }

    #[test]
    fn version_del_otro() {
        assert_eq!(peer_version(b"SKS2\x02abc"), PeerVersion::V2);
        assert_eq!(peer_version(b"SKS2\x03abc"), PeerVersion::Other(3));
        assert_eq!(peer_version(br#" {"type":"hello"}"#), PeerVersion::V1);
        assert_eq!(peer_version(b"GET / HTTP"), PeerVersion::Unknown);
        let b = generate_keypair();
        assert_eq!(
            PendingResponder::accept(b.secret.as_ref(), br#"{"type":"auth"}"#).err(),
            Some(CoreError::PeerIsV1)
        );
        assert_eq!(
            PendingResponder::accept(b.secret.as_ref(), b"SKS2\x09xx").err(),
            Some(CoreError::PeerVersion(9))
        );
    }

    #[test]
    fn publica_desde_la_secreta() {
        let k = generate_keypair();
        assert_eq!(public_key(k.secret.as_ref()).unwrap(), k.public);
    }
}
