# Vectores de prueba de la bóveda v1 (CAL-2)

Lo que la app **v1** escribe en disco, generado con su propio código, para que el núcleo Rust de la v2 demuestre que la lee y
la migra sin perder nada (NUC-2, [ADR-0009](../../docs/adr/0009-formato-de-boveda-v2.md)). **Es una bóveda de prueba**: las
contraseñas y datos de aquí no son de nadie y pueden estar en un repo público.

## Qué hay

| Archivo | Qué es |
|---|---|
| `vectores.json` | Entradas y salidas: contraseña maestra (y una incorrecta), `master_key_config`, clave derivada, código de recuperación, todo el almacén seguro, vectores sueltos de Argon2id y AES-GCM, doble cifrado con PIN, el JSON en claro de cada payload, cada fila de cada tabla (BLOB en hex) y los archivos seguros en claro |
| `boveda/vault_guard_db.sqlite` | La BD drift tal cual (esquema v10, `PRAGMA user_version`) |
| `boveda/secure_files/*.enc` | Los archivos seguros cifrados (`nonce ‖ ct ‖ tag` con la clave de la bóveda) |
| `boveda/export.skvault` | Una exportación (`SKVE2`, sal propia, Argon2id 64 MiB, 3, 2) con su contraseña en `vectores.json` |

El almacén seguro (Keystore en Android, DPAPI en Windows) no se puede copiar como archivo fuera de su equipo: va como mapa
clave → valor en `vectores.json` (`boveda.secureStorage`), que es lo que la migración leerá por el plugin.

## Rarezas de la v1 que la migración tiene que copiar

| Rareza | Detalle |
|---|---|
| La maestra entra a Argon2id con **doble codificación UTF-8** | La v1 pasa `String.fromCharCodes(utf8.encode(pw))`, que la librería vuelve a codificar: bytes = UTF-8 → Latin-1 → UTF-8. Con solo ASCII no se nota; con `ñ` o emoji, sí. `kdf[].kdfInputHex` trae los bytes exactos |
| El PIN del doble cifrado y la contraseña de exportación | Van en UTF-8 simple (sin la doble codificación) |
| Carpeta de una credencial | En `category_id`; `folder_id` está en desuso |
| Doble cifrado | `double_enc_v1:<sal b64>:<blob b64>`, Argon2id 32 MiB, 2, 2 |
| Código de recuperación | Es la clave que envuelve a la de la bóveda, en base64 sin `=` y en grupos de 4 con guiones; `recovery_encrypted_master` = AES-GCM(código, clave) |

## Cubre

Los seis tipos de credencial (contraseña, API key, nota, TOTP, passkey de respaldo, SSH), una solo con título, campos
personalizados secretos y no, doble cifrado con PIN (`double_enc_v1:`), oculta, favorita, orden manual, rotación
personalizada, historial de contraseñas, carpetas anidadas (y la rareza de la v1: la carpeta de una credencial vive en
`category_id`, `folder_id` está en desuso), una categoría heredada, texto con acentos, `ñ` y emoji, una nota larga, un archivo
vacío y uno binario.

## Cómo se regeneran

Desde `main` (la v1; en develop ya no está drift, NUC-2):

```powershell
.\tool\vectores_v1\generar.ps1
```

Corre `tool/vectores_v1/generar_vectores.dart` (el código real de setup, repositorios, exportación, recuperación y doble cifrado)
en la imagen de CI de Linux (`tool/ci-linux.ps1`), donde la bóveda real del dueño no existe. Al final relee todo con la v1
(desbloqueo desde cero, archivos, exportación, doble cifrado) y falla si algo no vuelve igual. Cada corrida cambia sales, nonces
e ids aleatorios: regenerar solo si cambia lo que la v1 escribe, nunca para "actualizar".

Para comprobarlos sin Dart (Python en Podman, rederiva y descifra todo y lo compara con `vectores.json`):

```powershell
.\tool\vectores_v1\verificar.ps1
```

No es una prueba de Dart ni entra en los gates ([ADR-0011](../../docs/adr/0011-pruebas-e2e-principal.md)): es la herramienta que
produce los datos; las pruebas que los usan son las de Rust del núcleo y la E2E `integration_test/migracion_v1_test.dart`.
