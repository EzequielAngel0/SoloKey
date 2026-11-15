//! Migracion unica de la boveda v1 (drift `vault_guard_db` v10 + `secure_files/*.enc`) al formato v2 (ADR-0009).
//!
//! Orden (si algo falla antes del ultimo paso, la v1 queda tal cual y no hay boveda v2):
//! 1. Verificar la maestra contra `verificationData` de la v1 (con su doble UTF-8).
//! 2. Copiar la v1 entera a `backup_dir` (BD, diarios, `secure_files/` y lo no secreto del almacen seguro) y
//!    comprobar la copia por hash.
//! 3. Leer la COPIA y escribir la v2 en un archivo temporal, con una DEK nueva.
//! 4. Reabrir la v2 con la maestra y comprobar que cada registro y cada archivo descifra igual que en la v1.
//! 5. Renombrar el temporal a la ruta final y, solo entonces, borrar los originales de la v1 (la copia se queda).

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use rusqlite::{Connection, OpenFlags, Row};
use serde::Deserialize;
use serde_json::{Map, Value};
use zeroize::Zeroizing;

use crate::crypto::{self, KdfParams};
use crate::error::CoreError;
use crate::v1;
use crate::vault::{self, Record, Vault};

/// Version de esquema de drift que sabe leer la migracion (la de la v1.1.0).
pub const V1_SCHEMA_VERSION: i64 = 10;

/// Donde esta la v1 en disco.
#[derive(Debug, Clone)]
pub struct V1Location {
    /// `vault_guard_db.sqlite` de drift.
    pub db: PathBuf,
    /// Carpeta `secure_files/` con los `<id>.enc`.
    pub secure_files_dir: PathBuf,
}

