# Mejoras y Características — SoloKey

Catálogo de ideas para SoloKey. Reorganizado el **2026-06-28** para separar lo
**ya implementado** de lo **pendiente**, y reflejar el estado real del código.

> **Decisión de producto:** SoloKey **no maneja PII** (no habrá tipos
> "tarjeta/identidad/banco" ni "acceso de emergencia / herencia digital").
> El modelo es **local-first**: sin nube; la sincronización es P2P E2EE en LAN.

---

## ✅ Ya implementado

Ideas de versiones anteriores de este documento que **hoy ya existen** en la app:

- **Auth contextual en micro-interacciones** — biometría antes de copiar/revelar
  (`AuthHelper.requireAuth`).
- **Teclado seguro anti-keylogger** — layout barajado para el master password
  (`shared/widgets/secure_keyboard/`).
- **Export/Import seguro** — `.skvault` cifrado con contraseña de exportación
  propia (distinta a la maestra); selección por carpetas/credenciales (árbol).
- **Import desde otros gestores** — CSV de Bitwarden / 1Password / Chrome
  (`csv_import_service.dart`).
- **Sincronización P2P / WiFi local E2EE** — companion de escritorio + móvil
  (`features/sync/`): emparejado por QR (X25519 + token), WebSocket AES-256-GCM,
  LWW, reconexión sin QR, sync continua y desbloqueo/aprobación desde el celular.
- **Autofill del SO (Android)** — `AutofillService` + chips inline + biometría.
- **Auditoría + HaveIBeenPwned (opt-in, k-Anonymity)**.
- **Historial de contraseñas anteriores** (`password_history`).
- **Favicons automáticos** de marcas (`CredentialIcon`).
- **TOTP** (pegar secreto o escanear QR), **carpetas** jerárquicas, **favoritos**,
  **llaves SSH**, **doble sobre** por PIN, **anti-fuerza-bruta** con wipe,
  **backup cifrado programado**, **recordatorios de rotación**, **archivos seguros**.
- **Ocultar/archivar + reordenar credenciales** (drag) — drift v10
  (`isHidden`/`sortOrder`), con vista "Ocultas" y reorden también en escritorio.
- **Quick-Fill de escritorio** (hotkey global + portapapeles con auto-clear),
  **autostart al tray**, **instalador Windows** (Inno Setup).
- **Passkeys** — 🟦 parcial: tipo de credencial + `PasskeyMetadata` ("respaldo
  de passkey"), **sin firma WebAuthn real** todavía (ver pendientes).

---

## 🔭 Pendiente — ideas futuras

### 🖥️ Escritorio
- **Extensión de navegador (Chrome/Edge/Firefox) — máxima prioridad:** el SO de
  escritorio no expone autofill; hoy solo hay Quick-Fill por portapapeles. Una
  extensión que hable con la app por el WebSocket local (mismo canal del sync)
  daría autocompletado real en webs. Es lo que más acerca SoloKey a
  Bitwarden/1Password en PC.
- **Auto-Type estilo KeePass:** simular pulsaciones en el campo enfocado
  (`user{TAB}pass{ENTER}`) en vez de copiar al portapapeles; complementa
  `Ctrl+Shift+L`.
- **Overlay tipo Spotlight:** ventana flotante de búsqueda rápida sobre el hotkey
  global, sin abrir la app entera.
- **Recordar tamaño/posición de ventana + multi-monitor** y **modo portable**
  (bóveda junto al `.exe` en USB).

### 📱 Móvil (Android)
- **Passkeys reales vía Credential Manager:** hoy es "respaldo" sin firma
  WebAuthn. Cierra la promesa de passkeys.
- **Widget de pantalla de inicio + Quick Settings tile:** widget de TOTP
  favoritos y un botón "bloquear bóveda ya". Alto valor, bajo esfuerzo.
- **Importar QR de migración de Google Authenticator** (`otpauth-migration://`):
  migración masiva de TOTPs en un escaneo.
- **PIN de coacción (duress):** un segundo PIN que abre una bóveda señuelo o
  dispara wipe. Encaja con el `WipeVaultUseCase` existente.

### 🔗 Ambas / transversal
- **Etiquetas (tags multi-categoría):** complemento a carpetas; una credencial
  con `#trabajo #banca` (una credencial puede tener varias etiquetas).
- **Compartición segura "VaultDrop":** pasar una credencial por QR/enlace
  efímero cifrado, reutilizando el canal E2EE del sync.
- **YubiKey / FIDO2 como 2FA del desbloqueo:** NFC en móvil, USB en PC.
- **Monitoreo proactivo de brechas:** hoy HaveIBeenPwned es manual/opt-in;
  convertirlo en chequeo programado que **notifique** (reutiliza
  `NotificationService` + workmanager ya existentes).
- **Export a formatos abiertos (CSV/JSON):** hoy solo se exporta `.skvault`
  cifrado; un export CSV/JSON plano (con advertencia de sensibilidad) facilitaría
  migrar a otros gestores. (El **import** CSV ya existe.)

### 🍎🐧 Multiplataforma (diferido)
- **Empaquetado macOS / Linux / iOS** — diferido por no contar con Mac/iPhone.
  El código ya es multiplataforma (Flutter); falta el build/firma y, en iOS, la
  extensión de autofill (`AutoFill Credential Provider`).
