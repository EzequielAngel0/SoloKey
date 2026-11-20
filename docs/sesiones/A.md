# Carril A · Núcleo (cripto, bóveda, BD, sync en Rust)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md). Decisiones:
[ADR-0008](../adr/0008-nucleo-en-rust.md) (núcleo Rust), [0009](../adr/0009-formato-de-boveda-v2.md) (formato),
[0010](../adr/0010-sync-v2-canal-cifrado.md) (sync), [0011](../adr/0011-pruebas-e2e-principal.md) (pruebas),
[0012](../adr/0012-todo-en-podman.md) (Podman).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | NUC-2 | Formato de bóveda v2 (SQLite con `rusqlite`, cabecera versionada, metadatos cifrados) y migración única desde la v1 con copia previa | XL | ◐ Rust hecho (formato, migración con vectores); falta Dart | [ver](#nuc-2) |
| 2 | NUC-3 | Sync v2 en el núcleo: canal Noise con llaves fijadas en el QR, protocolo versionado, LWW, aviso claro entre v1 y v2 | XL | ◐ Rust hecho (canal IK, delta LWW); falta Dart | [ver](#nuc-3) |
| 3 | NUC-6 | Directorio de datos configurable (bóveda aislada para E2E); la ruta real solo sin la bandera de prueba | S | ☐ | Lo pide E (CAL-5); va con NUC-2 |
| 4 | NUC-5 | Passkeys reales (WebAuthn, proveedor de Credential Manager en Android) | XL | ⊘ después de la v2.0.0 | [`../seguridad/WEBAUTHN.md`](../seguridad/WEBAUTHN.md) |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| D | `cargo-expand` en la etapa Rust de `solokey-build`: `rust/puente.ps1` lo instala en cada corrida | Regenerar el puente rápido |
| E | `tool/vectores_v1/generar_vectores.dart` ya usa el núcleo (no queda cripto Dart): la verdad de la v1 se regenera desde `main` | Saberlo si se rehacen los vectores |

## No reabre

| Qué | Por qué |
|---|---|
| Nube o servidor propio para sincronizar | Local-first es la promesa del producto (ADR-0001) |
| NUC-0, prototipo comparativo de R1 | El dueño eligió R1 directo (2026-11-15) |
| NUC-4, endurecer el borrado en Dart | Era para R0; con el núcleo en Rust no aplica |
| `rustup` en el host | Todo Rust en Podman (ADR-0012) |

## Detalle

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
