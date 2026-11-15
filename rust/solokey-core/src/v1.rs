//! Lectura de lo que escribio la v1 (Dart). Replica sus rarezas, documentadas en `vectores/v1/LEEME.md` (CAL-2).

use base64::engine::general_purpose::{STANDARD, STANDARD_NO_PAD};
use base64::Engine;
use zeroize::Zeroizing;

use crate::crypto::{self, KdfParams, SecretKey, KEY_LEN};
use crate::error::CoreError;

/// Prefijo del doble sobre de la v1.
pub const DOUBLE_ENVELOPE_PREFIX: &str = "double_enc_v1:";

/// Bytes que la v1 metia a Argon2id para la maestra: UTF-8, leido como Latin-1, y otra vez UTF-8.
///
/// La v1 pasaba `String.fromCharCodes(utf8.encode(pw))` y la libreria volvia a codificar. Con solo ASCII da lo
/// mismo que UTF-8 simple; con `ñ` o emoji, no.
pub fn master_kdf_input(password: &str) -> Zeroizing<Vec<u8>> {
    let mut out = Zeroizing::new(Vec::with_capacity(password.len() * 2));
    let mut buf = [0u8; 4];
    for &b in password.as_bytes() {
        out.extend_from_slice(char::from(b).encode_utf8(&mut buf).as_bytes());
    }
    buf.fill(0);
    out
}

/// Deriva la clave de una boveda v1 desde la maestra.
pub fn derive_master_key(
    password: &str,
    salt: &[u8],
    params: KdfParams,
) -> Result<SecretKey, CoreError> {
    crypto::derive_key(&master_kdf_input(password), salt, params)
}

/// `true` si `value` es un campo con doble sobre de la v1.
pub fn is_double_envelope(value: &str) -> bool {
    value.starts_with(DOUBLE_ENVELOPE_PREFIX)
}

/// Abre un `double_enc_v1:<sal b64>:<blob b64>` con el PIN (UTF-8 simple, Argon2id 32 MiB, 2, 2).
pub fn open_double_envelope(value: &str, pin: &str) -> Result<Zeroizing<Vec<u8>>, CoreError> {
    let rest = value
        .strip_prefix(DOUBLE_ENVELOPE_PREFIX)
        .ok_or(CoreError::Format)?;
    let (salt_b64, blob_b64) = rest.split_once(':').ok_or(CoreError::Format)?;
    let salt = STANDARD.decode(salt_b64).map_err(|_| CoreError::Format)?;
    let blob = STANDARD.decode(blob_b64).map_err(|_| CoreError::Format)?;
    let key = crypto::derive_key(pin.as_bytes(), &salt, KdfParams::DOUBLE_ENVELOPE_V1)?;
    crypto::decrypt(&blob, key.as_ref())
}

/// Clave de 32 bytes del codigo de recuperacion de la v1 (base64 sin `=`, en grupos de 4 con guiones).
pub fn recovery_code_key(code: &str) -> Result<SecretKey, CoreError> {
    let compact: Zeroizing<String> = Zeroizing::new(
        code.chars()
            .filter(|c| *c != '-' && !c.is_whitespace())
            .collect(),
    );
    let raw = Zeroizing::new(
        STANDARD_NO_PAD
            .decode(compact.as_bytes())
            .map_err(|_| CoreError::Format)?,
    );
    if raw.len() != KEY_LEN {
        return Err(CoreError::Format);
    }
    let mut k = Zeroizing::new([0u8; KEY_LEN]);
    k.copy_from_slice(&raw);
    Ok(k)
}
