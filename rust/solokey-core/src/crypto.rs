//! Cripto de la boveda (ADR-0003): Argon2id + AES-256-GCM con blob `nonce(12) || ciphertext || tag(16)`.
//!
//! Mismos parametros y mismo formato de blob que la v1 en Dart, para que la v2 abra lo que cifro la v1.

use aes_gcm::aead::rand_core::RngCore;
use aes_gcm::aead::{Aead, AeadCore, KeyInit, OsRng};
use aes_gcm::{Aes256Gcm, Key, Nonce};
use argon2::{Algorithm, Argon2, Params, Version};
use sha2::{Digest, Sha256};
use zeroize::Zeroizing;

use crate::error::CoreError;

/// Largo de la clave derivada y de la clave de AES-256.
pub const KEY_LEN: usize = 32;
/// Largo del nonce de AES-GCM.
pub const NONCE_LEN: usize = 12;
/// Largo de la etiqueta de AES-GCM.
pub const TAG_LEN: usize = 16;
/// Largo de la sal por boveda.
pub const SALT_LEN: usize = 32;

/// Texto conocido que se cifra para verificar la maestra sin guardarla (`MasterKeyConfig.verificationData`).
pub const VERIFICATION_PLAINTEXT: &[u8] = b"SoloKey::v1::verify";

/// Clave de 32 bytes que se pone a cero al soltarse.
pub type SecretKey = Zeroizing<[u8; KEY_LEN]>;

/// Parametros de Argon2id. `memory_kib` en bloques de 1 KiB, como `MasterKeyConfig.memory` de la v1.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct KdfParams {
    pub memory_kib: u32,
    pub iterations: u32,
    pub parallelism: u32,
}

impl KdfParams {
    /// Los de la boveda (ADR-0003): 64 MiB, 3 iteraciones, paralelismo 4.
    pub const VAULT: KdfParams = KdfParams {
        memory_kib: 65_536,
        iterations: 3,
        parallelism: 4,
    };
    /// Los del doble sobre de la v1 (`double_enc_v1`): 32 MiB, 2, 2.
    pub const DOUBLE_ENVELOPE_V1: KdfParams = KdfParams {
        memory_kib: 32_768,
        iterations: 2,
        parallelism: 2,
    };
}

/// Deriva una clave de 32 bytes con Argon2id v1.3.
///
/// `password` son los bytes exactos que entran al KDF; quien llama decide la codificacion (la maestra de la
/// v1 entra con doble UTF-8, ver `formato::v1`).
pub fn derive_key(password: &[u8], salt: &[u8], params: KdfParams) -> Result<SecretKey, CoreError> {
    let p = Params::new(
        params.memory_kib,
        params.iterations,
        params.parallelism,
        Some(KEY_LEN),
    )
    .map_err(|_| CoreError::KdfParams)?;
    let argon = Argon2::new(Algorithm::Argon2id, Version::V0x13, p);
    let mut out = Zeroizing::new([0u8; KEY_LEN]);
    argon
        .hash_password_into(password, salt, out.as_mut())
        .map_err(|_| CoreError::KdfParams)?;
    Ok(out)
}

fn cipher(key: &[u8]) -> Result<Aes256Gcm, CoreError> {
    if key.len() != KEY_LEN {
        return Err(CoreError::KeyLength);
    }
    Ok(Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key)))
}

/// Cifra con AES-256-GCM y nonce aleatorio. Devuelve `nonce || ciphertext || tag`.
pub fn encrypt(plaintext: &[u8], key: &[u8]) -> Result<Vec<u8>, CoreError> {
    encrypt_with_aad(plaintext, key, &[])
}

/// Como [`encrypt`], autenticando ademas `aad` (datos asociados que no se cifran pero no se pueden cambiar).
pub fn encrypt_with_aad(plaintext: &[u8], key: &[u8], aad: &[u8]) -> Result<Vec<u8>, CoreError> {
    let c = cipher(key)?;
    let nonce = Aes256Gcm::generate_nonce(&mut OsRng);
    let ct = c
        .encrypt(
            &nonce,
            aes_gcm::aead::Payload {
                msg: plaintext,
                aad,
            },
        )
        .map_err(|_| CoreError::Encrypt)?;
    let mut blob = Vec::with_capacity(NONCE_LEN + ct.len());
    blob.extend_from_slice(&nonce);
    blob.extend_from_slice(&ct);
    Ok(blob)
}

/// Descifra un blob de [`encrypt`]. El texto en claro sale en un buffer que se pone a cero al soltarse.
pub fn decrypt(blob: &[u8], key: &[u8]) -> Result<Zeroizing<Vec<u8>>, CoreError> {
    decrypt_with_aad(blob, key, &[])
}

/// Descifra un blob de [`encrypt_with_aad`] con los mismos `aad`.
pub fn decrypt_with_aad(
    blob: &[u8],
    key: &[u8],
    aad: &[u8],
) -> Result<Zeroizing<Vec<u8>>, CoreError> {
    if blob.len() < NONCE_LEN + TAG_LEN {
        return Err(CoreError::BlobTooShort);
    }
    let c = cipher(key)?;
    let (nonce, ct) = blob.split_at(NONCE_LEN);
    c.decrypt(
        Nonce::from_slice(nonce),
        aes_gcm::aead::Payload { msg: ct, aad },
    )
    .map(Zeroizing::new)
    .map_err(|_| CoreError::Decrypt)
}

