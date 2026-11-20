# Seguridad de SoloKey

Qué protege la app, contra qué, y lo que sigue abierto. Los controles técnicos en detalle están en
[`../arquitectura/ARQUITECTURA.md`](../arquitectura/ARQUITECTURA.md) §3 a §5; el porqué del cifrado, en
[ADR-0003](../adr/0003-cifrado-de-la-boveda.md). El modelo de amenazas de la v2, con lo que cada carril tiene que cumplir:
[`AMENAZAS_V2.md`](AMENAZAS_V2.md).

## 1. Qué cubre y qué no

| Amenaza | Cubre | Cómo |
|---|---|---|
| Roban el archivo de la bóveda o el equipo apagado | Sí | Argon2id + AES-256-GCM; sin la maestra no se abre |
| Alguien toma el equipo desbloqueado | En parte | Bloqueo por inactividad y al ir a segundo plano; revelar o copiar pide biometría o PIN |
| Capturas de pantalla y vista de apps recientes (Android) | Sí | `FLAG_SECURE` y ocultar en segundo plano (activado por defecto) |
| Portapapeles leído por otra app | En parte | Se limpia solo tras N segundos (`ClipboardService`) |
| Teclado con registro de teclas | En parte | Teclado seguro barajado para la maestra |
| Fuerza bruta de la maestra en la app | Sí | Retardos crecientes y borrado opcional tras N intentos |
| Otro equipo en la misma Wi-Fi | Sí | Mensajes de sync cifrados con `K_sync`; emparejar exige el QR |
| Malware con permisos en el equipo desbloqueado | **No** | Fuera del alcance de una app; lo dice la política de privacidad |
| Volcado de RAM con la bóveda abierta | **No** del todo | La clave se borra al bloquear; los `String` de Dart no (SEC-003) |

## 2. Hallazgos

| ID | Qué | Estado |
|---|---|---|
| SEC-001 | El código de recuperación iba al portapapeles sin limpieza | ✓ Arreglado: ya no hay `Clipboard.setData` fuera de `ClipboardService` |
| SEC-002 | El archivo temporal del export quedaba tras compartirlo | ✓ Arreglado: se borra tras el share (`vault_export_service.dart`) |
| SEC-003 | La contraseña maestra viaja como `String` (inmutable, no se puede poner a cero) | ◐ Mitigado al máximo de Dart: desde NUC-2 (2026-11-20) la bóveda se abre en el núcleo y la clave no vive en Dart (solo el `VaultHandle`; `keyCopy()` para la biometría se borra tras usarse). Queda el `String` que se teclea, que Dart no deja poner a cero ([ADR-0008](../adr/0008-nucleo-en-rust.md)) |
| SEC-004 | Ocultar en segundo plano venía apagado | ✓ Arreglado: `obscureOnBackground` en `true` por defecto |
| SEC-005 | El `android:label` no decía SoloKey | ✓ Arreglado |
| SEC-006 | Faltaba `allowBackup="false"` | ✓ Arreglado (también `fullBackupContent="false"`) |
| SEC-007 | El secreto TOTP quedaba en claro en el árbol de widgets | ◐ Mitigado: los secretos revelados se ocultan solos y al ir a segundo plano. Requisito de la v2 (el núcleo da el valor al revelar y se suelta al ocultar): [`AMENAZAS_V2.md`](AMENAZAS_V2.md) §RAM |
| SEC-008 | La sync usa `ws://` sin TLS; la confidencialidad depende solo del cifrado por mensaje | ◐ Abierto en la v1: aceptable por el E2EE, pero se ven metadatos (tamaños, horas). ✓ Cerrado en la v2 (NUC-3, 2026-11-20): la app usa el canal Noise IK del núcleo ([ADR-0010](../adr/0010-sync-v2-canal-cifrado.md)); en claro solo el saludo `SKS2` y el descubrimiento |
| SEC-009 | **Recuperar con el código deja la bóveda ilegible**: `resetMasterPassword` deriva la clave nueva de la contraseña nueva con la sal vieja y no re-cifra nada; además cambia el código por uno nuevo que nunca se muestra y no aplica la doble codificación de la maestra | ✓ Arreglado en la v2 (NUC-2, 2026-11-20): la app recupera por el núcleo, que re-envuelve la DEK sin re-cifrar (`vault.rs`, prueba `recuperar_con_codigo_conserva_los_datos`). **En la v1.1.0 sigue roto: no usar la recuperación ahí** (reproducido: 0 de 1 credenciales legibles tras recuperar) |
| SEC-010 | `bio_master_key` es la clave de la bóveda en base64 en el almacén seguro; la biometría es solo una pantalla delante (también en el autofill) | ◐ Abierto en la v1: el almacén seguro la protege de otras apps, no de quien tenga la sesión del usuario. La v2 la envuelve con una llave del sistema que exige la biometría (A + D) |
| SEC-011 | Lo copiado no se marca como sensible: Android 13+ enseña la vista previa y el historial de Windows (Win+V, y su sync en la nube) lo guarda | ◐ Abierto en la v1: se limpia a los N segundos, pero el historial de Windows conserva la copia. La v2 marca el contenido (D + C) |
| SEC-012 | El núcleo de la v2 lee de la cabecera de la bóveda los parámetros de Argon2id y los usa sin límites | ✓ Arreglado (2026-11-20): rango acotado al crear, abrir y cambiar la maestra (piso: los de la v1; techo: 256 MiB, 8 pasadas, 8 hilos); prueba `tests/cabecera_kdf.rs` y fuzz `cabecera_kdf` en verde. Era: memoria `4294967295` KiB aborta el proceso (pide 4 TiB), iteraciones `4294967295` lo cuelgan y `8` KiB con 1 pasada se acepta (fuerza bruta barata si alguien cambia la cabecera). |

Los hallazgos 001 a 007 son de la auditoría del 2026-03-30 (v1.0.0); su estado se comprobó en el código el 2026-11-14. El
SEC-008 salió al revisar la arquitectura ese mismo día. SEC-009 a 011 salieron del modelo de amenazas de la v2 (SEG-1,
2026-11-15); SEC-012, del fuzz del núcleo (SEG-2, 2026-11-19).

## 3. Reglas que no se rompen

- Nada de secretos en logs (`print`, `debugPrint`, errores, analítica). Lint `avoid_print` activo.
- Solo infraestructura cifra; la clave maestra vive en RAM lo mínimo.
- Ningún cambio al formato de la bóveda sin vectores de prueba de la versión anterior.
- Las pruebas de integración van con datos aislados (`SOLOKEY_DATA_DIR`, NUC-6) y aun así solo con `run_integration_tests.ps1`.

## 4. Lo que falta

| Qué | Dónde |
|---|---|
| Cumplir los requisitos del modelo de amenazas | Cada carril, fila por fila: [`AMENAZAS_V2.md`](AMENAZAS_V2.md) |
| Fuzz de lo que entra de fuera (CSV, `otpauth://`, `.skvault`, mensajes de sync) | SEG-2 |
| Escaneo diario de dependencias (OSV, `pub outdated`, Dependabot) | La sesión general: `tool/escaneo-deps.ps1` (PLA-6) |
| Passkeys reales (WebAuthn) | Plan y riesgos en [`WEBAUTHN.md`](WEBAUTHN.md); sin carril todavía |
