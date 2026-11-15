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
| Integración | `integration_test/**` | `.\run_integration_tests.ps1` | `vault_e2e_test` BORRA la bóveda local: solo con el runner (respalda con hash la BD, el `.dat` y `secure_files\`, y restaura en `finally`). |
| Respaldo del runner | `tool/respaldo-boveda.psm1` | `.\tool\probar-respaldo-boveda.ps1` | Sobre una bóveda falsa en `%TEMP%`; correrla al tocar el módulo o `Runner.rc`. |
| Vectores de la v1 | [`vectores/v1/`](../../vectores/v1/LEEME.md) | `.\tool\vectores_v1\verificar.ps1` | Python en Podman, sin Dart; los usa `cargo test` del núcleo (NUC-2). Regenerar solo si cambia lo que escribe la v1. |
| Dispositivos | PC + celular en la misma red | a mano | [`PRUEBAS_EN_DISPOSITIVOS.md`](PRUEBAS_EN_DISPOSITIVOS.md) |

## Gates

| Gate | Qué exige | Dónde |
|---|---|---|
| `pre-commit` | `flutter analyze` en 0 y `flutter test` verde (solo si el commit toca `.dart`) | `.githooks/` (activar: `git config core.hooksPath .githooks`) |
| `pre-push` | `flutter test --coverage` sobre el piso de `tool/coverage_min.txt` | `.githooks/` + `tool/check_coverage.dart` |
| CI | analyze + test + cobertura, en `main`, `develop` y PRs | `.github/workflows/tests.yml` (Flutter 3.44.4) |

El piso de cobertura es un **trinquete**: se sube al cubrir más y nunca se baja para que pase un cambio.

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

Para el núcleo en Rust ([ADR-0008](../adr/0008-nucleo-en-rust.md)), `cargo test` corre en `docker.io/library/rust` (luego en la
imagen `solokey-build` de PLA-3) sin instalar nada en Windows.
