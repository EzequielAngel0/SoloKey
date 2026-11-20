# Carril A · Hecho

Lo terminado del carril A ([`../../sesiones/A.md`](../../sesiones/A.md)), una o dos líneas por ID. Detalle técnico en
[`../../../CHANGELOG.md`](../../../CHANGELOG.md).

| ID | Qué | Fecha | Verificado |
|---|---|---|---|
| SEC-012 | Parámetros de Argon2id acotados en el núcleo: techo 256 MiB, 8 pasadas, 8 hilos; piso de la v1 al leer, crear y cambiar la maestra | 2026-11-20 | `tests/cabecera_kdf.rs` en rojo sin el control y en verde con él; fuzz `cabecera_kdf` 180 s y los cinco objetivos 30 s, verdes |
| NUC-1 | Puente `flutter_rust_bridge` 2: `SecurityServiceImpl` usa la cripto del núcleo; DLL y `.so` desde Podman en `rust/dist`, empaquetados por CMake y Gradle; fuera la cripto Dart y su prueba | 2026-11-20 | cargo test, clippy y fmt limpios; analyze 0; 493 pruebas; cobertura 63,27; claves de la v1 iguales por el puente (rojo con `latin1`); DLL junto a `SoloKey.exe` |
