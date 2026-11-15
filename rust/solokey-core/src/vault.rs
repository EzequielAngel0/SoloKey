//! Boveda v2 (ADR-0009, NUC-2): un archivo SQLite propio del nucleo.
//!
//! - **Cabecera** (`header`, una fila): version del formato, id de la boveda, KDF y sus parametros, y la clave de
//!   la boveda (DEK, 32 bytes aleatorios) envuelta dos veces: con la clave derivada de la maestra y con la del
//!   codigo de recuperacion. Cambiar la maestra o el codigo solo re-envuelve la DEK (cierra SEC-009).
//! - **Registros** (`records`): en claro solo `id` y `version` (version del sobre, hoy 1). Tipo, fechas, carpeta,
//!   orden y datos van en un sobre JSON cifrado con la DEK; el AAD ata el blob a su id para que no se puedan
//!   intercambiar filas.
//! - **Contenidos** (`blobs`): bytes de los archivos seguros, cifrados con la DEK y atados a su id.
//!
//! Al abrir, todos los sobres se descifran a un indice en RAM (`Zeroizing`); al soltar la boveda se pone a cero.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use base64::engine::general_purpose::STANDARD_NO_PAD;
use base64::Engine;
use rusqlite::{params, Connection, OpenFlags, OptionalExtension};
use serde::{Deserialize, Serialize};
use serde_json::value::RawValue;
use zeroize::Zeroizing;

use crate::crypto::{self, KdfParams, SecretKey, KEY_LEN};
use crate::error::CoreError;

/// Version del formato de archivo.
pub const FORMAT_VERSION: i64 = 2;
/// Version del sobre de cada registro.
pub const ENVELOPE_VERSION: i64 = 1;
/// `PRAGMA application_id` del archivo: "SKV2".
pub const APPLICATION_ID: i64 = 0x534B_5632;
/// Nombre del archivo dentro del directorio de datos.
pub const FILE_NAME: &str = "solokey.vault";
/// Texto que prueba la DEK al abrir con la clave (biometria) en vez de la maestra.
const KEY_CHECK: &[u8] = b"SoloKey::v2::key";

const SCHEMA: &str = "
CREATE TABLE header (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  format_version INTEGER NOT NULL,
  vault_id TEXT NOT NULL,
  kdf TEXT NOT NULL,
  kdf_memory_kib INTEGER NOT NULL,
  kdf_iterations INTEGER NOT NULL,
  kdf_parallelism INTEGER NOT NULL,
  kdf_salt BLOB NOT NULL,
  key_by_master BLOB NOT NULL,
  key_by_recovery BLOB,
  key_check BLOB NOT NULL
);
CREATE TABLE records (
  id TEXT PRIMARY KEY NOT NULL,
  version INTEGER NOT NULL,
  data BLOB NOT NULL
) WITHOUT ROWID;
CREATE TABLE blobs (
  id TEXT PRIMARY KEY NOT NULL,
  data BLOB NOT NULL
) WITHOUT ROWID;
";

/// Un registro tal como lo ve quien usa el nucleo. `data` es JSON (el de la entidad de Dart); `kind` lo decide
/// quien escribe (`credential`, `folder`, `category`, `history`, `file`...).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Record {
    pub id: String,
    pub kind: String,
    /// Milisegundos desde epoch (UTC). Es lo que usa la sync (gana la ultima escritura).
    pub updated_at: i64,
    /// Lapida: borrado que la sync tiene que propagar.
    pub deleted: bool,
    pub data: String,
}

#[derive(Serialize)]
struct EnvelopeOut<'a> {
    kind: &'a str,
    #[serde(rename = "updatedAt")]
    updated_at: i64,
    deleted: bool,
    data: &'a RawValue,
}

#[derive(Deserialize)]
struct EnvelopeIn<'a> {
    kind: String,
    #[serde(rename = "updatedAt")]
    updated_at: i64,
    deleted: bool,
    #[serde(borrow)]
    data: &'a RawValue,
}

struct Entry {
    kind: String,
    updated_at: i64,
    deleted: bool,
    data: Zeroizing<String>,
}

