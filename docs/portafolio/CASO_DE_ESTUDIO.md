# SoloKey — Caso de estudio

> Gestor de contraseñas **local-first** multiplataforma (Android + Windows) con
> sincronización P2P cifrada de extremo a extremo, sin nube y sin cuentas.
>
> **Rol:** diseño, arquitectura y desarrollo completos (proyecto individual).
> **Stack:** Flutter / Dart · Riverpod · Drift (SQLite) · get_it + injectable ·
> freezed · criptografía nativa (Argon2id, AES-256-GCM, X25519).
> **Código:** [github.com/EzequielAngel0/SoloKey](https://github.com/EzequielAngel0/SoloKey)

---

## 1. El problema

Los gestores de contraseñas comerciales obligan a elegir entre comodidad y
control: los basados en nube sincronizan bien pero custodian tus secretos en
servidores de terceros; los locales puros no se hablan entre dispositivos. El
objetivo de SoloKey fue no ceder ninguna de las dos cosas:

- **Los secretos nunca salen de tus dispositivos** (ni siquiera cifrados hacia
  una nube).
- **PC y celular se sincronizan igual de bien que un producto comercial**, pero
  hablándose directamente por la red local, cifrados de extremo a extremo.

## 2. La solución

Una app Flutter con dos caras — móvil Android y companion de escritorio para
Windows (bandeja del sistema, atajos globales, command palette) — sobre una
única base de código:

| Área | Qué hace |
| :--- | :--- |
| Bóveda | Credenciales (contraseñas, API keys, notas, SSH, passkeys), carpetas jerárquicas, favoritos, ocultar/reordenar, búsqueda reactiva |
| 2FA | Autenticador TOTP integrado (código en vivo con anillo de 30 s), importación por QR — incluida **captura de QR desde la pantalla en Windows** |
| Archivos seguros | Cualquier archivo cifrado en reposo, con preview de imágenes descifradas **solo en RAM**, búsqueda/orden/notas |
| Salud | Auditoría de seguridad con score: débiles, reutilizadas, antiguas, filtradas (HIBP con k-anonymity, opt-in), rotación programada con notificaciones nativas |
| Sync | Emparejamiento por QR, delta-sync bidireccional E2EE, reconexión sin QR, sync continua, desbloqueo del PC desde el celular, aprobación de login push (sin FCM) y **sincronización de archivos seguros** |
| Entrada/salida | Export/import cifrado propio (`.skvault`), CSV de Bitwarden/1Password/Chrome, enlaces `otpauth://`, autofill nativo de Android, teclado seguro anti-keylogger |

## 3. Arquitectura

Clean Architecture estricta en tres capas por feature (`domain` /
`application` / `infrastructure`+`presentation`), con una regla no negociable:
**el dominio y la presentación son "ciegos" a la criptografía** — toda
operación sensible se delega a servicios de infraestructura.

- **Estado:** Riverpod con codegen; entidades inmutables con `freezed`.
- **Persistencia:** Drift (SQLite) con payloads cifrados como BLOB; 10
  versiones de esquema migradas en producción.
- **DI:** get_it + injectable, con puentes a Riverpod para overrides en tests.
- **Concurrencia:** toda derivación de clave y cifrado corre en `Isolate.run()`
  — la UI nunca se bloquea ni con Argon2id a 64 MB de memoria.

## 4. Ingeniería de seguridad

- **KDF:** Argon2id (memoria 64 MB, 3 iteraciones, paralelismo 4 → clave de
  256 bits). Verificación de contraseña sin almacenar la clave ni hash directo.
- **Cifrado:** AES-256-GCM con IV aleatorio de 12 B; blob = nonce‖ciphertext‖tag
  (integridad autenticada, el tampering se detecta al descifrar).
- **Higiene de memoria:** la clave maestra vive solo en RAM y se **zeroa** al
  bloquear; cada copia temporal se limpia tras su uso (política verificada por
  tests que capturan el buffer y comprueban que quedó en ceros).
- **Capas extra:** doble sobre criptográfico por registro (re-autenticación
  para revelar), teclado en pantalla con layout barajado (anti-keylogger),
  FLAG_SECURE contra capturas, guard anti fuerza bruta con backoff exponencial
  y wipe opcional, código de recuperación de 32 B guardado solo como SHA-256.
- **Política Zero-Print:** prohibido volcar secretos a consola, reforzada con
  lint (`avoid_print`) y revisiones.

## 5. El reto técnico central: sync P2P E2EE sin servidor

La pieza más compleja. El escritorio levanta un servidor WebSocket en LAN; el
celular escanea un QR (IP + puerto + token de un solo uso) y ambos ejecutan un
intercambio **ECDH X25519** que deriva una clave de sesión `K_sync` por
dispositivo. Sobre ese canal:

- **Delta-sync bidireccional** con resolución de conflictos
  **Last-Write-Wins determinista** (timestamp + desempate por UUID, de modo que
  ambos lados llegan al mismo veredicto sin coordinarse).
- **Re-cifrado por dispositivo:** cada bóveda tiene su propio salt y clave, así
  que los payloads se descifran localmente, viajan solo dentro del canal E2EE y
  el receptor los re-cifra con SU clave. Aplica igual a credenciales y a los
  archivos seguros.
- **Reconexión sin QR:** `K_sync` persiste por dispositivo y un challenge HMAC
  autentica el resume; con heartbeat, auto-sync periódico y reconexión
  automática, la sincronización es continua mientras ambos están en la red.
- **Desbloqueo remoto:** el celular guarda un token (DUK) que envuelve la clave
  maestra del PC; aprobar con biometría desbloquea el escritorio **sin que la
  contraseña maestra viaje ni se almacene jamás**. La variante push (el PC pide
  aprobación al celular) funciona con notificaciones locales, sin FCM ni nube.
- **Compatibilidad:** el protocolo usa claves opcionales en los mensajes, de
  modo que versiones desparejas simplemente ignoran capacidades nuevas.

## 6. Calidad y proceso

- **510 tests** en pirámide unit → widget → e2e: lógica pura con tiempo
  inyectado (auto-bloqueo, LWW, ruteo de notificaciones), widget tests
  *behaviorales* (p. ej. teclear la contraseña maestra en el teclado seguro
  real y verificar el zeroing del buffer del desbloqueo remoto) y un e2e
  destructivo gateado por variable de entorno con backup/restore verificado
  por hash.
- **Ratchet de cobertura:** el mínimo (hoy **63.4 %**, sin contar código
  generado) vive en el repo y los hooks de pre-commit/pre-push corren
  `analyze` + suite completa + gate de cobertura: no entra código que baje el
  listón.
- **i18n completa** es/en, incluida la capa de servicios (notificaciones en
  background sin `BuildContext`).
- **Release reproducible:** un script de PowerShell empaqueta APKs
  (universal + split por ABI), instalador de Windows (Inno Setup) y zip
  portable, con `SHA256SUMS` y log de build.

## 7. Resultados

| Métrica | Valor |
| :--- | :--- |
| Plataformas | Android + Windows (instalador y portable) desde una base de código |
| Código | ~12,750 líneas Dart ejecutables (sin generados) + runner nativo Win32 y canal Android |
| Tests | 510 en verde; cobertura 63.4 % con ratchet obligatorio |
| Seguridad | 0 secretos en texto plano en reposo; sync E2EE sin servidor |
| Dependencia de nube | Ninguna: sin cuentas, sin telemetría, sin backend |

## 8. Lo que me llevé

- Diseñar un **protocolo de sincronización** obliga a pensar en fallas parciales
  desde el día uno: LWW determinista, tombstones, ítems que se saltan sin
  abortar la ronda y compatibilidad hacia atrás pagaron su costo rápidamente.
- La **higiene de memoria** (zeroing, copias mínimas, buffers de un solo uso)
  es una disciplina transversal, no una función: solo sobrevive si los tests la
  verifican.
- Un **ratchet de cobertura** convierte "deberíamos testear más" en una
  restricción mecánica del flujo de trabajo — la calidad dejó de depender de la
  fuerza de voluntad.