/// Bytes aleatorios del generador del sistema.
pub fn random_bytes(len: usize) -> Vec<u8> {
    let mut v = vec![0u8; len];
    OsRng.fill_bytes(&mut v);
    v
}

/// Sal aleatoria de 32 bytes para una boveda nueva.
pub fn generate_salt() -> [u8; SALT_LEN] {
    let mut s = [0u8; SALT_LEN];
    OsRng.fill_bytes(&mut s);
    s
}

/// Clave aleatoria de 32 bytes (clave de boveda de la v2, ver SEC-009).
pub fn generate_key() -> SecretKey {
    let mut k = Zeroizing::new([0u8; KEY_LEN]);
    OsRng.fill_bytes(k.as_mut());
    k
}

/// Blob que prueba la clave sin guardarla: cifra [`VERIFICATION_PLAINTEXT`].
pub fn create_verification_data(key: &[u8]) -> Result<Vec<u8>, CoreError> {
    encrypt(VERIFICATION_PLAINTEXT, key)
}

/// `true` si `key` descifra `verification` al texto conocido. Cualquier error cuenta como `false`.
pub fn verify_key(key: &[u8], verification: &[u8]) -> bool {
    matches!(decrypt(verification, key), Ok(pt) if pt.as_slice() == VERIFICATION_PLAINTEXT)
}

/// SHA-256.
pub fn sha256(data: &[u8]) -> [u8; 32] {
    Sha256::digest(data).into()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fast() -> KdfParams {
        KdfParams {
            memory_kib: 64,
            iterations: 1,
            parallelism: 1,
        }
    }

    #[test]
    fn ida_y_vuelta() {
        let key = generate_key();
        let blob = encrypt(b"hola", key.as_ref()).unwrap();
        assert_eq!(blob.len(), NONCE_LEN + 4 + TAG_LEN);
        assert_eq!(decrypt(&blob, key.as_ref()).unwrap().as_slice(), b"hola");
    }

    #[test]
    fn nonce_distinto_cada_vez() {
        let key = generate_key();
        let a = encrypt(b"x", key.as_ref()).unwrap();
        let b = encrypt(b"x", key.as_ref()).unwrap();
        assert_ne!(a[..NONCE_LEN], b[..NONCE_LEN]);
    }

    #[test]
    fn clave_equivocada_falla() {
        let blob = encrypt(b"hola", generate_key().as_ref()).unwrap();
        assert_eq!(
            decrypt(&blob, generate_key().as_ref()).unwrap_err(),
            CoreError::Decrypt
        );
    }

    #[test]
    fn bit_cambiado_falla() {
        let key = generate_key();
        let mut blob = encrypt(b"hola", key.as_ref()).unwrap();
        let last = blob.len() - 1;
        blob[last] ^= 1;
        assert_eq!(
            decrypt(&blob, key.as_ref()).unwrap_err(),
            CoreError::Decrypt
        );
        blob[last] ^= 1;
        blob[NONCE_LEN] ^= 0x80;
        assert_eq!(
            decrypt(&blob, key.as_ref()).unwrap_err(),
            CoreError::Decrypt
        );
    }

    #[test]
    fn aad_distinto_falla() {
        let key = generate_key();
        let blob = encrypt_with_aad(b"hola", key.as_ref(), b"id-1").unwrap();
        assert!(decrypt_with_aad(&blob, key.as_ref(), b"id-2").is_err());
        assert!(decrypt(&blob, key.as_ref()).is_err());
        assert_eq!(
            decrypt_with_aad(&blob, key.as_ref(), b"id-1")
                .unwrap()
                .as_slice(),
            b"hola"
        );
    }

    #[test]
    fn blob_corto_y_clave_corta() {
        assert_eq!(
            decrypt(&[0u8; 27], &[0u8; 32]).unwrap_err(),
            CoreError::BlobTooShort
        );
        assert_eq!(encrypt(b"x", &[0u8; 16]).unwrap_err(), CoreError::KeyLength);
    }

    #[test]
    fn verificacion() {
        let key = generate_key();
        let v = create_verification_data(key.as_ref()).unwrap();
        assert!(verify_key(key.as_ref(), &v));
        assert!(!verify_key(generate_key().as_ref(), &v));
        assert!(!verify_key(key.as_ref(), b"basura"));
    }

    #[test]
    fn kdf_determinista_y_sensible_a_la_sal() {
        let a = derive_key(b"pw", &[1u8; 32], fast()).unwrap();
        let b = derive_key(b"pw", &[1u8; 32], fast()).unwrap();
        let c = derive_key(b"pw", &[2u8; 32], fast()).unwrap();
        assert_eq!(*a, *b);
        assert_ne!(*a, *c);
    }

    #[test]
    fn kdf_parametros_invalidos() {
        let bad = KdfParams {
            memory_kib: 1,
            iterations: 0,
            parallelism: 0,
        };
        assert_eq!(
            derive_key(b"pw", &[0u8; 32], bad).unwrap_err(),
            CoreError::KdfParams
        );
    }

    #[test]
    fn sha256_conocido() {
        // SHA-256("abc"), FIPS 180-2.
        let h = sha256(b"abc");
        assert_eq!(
            h.iter().map(|b| format!("{b:02x}")).collect::<String>(),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }
}
