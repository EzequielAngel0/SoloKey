# SoloKey v2: propuesta de rediseño completo

Propuesta del 2026-11-14. El dueño pidió rehacer SoloKey por completo (colores, estilo, idiomas e incluso el lenguaje,
con Rust sobre la mesa) y dio libertad para proponer. **Nada de esto está decidido**: la primera sesión general lo
repasa con él (§1) y lo que apruebe pasa a los carriles ([`../sesiones/README.md`](../sesiones/README.md)).
El rediseño anterior (Graphite Pro, julio 2026) quedó en [`../archive/2026-07_diseno_graphite_pro/`](../archive/2026-07_diseno_graphite_pro/).

## 1. Decisiones para el dueño

| ID | Decisión | Opciones | Recomendada |
|---|---|---|---|
| DEC-1 | Lenguaje y stack | R0 Flutter como hoy · R1 núcleo Rust + interfaz Flutter · R2 todo Rust (Slint) · R3 Tauri 2 | **R1**, después de un prototipo que abra tu bóveda actual ([§2](#2-stack-dec-1)) |
| DEC-2 | Dirección visual | A "Tinta y papel" · B Grafito renovado · C Marca con color | **A** ([§3](#3-direccion-visual-dec-2)) |
| DEC-3 | Temas | Claro + oscuro + seguir al sistema · los 4 de hoy (claro, oscuro, dim, oled) | **Dos temas y seguir al sistema**: la mitad de pantallas que revisar |
| DEC-4 | Idiomas | Español como fuente + inglés · inglés como fuente (hoy) | **Español como fuente** (`template-arb-file: app_es.arb`), textos sin jerga |
| DEC-5 | Vibraciones y sonidos | Fuera · como hoy (22 `HapticFeedback`) | **Fuera**: la app no vibra ni suena; solo las notificaciones del sistema |
| DEC-6 | Nombre y logo | Conservar "SoloKey" y redibujar el monograma en el estilo nuevo · nombre nuevo | **Conservar el nombre**, logo redibujado plano |

## 2. Stack (DEC-1)

Hoy: Flutter 3.44 / Dart, 30.7k líneas propias, 63.4% de cobertura, cripto en Dart (`cryptography`: Argon2id + AES-256-GCM
en un isolate), Drift/SQLite, sync P2P por WebSocket con X25519.

| | R0 Flutter como hoy | **R1 Núcleo Rust + Flutter** | R2 Todo Rust (Slint) | R3 Tauri 2 |
|---|---|---|---|---|
| Qué es | Solo se rehace la interfaz | Un crate `solokey-core` (cripto, formato de bóveda, BD, sync) llamado con `flutter_rust_bridge`; Flutter solo pinta | Interfaz y lógica en Rust | Rust + interfaz web en un webview |
| A favor | Lo más rápido; se conserva todo | Borrado real de secretos en RAM (`zeroize`; en Dart el GC puede copiar un buffer y el borrado es "lo mejor posible"); crates de cripto auditados; un núcleo reusable (CLI, extensión de navegador); `cargo test` en Podman; los plugins de Flutter (biometría, autofill, notificaciones, bandeja) se quedan; se migra por partes detrás de las interfaces que ya existen (`ISecurityService`, repositorios) | Un solo lenguaje, binario chico | Binario chico; interfaz con tecnología web |
| En contra | La cripto sigue en Dart | Dos toolchains; `rustup` en el host (la DLL de Windows necesita MSVC) y el NDK para Android; builds más lentos | Autofill de Android, biometría, Keystore, notificaciones, bandeja y atajos se escriben a mano (JNI, Win32); ecosistema móvil verde; se reescribe todo, pruebas incluidas | El webview gasta más memoria y obliga a rehacerlo todo; un webview en una bóveda abre superficie XSS; el autofill sigue siendo Kotlin |
| Esfuerzo | M | L | XL | XL |

**Recomendación: R1, pero solo después del prototipo NUC-0** (carril A): un crate que abre una bóveda creada por la v1
(vectores de prueba generados con la app actual), llamado desde Flutter en Android y en Windows, midiendo tiempo de
desbloqueo, tamaño del APK y del instalador. El dueño usa la v1 y el prototipo lado a lado y decide.
La decisión queda en `docs/adr/0001-*.md`.

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
- **Tipografía**: Inter (interfaz) y JetBrains Mono (secretos y códigos), empaquetadas sin red. Cuerpo 16 en móvil y 14 en
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

- **La bóveda de la v1 se abre en la v2 sin perder nada.** Se prueba con una COPIA de una bóveda real, nunca con la real
  (`run_integration_tests.ps1` respalda y restaura).
- Sync entre versiones: protocolo versionado; un par v1 con uno v2 no mezcla datos y lo dice claro.
- Local-first: sin nube ni telemetría; red solo para la LAN y HIBP (opcional).
- Zero-Print (`avoid_print`), dominio ciego (la interfaz no hace cripto), i18n completo, colores solo por token.

## 6. Orden

| Fase | Qué | Carril |
|---|---|---|
| 0 | Decidir DEC-1 a DEC-6 con el dueño | General |
| 1 | Sistema de diseño (tokens, tema, kit, galería en debug, prueba al 200%) y, en paralelo, el prototipo Rust | B y A |
| 2 | Pantallas por flujo: acceso, bóveda y detalle, formulario, carpetas, seguridad, sync, ajustes, transferencia y archivos, escritorio | C |
| 3 | Si DEC-1 = R1: el núcleo reemplaza por partes (cripto, luego bóveda y BD, luego sync) | A |
| 4 | Entrega: firma de Android, instalador, v2.0.0 | D |
| Todo el tiempo | Pruebas, cobertura, seguridad | E |
