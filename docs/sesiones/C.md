# Carril C · Pantallas y flujos (móvil y escritorio)

Reglas y plantilla: [`README.md`](README.md). Experiencia aprobada: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §4 y
[ADR-0013](../adr/0013-diseno-idioma-y-experiencia-v2.md). Las pantallas se arman con el kit de B; si falta una pieza, se pide a B
(§Necesita), no se inventa en la pantalla.

## Aprobado, para desarrollar (en orden)

Empieza cuando B tenga DIS-1 y DIS-2. **Cada PAN** rehace el flujo en móvil Y escritorio, con sus textos en español (fuente) e
inglés, **su prueba E2E en Android y Windows** (con el harness de E) y **borra las pruebas Dart viejas** de lo que reemplaza
([ADR-0011](../adr/0011-pruebas-e2e-principal.md)).

| # | ID | Qué | Archivos de hoy | Esf. | Estado |
|---|---|---|---|---|---|
| 1 | PAN-10 | Español como idioma fuente (`template-arb-file: app_es.arb`) y textos sin jerga | `l10n.yaml`, `lib/l10n/*.arb` | M | ☐ |
| 2 | PAN-1 | Acceso: splash, primer uso en 3 pasos, desbloqueo (biometría primero), recuperación | `vault_access/presentation/*` | L | ☐ |
| 3 | PAN-2 | Bóveda: búsqueda fija, filtros con la ruta de carpetas, copiar en un toque; barra inferior de 3 | `home_screen`, `credential_card`, `favorites_view`, `folder_list_view` | L | ☐ |
| 4 | PAN-3 | Detalle por tipo (TOTP en vivo, contraseña, SSH, nota, passkey, API key) | `credential_detail_screen`, `password_history_screen` | L | ☐ |
| 5 | PAN-4 | Formulario crear y editar, con generador integrado y QR (cámara y pantalla) | `credential_form_screen` + `widgets/`, `qr_scanner_screen` | L | ☐ |
| 6 | PAN-5 | Carpetas (árbol, mover, editar) dentro de la bóveda | `folder_screen`, `folder_tree` | M | ☐ |
| 7 | PAN-6 | Seguridad: auditoría con el color de estado, HIBP opcional, rotación | `security_audit_screen`, `security_hub_view` | M | ☐ |
| 8 | PAN-7 | Sync: vincular por QR, pares, "sincronizar ahora", aviso v1/v2 | `pairing_screen`, `sync_summary_card` | M | ☐ |
| 9 | PAN-8 | Ajustes, transferencia, archivos seguros, passkeys, autofill | `settings_screen`, `transfer_screen`, `secure_files_*`, `passkeys_screen`, `autofill/*` | L | ☐ |
| 10 | PAN-9 | Escritorio: tres paneles, Ctrl+K, atajos, Quick-Fill | `desktop_main_layout`, `command_palette`, `quick_fill_screen` | L | ☐ |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| B | DIS-1 y DIS-2 (tokens, fuentes y kit) | Todas |
| E | Harness E2E de Android en Podman y de Windows con bóveda aislada (CAL-5) | La E2E de cada PAN |
| A | NUC-3 (protocolo v2) para el aviso entre v1 y v2 | PAN-7 |

## No reabre

| Qué | Por qué |
|---|---|
| Carpetas como pestaña propia | DEC-7: son un filtro de la bóveda |
| Menús de tres puntos o "mantener presionado" para lo frecuente | Nada escondido (skill `solokey` §3) |
