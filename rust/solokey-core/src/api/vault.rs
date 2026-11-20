//! Boveda v2 para Flutter (NUC-2): crear, abrir, leer y escribir registros, archivos, recuperacion y migracion.
//!
//! `data_dir` es el directorio de datos que decide Flutter (NUC-6): el real del sistema o uno aislado para las
//! pruebas E2E. El nucleo nunca adivina rutas.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::sync::Mutex;

use flutter_rust_bridge::frb;
use zeroize::Zeroizing;

use crate::api::error::CoreFailure;
use crate::crypto::KdfParams;
use crate::error::CoreError;
use crate::migrate_v1::{self, V1Location};
use crate::vault::{self, Record, Vault};

/// Un registro de la boveda. `data` es el JSON de la entidad.
#[derive(Debug, Clone)]
pub struct VaultRecord {
    pub id: String,
    pub kind: String,
    pub updated_at: i64,
    pub deleted: bool,
    pub data: String,
}

impl From<Record> for VaultRecord {
    fn from(r: Record) -> Self {
        VaultRecord {
            id: r.id,
            kind: r.kind,
            updated_at: r.updated_at,
            deleted: r.deleted,
            data: r.data,
        }
    }
}

impl From<VaultRecord> for Record {
    fn from(r: VaultRecord) -> Self {
        Record {
            id: r.id,
            kind: r.kind,
            updated_at: r.updated_at,
            deleted: r.deleted,
            data: r.data,
        }
    }
}

/// Parametros de Argon2id (KiB, iteraciones, paralelismo).
#[derive(Debug, Clone, Copy)]
pub struct KdfConfig {
    pub memory_kib: u32,
    pub iterations: u32,
    pub parallelism: u32,
}

impl From<KdfConfig> for KdfParams {
    fn from(k: KdfConfig) -> Self {
        KdfParams {
            memory_kib: k.memory_kib,
            iterations: k.iterations,
            parallelism: k.parallelism,
        }
    }
}

/// Lo que hay en un directorio de datos.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VaultState {
    /// No hay boveda v2.
    Missing,
    /// Hay boveda v2.
    Present,
}

/// Lo que dejo la migracion.
#[derive(Debug, Clone)]
pub struct MigrationSummary {
    pub credentials: u32,
    pub folders: u32,
    pub categories: u32,
    pub history: u32,
    pub files: u32,
    pub v1_had_recovery: bool,
    pub backup_dir: String,
}

/// Boveda abierta. `close` la pone a cero; despues cualquier llamada falla con "boveda cerrada".
#[frb(opaque)]
pub struct VaultHandle {
    inner: Mutex<Option<Vault>>,
}

/// Una boveda recien creada y su codigo de recuperacion (mostrarlo una vez).
#[frb(non_opaque)]
pub struct CreatedVault {
    pub vault: VaultHandle,
    pub recovery_code: String,
}

fn closed() -> CoreFailure {
    CoreFailure::closed()
}

fn path(data_dir: &str) -> PathBuf {
    vault::vault_path(Path::new(data_dir))
}

fn handle(v: Vault) -> VaultHandle {
    VaultHandle {
        inner: Mutex::new(Some(v)),
    }
}

/// Si hay boveda v2 en `data_dir`.
pub fn vault_state(data_dir: String) -> Result<VaultState, CoreFailure> {
    Ok(match vault::read_header(&path(&data_dir))? {
        Some(_) => VaultState::Present,
        None => VaultState::Missing,
    })
}

/// Crea una boveda nueva.
pub fn vault_create(
    data_dir: String,
    password: Vec<u8>,
    kdf: KdfConfig,
) -> Result<CreatedVault, CoreFailure> {
    let password = Zeroizing::new(password);
    let (v, code) = Vault::create(&path(&data_dir), &password, kdf.into())?;
    Ok(CreatedVault {
        vault: handle(v),
        recovery_code: code.as_str().to_owned(),
    })
}

/// Abre con la maestra (`utf8.encode` de lo tecleado).
pub fn vault_open(data_dir: String, password: Vec<u8>) -> Result<VaultHandle, CoreFailure> {
    let password = Zeroizing::new(password);
    Ok(handle(Vault::open(&path(&data_dir), &password)?))
}

/// Abre con la clave guardada tras la biometria.
pub fn vault_open_with_key(data_dir: String, key: Vec<u8>) -> Result<VaultHandle, CoreFailure> {
    let key = Zeroizing::new(key);
    Ok(handle(Vault::open_with_key(&path(&data_dir), &key)?))
}

/// Abre con el codigo de recuperacion y pone una maestra nueva.
pub fn vault_recover(
    data_dir: String,
    recovery_code: String,
    new_password: Vec<u8>,
    kdf: KdfConfig,
) -> Result<VaultHandle, CoreFailure> {
    let (code, new_password) = (Zeroizing::new(recovery_code), Zeroizing::new(new_password));
    Ok(handle(Vault::recover(
        &path(&data_dir),
        &code,
        &new_password,
        kdf.into(),
    )?))
}

/// Comprueba el codigo de recuperacion sin cambiar nada; `wrongPassword` si no sirve, `noRecovery` si no hay.
pub fn vault_check_recovery(data_dir: String, recovery_code: String) -> Result<(), CoreFailure> {
    let code = Zeroizing::new(recovery_code);
    Ok(Vault::check_recovery(&path(&data_dir), &code)?)
}

