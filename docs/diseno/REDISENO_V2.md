# SoloKey v2: propuesta de rediseño completo

Propuesta del 2026-11-14, **decidida con el dueño el 2026-11-15** (§1; el porqué de cada decisión está en su ADR). Lo aprobado
ya está en los carriles ([`../sesiones/README.md`](../sesiones/README.md)) con su orden en
[`../PENDIENTES_AGENTE.md`](../PENDIENTES_AGENTE.md) ▶.
El rediseño anterior (Graphite Pro, julio 2026) quedó en [`../archive/v1/diseno/`](../archive/v1/diseno/GRAPHITE_PRO.md).

## 1. Decisiones (aprobadas el 2026-11-15)

| ID | Decisión | Aprobado | ADR |
|---|---|---|---|
| DEC-1 | Lenguaje y stack | **R1 directo**: núcleo `solokey-core` en Rust + interfaz Flutter, sin prototipo comparativo | [0008](../adr/0008-nucleo-en-rust.md) |
| DEC-1b | Formato de la bóveda | **Formato propio de la v2 desde el inicio**, versionado y con metadatos cifrados; migración única desde la v1 con copia previa | [0009](../adr/0009-formato-de-boveda-v2.md) |
| DEC-1c | Sync | **Canal entero cifrado** (Noise) y protocolo versionado; v1 y v2 no se mezclan | [0010](../adr/0010-sync-v2-canal-cifrado.md) |
| DEC-2 | Dirección visual y letra | **A · Tinta y papel** + **Atkinson Hyperlegible** Next y Mono | [0013](../adr/0013-diseno-idioma-y-experiencia-v2.md) |
| DEC-3 | Temas | **Claro, oscuro y seguir al sistema** | 0013 |
| DEC-4 | Idiomas | **Español como fuente** + inglés | 0013 |
| DEC-5 | Vibraciones y sonidos | **Fuera** | 0013 |
| DEC-6 | Nombre y logo | **SoloKey**, monograma redibujado plano | 0013 |
| DEC-7 | Experiencia (§4) | **Aprobada completa** | 0013 |
| DEC-8 | Pruebas | **E2E en Android y Windows como red principal**; unitarias solo en Rust; las de Dart se borran al reescribir cada parte | [0011](../adr/0011-pruebas-e2e-principal.md) |
| DEC-9 | Herramientas | **Todo en Podman**, nada nuevo en el host (Rust tampoco); E2E de Windows en local con bóveda aislada y en CI | [0012](../adr/0012-todo-en-podman.md) |
| DEC-10 | Publicación | **Solo la v2.0.0 al final**, sin betas intermedias; `main` la recibe cuando el dueño lo pida | |

## 2. Stack (DEC-1)

Hoy: Flutter 3.44 / Dart, 30.7k líneas propias, 63.4% de cobertura, cripto en Dart (`cryptography`: Argon2id + AES-256-GCM
en un isolate), Drift/SQLite, sync P2P por WebSocket con X25519.

| | R0 Flutter como hoy | **R1 Núcleo Rust + Flutter** | R2 Todo Rust (Slint) | R3 Tauri 2 |
|---|---|---|---|---|
| Qué es | Solo se rehace la interfaz | Un crate `solokey-core` (cripto, formato de bóveda, BD, sync) llamado con `flutter_rust_bridge`; Flutter solo pinta | Interfaz y lógica en Rust | Rust + interfaz web en un webview |
| A favor | Lo más rápido; se conserva todo | Borrado real de secretos en RAM (`zeroize`; en Dart el GC puede copiar un buffer y el borrado es "lo mejor posible"); crates de cripto auditados; un núcleo reusable (CLI, extensión de navegador); `cargo test` en Podman; los plugins de Flutter (biometría, autofill, notificaciones, bandeja) se quedan; se migra por partes detrás de las interfaces que ya existen (`ISecurityService`, repositorios) | Un solo lenguaje, binario chico | Binario chico; interfaz con tecnología web |
| En contra | La cripto sigue en Dart | Dos toolchains; `rustup` en el host (la DLL de Windows necesita MSVC) y el NDK para Android; builds más lentos | Autofill de Android, biometría, Keystore, notificaciones, bandeja y atajos se escriben a mano (JNI, Win32); ecosistema móvil verde; se reescribe todo, pruebas incluidas | El webview gasta más memoria y obliga a rehacerlo todo; un webview en una bóveda abre superficie XSS; el autofill sigue siendo Kotlin |
| Esfuerzo | M | L | XL | XL |

**Decidido: R1 directo** (sin el prototipo comparativo que se recomendaba). `rustup` **no** va al host: todo lo de Rust se
compila en Podman, la DLL de Windows de forma cruzada ([ADR-0012](../adr/0012-todo-en-podman.md)). Por qué:
[ADR-0008](../adr/0008-nucleo-en-rust.md).

## 3. Dirección visual (DEC-2)

| | **A · Tinta y papel** | B · Grafito renovado | C · Marca con color |
|---|---|---|---|
| Idea | Interfaz neutra, como una libreta: tinta sobre papel. **El único color es el estado de seguridad** | Lo de hoy (grafito + azul) con pantallas rehechas | Neutros + un color de marca en botones y selección |
| Por qué sí | El color significa algo (sana, débil, comprometida); se lee de un vistazo; no se parece a todos los demás gestores azules | Lo más barato | Más "marca" |
| Por qué no | Requiere disciplina: nada de colorear "por adornar" | El dueño ya dijo que el resultado de julio no le gustó | El color de marca compite con los de estado |

