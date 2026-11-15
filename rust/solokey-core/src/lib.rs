//! Nucleo de SoloKey (ADR-0008): cripto, formato de boveda, BD y sync.
//!
//! Solo crates auditados (RustCrypto, `zeroize`); nada de cripto propia. Todo lo que toca un secreto
//! vive en tipos que se ponen a cero al soltarse (`Zeroizing`).

pub mod api;
pub mod crypto;
pub mod error;
pub mod migrate_v1;
pub mod v1;
pub mod vault;

pub use error::CoreError;
