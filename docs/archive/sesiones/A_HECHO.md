# Carril A · Hecho

Lo terminado del carril A ([`../../sesiones/A.md`](../../sesiones/A.md)), una o dos líneas por ID. Detalle técnico en
[`../../../CHANGELOG.md`](../../../CHANGELOG.md).

| ID | Qué | Fecha | Verificado |
|---|---|---|---|
| NUC-3 | Sync v2: la app usa el canal Noise IK y el delta LWW del núcleo; QR v2 con llave estática y token de un uso (10 min); control dentro del canal; aviso claro entre v1 y v2; fuera `DeltaSyncManager` y el canal de Dart | 2026-11-20 | cargo test (38), clippy y fmt; analyze 0; 422 pruebas; cobertura 61,84; E2E `sync_v2_test` verde en el runner (los dos papeles) y en rojo con el token reusable (línea 140); bóveda real restaurada con hash |
| SEC-012 | Parámetros de Argon2id acotados en el núcleo: techo 256 MiB, 8 pasadas, 8 hilos; piso de la v1 al leer, crear y cambiar la maestra | 2026-11-20 | `tests/cabecera_kdf.rs` en rojo sin el control y en verde con él; fuzz `cabecera_kdf` 180 s y los cinco objetivos 30 s, verdes |
| NUC-2 | Bóveda v2 en el núcleo (formato, migración única con copia previa) y la app sobre ella por `VaultStore`; fuera drift; sync con delta sobre registros; rotación con agenda sin secretos; `rusqlite` 0.41.1 | 2026-11-20 | cargo test, clippy y fmt; analyze 0; 435 pruebas; cobertura 60,45 con lo de B (piso 60,4); E2E de Windows verdes (migración de los vectores, crear dos veces) y en rojo sin borrar las claves de la v1; bóveda real restaurada con hash |
| NUC-6 | `SOLOKEY_DATA_DIR` (ignorado en release): bóveda, v1 a migrar y almacén en archivo en una carpeta aislada; `resetVault` solo borra ahí | 2026-11-20 | Las E2E del runner corrieron aisladas; la carpeta real sin `solokey.vault` después |
| NUC-1 | Puente `flutter_rust_bridge` 2: `SecurityServiceImpl` usa la cripto del núcleo; DLL y `.so` desde Podman en `rust/dist`, empaquetados por CMake y Gradle; fuera la cripto Dart y su prueba | 2026-11-20 | cargo test, clippy y fmt limpios; analyze 0; 493 pruebas; cobertura 63,27; claves de la v1 iguales por el puente (rojo con `latin1`); DLL junto a `SoloKey.exe` |
