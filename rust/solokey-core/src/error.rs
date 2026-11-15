//! Errores del nucleo. Nunca llevan secretos dentro (ni claves, ni texto descifrado).

#[derive(Debug, thiserror::Error, PartialEq, Eq)]
pub enum CoreError {
    #[error("parametros de KDF invalidos")]
    KdfParams,
    #[error("la clave debe medir 32 bytes")]
    KeyLength,
    #[error("el blob cifrado es demasiado corto")]
    BlobTooShort,
    #[error("no se pudo descifrar: clave equivocada o datos alterados")]
    Decrypt,
    #[error("no se pudo cifrar")]
    Encrypt,
    #[error("formato no reconocido")]
    Format,
    #[error("contrasena o clave incorrecta")]
    WrongPassword,
    #[error("la boveda no existe")]
    NotFound,
    #[error("ya existe una boveda en esa ruta")]
    AlreadyExists,
    #[error("la boveda es de una version mas nueva de SoloKey")]
    NewerFormat,
    #[error("la boveda no tiene codigo de recuperacion")]
    NoRecovery,
    #[error("la verificacion de la migracion no coincide")]
    Verify,
    #[error("no se pudo establecer el canal cifrado")]
    Handshake,
    #[error("el otro equipo tiene SoloKey v1: hay que actualizar los dos")]
    PeerIsV1,
    #[error("el otro equipo usa otra version del protocolo ({0})")]
    PeerVersion(u8),
    #[error("mensaje de sync fuera de protocolo")]
    Protocol,
    #[error("mensaje demasiado grande")]
    TooLarge,
    #[error("error de base de datos: {0}")]
    Db(String),
    #[error("error de archivo: {0}")]
    Io(String),
}