/// Borra la boveda del directorio (el archivo y sus diarios).
pub fn vault_wipe(data_dir: String) -> Result<(), CoreFailure> {
    Ok(vault::wipe(&path(&data_dir))?)
}

/// Migra la v1 a `data_dir`. Ver `migrate_v1::migrate`.
#[allow(clippy::too_many_arguments)]
pub fn migrate_from_v1(
    v1_db_path: String,
    v1_secure_files_dir: String,
    master_key_config_json: String,
    secure_storage_backup: Vec<(String, String)>,
    password: String,
    data_dir: String,
    backup_dir: String,
) -> Result<MigrationSummary, CoreFailure> {
    let password = Zeroizing::new(password);
    let src = V1Location {
        db: PathBuf::from(v1_db_path),
        secure_files_dir: PathBuf::from(v1_secure_files_dir),
    };
    let backup: BTreeMap<String, String> = secure_storage_backup.into_iter().collect();
    let r = migrate_v1::migrate(
        &src,
        &master_key_config_json,
        &backup,
        &password,
        &path(&data_dir),
        Path::new(&backup_dir),
    )?;
    Ok(MigrationSummary {
        credentials: r.credentials as u32,
        folders: r.folders as u32,
        categories: r.categories as u32,
        history: r.history as u32,
        files: r.files as u32,
        v1_had_recovery: r.v1_had_recovery,
        backup_dir: r.backup_dir.to_string_lossy().into_owned(),
    })
}

impl VaultHandle {
    fn with<T>(
        &self,
        f: impl FnOnce(&mut Vault) -> Result<T, CoreError>,
    ) -> Result<T, CoreFailure> {
        let mut g = self.inner.lock().map_err(|_| CoreFailure::closed())?;
        let v = g.as_mut().ok_or_else(closed)?;
        Ok(f(v)?)
    }

    /// Cierra y pone a cero la clave y el indice.
    pub fn close(&self) {
        if let Ok(mut g) = self.inner.lock() {
            *g = None;
        }
    }

    pub fn is_open(&self) -> bool {
        self.inner.lock().map(|g| g.is_some()).unwrap_or(false)
    }

    pub fn list(
        &self,
        kind: Option<String>,
        include_deleted: bool,
    ) -> Result<Vec<VaultRecord>, CoreFailure> {
        self.with(|v| {
            Ok(v.list(kind.as_deref(), include_deleted)
                .into_iter()
                .map(Into::into)
                .collect())
        })
    }

    pub fn get(&self, id: String) -> Result<Option<VaultRecord>, CoreFailure> {
        self.with(|v| Ok(v.get(&id).map(Into::into)))
    }

    /// Inserta o reemplaza varios registros en una transaccion.
    pub fn put(&self, records: Vec<VaultRecord>) -> Result<(), CoreFailure> {
        let records: Vec<Record> = records.into_iter().map(Into::into).collect();
        self.with(|v| v.put_many(&records))
    }

    /// Borra dejando lapida (la sync propaga el borrado).
    pub fn remove(&self, id: String, at: i64) -> Result<(), CoreFailure> {
        self.with(|v| v.remove(&id, at))
    }

    /// Borra sin lapida.
    pub fn purge(&self, id: String) -> Result<(), CoreFailure> {
        self.with(|v| v.purge(&id))
    }

    /// Vacia la boveda (misma maestra).
    pub fn clear(&self) -> Result<(), CoreFailure> {
        self.with(|v| v.clear())
    }

    pub fn put_blob(&self, id: String, bytes: Vec<u8>) -> Result<(), CoreFailure> {
        let bytes = Zeroizing::new(bytes);
        self.with(|v| v.put_blob(&id, &bytes))
    }

    pub fn get_blob(&self, id: String) -> Result<Option<Vec<u8>>, CoreFailure> {
        self.with(|v| Ok(v.get_blob(&id)?.map(|b| b.to_vec())))
    }

    pub fn delete_blob(&self, id: String) -> Result<(), CoreFailure> {
        self.with(|v| v.delete_blob(&id))
    }

    pub fn change_password(
        &self,
        new_password: Vec<u8>,
        kdf: KdfConfig,
    ) -> Result<(), CoreFailure> {
        let new_password = Zeroizing::new(new_password);
        self.with(|v| v.change_password(&new_password, kdf.into()))
    }

    /// Codigo de recuperacion nuevo (invalida el anterior). Mostrarlo una vez.
    pub fn reset_recovery(&self) -> Result<String, CoreFailure> {
        self.with(|v| Ok(v.reset_recovery()?.as_str().to_owned()))
    }

    pub fn remove_recovery(&self) -> Result<(), CoreFailure> {
        self.with(|v| v.remove_recovery())
    }

    pub fn has_recovery(&self) -> Result<bool, CoreFailure> {
        self.with(|v| Ok(v.header().has_recovery))
    }

    pub fn vault_id(&self) -> Result<String, CoreFailure> {
        self.with(|v| Ok(v.header().vault_id.clone()))
    }

    /// Copia de la clave de la boveda, para guardarla tras la biometria. Quien la recibe la borra.
    pub fn key_copy(&self) -> Result<Vec<u8>, CoreFailure> {
        self.with(|v| Ok(v.key_copy().to_vec()))
    }

    pub(crate) fn with_vault<T>(
        &self,
        f: impl FnOnce(&mut Vault) -> Result<T, CoreError>,
    ) -> Result<T, CoreFailure> {
        self.with(f)
    }
}