/// Lo que se migro.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct MigrationReport {
    pub credentials: usize,
    pub folders: usize,
    pub categories: usize,
    pub history: usize,
    pub files: usize,
    /// La v1 tenia codigo de recuperacion. El de la v1 no sirve en la v2: hay que generar uno nuevo.
    pub v1_had_recovery: bool,
    pub backup_dir: PathBuf,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct V1KdfParams {
    memory: u32,
    iterations: u32,
    parallelism: u32,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct V1MasterKeyConfig {
    salt: String,
    kdf_algorithm: String,
    kdf_params: V1KdfParams,
    verification_data: String,
}

/// Lo que se espera ver en la v2 tras convertir: para comprobarlo despues de reabrir.
struct Expected {
    records: Vec<Record>,
    files: BTreeMap<String, [u8; 32]>,
}

fn io(e: std::io::Error) -> CoreError {
    CoreError::Io(e.to_string())
}

fn with_suffix(p: &Path, suffix: &str) -> PathBuf {
    let mut s = p.as_os_str().to_owned();
    s.push(suffix);
    PathBuf::from(s)
}

/// Copia `from` a `to` y comprueba que quedo igual.
fn copy_verified(from: &Path, to: &Path) -> Result<(), CoreError> {
    fs::copy(from, to).map_err(io)?;
    let a = crypto::sha256(&fs::read(from).map_err(io)?);
    let b = crypto::sha256(&fs::read(to).map_err(io)?);
    if a != b {
        return Err(CoreError::Io(format!(
            "la copia de {} no coincide",
            from.display()
        )));
    }
    Ok(())
}

/// Copia de seguridad completa de la v1. Devuelve la ruta de la BD copiada.
fn backup(
    src: &V1Location,
    backup_dir: &Path,
    secure_storage: &BTreeMap<String, String>,
) -> Result<PathBuf, CoreError> {
    if backup_dir.exists() && fs::read_dir(backup_dir).map_err(io)?.next().is_some() {
        return Err(CoreError::AlreadyExists);
    }
    fs::create_dir_all(backup_dir).map_err(io)?;
    let db_name = src.db.file_name().ok_or(CoreError::NotFound)?;
    let db_copy = backup_dir.join(db_name);
    copy_verified(&src.db, &db_copy)?;
    for suffix in ["-wal", "-shm", "-journal"] {
        let p = with_suffix(&src.db, suffix);
        if p.exists() {
            copy_verified(&p, &with_suffix(&db_copy, suffix))?;
        }
    }
    let files_copy = backup_dir.join("secure_files");
    fs::create_dir_all(&files_copy).map_err(io)?;
    if src.secure_files_dir.exists() {
        for e in fs::read_dir(&src.secure_files_dir).map_err(io)? {
            let e = e.map_err(io)?;
            if e.file_type().map_err(io)?.is_file() {
                copy_verified(&e.path(), &files_copy.join(e.file_name()))?;
            }
        }
    }
    let json = serde_json::to_string_pretty(secure_storage).map_err(|_| CoreError::Format)?;
    fs::write(backup_dir.join("almacen_seguro.json"), json).map_err(io)?;
    Ok(db_copy)
}

fn b(row: &Row, col: &str) -> Result<Value, CoreError> {
    let v: Option<i64> = row.get(col)?;
    Ok(v.map(|x| Value::Bool(x != 0)).unwrap_or(Value::Bool(false)))
}
fn s(row: &Row, col: &str) -> Result<Value, CoreError> {
    let v: Option<String> = row.get(col)?;
    Ok(v.map(Value::String).unwrap_or(Value::Null))
}
fn i(row: &Row, col: &str) -> Result<Value, CoreError> {
    let v: Option<i64> = row.get(col)?;
    Ok(v.map(Value::from).unwrap_or(Value::Null))
}

fn decrypt_json(blob: &[u8], key: &[u8]) -> Result<Map<String, Value>, CoreError> {
    let pt = crypto::decrypt(blob, key)?;
    match serde_json::from_slice::<Value>(&pt).map_err(|_| CoreError::Format)? {
        Value::Object(m) => Ok(m),
        _ => Err(CoreError::Format),
    }
}

fn record(
    id: String,
    kind: &str,
    updated_at: i64,
    data: Map<String, Value>,
) -> Result<Record, CoreError> {
    let data = serde_json::to_string(&Value::Object(data)).map_err(|_| CoreError::Format)?;
    Ok(Record {
        id,
        kind: kind.into(),
        updated_at,
        deleted: false,
        data,
    })
}

/// Registros esperados, contenidos de los archivos (id, bytes) y conteo.
type V1Read = (Expected, Vec<(String, Zeroizing<Vec<u8>>)>, MigrationReport);

/// Lee la v1 (la copia) y arma los registros v2 y los contenidos de los archivos.
fn read_v1(db: &Path, files_dir: &Path, key: &[u8]) -> Result<V1Read, CoreError> {
    let conn = Connection::open_with_flags(db, OpenFlags::SQLITE_OPEN_READ_ONLY)?;
    let ver: i64 = conn.query_row("PRAGMA user_version", [], |r| r.get(0))?;
    if ver != V1_SCHEMA_VERSION {
        return Err(CoreError::Format);
    }
    let mut out = Vec::new();
    let mut rep = MigrationReport::default();

    // Credenciales: columnas en claro + payload descifrado, todo en un solo objeto.
    let mut st = conn.prepare("SELECT * FROM credential_entries")?;
    let mut rows = st.query([])?;
    while let Some(r) = rows.next()? {
        let id: String = r.get("id")?;
        let blob: Vec<u8> = r.get("encrypted_payload")?;
        let mut m = decrypt_json(&blob, key)?;
        let updated: i64 = r.get("updated_at")?;
        for (k, v) in [
            ("id", s(r, "id")?),
            ("type", s(r, "type")?),
            ("title", s(r, "title")?),
            ("categoryId", s(r, "category_id")?),
            ("folderId", s(r, "folder_id")?),
            ("isFavorite", b(r, "is_favorite")?),
            ("isDoubleEncrypted", b(r, "is_double_encrypted")?),
            ("isHidden", b(r, "is_hidden")?),
            ("sortOrder", i(r, "sort_order")?),
            ("createdAt", i(r, "created_at")?),
            ("updatedAt", i(r, "updated_at")?),
            ("rotationInterval", s(r, "rotation_interval")?),
            ("customRotationDays", i(r, "custom_rotation_days")?),
            ("lastRotationPromptedAt", i(r, "last_rotation_prompted_at")?),
        ] {
            m.insert(k.into(), v);
        }
        out.push(record(id, "credential", updated, m)?);
        rep.credentials += 1;
    }
    drop(rows);

    let mut st = conn.prepare("SELECT * FROM folder_entries")?;
    let mut rows = st.query([])?;
    while let Some(r) = rows.next()? {
        let id: String = r.get("id")?;
        let created: i64 = r.get("created_at")?;
        let mut m = Map::new();
        for (k, v) in [
            ("id", s(r, "id")?),
            ("parentId", s(r, "parent_id")?),
            ("name", s(r, "name")?),
            ("icon", s(r, "icon")?),
            ("colorHex", s(r, "color_hex")?),
            ("isFavorite", b(r, "is_favorite")?),
            ("createdAt", i(r, "created_at")?),
        ] {
            m.insert(k.into(), v);
        }
        out.push(record(id, "folder", created, m)?);
        rep.folders += 1;
    }
    drop(rows);

    let mut st = conn.prepare("SELECT * FROM category_entries")?;
    let mut rows = st.query([])?;
    while let Some(r) = rows.next()? {
        let id: String = r.get("id")?;
        let created: i64 = r.get("created_at")?;
        let mut m = Map::new();
        for (k, v) in [
            ("id", s(r, "id")?),
            ("name", s(r, "name")?),
            ("icon", s(r, "icon")?),
            ("createdAt", i(r, "created_at")?),
        ] {
            m.insert(k.into(), v);
        }
        out.push(record(id, "category", created, m)?);
        rep.categories += 1;
    }
    drop(rows);

    // Historial: el payload es una foto del payload de la credencial.
    let mut st = conn.prepare("SELECT * FROM password_history_entries")?;
    let mut rows = st.query([])?;
    while let Some(r) = rows.next()? {
        let id: String = r.get("id")?;
        let created: i64 = r.get("created_at")?;
        let blob: Vec<u8> = r.get("encrypted_payload")?;
        let mut m = decrypt_json(&blob, key)?;
        m.insert("id".into(), s(r, "id")?);
        m.insert("credentialId".into(), s(r, "credential_id")?);
        m.insert("createdAt".into(), i(r, "created_at")?);
        out.push(record(id, "history", created, m)?);
        rep.history += 1;
    }
    drop(rows);

    // Archivos seguros: metadatos como registro y contenido como blob con el mismo id.
    let mut contents = Vec::new();
    let mut hashes = BTreeMap::new();
    let mut st = conn.prepare("SELECT * FROM secure_file_entries")?;
    let mut rows = st.query([])?;
    while let Some(r) = rows.next()? {
        let id: String = r.get("id")?;
        let updated: i64 = r.get("updated_at")?;
        let stored: String = r.get("stored_file_name")?;
        if stored.contains(['/', '\\']) || stored.contains("..") {
            return Err(CoreError::Format);
        }
        let enc = fs::read(files_dir.join(&stored)).map_err(io)?;
        let pt = crypto::decrypt(&enc, key)?;
        let mut m = Map::new();
        for (k, v) in [
            ("id", s(r, "id")?),
            ("name", s(r, "name")?),
            ("sizeBytes", i(r, "size_bytes")?),
            ("mimeHint", s(r, "mime_hint")?),
            ("note", s(r, "note")?),
            ("folderId", s(r, "folder_id")?),
            ("isFavorite", b(r, "is_favorite")?),
            ("createdAt", i(r, "created_at")?),
            ("updatedAt", i(r, "updated_at")?),
        ] {
            m.insert(k.into(), v);
        }
        out.push(record(id.clone(), "file", updated, m)?);
        hashes.insert(id.clone(), crypto::sha256(&pt));
        contents.push((id, pt));
        rep.files += 1;
    }
    drop(rows);

    Ok((
        Expected {
            records: out,
            files: hashes,
        },
        contents,
        rep,
    ))
}

/// Comprueba que la v2 reabierta tiene exactamente lo esperado.
fn verify(v: &Vault, exp: &Expected) -> Result<(), CoreError> {
    let all = v.list(None, true);
    if all.len() != exp.records.len() {
        return Err(CoreError::Verify);
    }
    for e in &exp.records {
        let got = v.get(&e.id).ok_or(CoreError::Verify)?;
        let a: Value = serde_json::from_str(&got.data).map_err(|_| CoreError::Verify)?;
        let b: Value = serde_json::from_str(&e.data).map_err(|_| CoreError::Verify)?;
        if a != b || got.kind != e.kind || got.updated_at != e.updated_at || got.deleted {
            return Err(CoreError::Verify);
        }
    }
    for (id, h) in &exp.files {
        let got = v.get_blob(id)?.ok_or(CoreError::Verify)?;
        if &crypto::sha256(&got) != h {
            return Err(CoreError::Verify);
        }
    }
    Ok(())
}

/// Migra la v1 a una boveda v2 en `dest`.
///
/// - `master_key_config_json`: el valor `master_key_config` del almacen seguro de la v1.
/// - `secure_storage_backup`: lo NO secreto del almacen seguro que va a la copia (nunca `bio_master_key` ni llaves
///   de sync). Si trae `recovery_encrypted_master`, el informe marca `v1_had_recovery`. Lo elige quien llama.
pub fn migrate(
    src: &V1Location,
    master_key_config_json: &str,
    secure_storage_backup: &BTreeMap<String, String>,
    password: &str,
    dest: &Path,
    backup_dir: &Path,
) -> Result<MigrationReport, CoreError> {
    let cfg: V1MasterKeyConfig =
        serde_json::from_str(master_key_config_json).map_err(|_| CoreError::Format)?;
    if cfg.kdf_algorithm != "argon2id" {
        return Err(CoreError::Format);
    }
    let kdf = KdfParams {
        memory_kib: cfg.kdf_params.memory,
        iterations: cfg.kdf_params.iterations,
        parallelism: cfg.kdf_params.parallelism,
    };
    let salt = STANDARD.decode(&cfg.salt).map_err(|_| CoreError::Format)?;
    let verification = STANDARD
        .decode(&cfg.verification_data)
        .map_err(|_| CoreError::Format)?;

    // 1. Maestra
    let v1_key = v1::derive_master_key(password, &salt, kdf)?;
    if !crypto::verify_key(v1_key.as_ref(), &verification) {
        return Err(CoreError::WrongPassword);
    }
    if dest.exists() {
        return Err(CoreError::AlreadyExists);
    }
    if !src.db.exists() {
        return Err(CoreError::NotFound);
    }

    // 2. Copia previa
    let db_copy = backup(src, backup_dir, secure_storage_backup)?;

    // 3. Convertir desde la copia a un temporal
    let (expected, contents, mut report) =
        read_v1(&db_copy, &backup_dir.join("secure_files"), v1_key.as_ref())?;
    drop(v1_key);
    let tmp = with_suffix(dest, ".migrando");
    vault::wipe(&tmp)?;
    let result = (|| -> Result<(), CoreError> {
        let pw = Zeroizing::new(password.as_bytes().to_vec());
        let (mut v, _code) = Vault::create_with_key(&tmp, &pw, kdf, crypto::generate_key())?;
        v.remove_recovery()?;
        v.put_many(&expected.records)?;
        for (id, bytes) in &contents {
            v.put_blob(id, bytes)?;
        }
        drop(v);
        // 4. Verificar reabriendo con la maestra
        let v = Vault::open(&tmp, &pw)?;
        verify(&v, &expected)
    })();
    drop(contents);
    if let Err(e) = result {
        let _ = vault::wipe(&tmp);
        return Err(e);
    }

    // 5. Activar la v2 y retirar los originales de la v1 (la copia se queda en backup_dir)
    fs::rename(&tmp, dest).map_err(io)?;
    for suffix in ["", "-wal", "-shm", "-journal"] {
        let p = with_suffix(&src.db, suffix);
        if p.exists() {
            fs::remove_file(&p).map_err(io)?;
        }
    }
    if src.secure_files_dir.exists() {
        fs::remove_dir_all(&src.secure_files_dir).map_err(io)?;
    }
    report.v1_had_recovery = secure_storage_backup.contains_key("recovery_encrypted_master");
    report.backup_dir = backup_dir.to_owned();
    Ok(report)
}
