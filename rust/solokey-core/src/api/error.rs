//! Error que ve Flutter: un codigo estable para decidir que mostrar, y un texto para el registro (sin secretos).

use crate::error::CoreError;

/// Que fallo, para que la interfaz decida (por ejemplo "maestra incorrecta" frente a "archivo danado").
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FailureCode {
    WrongPassword,
    NotFound,
    AlreadyExists,
    NewerFormat,
    NoRecovery,
    Closed,
    /// El otro equipo tiene la v1: hay que actualizar los dos.
    PeerIsV1,
    /// El otro equipo usa otra version del protocolo.
    PeerVersion,
    /// No se pudo establecer el canal (llave equivocada o par desconocido).
    Handshake,
    /// Datos alterados, formato roto o fuera de protocolo.
    Corrupt,
    Io,
    Other,
}

#[derive(Debug, Clone)]
pub struct CoreFailure {
    pub code: FailureCode,
    pub message: String,
}

impl std::fmt::Display for CoreFailure {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&self.message)
    }
}

impl std::error::Error for CoreFailure {}

impl From<CoreError> for CoreFailure {
    fn from(e: CoreError) -> Self {
        let code = match &e {
            CoreError::WrongPassword => FailureCode::WrongPassword,
            CoreError::NotFound => FailureCode::NotFound,
            CoreError::AlreadyExists => FailureCode::AlreadyExists,
            CoreError::NewerFormat => FailureCode::NewerFormat,
            CoreError::NoRecovery => FailureCode::NoRecovery,
            CoreError::PeerIsV1 => FailureCode::PeerIsV1,
            CoreError::PeerVersion(_) => FailureCode::PeerVersion,
            CoreError::Handshake => FailureCode::Handshake,
            CoreError::Decrypt
            | CoreError::Format
            | CoreError::BlobTooShort
            | CoreError::Verify
            | CoreError::Protocol
            | CoreError::TooLarge => FailureCode::Corrupt,
            CoreError::Io(_) | CoreError::Db(_) => FailureCode::Io,
            CoreError::KdfParams | CoreError::KeyLength | CoreError::Encrypt => FailureCode::Other,
        };
        CoreFailure {
            code,
            message: e.to_string(),
        }
    }
}

impl CoreFailure {
    pub(crate) fn closed() -> CoreFailure {
        CoreFailure {
            code: FailureCode::Closed,
            message: "boveda cerrada".into(),
        }
    }
}
