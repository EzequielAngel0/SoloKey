# Seguridad de SoloKey

Qué protege la app, contra qué, y lo que sigue abierto. Los controles técnicos en detalle están en
[`../arquitectura/ARQUITECTURA.md`](../arquitectura/ARQUITECTURA.md) §3 a §5; el porqué del cifrado, en
[ADR-0003](../adr/0003-cifrado-de-la-boveda.md). El modelo de amenazas completo de la v2 es SEG-1 (carril E).

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
| SEC-003 | La contraseña maestra viaja como `String` (inmutable, no se puede poner a cero) | ◐ Abierto en la v1: límite de Dart; se mitiga acortando su vida. Lo cierra el núcleo Rust de la v2 ([ADR-0008](../adr/0008-nucleo-en-rust.md), NUC-1) |
| SEC-004 | Ocultar en segundo plano venía apagado | ✓ Arreglado: `obscureOnBackground` en `true` por defecto |
| SEC-005 | El `android:label` no decía SoloKey | ✓ Arreglado |
| SEC-006 | Faltaba `allowBackup="false"` | ✓ Arreglado (también `fullBackupContent="false"`) |
| SEC-007 | El secreto TOTP quedaba en claro en el árbol de widgets | ◐ Mitigado: los secretos revelados se ocultan solos y al ir a segundo plano; revisar en SEG-1 |
| SEC-008 | La sync usa `ws://` sin TLS; la confidencialidad depende solo del cifrado por mensaje | ◐ Abierto en la v1: aceptable por el E2EE, pero se ven metadatos (tamaños, horas). Decidido: la v2 cifra el canal entero ([ADR-0010](../adr/0010-sync-v2-canal-cifrado.md), NUC-3) |

Los hallazgos 001 a 007 son de la auditoría del 2026-03-30 (v1.0.0); su estado se comprobó en el código el 2026-11-14. El
SEC-008 salió al revisar la arquitectura ese mismo día.

## 3. Reglas que no se rompen

- Nada de secretos en logs (`print`, `debugPrint`, errores, analítica). Lint `avoid_print` activo.
- Solo infraestructura cifra; la clave maestra vive en RAM lo mínimo.
- Ningún cambio al formato de la bóveda sin vectores de prueba de la versión anterior.
- Las pruebas de integración tocan la bóveda real: solo con `run_integration_tests.ps1`.

## 4. Lo que falta

| Qué | Dónde |
|---|---|
| Modelo de amenazas de la v2 y revisión con `security-audit` | SEG-1, [`../sesiones/E.md`](../sesiones/E.md) |
| Fuzz de lo que entra de fuera (CSV, `otpauth://`, `.skvault`, mensajes de sync) | SEG-2 |
| Passkeys reales (WebAuthn) | Plan y riesgos en [`WEBAUTHN.md`](WEBAUTHN.md); sin carril todavía |
