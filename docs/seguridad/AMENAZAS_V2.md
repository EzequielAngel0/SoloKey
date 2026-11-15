# Modelo de amenazas de la v2 (SEG-1)

Contra qué se defiende la v2 y qué tiene que cumplir cada pieza para lograrlo. Es un modelo **de diseño**: la v2 aún no
existe en código, así que cada fila dice cómo está la v1 hoy y qué **requisito** deja para el carril que construye esa parte.
Los hallazgos con ID viven en [`SEGURIDAD.md`](SEGURIDAD.md) §2; las decisiones, en [ADR-0008](../adr/0008-nucleo-en-rust.md),
[0009](../adr/0009-formato-de-boveda-v2.md) y [0010](../adr/0010-sync-v2-canal-cifrado.md). Hecho el 2026-11-15 con la skill
`security-audit` (modo guía), leyendo el código de la v1.1.0.

## 1. Qué se protege y de quién

| Activo | Dónde vive |
|---|---|
| Contraseña maestra | Solo en la cabeza del usuario; en RAM mientras se deriva la clave |
| Clave de la bóveda (32 B) | RAM con la bóveda abierta; envuelta por el código de recuperación y por la biometría en el almacén seguro |
| Secretos (contraseñas, TOTP, SSH, notas, archivos) | Cifrados en disco; en claro en RAM y en pantalla al revelar o copiar |
| Metadatos (qué hay, cuándo cambió, carpetas) | v1: en claro en la BD; v2: cifrados ([ADR-0009](../adr/0009-formato-de-boveda-v2.md)) |
| Llaves de sync de cada par | Almacén seguro del sistema |

| Atacante | Puede | No se defiende |
|---|---|---|
| Ladrón del equipo apagado o de una copia del disco | Leer todos los archivos | |
| Alguien con el equipo desbloqueado un rato | Tocar la pantalla, abrir la app | |
| Otro equipo en la misma Wi-Fi | Ver y mandar tráfico en la LAN | |
| Otra app sin privilegios en el mismo equipo | Leer el portapapeles, el historial de portapapeles, capturas | |
| Un archivo de fuera (CSV, `.skvault`, QR) hecho a propósito | Llegar a los parsers | |
| Malware con los permisos del usuario o de administrador | Todo lo que el usuario puede | **Fuera de alcance**: se dice en la política de privacidad |

## 2. Amenazas por superficie

Estado de la v1: ✓ cubierto · ◐ en parte · ✗ no. La columna *Requisito v2* es lo que el carril tiene que construir y probar.

### RAM

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Volcado de memoria con la bóveda abierta lee la clave o la maestra | ◐ `SessionManager` pone a cero; los `String` de Dart no (SEC-003) | La maestra entra al núcleo como bytes y se borra con `zeroize` tras el KDF; la clave y el índice de metadatos viven solo en Rust y se borran al bloquear; Flutter nunca recibe la clave | A (NUC-1, NUC-2) |
| Un secreto revelado queda en el árbol de widgets | ◐ se oculta solo y al ir a segundo plano (SEC-007) | Revelar pide el valor al núcleo en el momento y lo suelta al ocultar; nada de secretos en el estado de Riverpod | C |
| Archivo de intercambio o volcado de error con secretos | ✗ sin control | Bloques con secretos marcados no paginables cuando el SO lo permita (`mlock`/`VirtualLock`, sin fallar si no); ningún secreto en mensajes de error ni en `Debug` de Rust | A |

### Disco

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Robo del archivo: fuerza bruta de la maestra | ✓ Argon2id 64 MiB, 3, 4 | Parámetros en la cabecera versionada; nunca por debajo de los de la v1 | A (NUC-2) |
| Robo del archivo: se ve qué hay y cuándo cambió | ✗ tipo, carpeta, fechas y orden en claro | Solo id y versión en claro (ADR-0009) | A (NUC-2) |
| Manipular la BD (cambiar filas, mover un blob a otro registro) | ◐ GCM detecta cambios del blob, pero no que se cambió de fila | AES-GCM con el id del registro y la versión como datos asociados (AAD) | A (NUC-2) |
| Restos de la v1 tras migrar | ✗ (no hay migración) | La copia previa queda cifrada como estaba; la v1 migrada se borra solo cuando el usuario lo confirma y se dice dónde queda la copia | A (NUC-2) |
| Clave de la biometría legible sin biometría | ✗ `bio_master_key` es la clave en base64 en el almacén seguro; la biometría solo es un paso de interfaz (SEC-010) | Envolver la clave con una llave del sistema que exija la biometría: Keystore con `setUserAuthenticationRequired` en Android, Windows Hello (`KeyCredentialManager`) en Windows | A + D |
| Respaldos del sistema se llevan la bóveda | ✓ `allowBackup="false"` (SEC-006) | Igual en la v2 (lo revisa D al tocar el manifiesto) | D |

