//! Protocolo de la sync v2 dentro del canal Noise: delta con "gana la ultima escritura" (LWW).
//!
//! Cada lado manda su `Summary` (id, fecha, lapida y hash de cada registro sincronizable). Al recibir el del
//! otro, manda en un `Push` los registros donde el suyo gana (y el contenido de los archivos). Al recibir el
//! `Push` del otro, aplica los que ganan. Termina cuando mando y recibio su `Push`.
//!
//! Los registros con `kind` que empieza por `_` son locales del equipo y nunca viajan.

use std::collections::{BTreeMap, HashMap};

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use serde::{Deserialize, Serialize};
use zeroize::Zeroizing;

use crate::crypto;
use crate::error::CoreError;
use crate::vault::{Record, Vault};

/// Version de los mensajes dentro del canal.
pub const MESSAGE_VERSION: u32 = 1;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct SummaryItem {
    pub id: String,
    pub updated_at: i64,
    pub deleted: bool,
    /// SHA-256 (hex) de los datos, para desempatar igual en los dos equipos.
    pub hash: String,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct WireRecord {
    id: String,
    kind: String,
    updated_at: i64,
    deleted: bool,
    data: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    blob: Option<String>,
}

#[derive(Serialize, Deserialize)]
#[serde(tag = "t", rename_all = "camelCase")]
enum Msg {
    Summary { v: u32, items: Vec<SummaryItem> },
    Push { v: u32, records: Vec<WireRecord> },
}

/// Fecha, lapida y hash de un registro: lo que decide quien gana.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Meta {
    pub updated_at: i64,
    pub deleted: bool,
    pub hash: String,
}

fn meta_of(r: &Record) -> Meta {
    Meta {
        updated_at: r.updated_at,
        deleted: r.deleted,
        hash: hash_hex(&r.data),
    }
}

fn hash_hex(data: &str) -> String {
    crypto::sha256(data.as_bytes())
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect()
}

/// `true` si la version remota gana a la local. La mas nueva gana; con la misma fecha exacta gana la lapida y
/// despues el hash mayor. Es determinista: los dos equipos eligen lo mismo (en la v1 el empate comparaba el
/// id consigo mismo y cada equipo se quedaba con lo suyo).
pub fn remote_wins(local: &Meta, remote: &Meta) -> bool {
    if remote.updated_at != local.updated_at {
        return remote.updated_at > local.updated_at;
    }
    if remote.deleted != local.deleted {
        return remote.deleted;
    }
    remote.hash > local.hash
}

fn syncable(r: &Record) -> bool {
    !r.kind.starts_with('_')
}

/// Lo que paso en una ronda.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct SyncReport {
    /// Registros que llegaron del otro y se aplicaron (ids).
    pub received: Vec<String>,
    /// Registros que se mandaron al otro (ids).
    pub sent: Vec<String>,
}

/// Una ronda de sync sobre un canal ya establecido. Sin E/S: devuelve los mensajes a mandar.
#[derive(Default)]
pub struct SyncEngine {
    sent_push: bool,
    got_push: bool,
    report: SyncReport,
}

impl SyncEngine {
    pub fn new() -> SyncEngine {
        SyncEngine::default()
    }

    /// Primer mensaje (los dos lados lo mandan al abrir el canal).
    pub fn start(&self, vault: &Vault) -> Result<Zeroizing<Vec<u8>>, CoreError> {
        let items = vault
            .list(None, true)
            .iter()
            .filter(|r| syncable(r))
            .map(|r| {
                let m = meta_of(r);
                SummaryItem {
                    id: r.id.clone(),
                    updated_at: m.updated_at,
                    deleted: m.deleted,
                    hash: m.hash,
                }
            })
            .collect();
        encode(&Msg::Summary {
            v: MESSAGE_VERSION,
            items,
        })
    }

