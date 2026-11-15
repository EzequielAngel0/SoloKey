# ADR-0008: Núcleo en Rust con interfaz Flutter (v2)

Estado: Vigente (2026-11-15) · Decide: el dueño (DEC-1 = R1, sin prototipo previo)

## Contexto
En Dart el borrado de secretos en RAM es "lo mejor posible": el recolector puede copiar un buffer y un `String` no se puede poner
a cero (SEC-003). La v2 rehace la app entera, así que es el momento de mover la lógica sensible a un lenguaje que sí lo garantice.
Comparativa completa de R0 a R3: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §2.

## Decisión
- Un crate **`solokey-core`** en `rust/` con la cripto, el formato de la bóveda, la base de datos, la sync y los parsers de datos
  de fuera (CSV de importación, `otpauth://`, `.skvault`). Se llama desde Flutter con **`flutter_rust_bridge` 2**.
- **Flutter solo pinta** ([ADR-0004](0004-un-solo-codigo-flutter.md) sigue vigente: un solo código de interfaz para Android y
  Windows). Los plugins de plataforma (biometría, autofill, notificaciones, bandeja) se quedan en Flutter.
- Crates de RustCrypto (`argon2`, `aes-gcm`, `x25519-dalek`) y **`zeroize`** en todo lo que toque un secreto.
- Se adopta **directo, sin prototipo comparativo**: el núcleo reemplaza por partes (cripto, luego bóveda y BD, luego sync) detrás
  de las interfaces que ya existen (`ISecurityService`, repositorios).
- **Rust no se instala en el host** ([ADR-0012](0012-todo-en-podman.md)): `cargo test`, el build de Android (`cargo-ndk`) y la DLL de
  Windows (`cargo-xwin`, cruzada) salen de una imagen de Podman.

## Consecuencias
- Los algoritmos de [ADR-0003](0003-cifrado-de-la-boveda.md) no cambian; cambia quién los ejecuta.
- Dos lenguajes en el repo y un paso de Rust en CI. El build de Windows en el host carga la DLL que dejó el contenedor.
- El núcleo es reusable (CLI, extensión de navegador) sin reescribir la cripto.

## Alternativas descartadas
R0 Flutter como hoy (la cripto sigue en Dart), R2 todo Rust con Slint (autofill, biometría y bandeja a mano), R3 Tauri (webview,
superficie XSS en una bóveda), y probar R1 con un prototipo antes de decidir (el dueño prefirió decidir ya).
