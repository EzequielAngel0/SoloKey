//! Primera trama que llega por la red de un equipo desconocido: version y saludo Noise del respondedor.
//! Nada de esto puede entrar en panico ni reservar memoria sin tope.
#![no_main]

use libfuzzer_sys::fuzz_target;
use solokey_core::sync::channel::{peer_version, PendingResponder};

/// Llave fija del equipo que responde (solo para el fuzz).
const SECRETA: [u8; 32] = [7u8; 32];

fuzz_target!(|trama: &[u8]| {
    let _ = peer_version(trama);
    let _ = PendingResponder::accept(&SECRETA, trama);
});