    /// Procesa un mensaje del otro y devuelve lo que hay que contestar.
    pub fn handle(
        &mut self,
        vault: &mut Vault,
        msg: &[u8],
    ) -> Result<Vec<Zeroizing<Vec<u8>>>, CoreError> {
        let msg: Msg = serde_json::from_slice(msg).map_err(|_| CoreError::Format)?;
        match msg {
            Msg::Summary { v, items } => {
                check_version(v)?;
                if self.sent_push {
                    return Err(CoreError::Protocol);
                }
                let push = self.build_push(vault, items)?;
                self.sent_push = true;
                Ok(vec![push])
            }
            Msg::Push { v, records } => {
                check_version(v)?;
                if self.got_push {
                    return Err(CoreError::Protocol);
                }
                self.apply(vault, records)?;
                self.got_push = true;
                Ok(vec![])
            }
        }
    }

    /// Si el mensaje es un resumen (el que abre una ronda).
    pub fn is_summary(msg: &[u8]) -> bool {
        matches!(serde_json::from_slice::<Msg>(msg), Ok(Msg::Summary { .. }))
    }

    /// Ya mando y recibio todo.
    pub fn is_complete(&self) -> bool {
        self.sent_push && self.got_push
    }

    pub fn report(&self) -> &SyncReport {
        &self.report
    }

    fn build_push(
        &mut self,
        vault: &Vault,
        peer: Vec<SummaryItem>,
    ) -> Result<Zeroizing<Vec<u8>>, CoreError> {
        let peer: HashMap<String, Meta> = peer
            .into_iter()
            .map(|i| {
                (
                    i.id,
                    Meta {
                        updated_at: i.updated_at,
                        deleted: i.deleted,
                        hash: i.hash,
                    },
                )
            })
            .collect();
        let mut records = Vec::new();
        for r in vault.list(None, true).into_iter().filter(syncable) {
            let mine = meta_of(&r);
            let send = match peer.get(&r.id) {
                None => true,
                Some(theirs) => remote_wins(theirs, &mine),
            };
            if !send {
                continue;
            }
            let blob = if r.deleted {
                None
            } else {
                vault.get_blob(&r.id)?.map(|b| STANDARD.encode(&*b))
            };
            self.report.sent.push(r.id.clone());
            records.push(WireRecord {
                id: r.id,
                kind: r.kind,
                updated_at: r.updated_at,
                deleted: r.deleted,
                data: r.data,
                blob,
            });
        }
        encode(&Msg::Push {
            v: MESSAGE_VERSION,
            records,
        })
    }

    fn apply(&mut self, vault: &mut Vault, records: Vec<WireRecord>) -> Result<(), CoreError> {
        let mut winners = Vec::new();
        let mut blobs: BTreeMap<String, Option<Zeroizing<Vec<u8>>>> = BTreeMap::new();
        for w in records {
            if w.kind.is_empty() || w.kind.starts_with('_') || w.id.is_empty() {
                return Err(CoreError::Protocol);
            }
            let remote = Record {
                id: w.id,
                kind: w.kind,
                updated_at: w.updated_at,
                deleted: w.deleted,
                data: w.data,
            };
            let wins = match vault.get(&remote.id) {
                None => true,
                Some(local) if local.kind != remote.kind => return Err(CoreError::Protocol),
                Some(local) => remote_wins(&meta_of(&local), &meta_of(&remote)),
            };
            if !wins {
                continue;
            }
            let blob = match (&w.blob, remote.deleted) {
                (Some(b64), false) => Some(Zeroizing::new(
                    STANDARD.decode(b64).map_err(|_| CoreError::Format)?,
                )),
                _ => None,
            };
            blobs.insert(remote.id.clone(), blob);
            winners.push(remote);
        }
        // Primero los contenidos y despues los registros: si se corta a medias, el registro viejo sigue
        // apuntando a un contenido valido y la proxima ronda lo vuelve a traer.
        for (id, blob) in &blobs {
            match blob {
                Some(b) => vault.put_blob(id, b)?,
                None => vault.delete_blob(id)?,
            }
        }
        vault.put_many(&winners)?;
        self.report
            .received
            .extend(winners.into_iter().map(|r| r.id));
        Ok(())
    }
}