impl Entry {
    fn to_record(&self, id: &str) -> Record {
        Record {
            id: id.to_owned(),
            kind: self.kind.clone(),
            updated_at: self.updated_at,
            deleted: self.deleted,
            data: self.data.as_str().to_owned(),
        }
    }
}

/// Cabecera en claro (no contiene secretos).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Header {
    pub format_version: i64,
    pub vault_id: String,
    pub kdf: KdfParams,
    pub salt: Vec<u8>,
    pub has_recovery: bool,
}

/// Boveda abierta. Guarda la DEK y el indice descifrado; todo se pone a cero al soltarla.
pub struct Vault {
    path: PathBuf,
    conn: Connection,
    header: Header,
    key: SecretKey,
    index: BTreeMap<String, Entry>,
}

fn aad_dek(vault_id: &str, by: &str) -> Vec<u8> {
    format!("solokey:v2:dek:{by}:{vault_id}").into_bytes()
}
fn aad_check(vault_id: &str) -> Vec<u8> {
    format!("solokey:v2:check:{vault_id}").into_bytes()
}
fn aad_record(id: &str, version: i64) -> Vec<u8> {
    format!("solokey:v2:rec:{version}:{id}").into_bytes()
}
fn aad_blob(id: &str) -> Vec<u8> {
    format!("solokey:v2:blob:{id}").into_bytes()
}

/// Codigo de recuperacion legible: base64 sin `=` en grupos de 4 con guiones (como la v1).
pub fn format_recovery_code(key: &[u8]) -> String {
    let raw = Zeroizing::new(STANDARD_NO_PAD.encode(key));
    let chars: Vec<char> = raw.chars().collect();
    chars
        .chunks(4)
        .map(|c| c.iter().collect::<String>())
        .collect::<Vec<_>>()
        .join("-")
}

/// Ruta del archivo de boveda dentro del directorio de datos.
pub fn vault_path(data_dir: &Path) -> PathBuf {
    data_dir.join(FILE_NAME)
}

/// Borra el archivo de boveda y sus diarios de SQLite. No falla si no existen.
pub fn wipe(path: &Path) -> Result<(), CoreError> {
    for suffix in ["", "-journal", "-wal", "-shm"] {
        let mut p = path.as_os_str().to_owned();
        p.push(suffix);
        match std::fs::remove_file(PathBuf::from(p)) {
            Ok(()) => {}
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(e) => return Err(CoreError::Io(e.to_string())),
        }
    }
    Ok(())
}

fn configure(conn: &Connection) -> Result<(), CoreError> {
    conn.execute_batch(
        "PRAGMA secure_delete = ON; PRAGMA foreign_keys = ON; PRAGMA synchronous = FULL;",
    )?;
    Ok(())
}

/// Lee la cabecera sin abrir la boveda. `None` si el archivo no es una boveda v2.
pub fn read_header(path: &Path) -> Result<Option<Header>, CoreError> {
    if !path.exists() {
        return Ok(None);
    }
    let conn = Connection::open_with_flags(path, OpenFlags::SQLITE_OPEN_READ_ONLY)?;
    read_header_conn(&conn)
}

fn read_header_conn(conn: &Connection) -> Result<Option<Header>, CoreError> {
    let app_id: i64 = conn.query_row("PRAGMA application_id", [], |r| r.get(0))?;
    if app_id != APPLICATION_ID {
        return Ok(None);
    }
    let h = conn
        .query_row(
            "SELECT format_version, vault_id, kdf, kdf_memory_kib, kdf_iterations, kdf_parallelism, kdf_salt,
                    key_by_recovery IS NOT NULL FROM header WHERE id = 1",
            [],
            |r| {
                Ok((
                    r.get::<_, i64>(0)?,
                    r.get::<_, String>(1)?,
                    r.get::<_, String>(2)?,
                    r.get::<_, u32>(3)?,
                    r.get::<_, u32>(4)?,
                    r.get::<_, u32>(5)?,
                    r.get::<_, Vec<u8>>(6)?,
                    r.get::<_, bool>(7)?,
                ))
            },
        )
        .optional()?;
    let Some((format_version, vault_id, kdf, m, t, p, salt, has_recovery)) = h else {
        return Err(CoreError::Format);
    };
    if kdf != "argon2id" {
        return Err(CoreError::Format);
    }
    if format_version > FORMAT_VERSION {
        return Err(CoreError::NewerFormat);
    }
    Ok(Some(Header {
        format_version,
        vault_id,
        kdf: KdfParams {
            memory_kib: m,
            iterations: t,
            parallelism: p,
        },
        salt,
        has_recovery,
    }))
}

