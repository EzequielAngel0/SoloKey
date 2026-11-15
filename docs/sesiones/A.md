# Carril A · Núcleo (cripto, bóveda, BD, sync en Rust)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md). Decisiones:
[ADR-0008](../adr/0008-nucleo-en-rust.md) (núcleo Rust), [0009](../adr/0009-formato-de-boveda-v2.md) (formato),
[0010](../adr/0010-sync-v2-canal-cifrado.md) (sync), [0011](../adr/0011-pruebas-e2e-principal.md) (pruebas),
[0012](../adr/0012-todo-en-podman.md) (Podman).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | NUC-1 | Crate `solokey-core` con la cripto (Argon2id, AES-256-GCM, `zeroize`) detrás de `ISecurityService`, vía `flutter_rust_bridge` 2; corre en Android y Windows | L | ◐ Rust hecho; falta el puente Dart | [ver](#nuc-1) |
| 2 | NUC-2 | Formato de bóveda v2 (SQLite con `rusqlite`, cabecera versionada, metadatos cifrados) y migración única desde la v1 con copia previa | XL | ☐ | [ver](#nuc-2) |
| 3 | NUC-3 | Sync v2 en el núcleo: canal Noise con llaves fijadas en el QR, protocolo versionado, LWW, aviso claro entre v1 y v2 | XL | ☐ | [ver](#nuc-3) |
| 4 | NUC-6 | Directorio de datos configurable (bóveda aislada para E2E); la ruta real solo sin la bandera de prueba | S | ☐ | Lo pide E (CAL-5); va con NUC-2 |
| 5 | NUC-5 | Passkeys reales (WebAuthn, proveedor de Credential Manager en Android) | XL | ⊘ después de la v2.0.0 | [`../seguridad/WEBAUTHN.md`](../seguridad/WEBAUTHN.md) |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| D | Imagen `solokey-build` en Podman (Rust, `cargo-ndk`, `cargo-xwin`, SDK y NDK de Android) y paso de Rust en CI (PLA-3) | NUC-1 en Android y Windows |
| E | Vectores de prueba de la v1 (CAL-2) | NUC-2 (la migración) |

## No reabre

| Qué | Por qué |
|---|---|
| Nube o servidor propio para sincronizar | Local-first es la promesa del producto (ADR-0001) |
| NUC-0, prototipo comparativo de R1 | El dueño eligió R1 directo (2026-11-15) |
| NUC-4, endurecer el borrado en Dart | Era para R0; con el núcleo en Rust no aplica |
| `rustup` en el host | Todo Rust en Podman (ADR-0012) |

## Detalle

### NUC-1

1. `rust/solokey-core` (workspace en `rust/`). Crates de RustCrypto: `argon2`, `aes-gcm`, `zeroize`; nada de cripto propia.
2. Mismos parámetros que la v1 (ADR-0003): Argon2id 64 MiB, 3, 4, 32 bytes; `nonce‖ciphertext‖tag`.
3. Pruebas unitarias **solo aquí**, en Rust (`cargo test` en Podman), con los vectores de CAL-2 cuando estén.
4. Puente con `flutter_rust_bridge` 2; la implementación Dart de `ISecurityService` pasa a llamar al núcleo. La cripto en Dart y
   sus pruebas se borran en la misma rama (ADR-0011).
5. Android: `.so` por ABI con `cargo-ndk` en la imagen de D. Windows: `solokey_core.dll` cruzada con `cargo-xwin`, que el build
   de Flutter del host empaqueta.

### NUC-2

1. Diseñar el formato (documentarlo en `arquitectura/ARQUITECTURA.md`): cabecera con versión y KDF; por registro, en claro solo
   id y versión; tipo, carpeta, fechas, orden y payload cifrados.
2. Migración al primer arranque de la v2: copia automática de la bóveda v1 (DB + almacén seguro + `secure_files/`), conversión,
   verificación de que todo descifra igual, y solo entonces se marca migrada. Si falla, la v1 queda intacta y se avisa.
3. Probar con los vectores de CAL-2 y con una **copia** de una bóveda real; nunca con la real.
4. Drift y sus pruebas se van cuando el núcleo maneje la BD.

### NUC-3

1. Noise (crate `snow`): elegir patrón (p. ej. IK con la llave del par fijada en el QR) y documentar el porqué.
2. Versión de protocolo en el primer mensaje; v1 contra v2: no se mezclan datos y la interfaz lo dice.
3. Se conserva QR, descubrimiento en la LAN y LWW (fecha, desempate por UUID). Cierra SEC-008.
