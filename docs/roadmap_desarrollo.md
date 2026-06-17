# Roadmap de Desarrollo — SoloKey

> Documento vivo. Recoge **todo lo acordado** para los próximos lotes de trabajo:
> sistema de temas, renombrado de package, mejoras móvil/escritorio, seguridad,
> i18n y conclusiones de auditoría. Fecha de creación: **2026-06-17**.
>
> Convención de commits del proyecto: **una sola línea**, `tipo(ambito): desc`,
> español sin acentos (ASCII), sin pies de firma. Cada lote debe dejar el repo
> **compilando** (`flutter analyze` 0 errores) y con **tests en verde**.

---

## 0. Estado y decisiones tomadas

| Decisión | Valor acordado |
| :--- | :--- |
| Enfoque de temas | **Centralizar primero, luego activar** (sin estados rotos intermedios) |
| Primeros lotes de features (tras temas) | **(1) Rename package** y **(2) Móvil: acciones de notificación + autofill** |
| Sincronización | **Se conserva** (es E2EE sólida); solo se endurece el WiFi-unlock |
| SSH key gen | **Sin cambios** (usa CSPRNG correcto) |
| Passkeys | **Reetiquetar** como "respaldo de passkey" (no es FIDO2 real aún) |
| Package name | `com.angelezequiel.solokey` |
| Paleta | **Sin neón**, sencilla de ver; 4 temas: claro / oscuro / dim / oled + seguir sistema |

Leyenda de estado: ⬜ pendiente · 🟦 en progreso · ✅ hecho.

---

## 1. Sistema de Temas (claro / oscuro / dim / oled + sistema)

### 1.1 Realidad del alcance
- **518** literales `Color(0x…)` hardcodeados en **31** archivos.
- **105** referencias a `AppColors.*` en **8** archivos.
- **195** usos de `Colors.white` + algunos `Colors.black/transparent/red`.
- Total ≈ **~820 referencias de color** a centralizar en ~**39** archivos.

### 1.2 Inventario de colores únicos (conteo real)

| Hex | Usos | Rol semántico propuesto |
| :--- | ---: | :--- |
| `0xFF6C63FF` | 91 | `accent` / brand primario (indigo) |
| `0xFF9E9EBF` | 68 | `textMuted` |
| `0xFFCF6679` | 59 | `danger` |
| `0xFF4CAF50` | 40 | `success` / `typePasskey` |
| `0xFF2A2A4A` | 33 | `divider` / `textEmpty` |
| `0xFF5C5C7A` | 31 | `textDisabled` |
| `0xFF39FF14` | 30 | **(NEÓN — eliminar)** → pasa a `accent` indigo |
| `0xFF1A1A2E` | 30 | `drawer` |
| `0xFF16213E` | 23 | `card` |
| `0xFFFFB74D` | 15 | `warning` |
| `0xFFFF3366` | 13 | `error` |
| `0xFFE91E8C` | 12 | `typeTotp` |
| `0xFF03DAC6` | 11 | `secondary` / `typeApiKey` |
| `Colors.white` | 195 | `textPrimary` / `onPrimary` (según contraste) |
| *cola larga* (0xFF1E1E30, 0xFF1F1F30, 0xFF222232, 0xFF0F0F23, 0xFF13131F, …) | 1–6 c/u | **superficies casi-duplicadas** → consolidar en `surface`/`card`/`cardDark`/`background` |

> La "cola larga" de ~20 tonos oscuros casi idénticos (variaciones de
> `#1x1x2x` y `#0x0x1x`) es deuda técnica: se consolidan a 4 roles de
> superficie (`background`, `surface`, `card`, `cardDark`).

### 1.3 Roles de la paleta (fuente única de verdad)

`AppPalette extends ThemeExtension<AppPalette>` con estos campos:

```
Branding:  primary, accent, secondary, onPrimary
Surfaces:  background, surface, card, cardDark, drawer, divider
Texto:     textPrimary, textBody, textMuted, textDisabled, textEmpty
Semántico: danger, error, warning, success, info
Tipos:     typePassword, typeApiKey, typeNote, typeTotp, typePasskey, typeSshKey
Overlays:  scrim (negro alpha), shimmerBase, shimmerHighlight
```

Acceso: `extension PaletteX on BuildContext { AppPalette get palette => Theme.of(context).extension<AppPalette>()!; }`
Uso en widgets: `context.palette.card`, `context.palette.textMuted`, etc.

### 1.4 Paletas objetivo (SIN neón, sencillas)

