# Carril A · Núcleo (cripto, bóveda, BD, sync)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §2 y §5.

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía: todo depende de DEC-1 (stack), que decide la sesión general.

## En espera

| ID | Qué | Esf. | Lo destraba |
|---|---|---|---|
| NUC-0 | Prototipo: crate Rust que abre una bóveda de la v1, llamado desde Flutter en Android y Windows; mide desbloqueo, tamaño de APK e instalador | L | Que el dueño apruebe probar R1 (DEC-1) y acepte `rustup` en el host ([ver](#nuc-0)) |
| NUC-1 | Núcleo `solokey-core`: cripto (Argon2id, AES-256-GCM, `zeroize`) detrás de `ISecurityService` | L | DEC-1 = R1 tras comparar NUC-0 |
| NUC-2 | Bóveda y BD en el núcleo (lee el esquema Drift v10 o migra a uno propio) con migración probada sobre una copia | XL | NUC-1 |
| NUC-3 | Sync en el núcleo (X25519, AES-GCM, LWW) con versión de protocolo y aviso entre v1 y v2 | XL | NUC-2 |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| D | `rustup` + targets de Android en el host y el paso de Rust en CI (`tests.yml`) | NUC-0 en adelante |
| E | Vectores de prueba generados con la app v1 (salt, parámetros, blob cifrado, verificationData) | NUC-0 |

## Propuestas de la sesión (◇)

| ID | Qué | Para qué | Esf. |
|---|---|---|---|
| NUC-4 ◇ | Si DEC-1 = R0: endurecer el borrado de secretos en Dart (buffers únicos, sin `String` intermedios en revelar y copiar) | Lo más cercano a `zeroize` sin cambiar de lenguaje | M |
| NUC-5 ◇ | Passkeys WebAuthn real (Credential Manager en Android) | Hoy es solo "respaldo de passkey"; plan en [`../seguridad/WEBAUTHN.md`](../seguridad/WEBAUTHN.md) | XL |

## No reabre

| Qué | Por qué |
|---|---|
| Nube o servidor propio para sincronizar | Local-first es la promesa del producto |

## Detalle

### NUC-0

1. Con la app v1 (en un entorno de prueba, nunca la bóveda real) generar vectores: contraseña conocida, salt, `KdfParams`
   (Argon2id 64 MiB, 3 iteraciones, paralelismo 4, 32 bytes), `verificationData` y un payload cifrado (`nonce‖ciphertext‖tag`).
2. Crate en `rust/` con `argon2`, `aes-gcm` y `zeroize` (RustCrypto): `cargo test` en Podman (`docker.io/library/rust`) que
   reproduce los vectores.
3. `flutter_rust_bridge` 2: desbloquear desde Flutter en Windows y en Android (emulador o celular).
4. Medir contra la v1: tiempo de desbloqueo, tamaño de APK universal e instalador, y lo que costó el build.
5. Dejarle al dueño las dos versiones para comparar; su decisión va a `docs/adr/0001-stack-v2.md`.
