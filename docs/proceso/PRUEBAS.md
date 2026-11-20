# Pruebas de SoloKey

Qué se prueba, con qué y cómo se sabe que una prueba protege de verdad. El motor de
integración (Windows y Android, patrones anti-flaky) está en
[`PRUEBAS_INTEGRACION.md`](PRUEBAS_INTEGRACION.md); la checklist PC + celular, en
[`PRUEBAS_EN_DISPOSITIVOS.md`](PRUEBAS_EN_DISPOSITIVOS.md).

> **La v2 cambia la red** (decidido el 2026-11-15): E2E en Android y Windows como red principal, pruebas unitarias solo en Rust,
> y las de Dart se borran al reescribir cada parte ([ADR-0011](../adr/0011-pruebas-e2e-principal.md)); todo en Podman salvo lo
> que Windows exige ([ADR-0012](../adr/0012-todo-en-podman.md)). Esta guía describe la v1 hasta que el carril E la reescriba (CAL-5).

## La red

| Nivel | Dónde | Cómo se corre | Notas |
|---|---|---|---|
| Unit | `test/**` (espeja `lib/**`) | `flutter test` | Cripto, servicios, use cases, providers, lógica pura con tiempo inyectado. |
| Widget | `test/**` con `test/support/widget_harness.dart` | `flutter test` | Behavioral: interactúa (tocar, escribir, revelar), no solo "renderiza". Fakes en `test/support/`. |
| Integración | `integration_test/**` | `.\run_integration_tests.ps1` | `vault_e2e_test` BORRA la bóveda local: solo con el runner (respalda con hash la BD, el `.dat` y `secure_files\`, y restaura en `finally`). En CI, el job `e2e-windows` (`windows-2022`, sin bóveda real) corre lo mismo en cada push. |
| Respaldo del runner | `tool/respaldo-boveda.psm1` | `.\tool\probar-respaldo-boveda.ps1` | Sobre una bóveda falsa en `%TEMP%`; correrla al tocar el módulo o `Runner.rc`. |
| Vectores de la v1 | [`vectores/v1/`](../../vectores/v1/LEEME.md) | `.\tool\vectores_v1\verificar.ps1` | Python en Podman, sin Dart; los usa `cargo test` del núcleo (NUC-2). Regenerar solo si cambia lo que escribe la v1. |
| Núcleo Rust | `rust/solokey-core/` (`src/**` y `tests/**`) | `.\rust\cargo.ps1 test` | En Podman; las pruebas de la v1 leen `vectores/v1/`. Clippy: `.\rust\cargo.ps1 clippy --all-targets -- -D warnings` |
| Fuzz del núcleo | `rust/solokey-core/fuzz/` | `.\rust\fuzz.ps1 [-Objetivo <o>] [-Segundos 60]` | En Podman; un fallo deja su entrada en `fuzz/artifacts/<o>/` y se repite con `-Reproducir` |
| Dispositivos | PC + celular en la misma red | a mano | [`PRUEBAS_EN_DISPOSITIVOS.md`](PRUEBAS_EN_DISPOSITIVOS.md) |

## Gates

| Gate | Qué exige | Dónde |
|---|---|---|
| `pre-commit` | `flutter analyze` en 0 y `flutter test` verde (solo si el commit toca `.dart`) | `.githooks/` (activar: `git config core.hooksPath .githooks`) |
| `pre-push` | `flutter test --coverage` sobre el piso de `tool/coverage_min.txt` | `.githooks/` + `tool/check_coverage.dart` |
| CI | analyze + test + cobertura; `cargo test` + clippy del núcleo (`rust`); `integration_test/` en Windows (`e2e-windows`) y en un emulador de Android 14 (`e2e-android`). En `main`, `develop` y PRs | `.github/workflows/tests.yml` (Flutter 3.44.4) |

El piso de cobertura es un **trinquete**: se sube al cubrir más y nunca se baja para que pase un cambio. Única excepción (dueño, 2026-11-20): la rama que mueve código a Rust y borra sus pruebas Dart (ADR-0011) fija el piso en lo medido, redondeado hacia abajo a un decimal, y lo dice en su CHANGELOG (NUC-1: de 63,4 a 63,2).

**Runners**: el CI corre en máquinas de GitHub (`ubuntu-latest`), gratis por ser un repo público. **No hay runners propios**: nada
que encender ni apagar; esperar el resultado con `gh run watch`. Por qué: [ADR-0007](../adr/0007-red-de-calidad-y-ci.md).

## Reglas

1. **Toca código, toca sus tests**: unit para lógica, widget para UI.
2. **Prueba que tu prueba falla.** Después de escribirla, revierte el arreglo, mírala en ROJO y restaura. Un test que nunca se vio en rojo no ha demostrado nada.
3. **El modo de fallo importa.** "Sin red" es una conexión que LANZA, no un par que contesta con un campo vacío; un archivo corrupto no es un archivo ausente. Cada guard vive en uno solo de esos caminos.
4. **Fixtures con datos reales.** Antes de inventar el formato de un campo, míralo en lo que la app guarda o el par manda de verdad (blob cifrado, payload de sync, fecha).
5. **Rojo en CI y verde en local casi siempre es el sistema operativo** (CI es Linux, el equipo es Windows): reprodúcelo en un contenedor Linux con el SDK de `tests.yml` antes de subir timeouts o llamarlo "flaky". Busca `Platform.isX`, rutas, fuentes y rasterizado.
6. **CI verde no prueba que el gate siga vivo.** Si un cambio de dependencias deja un paso sin analizar nada, sigue en verde: lee la salida, no solo el código de salida.
7. **Letra al 200% y modo oscuro** (desde la v2): cada pantalla nueva se monta con `textScaler` 2.0 y con datos LARGOS en los dos temas sin desbordes. La pantalla vacía casi nunca se desborda; la que trae datos sí.

## Trampas conocidas

- No `pumpAndSettle` con timers vivos (el anillo de TOTP usa `Timer.periodic`): avanza con `pump(duration)`.
- Tras `enterText` en la búsqueda, avanza más de 250 ms (debounce).
- BD de prueba: `AppDatabase.forTesting(NativeDatabase.memory())`.
- En Windows, `integration_test` corre **un archivo por invocación** (instancia única de la app).
- El build de prueba de escritorio comparte el almacenamiento con la app instalada (`Documents\vault_guard_db.sqlite`, el `.dat` de `flutter_secure_storage` y `secure_files\`, en `%APPDATA%\<CompanyName>\<ProductName>` de `Runner.rc`): por eso el E2E destructivo va SOLO con `run_integration_tests.ps1`.

## Dispositivos y emulador

**Antes de tocar el emulador, el celular o un build pesado: `ListAgents`** (son de todo el equipo, también de otros proyectos).

| Para | Cómo |
|---|---|
| Ver qué hay conectado | `flutter devices` (Windows, el emulador y el celular por USB o `adb pair`) |
| Emulador de Android | AVD `Pixel_9`: `C:\Android\Sdk\emulator\emulator.exe -avd Pixel_9` (Android Studio no hace falta) |
| Correr en debug | `flutter run -d <id>`; en Windows, `flutter run -d windows` **abre la bóveda REAL** del dueño (comparte el almacenamiento): leer sí, nada destructivo |
| APK para el emulador | `flutter build apk --debug --dart-define=SECURE_KEYBOARD_ORDERED=1` (o el mismo `--dart-define` en `flutter run`): teclado seguro en orden para manejarlo por `adb`. Un build release lo ignora y siempre baraja (dueño, 2026-11-19) |
| Solo el emulador | El celular W555 **no** se usa en este proyecto (dueño, 2026-11-19): siempre `adb -s emulator-5554` |
| Letra al 200% | `adb shell settings put system font_scale 2.0`; al terminar, de vuelta a `1.0` |
| Modo oscuro | `adb shell cmd uimode night yes` (y `no` para volver) |
| El celular del dueño | Es su teléfono con su bóveda: **nunca desinstalar la app** (borra la bóveda). Instalar encima con `adb install -r`; si la firma no coincide, parar y preguntarle |
| Al terminar | Dejar la app corriendo (emulador o Windows) para que él la vea, letra al 100%; sin capturas, solo decirle dónde está |

La prueba física PC y celular de la sync tiene su checklist: [`PRUEBAS_EN_DISPOSITIVOS.md`](PRUEBAS_EN_DISPOSITIVOS.md).

## Reproducir CI en Linux (Podman)

`tool/ci-linux.ps1` (CAL-3) corre los pasos del job `analyze-test-coverage` de `tests.yml` (pub get, analyze, test con
cobertura y su gate) en Podman, con la misma versión de Flutter, leída de `tests.yml`:

| Para | Comando |
|---|---|
| El CI entero | `.\tool\ci-linux.ps1` (dice VERDE o ROJO y sale con el código del paso que falló) |
| Otra cosa | `.\tool\ci-linux.ps1 -Comando 'flutter test test/core'` |
| Sacar archivos | `-Salida <carpeta>`: se monta en `/out` (así salen los vectores de CAL-2) |
| Tras subir Flutter en `tests.yml` | Nada: la imagen nueva se construye sola; la vieja se borra con `podman rmi` |
| Borrarlo todo | `podman rmi localhost/solokey-ci-linux:<versión>; podman volume rm solokey-pub-cache` |

La imagen `localhost/solokey-ci-linux:<versión>` sale de `tool/ci-linux/Containerfile` (Ubuntu 24.04 y el tarball oficial de
Flutter): `ghcr.io/cirruslabs/flutter` no publica la 3.44.4. El árbol se copia dentro del contenedor en vez de compilar sobre el
montaje, porque `pub get` escribe rutas de Linux en `.dart_tool` y dejaría el árbol de Windows sin poder correr sus tests.

Para el núcleo en Rust ([ADR-0008](../adr/0008-nucleo-en-rust.md)) nada va al host:

| Qué | Imagen | Comando | Borrarlo |
|---|---|---|---|
| `cargo test` | `docker.io/library/rust:1.91-slim-bookworm` | `.\rust\cargo.ps1 test` | `podman volume rm solokey-cargo-registry solokey-cargo-target` |
| Clippy (la imagen `slim` no lo trae) | `localhost/solokey-build` | `.\tool\build.ps1 -Comando 'cd rust && cargo clippy --locked --all-targets -- -D warnings'` | ver abajo |
| `.so` por ABI y `solokey_core.dll` | `localhost/solokey-build` | `.\tool\build.ps1 -Nucleo -Salida rust\dist` → `rust\dist\jniLibs\<abi>\` y `rust\dist\solokey_core.dll`. **Hace falta antes de `flutter test`, `run` o `build`** (NUC-1): la app carga el núcleo desde ahí | ver abajo |
| Puente `flutter_rust_bridge` | `localhost/solokey-build` | `.\rust\puente.ps1` regenera `lib/core/infrastructure/rust/` y `src/frb_generated.rs` tras cambiar `src/api/` | ver abajo |
| Fuzz (SEG-2) | `localhost/solokey-fuzz:<nightly>` (`rust/solokey-core/fuzz/Containerfile`: nightly fijado y `cargo-fuzz`) | `.\rust\fuzz.ps1` | `podman rmi localhost/solokey-fuzz:<nightly>; podman volume rm solokey-fuzz-corpus solokey-fuzz-target` |

## Build y E2E de Android en Podman (PLA-3)

Ni el SDK ni el NDK de Android ni Rust van al host ([ADR-0012](../adr/0012-todo-en-podman.md)). `tool/build.ps1` construye la
imagen si falta, copia el árbol dentro del contenedor (como `ci-linux.ps1`) y deja lo que sale en `build\podman\`:

| Para | Comando |
|---|---|
| APK release | `.\tool\build.ps1` → `build\podman\app-release.apk` |
| Entregable de Android | `.\build_release.ps1 -Target android [-Aab] [-Obfuscate]` (usa `tool\build.ps1`; Windows e Inno siguen en el host) |
| Otra cosa | `.\tool\build.ps1 -Comando '<bash>'`; lo que se copie a `$SALIDA` sale en `build\podman\` (o en `-Salida <carpeta>`) |
| E2E de Android | `.\tool\build.ps1 -E2e`: `integration_test/` en un emulador **nuevo dentro del contenedor** (KVM de la VM de Podman), el mismo que usa el job `e2e-android` del CI. Nace vacío y muere con el contenedor: no toca el emulador ni el celular del host. Corre un archivo por vez e instala antes con `adb install -g`: la app pide el permiso de notificaciones antes de `runApp` y `flutter test` la desinstala al acabar cada archivo. Si falla, deja el logcat en `build\podman\logcat.txt` |
| Borrarlo todo | `podman images --filter reference=localhost/solokey-e2e -q \| % { podman rmi $_ }; podman images --filter reference=localhost/solokey-build -q \| % { podman rmi $_ }; podman volume rm solokey-gradle solokey-xwin solokey-build-target` |

Las imágenes salen de `tool/build/Containerfile` (etapa `build`: Ubuntu 24.04, Flutter de `tests.yml`, JDK 17, SDK y NDK de
Android, Rust 1.91.1 con `cargo-ndk`, `cargo-xwin` y `flutter_rust_bridge_codegen`; etapa `e2e`: la de build más el emulador y
la imagen de sistema de Android 14). La etiqueta es `<flutter>-<hash de la receta>`: tocar el `Containerfile` construye una
imagen nueva y la vieja queda para `podman rmi`. Cachés en volúmenes con nombre: `solokey-pub-cache` (compartido con
`ci-linux.ps1`), `solokey-gradle`, `solokey-cargo-registry` (compartido con `rust/cargo.ps1`), `solokey-xwin` (el CRT y el SDK de
Windows que baja `cargo-xwin`) y `solokey-build-target`.

Firma: `tool/build.ps1` monta en solo lectura la llave debug del host (`%USERPROFILE%\.android\debug.keystore`). Sin ella
cada contenedor crea una llave nueva y el APK no se instala encima del que ya está en el celular (habría que desinstalar, y eso
borra la bóveda). Para comprobarlo: `apksigner verify --print-certs` dentro de la imagen y `keytool -list -v` sobre la llave.

| Escaneo | Imagen | Comando | Borrarlo |
|---|---|---|---|
| Dependencias (PLA-6) | `ghcr.io/google/osv-scanner:v2.7.0` (fijada por digest en el script) | `.\tool\escaneo-deps.ps1 [-Forzar]` | `podman rmi ghcr.io/google/osv-scanner:v2.7.0` |
