//! Codigo de recuperacion que escribe el usuario. No entra en panico con cualquier texto, y un codigo bien
//! formado vuelve a dar la misma clave (ida y vuelta con `format_recovery_code`).
#![no_main]

use libfuzzer_sys::fuzz_target;
use solokey_core::v1::recovery_code_key;
use solokey_core::vault::format_recovery_code;

fuzz_target!(|data: &[u8]| {
    if let Ok(texto) = std::str::from_utf8(data) {
        let _ = recovery_code_key(texto);
    }
    if data.len() >= 32 {
        let clave = &data[..32];
        let codigo = format_recovery_code(clave);
        let vuelta = recovery_code_key(&codigo).expect("un codigo generado siempre se lee");
        assert_eq!(&vuelta[..], clave, "ida y vuelta del codigo de recuperacion");
    }
});
