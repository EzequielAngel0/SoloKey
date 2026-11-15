# SoloKey — Entradas listas para el CV

> Tres formatos por idioma: línea única, entrada estándar (3–4 bullets) y
> versión extendida para CV técnico. Cifras verificables en el repo
> (510 tests, cobertura 63.4 % con ratchet, ~12.7k líneas Dart sin generados).

---

## Español

### Línea única (sección "Proyectos")

**SoloKey — Gestor de contraseñas local-first (Flutter/Dart).** App Android +
Windows con cifrado Argon2id/AES-256-GCM y sincronización P2P E2EE sin
servidor; 510 tests y piso de cobertura obligatorio en CI.

### Entrada estándar

**SoloKey** — Gestor de contraseñas local-first · Proyecto personal · Flutter/Dart
*Android + Windows · [github.com/EzequielAngel0/SoloKey](https://github.com/EzequielAngel0/SoloKey)*

- Diseñé y construí una app multiplataforma completa (móvil + companion de
  escritorio) con Clean Architecture, Riverpod, Drift/SQLite e inyección de
  dependencias, donde la capa de dominio es "ciega" a la criptografía.
- Implementé el motor criptográfico: Argon2id (64 MB) + AES-256-GCM en
  isolates, clave maestra solo en RAM con zeroing verificado por tests,
  anti fuerza bruta con backoff y código de recuperación hasheado.
- Desarrollé un protocolo de sincronización P2P cifrado de extremo a extremo
  (ECDH X25519, delta-sync bidireccional con Last-Write-Wins determinista,
  reconexión autenticada por HMAC) que sincroniza credenciales y archivos
  cifrados entre PC y celular sin ningún servidor.
- Establecí una red de 510 tests (unit/widget/e2e) con piso de cobertura
  obligatorio (ratchet en hooks de pre-commit/pre-push) e i18n completa es/en.

### Versión extendida (CV técnico / entrevista)

Además de lo anterior:

- Desbloqueo remoto del escritorio aprobado desde el celular con biometría: la
  clave maestra viaja envuelta con un token de un solo uso (DUK) por el canal
  E2EE; la contraseña maestra nunca se transmite ni se almacena.
- Autofill nativo de Android (servicio + canal de plataforma), teclado en
  pantalla anti-keylogger con layout barajado, FLAG_SECURE y doble sobre
  criptográfico por registro.
- Auditoría de salud con score, detección de contraseñas filtradas vía
  HaveIBeenPwned con k-anonymity (solo viaja un prefijo SHA-1 de 5 caracteres,
  opt-in) y rotación programada con notificaciones nativas en background
  (WorkManager / daemon de bandeja).
- Empaquetado reproducible: APKs por ABI + instalador Inno Setup + zip
  portable con sumas SHA-256, desde un único script.

---

## English

### One-liner (Projects section)

**SoloKey — Local-first password manager (Flutter/Dart).** Android + Windows
app with Argon2id/AES-256-GCM encryption and serverless end-to-end encrypted
P2P sync; 510 tests with a mandatory coverage floor in CI.

### Standard entry

**SoloKey** — Local-first password manager · Personal project · Flutter/Dart
*Android + Windows · [github.com/EzequielAngel0/SoloKey](https://github.com/EzequielAngel0/SoloKey)*

- Designed and built a full cross-platform app (mobile + desktop companion)
  with Clean Architecture, Riverpod, Drift/SQLite and dependency injection,
  keeping the domain layer crypto-blind by design.
- Implemented the crypto engine: Argon2id (64 MB) + AES-256-GCM running in
  isolates, master key held in RAM only with test-verified zeroing,
  brute-force backoff and hashed recovery codes.
- Developed a serverless end-to-end encrypted P2P sync protocol (X25519 ECDH,
  bidirectional delta-sync with deterministic Last-Write-Wins conflict
  resolution, HMAC-authenticated resume) syncing credentials and encrypted
  files between PC and phone with no backend.
- Established a 510-test suite (unit/widget/e2e) with a ratcheted coverage
  floor enforced by pre-commit/pre-push hooks, plus full es/en i18n.

### Extended version (technical CV / interviews)

On top of the standard entry:

- Phone-approved remote desktop unlock: the master key travels wrapped with a
  one-time device unlock token over the E2EE channel; the master password is
  never transmitted or stored.
- Native Android autofill (service + platform channel), shuffled-layout
  on-screen keyboard (anti-keylogger), FLAG_SECURE and per-record double
  envelope encryption.
- Password-health audit with score, breached-password detection via
  HaveIBeenPwned k-anonymity (only a 5-char SHA-1 prefix ever leaves the
  device, opt-in) and scheduled rotation reminders via native background
  notifications (WorkManager / tray daemon).
- Reproducible packaging: per-ABI APKs + Inno Setup installer + portable zip
  with SHA-256 checksums from a single script.

---

## Habilidades que este proyecto respalda (para la sección Skills)

Flutter · Dart · Riverpod · Drift/SQLite · Clean Architecture · Criptografía
aplicada (Argon2id, AES-GCM, ECDH X25519, HMAC) · Diseño de protocolos de red ·
WebSockets · Testing (unit/widget/e2e, coverage gates) · CI por hooks · i18n ·
Integración nativa Android (autofill, canales) y Win32 · Empaquetado y release.
