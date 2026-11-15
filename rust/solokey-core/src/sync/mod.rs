//! Sync v2 (ADR-0010, NUC-3): canal Noise (`channel`) y delta con LWW (`protocol`). Sin E/S: el socket y el
//! descubrimiento en la LAN se quedan en Flutter; aqui solo entran y salen bytes.

pub mod channel;
pub mod protocol;
