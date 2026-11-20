//! Parametros de Argon2id cambiados en la cabecera de una boveda real (SEC-012): abrirla no puede pedir memoria
//! sin limite, colgarse ni aceptar unos mas debiles que los de la v1 (AMENAZAS_V2.md, "Disco"). La entrada son
//! 12 bytes: memoria en KiB, pasadas y paralelismo, u32 little endian.
#![no_main]

use std::cell::RefCell;

use libfuzzer_sys::fuzz_target;
use solokey_core::crypto::KdfParams;
use solokey_core::vault::{vault_path, Vault};
use solokey_core::CoreError;

const MAESTRA: &[u8] = b"fuzz";
// Los de la v1: el minimo que la v2 puede aceptar.
const V1: KdfParams = KdfParams { memory_kib: 65_536, iterations: 3, parallelism: 4 };

thread_local! {
    static BOVEDA: RefCell<Option<(tempfile::TempDir, std::path::PathBuf)>> = const { RefCell::new(None) };
}

fn u32_le(b: &[u8]) -> u32 {
    u32::from_le_bytes([b[0], b[1], b[2], b[3]])
}

fuzz_target!(|entrada: &[u8]| {
    if entrada.len() < 12 {
        return;
    }
    let (m, t, p) = (u32_le(&entrada[0..4]), u32_le(&entrada[4..8]), u32_le(&entrada[8..12]));
    BOVEDA.with(|b| {
        let mut b = b.borrow_mut();
        if b.is_none() {
            let dir = tempfile::tempdir().expect("tempdir");
            let ruta = vault_path(dir.path());
            let (v, _code) = Vault::create(&ruta, MAESTRA, V1).expect("crear");
            drop(v);
            *b = Some((dir, ruta));
        }
        let (_, ruta) = b.as_ref().unwrap();
        let conn = rusqlite::Connection::open(ruta).expect("abrir sqlite");
        conn.execute(
            "UPDATE header SET kdf_memory_kib = ?1, kdf_iterations = ?2, kdf_parallelism = ?3 WHERE id = 1",
            rusqlite::params![m, t, p],
        )
        .expect("cambiar cabecera");
        drop(conn);
        let r = Vault::open(ruta, MAESTRA);
        // Ok o WrongPassword quiere decir que el KDF corrio con esos parametros: tienen que ser al menos los de la v1.
        if matches!(r, Ok(_) | Err(CoreError::WrongPassword)) {
            assert!(
                m >= V1.memory_kib && t >= V1.iterations,
                "la boveda acepto parametros de KDF mas debiles que los de la v1: memoria {m} KiB, pasadas {t}"
            );
        }
    });
});