| Rol | Claro | Oscuro (default) | Dim | OLED |
| :--- | :--- | :--- | :--- | :--- |
| `primary`/`accent` | `#5B54E0` | `#6C63FF` | `#8C84FF` | `#6C63FF` |
| `background` | `#F6F6FB` | `#14141C` | `#1B1B24` | `#000000` |
| `surface` | `#FFFFFF` | `#1E1E2C` | `#24242F` | `#0A0A0F` |
| `card` | `#F1F1F7` | `#1A1A2E` | `#20202B` | `#0D0D14` |
| `cardDark` | `#E8E8F0` | `#13131F` | `#181820` | `#060609` |
| `divider` | `#E2E2EC` | `#2A2A4A` | `#30303E` | `#1A1A22` |
| `textPrimary` | `#13131F` | `#ECECF5` | `#E0E0EC` | `#F2F2F8` |
| `textMuted` | `#5C5C7A` | `#9E9EBF` | `#9A9AB5` | `#9A9AB5` |
| `danger` | `#B3261E` | `#CF6679` | `#CF6679` | `#CF6679` |
| `success` | `#2E7D32` | `#4CAF50` | `#4CAF50` | `#4CAF50` |
| `warning` | `#B26A00` | `#FFB74D` | `#FFB74D` | `#FFB74D` |
| `info` | `#0277BD` | `#4FC3F7` | `#4FC3F7` | `#4FC3F7` |

> Sin verdes neón ni cian eléctrico. El cian de SSH (`#00E5FF`) se suaviza a
> `#00B8D4`. El acento indigo `#6C63FF` (ya el más usado, 91 veces) pasa a ser
> el color de marca, reemplazando al neón.

### 1.5 Plan por lotes (cada uno compila y se ve igual hasta el Lote 3)

- **Lote 1 — Infraestructura** ⬜
  - Crear `lib/theme/app_palette.dart` (`AppPalette` ThemeExtension + `context.palette`).
  - Instancia `AppPalette.dark` con los **valores actuales exactos** (look idéntico).
  - Registrar la extensión en `AppTheme.dark()`. Verificar `analyze` + tests.
- **Lote 2 — Migración (sin cambiar el look)** ⬜
  - Reemplazar `AppColors.X` → `context.palette.X` (8 archivos).
  - Mapear los 518 literales `Color(0x…)` → `context.palette.<rol>` por hex (31 archivos), en sub-tandas por carpeta:
    1. `lib/shared/widgets/**` y `lib/theme/**`
    2. `lib/features/credentials/**`
    3. `lib/features/vault_access/**` + `settings` + `sync` + `folders` + `passkeys`
  - Casos sin contexto (constructores `const`, helpers estáticos): quitar `const` o pasar el color por parámetro.
- **Lote 3 — Activación** ⬜
  - `enum AppThemeMode { system, light, dark, dim, oled }`.
  - `AppPalette.light/.dim/.oled` + `AppTheme.build(mode)` → 4 `ThemeData` con `ColorScheme` y temas de componentes coherentes (de-neon aquí).
  - `ThemeNotifier` (Riverpod) + persistencia en `AppSecuritySettings` (nuevo campo `themeMode`).
  - `App` resuelve el `ThemeData` reactivo (sistema vía `MediaQuery.platformBrightnessOf`).
  - Selector en `SettingsScreen` (4 temas + "Seguir el sistema").

---

## 2. Renombrado de package → `com.angelezequiel.solokey`

Estado actual: `applicationId/namespace = com.vaultguard` (Android). Pasos:

- ⬜ `android/app/build.gradle(.kts)`: `namespace` y `applicationId` → `com.angelezequiel.solokey`.
- ⬜ Mover `android/app/src/main/kotlin/com/vaultguard/…` → `…/com/angelezequiel/solokey/…` y actualizar `package` en `MainActivity.kt` y `SoloKeyAutofillService.kt`.
- ⬜ `AndroidManifest.xml`: las referencias `.MainActivity` / `.SoloKeyAutofillService` son relativas al namespace → se resuelven solas; verificar.
- ⬜ Revisar `debug/` y `profile/` `AndroidManifest` si existen.
- ⬜ Verificación: `flutter analyze` + `flutter build apk --debug` (build puede tardar).
- ℹ️ El **nombre del paquete Dart** (`pubspec.yaml: name: password_manager`) es independiente; renombrarlo a `solokey` es opcional y de mayor alcance (toca todos los `import 'package:…'`). **No** incluido salvo que se pida.

---

## 3. Móvil — Acciones de notificación + Autofill

- ⬜ **Acciones de notificación de rotación** (cierra el gap con `password_rotation_reminders.md`):
  - Botón **[Cambiar contraseña]** → abre el detalle/edición de la credencial (deep-link ya existe vía `rootNavigatorKey`).
  - Botón **[Posponer 3 días]** → escribe `lastRotationPromptedAt = now + 3d` (o un campo `snoozeUntil`) para silenciar.
  - `AndroidNotificationDetails(actions: [...])` + manejar `notificationResponse.actionId` en `_onMobileTap` y en el isolate de fondo.