fn check_version(v: u32) -> Result<(), CoreError> {
    if v != MESSAGE_VERSION {
        return Err(CoreError::Protocol);
    }
    Ok(())
}

fn encode(m: &Msg) -> Result<Zeroizing<Vec<u8>>, CoreError> {
    serde_json::to_vec(m)
        .map(Zeroizing::new)
        .map_err(|_| CoreError::Format)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crypto::KdfParams;
    use crate::sync::channel::{generate_keypair, Channel, Initiator, PendingResponder};
    use crate::vault::{vault_path, Vault};

    fn fast() -> KdfParams {
        KdfParams {
            memory_kib: 64,
            iterations: 1,
            parallelism: 1,
        }
    }

    fn vault(dir: &tempfile::TempDir, name: &str) -> Vault {
        Vault::create(&vault_path(&dir.path().join(name)), b"m", fast())
            .unwrap()
            .0
    }

    fn rec(id: &str, t: i64, data: &str) -> Record {
        Record {
            id: id.into(),
            kind: "credential".into(),
            updated_at: t,
            deleted: false,
            data: data.into(),
        }
    }

    fn channels() -> (Channel, Channel) {
        let a = generate_keypair();
        let b = generate_keypair();
        let (i, m1) = Initiator::start(a.secret.as_ref(), &b.public, b"").unwrap();
        let (cb, m2) = PendingResponder::accept(b.secret.as_ref(), &m1)
            .unwrap()
            .respond(b"")
            .unwrap();
        let (ca, _) = i.finish(&m2).unwrap();
        (ca, cb)
    }

    /// Corre una ronda completa por el canal cifrado, como lo haria la red.
    fn sync(a: &mut Vault, b: &mut Vault) -> (SyncReport, SyncReport) {
        let (mut ca, mut cb) = channels();
        let mut ea = SyncEngine::new();
        let mut eb = SyncEngine::new();
        let mut to_b: Vec<Vec<u8>> = ca.seal(&ea.start(a).unwrap()).unwrap();
        let mut to_a: Vec<Vec<u8>> = cb.seal(&eb.start(b).unwrap()).unwrap();
        for _ in 0..4 {
            let mut next_b = Vec::new();
            for f in std::mem::take(&mut to_b) {
                if let Some(m) = cb.open(&f).unwrap() {
                    for out in eb.handle(b, &m).unwrap() {
                        next_b.extend(cb.seal(&out).unwrap());
                    }
                }
            }
            let mut next_a = Vec::new();
            for f in std::mem::take(&mut to_a) {
                if let Some(m) = ca.open(&f).unwrap() {
                    for out in ea.handle(a, &m).unwrap() {
                        next_a.extend(ca.seal(&out).unwrap());
                    }
                }
            }
            to_a = next_b;
            to_b = next_a;
        }
        assert!(ea.is_complete() && eb.is_complete());
        (ea.report().clone(), eb.report().clone())
    }

    #[test]
    fn cada_lado_recibe_lo_que_le_falta_y_gana_lo_mas_nuevo() {
        let d = tempfile::tempdir().unwrap();
        let (mut a, mut b) = (vault(&d, "a"), vault(&d, "b"));
        a.put(rec("solo-a", 1, r#"{"t":"a"}"#)).unwrap();
        b.put(rec("solo-b", 1, r#"{"t":"b"}"#)).unwrap();
        a.put(rec("ambos", 5, r#"{"t":"viejo"}"#)).unwrap();
        b.put(rec("ambos", 9, r#"{"t":"nuevo"}"#)).unwrap();
        a.put(Record {
            id: "local".into(),
            kind: "_peer".into(),
            updated_at: 1,
            deleted: false,
            data: "{}".into(),
        })
        .unwrap();

        let (ra, rb) = sync(&mut a, &mut b);
        assert_eq!(ra.sent, vec!["solo-a"]);
        assert_eq!(rb.sent, vec!["ambos", "solo-b"]);
        for v in [&a, &b] {
            assert_eq!(v.get("ambos").unwrap().data, r#"{"t":"nuevo"}"#);
            assert!(v.get("solo-a").is_some() && v.get("solo-b").is_some());
        }
        assert!(b.get("local").is_none(), "lo local no viaja");
        assert_eq!(
            a.get("ambos").unwrap().updated_at,
            9,
            "la fecha se conserva tal cual"
        );

        // Segunda ronda: nada que mandar.
        let (ra, rb) = sync(&mut a, &mut b);
        assert!(ra.sent.is_empty() && rb.sent.is_empty());
    }

    #[test]
    fn borrado_se_propaga_y_archivos_viajan() {
        let d = tempfile::tempdir().unwrap();
        let (mut a, mut b) = (vault(&d, "a"), vault(&d, "b"));
        a.put(Record {
            id: "f".into(),
            kind: "file".into(),
            updated_at: 1,
            deleted: false,
            data: "{}".into(),
        })
        .unwrap();
        a.put_blob("f", b"contenido del archivo").unwrap();
        a.put(rec("x", 1, "{}")).unwrap();
        sync(&mut a, &mut b);
        assert_eq!(
            b.get_blob("f").unwrap().unwrap().as_slice(),
            b"contenido del archivo"
        );

        b.remove("x", 2).unwrap();
        b.remove("f", 2).unwrap();
        sync(&mut a, &mut b);
        assert!(a.get("x").unwrap().deleted);
        assert!(a.get_blob("f").unwrap().is_none());
    }

    #[test]
    fn empate_exacto_converge_igual_en_los_dos() {
        let d = tempfile::tempdir().unwrap();
        let (mut a, mut b) = (vault(&d, "a"), vault(&d, "b"));
        a.put(rec("c", 7, r#"{"t":"de a"}"#)).unwrap();
        b.put(rec("c", 7, r#"{"t":"de b"}"#)).unwrap();
        sync(&mut a, &mut b);
        assert_eq!(
            a.get("c").unwrap().data,
            b.get("c").unwrap().data,
            "en la v1 aqui divergian"
        );
    }

    #[test]
    fn lww_reglas() {
        let m = |t, d: bool, h: &str| Meta {
            updated_at: t,
            deleted: d,
            hash: h.into(),
        };
        assert!(remote_wins(&m(1, false, "a"), &m(2, false, "a")));
        assert!(!remote_wins(&m(2, false, "a"), &m(1, true, "z")));
        assert!(remote_wins(&m(1, false, "z"), &m(1, true, "a")));
        assert!(remote_wins(&m(1, false, "a"), &m(1, false, "b")));
        assert!(!remote_wins(&m(1, false, "b"), &m(1, false, "a")));
        assert!(!remote_wins(&m(1, false, "a"), &m(1, false, "a")));
    }

    #[test]
    fn mensajes_raros_se_rechazan() {
        let d = tempfile::tempdir().unwrap();
        let mut a = vault(&d, "a");
        let mut e = SyncEngine::new();
        assert_eq!(e.handle(&mut a, b"no json").err(), Some(CoreError::Format));
        assert_eq!(
            e.handle(&mut a, br#"{"t":"summary","v":99,"items":[]}"#)
                .err(),
            Some(CoreError::Protocol)
        );
        let local = br#"{"t":"push","v":1,"records":[{"id":"x","kind":"_peer","updatedAt":1,"deleted":false,"data":"{}"}]}"#;
        assert_eq!(
            e.handle(&mut a, local).err(),
            Some(CoreError::Protocol),
            "no se aceptan registros locales"
        );
        a.put(rec("y", 1, "{}")).unwrap();
        let otro_tipo = br#"{"t":"push","v":1,"records":[{"id":"y","kind":"folder","updatedAt":9,"deleted":false,"data":"{}"}]}"#;
        assert_eq!(e.handle(&mut a, otro_tipo).err(), Some(CoreError::Protocol));
        assert_eq!(a.get("y").unwrap().kind, "credential");
    }
}
