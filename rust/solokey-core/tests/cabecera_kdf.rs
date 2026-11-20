//! SEC-012: los parametros de Argon2id de la cabecera vienen del disco. Abrir no puede abortar, colgarse ni aceptar
//! unos mas debiles que los de la v1. Va en `tests/` para compilar sin `cfg(test)` (el piso real, no el de las
//! pruebas unitarias).

use solokey_core::crypto::KdfParams;
use solokey_core::vault::{vault_path, Vault};
use solokey_core::CoreError;

const MAESTRA: &[u8] = b"maestra de prueba";

fn alterar(ruta: &std::path::Path, m: u32, t: u32, p: u32) {
    let conn = rusqlite::Connection::open(ruta).unwrap();
    conn.execute(
        "UPDATE header SET kdf_memory_kib = ?1, kdf_iterations = ?2, kdf_parallelism = ?3 WHERE id = 1",
        rusqlite::params![m, t, p],
    )
    .unwrap();
}

#[test]
fn cabecera_con_kdf_fuera_de_rango_no_abre() {
    let dir = tempfile::tempdir().unwrap();
    let ruta = vault_path(dir.path());
    drop(Vault::create(&ruta, MAESTRA, KdfParams::VAULT).unwrap());

    // Los casos que encontro el fuzz (SEG-2): 4 TiB, pasadas sin fin y 8 KiB con una pasada.
    for (m, t, p) in [
        (u32::MAX, 3, 4),
        (65_536, u32::MAX, 4),
        (8, 1, 1),
        (65_536, 2, 4),
        (65_536, 3, 0),
        (65_536, 3, u32::MAX),
    ] {
        alterar(&ruta, m, t, p);
        assert!(
            matches!(Vault::open(&ruta, MAESTRA), Err(CoreError::Format)),
            "abrio con memoria {m} KiB, {t} pasadas y paralelismo {p}"
        );
    }

    alterar(&ruta, 65_536, 3, 4);
    assert!(Vault::open(&ruta, MAESTRA).is_ok());
}

#[test]
fn no_crea_ni_cambia_a_un_kdf_debil() {
    let dir = tempfile::tempdir().unwrap();
    let ruta = vault_path(dir.path());
    let debil = KdfParams {
        memory_kib: 8,
        iterations: 1,
        parallelism: 1,
    };
    assert!(matches!(
        Vault::create(&ruta, MAESTRA, debil),
        Err(CoreError::KdfParams)
    ));
    assert!(!ruta.exists());

    let (mut v, _code) = Vault::create(&ruta, MAESTRA, KdfParams::VAULT).unwrap();
    assert!(matches!(
        v.change_password(b"otra", debil),
        Err(CoreError::KdfParams)
    ));
}

#[test]
fn derivar_no_pasa_del_techo() {
    let enorme = KdfParams {
        memory_kib: u32::MAX,
        iterations: 3,
        parallelism: 4,
    };
    assert!(matches!(
        solokey_core::crypto::derive_key(b"x", &[0u8; 16], enorme),
        Err(CoreError::KdfParams)
    ));
}
