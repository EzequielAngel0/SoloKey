//! Superficie que ve Flutter por `flutter_rust_bridge` 2. Todo lo de aqui corre en el pool de hilos del puente
//! (en Dart es `Future`), asi que la interfaz no se bloquea con Argon2id.
//!
//! Los `Vec<u8>` que llegan de Dart son copias: se ponen a cero al terminar. Lo que vuelve a Dart (una clave
//! derivada, un texto descifrado) lo borra quien lo recibe (`SessionManager`, `zeroBuffer`).

pub mod crypto;
pub mod error;
pub mod sync;
pub mod vault;
