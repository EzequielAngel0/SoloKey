//! Archivo de boveda manipulado en disco: leer la cabecera no puede entrar en panico. Si la acepta, sus
//! parametros de Argon2id tienen que estar acotados antes de abrirla (AMENAZAS_V2.md, "Lo que entra de fuera").
#![no_main]

use libfuzzer_sys::fuzz_target;
use solokey_core::vault::read_header;

fuzz_target!(|archivo: &[u8]| {
    let dir = tempfile::tempdir().expect("tempdir");
    let ruta = dir.path().join("vault.solokey");
    std::fs::write(&ruta, archivo).expect("escribir");
    let _ = read_header(&ruta);
});