fn new_vault_id() -> String {
    let b = crypto::random_bytes(16);
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn to_key(bytes: &[u8]) -> Result<SecretKey, CoreError> {
    if bytes.len() != KEY_LEN {
        return Err(CoreError::KeyLength);
    }
    let mut k = Zeroizing::new([0u8; KEY_LEN]);
    k.copy_from_slice(bytes);
    Ok(k)
}

impl Vault {
    /// Crea una boveda nueva en `path` (no debe existir). Devuelve la boveda abierta y el codigo de recuperacion,
    /// que se muestra UNA vez y no se guarda en ningun lado.
    pub fn create(
        path: &Path,
        password: &[u8],
        kdf: KdfParams,
    ) -> Result<(Vault, Zeroizing<String>), CoreError> {
        let dek = crypto::generate_key();
        let (vault, code) = Self::create_with_key(path, password, kdf, dek)?;
        Ok((vault, code))
    }

    /// Como [`Vault::create`] con una DEK dada (la migracion la usa para escribir en un archivo temporal).
    pub(crate) fn create_with_key(
        path: &Path,
        password: &[u8],
        kdf: KdfParams,
        dek: SecretKey,
    ) -> Result<(Vault, Zeroizing<String>), CoreError> {
        if path.exists() {
            return Err(CoreError::AlreadyExists);
        }
        if let Some(dir) = path.parent() {
            std::fs::create_dir_all(dir).map_err(|e| CoreError::Io(e.to_string()))?;
        }
        let salt = crypto::generate_salt();
        let kek = crypto::derive_key(password, &salt, kdf)?;
        let recovery = crypto::generate_key();
        let vault_id = new_vault_id();

        let key_by_master =
            crypto::encrypt_with_aad(dek.as_ref(), kek.as_ref(), &aad_dek(&vault_id, "master"))?;
        let key_by_recovery = crypto::encrypt_with_aad(
            dek.as_ref(),
            recovery.as_ref(),
            &aad_dek(&vault_id, "recovery"),
        )?;
        let key_check = crypto::encrypt_with_aad(KEY_CHECK, dek.as_ref(), &aad_check(&vault_id))?;

        let conn = Connection::open(path)?;
        configure(&conn)?;
        let r = (|| -> Result<(), CoreError> {
            conn.execute_batch(&format!(
                "PRAGMA application_id = {APPLICATION_ID}; PRAGMA user_version = {FORMAT_VERSION};"
            ))?;
            conn.execute_batch(SCHEMA)?;
            conn.execute(
                "INSERT INTO header (id, format_version, vault_id, kdf, kdf_memory_kib, kdf_iterations,
                   kdf_parallelism, kdf_salt, key_by_master, key_by_recovery, key_check)
                 VALUES (1, ?1, ?2, 'argon2id', ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
                params![
                    FORMAT_VERSION,
                    vault_id,
                    kdf.memory_kib,
                    kdf.iterations,
                    kdf.parallelism,
                    salt.as_slice(),
                    key_by_master,
                    key_by_recovery,
                    key_check
                ],
            )?;
            Ok(())
        })();
        if let Err(e) = r {
            drop(conn);
            let _ = wipe(path);
            return Err(e);
        }
        let header = Header {
            format_version: FORMAT_VERSION,
            vault_id,
            kdf,
            salt: salt.to_vec(),
            has_recovery: true,
        };
        let code = Zeroizing::new(format_recovery_code(recovery.as_ref()));
        Ok((
            Vault {
                path: path.to_owned(),
                conn,
                header,
                key: dek,
                index: BTreeMap::new(),
            },
            code,
        ))
    }

    /// Abre con la maestra. `WrongPassword` si no corresponde.
    pub fn open(path: &Path, password: &[u8]) -> Result<Vault, CoreError> {
        let (conn, header) = Self::connect(path)?;
        let kek = crypto::derive_key(password, &header.salt, header.kdf)?;
        let wrapped: Vec<u8> =
            conn.query_row("SELECT key_by_master FROM header WHERE id = 1", [], |r| {
                r.get(0)
            })?;
        let dek =
            crypto::decrypt_with_aad(&wrapped, kek.as_ref(), &aad_dek(&header.vault_id, "master"))
                .map_err(|_| CoreError::WrongPassword)?;
        Self::finish_open(path, conn, header, to_key(&dek)?)
    }

    /// Abre con la DEK (la que guarda la biometria). `WrongPassword` si no es la de esta boveda.
    pub fn open_with_key(path: &Path, key: &[u8]) -> Result<Vault, CoreError> {
        let (conn, header) = Self::connect(path)?;
        let check: Vec<u8> =
            conn.query_row("SELECT key_check FROM header WHERE id = 1", [], |r| {
                r.get(0)
            })?;
        let ok = crypto::decrypt_with_aad(&check, key, &aad_check(&header.vault_id))
            .map(|pt| pt.as_slice() == KEY_CHECK)
            .unwrap_or(false);
        if !ok {
            return Err(CoreError::WrongPassword);
        }
        Self::finish_open(path, conn, header, to_key(key)?)
    }

    /// Abre con el codigo de recuperacion y pone una maestra nueva. No re-cifra registros: solo re-envuelve la DEK.
    pub fn recover(
        path: &Path,
        code: &str,
        new_password: &[u8],
        kdf: KdfParams,
    ) -> Result<Vault, CoreError> {
        let (conn, header) = Self::connect(path)?;
        let rk = crate::v1::recovery_code_key(code).map_err(|_| CoreError::WrongPassword)?;
        let wrapped: Option<Vec<u8>> =
            conn.query_row("SELECT key_by_recovery FROM header WHERE id = 1", [], |r| {
                r.get(0)
            })?;
        let wrapped = wrapped.ok_or(CoreError::NoRecovery)?;
        let dek = crypto::decrypt_with_aad(
            &wrapped,
            rk.as_ref(),
            &aad_dek(&header.vault_id, "recovery"),
        )
        .map_err(|_| CoreError::WrongPassword)?;
        let mut v = Self::finish_open(path, conn, header, to_key(&dek)?)?;
        v.change_password(new_password, kdf)?;
        Ok(v)
    }

    fn connect(path: &Path) -> Result<(Connection, Header), CoreError> {
        if !path.exists() {
            return Err(CoreError::NotFound);
        }
        let conn = Connection::open_with_flags(path, OpenFlags::SQLITE_OPEN_READ_WRITE)?;
        configure(&conn)?;
        let header = read_header_conn(&conn)?.ok_or(CoreError::Format)?;
        Ok((conn, header))
    }

    fn finish_open(
        path: &Path,
        conn: Connection,
        header: Header,
        key: SecretKey,
    ) -> Result<Vault, CoreError> {
        let mut index = BTreeMap::new();
        {
            let mut stmt = conn.prepare("SELECT id, version, data FROM records")?;
            let mut rows = stmt.query([])?;
            while let Some(row) = rows.next()? {
                let id: String = row.get(0)?;
                let version: i64 = row.get(1)?;
                if version > ENVELOPE_VERSION {
                    return Err(CoreError::NewerFormat);
                }
                let blob: Vec<u8> = row.get(2)?;
                let pt = crypto::decrypt_with_aad(&blob, key.as_ref(), &aad_record(&id, version))?;
                let env: EnvelopeIn = serde_json::from_slice(&pt).map_err(|_| CoreError::Format)?;
                index.insert(
                    id,
                    Entry {
                        kind: env.kind,
                        updated_at: env.updated_at,
                        deleted: env.deleted,
                        data: Zeroizing::new(env.data.get().to_owned()),
                    },
                );
            }
        }
        Ok(Vault {
            path: path.to_owned(),
            conn,
            header,
            key,
            index,
        })
    }

    pub fn header(&self) -> &Header {
        &self.header
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    /// Copia de la DEK, para guardarla tras la biometria. Quien la recibe la borra.
    pub fn key_copy(&self) -> SecretKey {
        Zeroizing::new(*self.key)
    }

    /// Registros, en orden de id. `kind = None` trae todos; las lapidas solo con `include_deleted`.
    pub fn list(&self, kind: Option<&str>, include_deleted: bool) -> Vec<Record> {
        self.index
            .iter()
            .filter(|(_, e)| kind.is_none_or(|k| e.kind == k) && (include_deleted || !e.deleted))
            .map(|(id, e)| e.to_record(id))
            .collect()
    }

    /// Un registro (tambien si es lapida).
    pub fn get(&self, id: &str) -> Option<Record> {
        self.index.get(id).map(|e| e.to_record(id))
    }

    /// Escribe (inserta o reemplaza) uno o varios registros en una transaccion.
    pub fn put_many(&mut self, records: &[Record]) -> Result<(), CoreError> {
        let mut staged = Vec::with_capacity(records.len());
        for r in records {
            if r.id.is_empty() || r.kind.is_empty() {
                return Err(CoreError::Format);
            }
            let data = RawValue::from_string(r.data.clone()).map_err(|_| CoreError::Format)?;
            let env = Zeroizing::new(
                serde_json::to_vec(&EnvelopeOut {
                    kind: &r.kind,
                    updated_at: r.updated_at,
                    deleted: r.deleted,
                    data: &data,
                })
                .map_err(|_| CoreError::Format)?,
            );
            let blob = crypto::encrypt_with_aad(
                &env,
                self.key.as_ref(),
                &aad_record(&r.id, ENVELOPE_VERSION),
            )?;
            staged.push((r, blob));
        }
        let tx = self.conn.transaction()?;
        for (r, blob) in &staged {
            tx.execute(
                "INSERT INTO records (id, version, data) VALUES (?1, ?2, ?3)
                 ON CONFLICT(id) DO UPDATE SET version = excluded.version, data = excluded.data",
                params![r.id, ENVELOPE_VERSION, blob],
            )?;
        }
        tx.commit()?;
        for (r, _) in staged {
            self.index.insert(
                r.id.clone(),
                Entry {
                    kind: r.kind.clone(),
                    updated_at: r.updated_at,
                    deleted: r.deleted,
                    data: Zeroizing::new(r.data.clone()),
                },
            );
        }
        Ok(())
    }

    pub fn put(&mut self, record: Record) -> Result<(), CoreError> {
        self.put_many(std::slice::from_ref(&record))
    }

    /// Deja una lapida (para que la sync propague el borrado) y borra su contenido si lo tenia.
    pub fn remove(&mut self, id: &str, at: i64) -> Result<(), CoreError> {
        let Some(kind) = self.index.get(id).map(|e| e.kind.clone()) else {
            return Ok(());
        };
        self.put(Record {
            id: id.to_owned(),
            kind,
            updated_at: at,
            deleted: true,
            data: "null".into(),
        })?;
        self.delete_blob(id)
    }

    /// Borra un registro sin dejar rastro (sin lapida).
    pub fn purge(&mut self, id: &str) -> Result<(), CoreError> {
        self.conn
            .execute("DELETE FROM records WHERE id = ?1", params![id])?;
        self.index.remove(id);
        self.delete_blob(id)
    }

    /// Borra todos los registros y contenidos (la boveda queda vacia, con la misma maestra).
    pub fn clear(&mut self) -> Result<(), CoreError> {
        self.conn
            .execute_batch("DELETE FROM records; DELETE FROM blobs;")?;
        self.index.clear();
        Ok(())
    }

    /// Guarda el contenido cifrado de un archivo seguro.
    pub fn put_blob(&mut self, id: &str, bytes: &[u8]) -> Result<(), CoreError> {
        let blob = crypto::encrypt_with_aad(bytes, self.key.as_ref(), &aad_blob(id))?;
        self.conn.execute(
            "INSERT INTO blobs (id, data) VALUES (?1, ?2) ON CONFLICT(id) DO UPDATE SET data = excluded.data",
            params![id, blob],
        )?;
        Ok(())
    }

    /// Contenido descifrado de un archivo seguro, o `None` si no existe.
    pub fn get_blob(&self, id: &str) -> Result<Option<Zeroizing<Vec<u8>>>, CoreError> {
        let blob: Option<Vec<u8>> = self
            .conn
            .query_row("SELECT data FROM blobs WHERE id = ?1", params![id], |r| {
                r.get(0)
            })
            .optional()?;
        blob.map(|b| crypto::decrypt_with_aad(&b, self.key.as_ref(), &aad_blob(id)))
            .transpose()
    }

    pub fn delete_blob(&mut self, id: &str) -> Result<(), CoreError> {
        self.conn
            .execute("DELETE FROM blobs WHERE id = ?1", params![id])?;
        Ok(())
    }

    /// Cambia la maestra (sal nueva). Solo re-envuelve la DEK.
    pub fn change_password(
        &mut self,
        new_password: &[u8],
        kdf: KdfParams,
    ) -> Result<(), CoreError> {
        let salt = crypto::generate_salt();
        let kek = crypto::derive_key(new_password, &salt, kdf)?;
        let wrapped = crypto::encrypt_with_aad(
            self.key.as_ref(),
            kek.as_ref(),
            &aad_dek(&self.header.vault_id, "master"),
        )?;
        self.conn.execute(
            "UPDATE header SET kdf_memory_kib = ?1, kdf_iterations = ?2, kdf_parallelism = ?3, kdf_salt = ?4,
               key_by_master = ?5 WHERE id = 1",
            params![kdf.memory_kib, kdf.iterations, kdf.parallelism, salt.as_slice(), wrapped],
        )?;
        self.header.kdf = kdf;
        self.header.salt = salt.to_vec();
        Ok(())
    }

    /// Genera un codigo de recuperacion nuevo (el anterior deja de servir). Se muestra una vez.
    pub fn reset_recovery(&mut self) -> Result<Zeroizing<String>, CoreError> {
        let rk = crypto::generate_key();
        let wrapped = crypto::encrypt_with_aad(
            self.key.as_ref(),
            rk.as_ref(),
            &aad_dek(&self.header.vault_id, "recovery"),
        )?;
        self.conn.execute(
            "UPDATE header SET key_by_recovery = ?1 WHERE id = 1",
            params![wrapped],
        )?;
        self.header.has_recovery = true;
        Ok(Zeroizing::new(format_recovery_code(rk.as_ref())))
    }

    /// Quita el codigo de recuperacion.
    pub fn remove_recovery(&mut self) -> Result<(), CoreError> {
        self.conn
            .execute("UPDATE header SET key_by_recovery = NULL WHERE id = 1", [])?;
        self.header.has_recovery = false;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    pub(crate) fn fast() -> KdfParams {
        KdfParams {
            memory_kib: 64,
            iterations: 1,
            parallelism: 1,
        }
    }

    fn tmp() -> (tempfile::TempDir, PathBuf) {
        let d = tempfile::tempdir().unwrap();
        let p = vault_path(d.path());
        (d, p)
    }

    fn rec(id: &str, kind: &str, t: i64, data: &str) -> Record {
        Record {
            id: id.into(),
            kind: kind.into(),
            updated_at: t,
            deleted: false,
            data: data.into(),
        }
    }

    #[test]
    fn crea_escribe_cierra_y_reabre() {
        let (_d, p) = tmp();
        let (mut v, code) = Vault::create(&p, b"maestra", fast()).unwrap();
        assert_eq!(code.len(), 43 + 10); // 43 caracteres en 11 grupos
        v.put(rec(
            "a",
            "credential",
            10,
            r#"{"title":"Banco","password":"s3cr3t"}"#,
        ))
        .unwrap();
        v.put(rec("b", "folder", 11, r#"{"name":"Trabajo"}"#))
            .unwrap();
        v.put_blob("b", b"contenido").unwrap();
        drop(v);

        let v = Vault::open(&p, b"maestra").unwrap();
        assert_eq!(v.list(None, false).len(), 2);
        assert_eq!(
            v.list(Some("credential"), false)[0].data,
            r#"{"title":"Banco","password":"s3cr3t"}"#
        );
        assert_eq!(v.get_blob("b").unwrap().unwrap().as_slice(), b"contenido");
        assert_eq!(v.header().format_version, FORMAT_VERSION);
    }

    #[test]
    fn maestra_equivocada() {
        let (_d, p) = tmp();
        Vault::create(&p, b"maestra", fast()).unwrap();
        assert_eq!(
            Vault::open(&p, b"otra").err(),
            Some(CoreError::WrongPassword)
        );
    }

    #[test]
    fn en_disco_no_hay_nada_en_claro() {
        let (_d, p) = tmp();
        let (mut v, _) = Vault::create(&p, b"maestra", fast()).unwrap();
        v.put(rec(
            "id-1",
            "credential",
            1_767_323_645_000,
            r#"{"title":"TITULO-VISIBLE"}"#,
        ))
        .unwrap();
        v.put_blob("id-1", b"CONTENIDO-VISIBLE").unwrap();
        drop(v);
        let raw = std::fs::read(&p).unwrap();
        let has = |needle: &[u8]| raw.windows(needle.len()).any(|w| w == needle);
        assert!(!has(b"TITULO-VISIBLE"));
        assert!(!has(b"CONTENIDO-VISIBLE"));
        assert!(!has(b"credential"));
        assert!(!has(b"1767323645000"));
        assert!(has(b"id-1"), "el id si va en claro");
    }

    #[test]
    fn filas_intercambiadas_no_se_abren() {
        let (_d, p) = tmp();
        let (mut v, _) = Vault::create(&p, b"maestra", fast()).unwrap();
        v.put(rec("a", "credential", 1, r#"{"x":1}"#)).unwrap();
        v.put(rec("b", "credential", 1, r#"{"x":2}"#)).unwrap();
        drop(v);
        let c = Connection::open(&p).unwrap();
        c.execute_batch(
            "UPDATE records SET data = (SELECT data FROM records WHERE id = 'b') WHERE id = 'a';",
        )
        .unwrap();
        drop(c);
        assert_eq!(Vault::open(&p, b"maestra").err(), Some(CoreError::Decrypt));
    }

    #[test]
    fn lapida_purga_y_limpieza() {
        let (_d, p) = tmp();
        let (mut v, _) = Vault::create(&p, b"maestra", fast()).unwrap();
        v.put(rec("a", "file", 1, "{}")).unwrap();
        v.put_blob("a", b"x").unwrap();
        v.remove("a", 5).unwrap();
        assert!(v.list(None, false).is_empty());
        let t = v.get("a").unwrap();
        assert!(t.deleted && t.updated_at == 5 && t.kind == "file");
        assert!(v.get_blob("a").unwrap().is_none());
        v.purge("a").unwrap();
        assert!(v.get("a").is_none());
        v.put(rec("b", "file", 1, "{}")).unwrap();
        v.clear().unwrap();
        drop(v);
        assert!(Vault::open(&p, b"maestra")
            .unwrap()
            .list(None, true)
            .is_empty());
    }

    #[test]
    fn cambiar_maestra_y_abrir_con_clave() {
        let (_d, p) = tmp();
        let (mut v, _) = Vault::create(&p, b"vieja", fast()).unwrap();
        v.put(rec("a", "credential", 1, "{}")).unwrap();
        let key = v.key_copy();
        v.change_password(b"nueva", fast()).unwrap();
        drop(v);
        assert_eq!(
            Vault::open(&p, b"vieja").err(),
            Some(CoreError::WrongPassword)
        );
        assert_eq!(
            Vault::open(&p, b"nueva").unwrap().list(None, false).len(),
            1
        );
        assert_eq!(
            Vault::open_with_key(&p, key.as_ref())
                .unwrap()
                .list(None, false)
                .len(),
            1
        );
        assert_eq!(
            Vault::open_with_key(&p, &[7u8; 32]).err(),
            Some(CoreError::WrongPassword)
        );
    }

    /// SEC-009: recuperar NO deja la boveda ilegible; la DEK es fija y el codigo solo la envuelve.
    #[test]
    fn recuperar_con_codigo_conserva_los_datos() {
        let (_d, p) = tmp();
        let (mut v, code) = Vault::create(&p, b"olvidada", fast()).unwrap();
        v.put(rec("a", "credential", 1, r#"{"p":"x"}"#)).unwrap();
        drop(v);
        assert_eq!(
            Vault::recover(&p, "AAAA-BBBB", b"n", fast()).err(),
            Some(CoreError::WrongPassword)
        );
        let v = Vault::recover(&p, &code, b"nueva", fast()).unwrap();
        assert_eq!(v.get("a").unwrap().data, r#"{"p":"x"}"#);
        drop(v);
        assert_eq!(
            Vault::open(&p, b"nueva").unwrap().get("a").unwrap().data,
            r#"{"p":"x"}"#
        );
        assert_eq!(
            Vault::open(&p, b"olvidada").err(),
            Some(CoreError::WrongPassword)
        );
    }

    #[test]
    fn codigo_nuevo_invalida_el_anterior_y_se_puede_quitar() {
        let (_d, p) = tmp();
        let (mut v, viejo) = Vault::create(&p, b"m", fast()).unwrap();
        let nuevo = v.reset_recovery().unwrap();
        drop(v);
        assert!(Vault::recover(&p, &viejo, b"m", fast()).is_err());
        let mut v = Vault::recover(&p, &nuevo, b"m", fast()).unwrap();
        v.remove_recovery().unwrap();
        drop(v);
        assert_eq!(
            Vault::recover(&p, &nuevo, b"m", fast()).err(),
            Some(CoreError::NoRecovery)
        );
    }

    #[test]
    fn no_pisa_una_boveda_ni_abre_lo_que_no_es() {
        let (d, p) = tmp();
        Vault::create(&p, b"m", fast()).unwrap();
        assert_eq!(
            Vault::create(&p, b"m", fast()).err(),
            Some(CoreError::AlreadyExists)
        );
        let otra = d.path().join("otra.sqlite");
        Connection::open(&otra)
            .unwrap()
            .execute_batch("CREATE TABLE t(x);")
            .unwrap();
        assert!(read_header(&otra).unwrap().is_none());
        assert_eq!(Vault::open(&otra, b"m").err(), Some(CoreError::Format));
        assert_eq!(
            Vault::open(&d.path().join("no"), b"m").err(),
            Some(CoreError::NotFound)
        );
    }

    #[test]
    fn formato_mas_nuevo_se_rechaza() {
        let (_d, p) = tmp();
        Vault::create(&p, b"m", fast()).unwrap();
        Connection::open(&p)
            .unwrap()
            .execute("UPDATE header SET format_version = 3", [])
            .unwrap();
        assert_eq!(Vault::open(&p, b"m").err(), Some(CoreError::NewerFormat));
    }

    #[test]
    fn datos_que_no_son_json_se_rechazan() {
        let (_d, p) = tmp();
        let (mut v, _) = Vault::create(&p, b"m", fast()).unwrap();
        assert_eq!(
            v.put(rec("a", "credential", 1, "{no json")).err(),
            Some(CoreError::Format)
        );
        assert_eq!(
            v.put(rec("", "credential", 1, "{}")).err(),
            Some(CoreError::Format)
        );
    }

    #[test]
    fn borrar_la_boveda() {
        let (_d, p) = tmp();
        Vault::create(&p, b"m", fast()).unwrap();
        wipe(&p).unwrap();
        assert!(!p.exists());
        wipe(&p).unwrap();
    }
}
