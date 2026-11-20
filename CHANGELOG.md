# Changelog

Registro técnico de cambios de SoloKey. Formato inspirado en
[Keep a Changelog](https://keepachangelog.com/es/) y versionado
[SemVer](https://semver.org/lang/es/). Las notas "para humanos" de cada
versión viven en la página de Releases de GitHub.

## [Unreleased]

### Añadido

- **Build y E2E de Android en Podman (PLA-3, 2026-11-19)**: `tool/build/Containerfile` con etapas independientes (Rust 1.91.1
  con `cargo-ndk`, `cargo-xwin` y `flutter_rust_bridge_codegen`; Flutter de `tests.yml`; SDK y NDK de Android) que `podman build
  --jobs` construye a la vez, juntas en `localhost/solokey-build` y, con el emulador y Android 14, en `localhost/solokey-e2e`.
  `tool/build.ps1` copia el árbol al contenedor y saca el APK, el núcleo (`-Nucleo`: `.so` de tres ABI y `solokey_core.dll`) o
  corre `integration_test/` en un emulador desechable dentro del contenedor (`-E2e`, KVM de la VM). `build_release.ps1 -Target
  android` compila por ahí; Windows e Inno siguen en el host. CI: jobs `rust` (`cargo test` + clippy) y `e2e-android` (emulador
  de GitHub). Absorbe y borra `rust/Containerfile`. Limpieza en `docs/proceso/PRUEBAS.md`.
- **Fuzz del núcleo Rust (SEG-2, parte, 2026-11-19)**: crate `rust/solokey-core/fuzz` con `cargo-fuzz` 0.12.0 sobre nightly fijado,
  en Podman (`rust/fuzz.ps1`, imagen `localhost/solokey-fuzz:<nightly>`, corpus en el volumen `solokey-fuzz-corpus`). Objetivos:
  `sync_trama` (saludo del canal Noise), `sync_mensaje` (`SyncEngine::handle`), `codigo_recuperacion`, `cabecera_boveda` y
  `cabecera_kdf`. Los cuatro primeros, 30 s cada uno sin fallos; `cabecera_kdf` cae en 4 entradas por SEC-012 (los parámetros de
  Argon2id de la cabecera no se acotan: memoria de 4 TiB aborta, pasadas sin límite cuelgan, 8 KiB y 1 pasada se aceptan) y queda
  en rojo hasta que A lo arregle. CSV, `otpauth://` y `.skvault` esperan a que sus parsers existan en el núcleo.
- **Escaneo diario de dependencias (PLA-6, 2026-11-19)**: `tool/escaneo-deps.ps1` junta OSV-Scanner en Podman (v2.7.0 fijada por
  digest, `pubspec.lock` y `rust/Cargo.lock` montados de solo lectura), `flutter pub outdated` y las alertas abiertas de
  Dependabot. Hallazgo = CVSS ≥ 7 con arreglo; sale 0 limpio, 2 si hay algo que contarle al dueño y 1 si un paso falla; el
  resultado del día queda en `.claude\estado\escaneo-deps.json`. Primer escaneo: 303 paquetes, un aviso en el núcleo Rust
  (`libsqlite3-sys` 0.30.1, RUSTSEC-2026-0459, CVSS 6,8, arreglado en 0.39).
- **Teclado seguro en orden para el emulador (2026-11-19)**: `--dart-define=SECURE_KEYBOARD_ORDERED=1` deja las teclas sin
  barajar para manejar la app por `adb`; un build release lo ignora y siempre baraja (`kReleaseMode`).
- **E2E de Windows en CI (CAL-5, parte, 2026-11-15)**: job `e2e-windows` en `tests.yml` (`windows-2022`, runner desechable; `windows-latest` trae VS 18 y dos plugins no compilan):
  `app_boot_test` y dos corridas de `vault_e2e_test`, cada una en su paso. Falta Android en Podman (espera a PLA-3) y la bóveda
  aislada en local (espera a NUC-6).
- **Modelo de amenazas de la v2 (SEG-1, 2026-11-15)**: `docs/seguridad/AMENAZAS_V2.md`, por superficie (RAM, disco,
  portapapeles y pantalla, sync Noise, migración, lo que entra de fuera, recuperación, pruebas), con el estado de la v1 y el
  requisito y carril de cada fila. Hallazgos nuevos en `SEGURIDAD.md`: SEC-009 (recuperar con el código deja la bóveda ilegible,
  reproducido), SEC-010 (`bio_master_key` sin atar a la biometría) y SEC-011 (portapapeles sin marcar como sensible).
- **Sync v2 en el núcleo (NUC-3, parte Rust, 2026-11-15)**: `sync/channel.rs` (Noise `IK` con `snow`, llave del par fijada en el
  QR, tramas de saludo con `SKS2` + versión para reconocer a un par v1 u otra versión, mensajes largos partidos y juntados) y
  `sync/protocol.rs` (delta con `Summary` y `Push`, LWW con desempate determinista por lápida y hash, archivos y lápidas viajan, lo
  local no). Sin E/S: el socket queda en Flutter. Arregla en la v2 el empate de la v1, que dejaba a cada equipo con lo suyo.
- **Formato de bóveda v2 y migración desde la v1 (NUC-2, parte Rust, 2026-11-15)**: `vault.rs` (SQLite `solokey.vault`, cabecera
  versionada, DEK aleatoria envuelta por maestra y por código, sobres cifrados con AAD por id; en claro solo id y versión) y
  `migrate_v1.rs` (verifica, copia con hash, convierte desde la copia, reabre y compara todo, y solo entonces activa la v2). Probado
  con la bóveda de CAL-2: conteos, payloads, doble sobre y hash de cada archivo iguales; maestra mala o archivo alterado dejan la
  v1 intacta. Cierra SEC-009 en el núcleo. Formato en `ARQUITECTURA.md` §4.1.
- **Núcleo Rust `solokey-core`, cripto (NUC-1, parte Rust, 2026-11-15)**: workspace `rust/` con Argon2id + AES-256-GCM
  (`argon2`, `aes-gcm`, `zeroize`), lectura de las rarezas de la v1 (doble UTF-8 de la maestra, `double_enc_v1`, código de
  recuperación) y la API para `flutter_rust_bridge` (`src/api/`). `cargo test` en Podman (`rust/cargo.ps1`) con los vectores de
  CAL-2: da byte a byte lo de la v1. Imagen `localhost/solokey-rust` (`rust/Containerfile`) para el puente y las librerías nativas.

- **Vectores de prueba de la bóveda v1 (CAL-2, 2026-11-15)**: `vectores/v1/` (BD drift v10, archivos seguros, `.skvault` y
  `vectores.json` con entradas, claves, almacén seguro, filas y payloads en claro) para que el núcleo Rust pruebe la migración
  (NUC-2). Salen del código real de la v1 en Podman (`tool/vectores_v1/generar.ps1`, nunca la bóveda real) y se comprueban sin
  Dart con `tool/vectores_v1/verificar.ps1` (Python). Hallazgo: la maestra entra a Argon2id con doble codificación UTF-8.
- **CI de Linux en Podman (CAL-3, 2026-11-15)**: `tool/ci-linux.ps1` corre el job `analyze-test-coverage` de `tests.yml` con la
  misma versión de Flutter, en la imagen `localhost/solokey-ci-linux:<versión>` (`tool/ci-linux/Containerfile`, Ubuntu 24.04 y el
  tarball oficial; `ghcr.io/cirruslabs/flutter` no publica la 3.44.4) y el volumen `solokey-pub-cache`. Copia el árbol dentro
  del contenedor, pasa el script como archivo (PowerShell 5.1 rompe las comillas de los argumentos) y sale con el código del paso
  que falló.

### Arreglado

- **Respaldo del runner de integración (CAL-4, 2026-11-15)**: `run_integration_tests.ps1` no respaldaba `secure_files\` ni el
  `flutter_secure_storage.dat` de la identidad actual (la regex de `Runner.rc` no leía el formato `"valor" "\0"` y solo quedaba la
  ruta vieja `com.vaultguard`). El snapshot pasa a `tool/respaldo-boveda.psm1`: carpeta entera con hash por archivo, falla cerrado si
  no lee la identidad, sale con 2 si algo no vuelve igual y limpia los `*.e2e-backup` de cada carpeta de soporte. Prueba sobre una
  bóveda falsa: `tool/probar-respaldo-boveda.ps1` (vista en rojo sin la carpeta y con la regex vieja).

### Cambiado

- **Tinta y papel (DIS-1, 2026-11-20)**: `AppPalette` reescrita con tokens por rol (papel, hoja, elevada, hundida; tinta en cuatro
  niveles; bordes estándar, suave, de control y foco; comprometida, débil y sana con su letra y su fondo de aviso; velo y sombra),
  clara y oscura, AA comprobado (débil `#94600F` y sana `#2A7449` en claro, más oscuros que REDISENO_V2 §3 para pasar 4.5:1).
  `AppTheme` reescrito sobre esos tokens: liso (sin onda al tocar), botón principal de tinta, esquinas de 12, borde fino y sombra
  suave, cuerpo 16 en móvil y 14 en escritorio. Nuevo `app_tokens.dart` (`AppSpace`, `AppRadius`, `AppDepth`, `AppMotion`).
  Transición de pantalla de 200 ms en todas las plataformas que respeta "reducir movimiento". Temas: claro, oscuro y sistema (por
  defecto, también mientras cargan los ajustes); `dim` y `oled` guardados pasan a oscuro. Letra: Atkinson Hyperlegible Next y
  Mono (OFL, `google/fonts`, variable `wght` 200-800, sha256 `5a455d1c…` y `5ce8b169…`) instanciadas a pesos fijos (400, 500,
  600 y 700; Mono 400, 500 y 700) con fontTools 4.55.3 en Podman; fuera Inter y JetBrains Mono. Fuera `app_colors.dart`, las
  paletas dim y OLED y los 6 colores de tipo; los nombres de la v1 (`primary`, `accent`, `typeX`...) quedan como alias de los
  tokens nuevos hasta que C rehaga cada pantalla. Borrada `test/theme/theme_smoke_test.dart` (ADR-0011).

- **PLA-4 (2026-11-19)**: dependencias mayores, una por commit. go_router 18; local_auth 3 (parámetros sueltos y
  `LocalAuthException`); flutter_secure_storage 10 con `migrateOnAlgorithmChange` y `resetOnError: false` (migra sola lo que la v9
  guardó con EncryptedSharedPreferences; `migrateWithBackup` se salta esa migración en 10.3.4); Riverpod 3 con riverpod_generator 4
  (`build.yaml` conserva los nombres `xxxNotifierProvider` y `noProviderRetry` apaga el reintento automático); freezed 3.2
  (modelos `abstract`/`sealed`, mismo JSON de la bóveda); file_picker 11 (API estática); get_it 9, equatable 3, workmanager 0.10,
  flutter_local_notifications 22, drift 2.31 (mismo esquema), y window_manager 0.5, tray_manager 0.5 y desktop_drop 0.7, las
  últimas que aceptan Flutter 3.44 y AGP 8. Se quitan `context_menus` y `screen_protector`, sin uso. Probado en el emulador:
  bóveda de la v9 → v10 migrada y abierta, y la app final desbloquea y recorre sus pestañas; APK release limpio.
- **PLA-5 (2026-11-15)**: el paquete Dart pasa de `password_manager` a `solokey` (`pubspec.yaml` e imports `package:solokey/`).
  Sin cambios en `Runner.rc`, `BINARY_NAME`, `applicationId` ni `project()` de CMake: la bóveda existente se sigue abriendo.
- **Docs y proceso (2026-11-14)**: rama `develop` de integración (CI también en `develop`); método por sesiones
  (`docs/sesiones/`, carriles A a E); plan de la v2 en `docs/diseno/REDISENO_V2.md`; guías `docs/proceso/PRUEBAS.md` y
  `RAMAS.md`; `tool/quitar-worktree.ps1` (quita un worktree sin vaciar el caché de Pub). Lo terminado de la v1 (prompts por
  pantalla, diseño Graphite Pro, roadmap y bugs) pasa a `docs/archive/v1/`.
- **Arquitectura de `docs/` (2026-11-14)**: `PENDIENTES_AGENTE.md` y `PENDIENTES_DUENO.md` en la raíz de `docs/`; documento
  central `arquitectura/ARQUITECTURA.md`; decisiones en `adr/` (0001 a 0007); `producto/PRODUCTO.md` e `IDEAS.md`;
  `seguridad/SEGURIDAD.md` con el estado de cada hallazgo (SEC-001, 002, 004, 005 y 006 arreglados; 003, 007 y 008 abiertos). Se borran
  `spec/`, `architecture/` y el informe de marzo (absorbidos); el resto se renombra por carpetas en español. El archivo pasa a
  `archive/v1/` con nombres en mayúsculas; ADR 0004 a 0007 (Flutter único, SQLite, sync P2P, calidad y CI); `.gitignore` limpio;
  emulador, celular y runners en `proceso/PRUEBAS.md`.

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
