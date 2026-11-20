//! Mensaje de sync (JSON) ya descifrado del canal: lo manda un par emparejado, pero puede estar roto o ser
//! malicioso. `SyncEngine::handle` no puede entrar en panico ni dejar la boveda a medias.
#![no_main]

use std::cell::RefCell;

use libfuzzer_sys::fuzz_target;
use solokey_core::crypto::KdfParams;
use solokey_core::sync::protocol::SyncEngine;
use solokey_core::vault::{vault_path, Record, Vault};

thread_local! {
    static BOVEDA: RefCell<Option<(tempfile::TempDir, Vault)>> = const { RefCell::new(None) };
}

fuzz_target!(|msg: &[u8]| {
    BOVEDA.with(|b| {
        let mut b = b.borrow_mut();
        if b.is_none() {
            // Una sola vez por proceso: con los parametros reales (SEC-012 no deja crear con menos).
            let dir = tempfile::tempdir().expect("tempdir");
            let (v, _code) =
                Vault::create(&vault_path(dir.path()), b"fuzz", KdfParams::VAULT).expect("crear");
            *b = Some((dir, v));
        }
        let (_, vault) = b.as_mut().unwrap();
        // Mismo punto de partida en cada entrada: un registro conocido.
        vault.clear().expect("vaciar");
        vault
            .put(Record {
                id: "r1".into(),
                kind: "password".into(),
                updated_at: 1_000,
                deleted: false,
                data: "{\"title\":\"uno\"}".into(),
            })
            .expect("put");
        let mut engine = SyncEngine::new();
        let _ = engine.handle(vault, msg);
    });
});
