# Carril C · Pantallas y flujos (móvil y escritorio)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §4. Las pantallas se
arman con el kit de B; si falta una pieza, se pide a B (§Necesita), no se inventa en la pantalla.

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía: empieza cuando B tenga DIS-1 y DIS-2.

## Propuestas de la sesión (◇)

Una por flujo, en este orden. Cada una rehace la pantalla en móvil Y escritorio, con sus textos en es/en y sus widget tests.

| ID | Qué | Archivos de hoy | Esf. |
|---|---|---|---|
| PAN-1 ◇ | Acceso: splash, primer uso en 3 pasos, desbloqueo (biometría primero), recuperación | `vault_access/presentation/*` | L |
| PAN-2 ◇ | Bóveda: búsqueda fija, filtros con la ruta de carpetas, copiar en un toque; barra inferior de 3 | `home_screen`, `credential_card`, `favorites_view`, `folder_list_view` | L |
| PAN-3 ◇ | Detalle por tipo (TOTP en vivo, contraseña, SSH, nota, passkey, API key) | `credential_detail_screen`, `password_history_screen` | L |
| PAN-4 ◇ | Formulario crear y editar, con generador integrado y QR (cámara y pantalla) | `credential_form_screen` + `widgets/`, `qr_scanner_screen` | L |
| PAN-5 ◇ | Carpetas (árbol, mover, editar) dentro de la bóveda | `folder_screen`, `folder_tree` | M |
| PAN-6 ◇ | Seguridad: auditoría con el color de estado, HIBP opcional, rotación | `security_audit_screen`, `security_hub_view` | M |
| PAN-7 ◇ | Sync: vincular por QR, pares, "sincronizar ahora", qué se sincronizó | `pairing_screen`, `sync_summary_card` | M |
| PAN-8 ◇ | Ajustes, transferencia (importar y exportar), archivos seguros, passkeys, autofill | `settings_screen`, `transfer_screen`, `secure_files_*`, `passkeys_screen`, `autofill/*` | L |
| PAN-9 ◇ | Escritorio: tres paneles, Ctrl+K, atajos, Quick-Fill | `desktop_main_layout`, `command_palette`, `quick_fill_screen` | L |
| PAN-10 ◇ | Español como idioma fuente de los ARB y textos sin jerga (si DEC-4) | `l10n.yaml`, `lib/l10n/*.arb` | M |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| B | DIS-1 y DIS-2 (tokens y kit) | Todas |
| E | Prueba al 200% con datos largos por pantalla | Cada PAN |
