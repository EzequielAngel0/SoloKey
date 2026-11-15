//! Cripto para `ISecurityService` (NUC-1). Mismos algoritmos y formato que la v1 (ADR-0003).

use zeroize::Zeroizing;

use crate::crypto::{self as c, KdfParams};

/// Argon2id. `password` son los bytes exactos de entrada al KDF (Dart pasa `utf8.encode(password)`, lo mismo que
/// hacia la libreria `cryptography` de la v1).
pub fn derive_key(
    password: Vec<u8>,
    salt: Vec<u8>,
    memory_kib: u32,
    iterations: u32,
    parallelism: u32,
) -> anyhow::Result<Vec<u8>> {
    let password = Zeroizing::new(password);
    let key = c::derive_key(
        &password,
        &salt,
        KdfParams {
            memory_kib,
            iterations,
            parallelism,
        },
    )?;
    Ok(key.to_vec())
}

/// AES-256-GCM; devuelve `nonce || ciphertext || tag`.
pub fn encrypt(plaintext: Vec<u8>, key: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    let (plaintext, key) = (Zeroizing::new(plaintext), Zeroizing::new(key));
    Ok(c::encrypt(&plaintext, &key)?)
}

/// Descifra un blob de [`encrypt`].
pub fn decrypt(blob: Vec<u8>, key: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    let key = Zeroizing::new(key);
    let pt = c::decrypt(&blob, &key)?;
    Ok(pt.to_vec())
}

/// Sal aleatoria de 32 bytes.
pub fn generate_salt() -> Vec<u8> {
    c::generate_salt().to_vec()
}

/// Blob de verificacion de la clave (`MasterKeyConfig.verificationData`).
pub fn create_verification_data(key: Vec<u8>) -> anyhow::Result<Vec<u8>> {
    let key = Zeroizing::new(key);
    Ok(c::create_verification_data(&key)?)
}

/// `true` si `key` abre `verification`.
pub fn verify_key(key: Vec<u8>, verification: Vec<u8>) -> bool {
    let key = Zeroizing::new(key);
    c::verify_key(&key, &verification)
}

/// SHA-256.
pub fn sha256(data: Vec<u8>) -> Vec<u8> {
    c::sha256(&data).to_vec()
}