### Tokens de A (punto de partida, se afinan en DIS-1)

| Rol | Claro | Oscuro | Uso |
|---|---|---|---|
| Fondo (papel) | `#F7F6F2` | `#121316` | Fondo de pantalla |
| Superficie | `#FFFFFF` | `#1A1C20` | Tarjetas, paneles, hojas |
| Tinta | `#15171A` | `#ECEDEF` | Texto principal **y botón principal** (tinta con letra de papel) |
| Tinta suave | `#5B6068` | `#A2A6AD` | Texto secundario |
| Borde | `#E4E2DC` | `#2A2D33` | Separadores y contorno de tarjetas |
| Comprometida / no se deshace | `#B4322A` | `#F0625A` | Brecha, borrar, cerrar sesión en todos lados |
| Débil / atención | `#A86A12` | `#E8B14A` | Débil, repetida, vieja, por vencer |
| Sana | `#2F7D4F` | `#5CBF85` | Auditoría sin problemas, sincronizado |

- **Tipos de credencial por icono, no por color** (hoy hay 6 colores de tipo).
- **Liso**: sin degradados, vidrio, brillos ni biseles. Hoy hay degradados en `autofill_onboarding_screen.dart`,
  `security_audit_screen.dart` y `secure_keyboard.dart`. Profundidad = borde fino + sombra suave; esquinas de 12.
- **Tipografía** (decidida): Atkinson Hyperlegible Next (interfaz) y Atkinson Hyperlegible Mono (secretos y códigos),
  empaquetadas sin red. Cuerpo 16 en móvil y 14 en
  escritorio; en una contraseña revelada, números y símbolos con otro peso, no otro color.
- **Movimiento**: transiciones cortas (200 ms o menos) y nada decorativo (fuera el escalonado de listas y el shimmer);
  respeta "reducir movimiento".

## 4. Experiencia

| Área | Propuesta |
|---|---|
| Principio | **Lo importante a la vista**: copiar usuario, contraseña o código en un toque desde la lista; nada escondido en menús de tres puntos ni en "mantener presionado" |
| Móvil | Barra inferior: **Bóveda · Seguridad · Ajustes**. Bóveda = búsqueda fija arriba + filtros (todo, favoritos, tipo, carpeta) con la ruta de carpetas a la vista; las carpetas dejan de ser pestaña |
| Escritorio | Tres paneles (navegación, lista, detalle), Ctrl+K, atajos, bandeja. Mismos componentes que el móvil, más densos |
| Detalle por tipo | TOTP: el código grande con su anillo de 30 s. Contraseña: revelar y copiar grandes. SSH, nota, passkey (respaldo) y API key con su forma propia |
| Acceso | Biometría o Windows Hello primero, contraseña maestra después; el teclado seguro se queda como opción |
| Primer uso | Tres pasos: crear la contraseña maestra, guardar el código de recuperación (hay que confirmarlo) e importar (opcional) |
| Textos | Sin jerga: "clave de sincronización", no `K_sync`; "aprobar desde el celular", no "token DUK" |
| Accesibilidad | Aguanta la letra del sistema al **200%** con datos largos, contraste AA, toques de 48 o más |

## 5. Reglas que no cambian

- **La bóveda de la v1 se migra a la v2 sin perder nada** (copia automática antes; [ADR-0009](../adr/0009-formato-de-boveda-v2.md)).
  Se prueba con vectores de la v1 (CAL-2) y con una COPIA de una bóveda real, nunca con la real.
- Sync entre versiones: protocolo versionado; un par v1 con uno v2 no mezcla datos y lo dice claro.
- Ninguna prueba toca la bóveda real: las E2E usan un directorio de datos aislado ([ADR-0011](../adr/0011-pruebas-e2e-principal.md)).
- Local-first: sin nube ni telemetría; red solo para la LAN y HIBP (opcional).
- Zero-Print (`avoid_print`), dominio ciego (la interfaz no hace cripto), i18n completo, colores solo por token.

## 6. Orden

Detalle por carril y prompts: [`../PENDIENTES_AGENTE.md`](../PENDIENTES_AGENTE.md) ▶.

| Fase | Qué | Carril |
|---|---|---|
| 0 | Decisiones con el dueño | General ✓ (2026-11-15) |
| 1 | Cimientos, con nadie más tocando código: renombrar el paquete (PLA-5) y subir dependencias mayores (PLA-4); respaldo de archivos seguros (CAL-4) y vectores de la v1 (CAL-2) | D y E |
| 2 | Sistema de diseño (DIS-1 a DIS-3, DIS-5) en paralelo con la imagen de build en Podman (PLA-3) y el núcleo cripto en Rust (NUC-1) | B, D y A (dos pesadas a la vez) |
| 3 | Pantallas por flujo (PAN-10, luego PAN-1 a PAN-9), cada una con su E2E y borrando las pruebas viejas; formato v2 y migración (NUC-2); harness E2E (CAL-5) | C, A y E |
| 4 | Sync v2 (NUC-3), logo (DIS-4), firma de Android (PLA-1), escaneo (PLA-6), 200%, amenazas y fuzz (CAL-1, SEG-1, SEG-2) | A, B, D y E |
| 5 | v2.0.0: PR `develop` a `main` y `build_release.ps1`, solo con el permiso del dueño | General |
| Después | Passkeys reales con WebAuthn (NUC-5) | A |