### Portapapeles y pantalla

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Otra app lee lo copiado | ◐ se limpia a los N segundos | Igual, y limpiar al bloquear la bóveda | C |
| El sistema muestra o guarda lo copiado (SEC-011) | ✗ Android 13+ enseña la vista previa; el historial de Windows (Win+V) y su sincronización en la nube lo guardan | Android: `ClipDescription.EXTRA_IS_SENSITIVE`; Windows: formatos `ExcludeClipboardContentFromMonitorProcessing` y `CanIncludeInClipboardHistory = 0`. Requiere un canal nativo (D) | D + C |
| Capturas y apps recientes | ✓ `FLAG_SECURE` y ocultar en segundo plano (SEC-004) | Igual; en Windows, `SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)` mientras haya un secreto a la vista | D |

### Sync (Noise)

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Ver tamaños, horas y forma del intercambio | ✗ `ws://` (SEC-008) | Canal Noise entero; solo el descubrimiento en claro (ADR-0010) | A (NUC-3) |
| Suplantar a un par ya emparejado | ✓ reto HMAC con `K_sync` | Patrón con las dos llaves estáticas fijadas (KK o IK tras el emparejamiento); llave del par mal = se corta y se dice | A (NUC-3) |
| Emparejamiento interceptado | ◐ token de un uso en el QR | El QR lleva la llave estática y un secreto de un uso que entra al handshake (PSK); caduca en minutos | A (NUC-3) |
| Repetir o reordenar mensajes viejos | ◐ LWW por fecha | Contador por sesión en el canal y versión por registro; un registro con versión vieja no pisa uno nuevo | A (NUC-3) |
| Mezclar v1 y v2 | n/a | Versión en el primer mensaje; v1 con v2 se rechaza con un mensaje claro (ADR-0010) | A (NUC-3) |
| Desbloqueo remoto: la clave viaja | ◐ envuelta con la llave del par | Igual, dentro de Noise, con confirmación en el celular que muestre qué equipo pide | A + C |
| Mensaje enorme o malformado tumba al otro | ✗ sin límites | Tamaño máximo por mensaje y por registro antes de descifrar; parser cubierto por fuzz | A + E (SEG-2) |

### Migración v1 a v2

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Se pierde un registro al convertir | n/a | Copia previa automática; convertir, descifrar todo de nuevo y comparar uno a uno antes de dar la v1 por migrada (ADR-0009); se prueba con los vectores de CAL-2 ([`../../vectores/v1/`](../../vectores/v1/LEEME.md)) | A (NUC-2) |
| Una bóveda v1 a medio escribir o corrupta | n/a | Si un registro no descifra, la migración se detiene, la v1 queda intacta y se dice cuál | A (NUC-2) |
| Rarezas de la v1 | n/a | La maestra de la v1 entra a Argon2id con doble codificación UTF-8 (sin copiarla, quien use `ñ` o emoji no abre su bóveda; la v2 usa UTF-8 simple tras migrar); la carpeta de una credencial está en `category_id`; los campos `double_enc_v1:` se migran tal cual (siguen pidiendo su PIN); el historial y los archivos seguros también | A (NUC-2) |

### Lo que entra de fuera

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| CSV, `otpauth://`, QR o `.skvault` hecho para tumbar o colgar la app | ✗ parsers en Dart sin límites | Parsers en el núcleo con tamaño máximo, sin recursión sin límite y con fuzz en Podman | A + E (SEG-2) |
| `.skvault` con parámetros de KDF absurdos (memoria enorme) | n/a (fijos en la v1) | Si la v2 los guarda en la cabecera, aceptar solo un rango acotado | A |
| Importar mete un secreto en un campo que se muestra | ◐ | La importación nunca pone secretos en el título ni en campos en claro | A |

### Recuperación y bloqueo

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Recuperar con el código borra el acceso a todo (SEC-009) | ✗ la clave nueva sale de la contraseña nueva y no se re-cifra nada; el código nuevo nunca se muestra | La clave de la bóveda es aleatoria y fija; la maestra y el código de recuperación solo la **envuelven**. Cambiar la maestra o recuperar = re-envolver, sin tocar los registros; un código nuevo se muestra y se confirma | A (NUC-2) + C |
| Fuerza bruta en la app | ✓ retardos y borrado opcional | Igual; el contador vive en el núcleo y no se reinicia cerrando la app | A |
| Equipo desbloqueado y abandonado | ✓ bloqueo por inactividad y en segundo plano | Igual | C |

### Pruebas y herramientas

| Amenaza | v1 | Requisito v2 | Carril |
|---|---|---|---|
| Una prueba borra la bóveda real | ◐ solo con `run_integration_tests.ps1` (respaldo con hash, CAL-4) | Directorio de datos aislado para las E2E (NUC-6, CAL-5) | A + E |
| Secretos en logs | ✓ lint `avoid_print` | Igual en Dart; en Rust, tipos de secreto sin `Debug`/`Display` y prueba que lo verifique | A |

## 3. Lo que se revisa al cerrar cada pieza

Cada carril, al cerrar el ID que toca una fila, vuelve aquí, cambia la fila a lo construido y enlaza su prueba (cargo test,
E2E o fuzz). Una fila sin prueba no se da por cubierta.