- ⬜ **Autofill inline (Android 11+)**: `inlinePresentation` en `SoloKeyAutofillService` para sugerencias dentro del teclado.
- ⬜ **Biometría antes de inyectar**: `AuthHelper.requireAuth()` previo a entregar credenciales al campo destino.

---

## 4. Escritorio (lote posterior)

- ⬜ **Autostart al tray**: `launch_at_startup` + arranque minimizado; toggle en Settings. Es lo que hace ÚTILES las notificaciones de rotación en desktop (hoy solo corren si la app está abierta).
- ⬜ **Hotkey global tipo spotlight**: `hotkey_manager` para buscar/copiar sin abrir la ventana.
- ⬜ **Instalador MSIX**: `msix` (dev dep) + config en `pubspec.yaml`; arregla ícono/título de los toasts de Windows y habilita distribución (requiere certificado para firmar).

---

## 5. Seguridad (lote posterior)

- ⬜ **Anti-fuerza bruta**: contador de intentos fallidos en `UnlockScreen` con bloqueo escalonado (backoff) y **wipe opcional** tras N intentos (configurable en Settings).
- ⬜ **Backup cifrado programado**: export `.skvault` automático al almacenamiento elegido por el usuario (no servidor propio), con `share_plus`/`file_picker` ya presentes.
- ⬜ **Endurecer sync WiFi-unlock**: dejar de enviar la master password al escritorio; enviar un **token de desbloqueo de un solo uso**. Opcional: `wss://` con TLS autofirmado para ocultar metadata.

---

## 6. i18n (último, por ser mecánico)

- ⬜ `flutter_localizations` + `gen-l10n` + archivos ARB (`es`, `en`).
- ⬜ Extraer todos los strings hardcodeados (depende de tener pantallas estables tras los temas).

---

## 7. Conclusiones de auditoría (ya revisadas)

- ✅ **SSH (`ssh_key_generator_service.dart`)**: `Ed25519().newKeyPair()` (CSPRNG del paquete `cryptography`); `Random.secure()` solo para el `checkint` (no secreto). **Correcto, sin cambios.**
- ✅ **Sync (`sync_service.dart`)**: E2EE real — X25519 ECDH + token QR fuera de banda → `K_sync = SHA-256(shared‖token)`; autenticación mutua HMAC-SHA256; mensajes AES-256-GCM; buffers zeroeados. `ws://` es aceptable porque el payload ya va cifrado. **Se conserva**; única mejora pendiente: el WiFi-unlock (sección 5).
- ⬜ **Passkeys**: hoy `PasskeyMetadata` + handle en el campo password, **sin firma WebAuthn real**. Reetiquetar en UI como "respaldo de passkey" (`TypeBadge`, `CredentialCard`, `TypeSelector`, `passkeys_screen`) hasta integrar Credential Manager (Fase 12).

---

## 8. Backlog consolidado (prioridad y orden)

| # | Item | Prioridad | Lote | Estado |
| --: | :--- | :--- | :--- | :--- |
| 1 | Temas: infraestructura `AppPalette` | 🔴 | Temas L1 | ⬜ |
| 2 | Temas: migrar ~820 refs a la paleta | 🔴 | Temas L2 | ⬜ |
| 3 | Temas: 4 variantes + sistema + selector | 🔴 | Temas L3 | ⬜ |
| 4 | Passkeys: reetiquetar "respaldo" | 🟢 | con Temas L2 | ⬜ |
| 5 | Rename package `com.angelezequiel.solokey` | 🔴 | Features A | ⬜ |
| 6 | Móvil: acciones de notificación | 🔴 | Features B | ⬜ |
| 7 | Móvil: autofill inline + biometría | 🔴 | Features B | ⬜ |
| 8 | Escritorio: autostart al tray | 🔴 | Features C | ⬜ |
| 9 | Escritorio: hotkey global | 🔴 | Features C | ⬜ |
| 10 | Escritorio: instalador MSIX | 🔴 | Features C | ⬜ |
| 11 | Seguridad: anti-fuerza bruta | 🟡 | Features D | ⬜ |
| 12 | Seguridad: backup cifrado programado | 🟡 | Features D | ⬜ |
| 13 | Sync: endurecer WiFi-unlock (+wss) | 🟢 | Features D | ⬜ |
| 14 | i18n (es/en) | 🟡 | Final | ⬜ |

---

*Generado como guía de ejecución. Se actualizará el estado (⬜/🟦/✅) conforme avance cada lote.*
