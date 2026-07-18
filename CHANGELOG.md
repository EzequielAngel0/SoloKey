# Changelog

Registro técnico de cambios de SoloKey. Formato inspirado en
[Keep a Changelog](https://keepachangelog.com/es/) y versionado
[SemVer](https://semver.org/lang/es/). Las notas "para humanos" de cada
versión viven en la página de Releases de GitHub.

## [1.1.0] — 2026-07-18

### Añadido

**Companion de escritorio (Windows) + Sincronización P2P E2EE**

- Servidor de sync en LAN (WebSocket sobre Shelf) con emparejamiento por QR
  (IP + puerto + token de un solo uso) e intercambio de claves **ECDH X25519**
  → `K_sync` por dispositivo; canal cifrado AES-256-GCM, multi-peer.
- **Delta-sync bidireccional** con resolución de conflictos Last-Write-Wins
  determinista (timestamp + desempate por UUID) para credenciales y carpetas.
- **Reconexión sin QR** (resume autenticado por challenge HMAC con `K_sync`
  persistida), heartbeat, auto-sync periódico y reconexión automática (M1/R1).
- **Desbloqueo remoto del PC** desde el celular vía token DUK: la clave
  maestra viaja envuelta por el canal E2EE; la contraseña maestra nunca se
  transmite ni almacena. Variante push: el PC pide aprobación al celular con
  notificación local, sin FCM (M3).
- **Botón "Sincronizar ahora" en el escritorio**: `sync_request` E2EE a los
  celulares conectados; la ronda es bidireccional.
- **Sincronización de archivos seguros** en el mismo delta (manifest + LWW +
  re-cifrado por dispositivo vía `ISecureFileRepository.applySynced`);
  protocolo retrocompatible (claves opcionales en los mensajes).
- Resumen "qué se sincronizó" (`SyncSummary` + historial persistido cifrado) y
  notificación nativa "N cambios sincronizados"; la bóveda se refresca sola
  tras aplicar un delta (invalidación de providers).
- Escritorio: instancia única, bandeja del sistema con acciones rápidas,
  autoarranque minimizado, Windows Hello (PIN/huella/rostro), atajos globales
  remapeables, command palette, master-detail responsivo, sidebar por
  secciones, drag & drop de credenciales al árbol de carpetas y persistencia
  de ventana/pestaña/sidebar.
- **Captura de QR desde la pantalla en Windows** para dar de alta TOTP
  (screen_capturer + zxing2), además del escaneo por cámara en Android.

**Bóveda y UX**

- Rediseño visual Graphite Pro + rediseño UX pantalla por pantalla (lotes
  L0–L9): detalle por tipo con TOTP en vivo (anillo 30 s), carpetas con
  breadcrumbs/árbol, salud inline, security score, estados vacíos del kit.
- Archivos seguros: cifrado en reposo, preview de imágenes descifradas solo en
  RAM con zeroing, límite de tamaño, dedupe de nombres, drag & drop,
  **búsqueda/orden (recientes/nombre/tamaño)/notas** (pipeline puro
  `visibleSecureFiles`).
- Ocultar/archivar y reordenar credenciales (migración Drift v10:
  `isHidden`/`sortOrder`, viajan en el sync); mover a carpeta desde la card.
- Transferencia: export cifrado `.skvault` selectivo (por tipo/carpeta/ids),
  import CSV (Bitwarden/1Password/Chrome) con aviso de duplicados, import de
  autenticadores `otpauth://`, backup programado y aviso de respaldo al
  desinstalar en Windows.
- Llaves SSH (tipo + metadatos + generador) y cifrado de doble sobre por
  registro (Argon2id + AES-256-GCM; revelar exige re-autenticación).
- Notificaciones nativas de rotación de contraseñas con cooldown de 24 h,
  acciones (cambiar/posponer), chequeo en background (WorkManager en Android,
  daemon de bandeja en escritorio) sin tocar el payload cifrado.
- i18n completa **es/en** (UI + capa de servicios, incluidos isolates de
  fondo), accesibilidad (Semantics, tooltips, foco por teclado) y temas
  dark/light/dim/oled con densidad configurable.

**Calidad e infraestructura**

- Red de pruebas de 0 → **510 tests** (pirámide unit → widget behavioral →
  e2e con backup/restore verificado por hash y gate `E2E_ALLOW_WIPE`).
- **Ratchet de cobertura** (piso actual 63.4 % sin generados) aplicado en
  hooks de pre-commit (analyze + suite) y pre-push (suite + gate).
- Script único de release (`build_release.ps1`): APKs universal + split por
  ABI, instalador Inno Setup, zip portable, `SHA256SUMS.txt` y log.
- Licencia **MIT**, documentación de portfolio y plantillas legales
  (privacidad/términos) para la landing.

### Corregido

- Vinculación por QR en Windows: el fallo de mDNS/Bonjour ya no impide
  generar el QR; selección de IP no virtual y regla de firewall opt-in (B2).
- Procesos duplicados de escritorio al reabrir (instancia única, B1).
- Export agrupaba por `folderId` muerto en vez de `categoryId` (B3).
- Icono de la barra de tareas de Windows con AUMID explícito
  (`WM_SETICON` + propiedades Relaunch* en el property store).
- El switch de verificación de filtraciones (HIBP) no persistía al salir de la
  pantalla (ahora vive en `AppSecuritySettings.hibpCheckEnabled`).
- Recovery codes: colisión de `base64Url` con guiones al decodificar.
- Errores de desbloqueo tipados y localizados (sin strings hardcodeados).

### Seguridad

- Zeroing verificado por tests en desbloqueo remoto y export/import.
- Guard anti fuerza bruta con backoff exponencial y wipe opcional tras N
  intentos; contador de intentos restantes en la pantalla de desbloqueo.
- Auditoría: HIBP con k-anonymity (opt-in), exclusión de SSH/passkeys de los
  chequeos de debilidad; favicons estrictamente opt-in (antes se filtraba el
  dominio de cada credencial con sitio web).
- Refactors de decisiones sensibles a funciones puras testeables
  (auto-bloqueo al volver de fondo, ruteo de taps de notificación).

## [1.0.0] — 2026-03-31 (Beta)

Primera versión pública (solo APK Android, beta):

- Bóveda local cifrada: Argon2id (64 MB, t=3, p=4) + AES-256-GCM en isolates;
  clave maestra solo en RAM con zeroing al bloquear; verificación sin
  almacenar la clave.
- Credenciales (password/API key/nota/TOTP), carpetas jerárquicas, favoritos,
  búsqueda reactiva, generador con distribución natural.
- Auditoría de seguridad (débiles/duplicadas/antiguas), recovery code de 32 B
  (hash SHA-256), auto-bloqueo por inactividad/fondo, FLAG_SECURE, limpieza
  de portapapeles temporizada.
- Autofill nativo de Android, teclado seguro anti-keylogger con layout
  barajado, autenticación biométrica contextual al copiar/revelar.
