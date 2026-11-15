# SoloKey: el producto

Gestor de contraseñas **local-first** para **Android y Windows**: la bóveda vive cifrada en tus equipos, sin nube ni cuentas, y
se sincroniza entre ellos por la red local. Código abierto, licencia MIT. Decisiones de fondo: [`../adr/`](../adr/README.md).

## 1. Qué hace la v1 (1.1.0, 2026-07-18)

| Área | Qué |
|---|---|
| Bóveda | Contraseña maestra (Argon2id), biometría o Windows Hello, bloqueo por inactividad, código de recuperación, borrado tras N intentos |
| Registros | Contraseñas, API keys, notas seguras, TOTP (código en vivo), llaves SSH (con generador), passkeys (solo respaldo, sin WebAuthn), archivos seguros |
| Organizar | Carpetas jerárquicas con migas y árbol, favoritos, ocultar y reordenar, búsqueda |
| Generador | Longitud y juegos de caracteres, medidor de fuerza, integrado en el formulario |
| Salud | Auditoría (débiles, repetidas, viejas), HaveIBeenPwned opcional, recordatorios de rotación por credencial |
| Mover datos | Export cifrado `.skvault` selectivo, import CSV (Bitwarden, 1Password, Chrome), import `otpauth://`, respaldo programado |
| Entre equipos | Sync P2P cifrada en la LAN, reconexión sin QR, "Sincronizar ahora", desbloquear o aprobar el PC desde el celular |
| Android | Autofill del sistema, capturas bloqueadas |
| Windows | Bandeja, instancia única, autoarranque, atajos globales, Quick-Fill, paleta de comandos, captura de QR de la pantalla, instalador |
| General | Español e inglés, temas oscuro, claro, tenue y OLED, accesibilidad (Semantics, foco por teclado) |

Lo que cambió versión por versión: [`../../CHANGELOG.md`](../../CHANGELOG.md).

## 2. Para quién y dónde

Una persona que quiere sus secretos en sus propios equipos (hoy, el dueño): celular Android y una PC con Windows en la misma
casa u oficina. No hay plan de multiusuario, equipos ni cuentas.

## 3. Decisiones de producto (no re-litigar)

| Decisión | Desde | Fuente |
|---|---|---|
| Sin nube, sin cuentas, sin telemetría | 2026-03 | [ADR-0001](../adr/0001-local-first-sin-nube.md) |
| Sin tarjetas, identidades ni herencia digital | 2026-06 | [ADR-0002](../adr/0002-sin-datos-personales.md) |
| El generador vive dentro del formulario, no en otra pantalla | 2026-03 | Flujo de alta sin cortes |
| La biometría solo se lanza sola si el usuario la activó; cancelar regresa a la contraseña sin reintentar | 2026-03 | Sin bucles de huella |
| Windows se entrega como instalador (Inno Setup), no como `.exe` suelto | 2026-07 | [`../publicacion/PUBLICAR.md`](../publicacion/PUBLICAR.md) |
| macOS, Linux e iOS diferidos (no hay hardware) | 2026-07 | PLA-2 |

## 4. Hacia dónde va

- **v2**: rediseño completo con núcleo en Rust, decidido el 2026-11-15: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md).
  Las passkeys reales (WebAuthn) están aprobadas para después de la v2.0.0 (NUC-5, carril A).
- **Ideas sin aprobar** (extensión de navegador, widget de TOTP, auto-type...): [`IDEAS.md`](IDEAS.md). Una idea
  aprobada sale de ahí y entra al doc de su carril en [`../sesiones/`](../sesiones/README.md).
