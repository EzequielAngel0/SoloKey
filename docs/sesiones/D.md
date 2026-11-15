# Carril D · Plataforma y entrega

Reglas y plantilla: [`README.md`](README.md). Build: `.\build_release.ps1` (nunca `flutter build windows` suelto; el entregable de
Windows es el instalador de Inno Setup). Herramientas: [ADR-0012](../adr/0012-todo-en-podman.md) (todo en Podman, nada nuevo en
el host).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | PLA-5 | Renombrar el paquete Dart `password_manager` a `solokey` (imports, `pubspec.yaml`, CI) | S | ☐ | [ver](#pla-5); **solo, sin otro carril tocando código** |
| 2 | PLA-4 | Subir dependencias mayores (Riverpod 3, go_router 18, freezed 3, flutter_secure_storage 11, local_auth 3, `window_manager`, `tray_manager`, drift 2.35) | L | ☐ | [ver](#pla-4) |
| 3 | PLA-6 | `tool\escaneo-deps.ps1`: OSV-Scanner en Podman sobre `pubspec.lock` y `Cargo.lock` + `flutter pub outdated` + alertas de Dependabot abiertas | S | ☐ | [ver](#detalle-escaneos-pla-6-a-8) |
| 4 | PLA-3 | Imagen `solokey-build` en Podman (Flutter, SDK y NDK de Android, Rust, `cargo-ndk`, `cargo-xwin`); APK y DLL del núcleo salen de ahí; CI con Rust, E2E de Android y `windows-latest` | L | ☐ | [ver](#pla-3) |
| 5 | PLA-1 | Firma de release de Android (keystore propio fuera del repo, `key.properties` ignorado; el dueño guarda el respaldo) | M | ☐ | Antes de la v2.0.0 |

## Aprobado, sin desarrollar (el dueño dice cuándo)

Aprobados el 2026-11-14 junto con PLA-6 como un paquete ("los escaneos"), redactados y **sin construir** hasta que el dueño lo
pida. Plan en [Detalle: escaneos](#detalle-escaneos-pla-6-a-8).

| ID | Qué | Esf. |
|---|---|---|
| PLA-7 | Dependabot: `.github/dependabot.yml` (pub y Actions, semanal, a `develop`) y encender las alertas del repo | S |
| PLA-8 | `tool\escaneo-ramas.ps1`: worktrees y ramas ya mergeadas, carpetas `..\SoloKey-*` huérfanas, ramas viejas sin PR | S |

## En espera

| ID | Qué | Esf. | Lo destraba |
|---|---|---|---|
| PLA-2 | Empaquetado macOS, Linux e iOS | XL | Hardware; diferido por el dueño |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| A | Estructura de `rust/` (NUC-1) | PLA-3 y el `Cargo.lock` de PLA-6 |

## No reabre

| Qué | Por qué |
|---|---|
| `-ExecutionPolicy Bypass` en los scripts | Lo bloquea el clasificador; `RemoteSigned` ya permite los `.ps1` locales |
| `rustup`, NDK o SDK nuevos en el host | ADR-0012 |
| Betas intermedias publicadas | DEC-10: solo la v2.0.0 al final |

## Detalle

### PLA-5

- **Solo el nombre del paquete Dart** (`name:` de `pubspec.yaml` e imports `package:password_manager/`). Cambia casi todos los
  archivos: ningún otro carril toca código mientras dura.
- **NO tocar** lo que decide dónde vive la bóveda del dueño o cómo se instala: `CompanyName` y `ProductName` de
  `windows/runner/Runner.rc` (forman la ruta `%APPDATA%\Angel Ezequiel Barbosa Lomeli\SoloKey` del almacén seguro y de
  `secure_files`), `BINARY_NAME` (`SoloKey`, lo usan el instalador y el arranque con Windows), el `applicationId` de Android y la
  ruta vieja `com.vaultguard\password_manager` que respalda `run_integration_tests.ps1`. `project(password_manager)` de
  `windows/CMakeLists.txt` puede quedarse.
- Verificar: `flutter analyze` en 0, pruebas en verde, y que la app de Windows abre la bóveda real **sin pedir crear una nueva**
  (respaldo previo en `%USERPROFILE%\SoloKey-respaldo-20261114-235706`).

### PLA-4

- Una rama, una mayor por commit, cada una con analyze y pruebas en verde. Leer el CHANGELOG de cada paquete antes.
- Escaneo de seguridad del 2026-11-15 (OSV-Scanner v2.2.1, 203 paquetes): **sin vulnerabilidades conocidas**. Es mantenimiento.
- `drift`, `cryptography` y `shelf*` se van con el núcleo Rust: subirlos solo si lo exige otra dependencia.
- `flutter_secure_storage` 11: comprobar que sigue leyendo el `.dat` de la v1 (DPAPI) antes de mergear; probar con una copia.

### PLA-3

- La VM de Podman tiene `/dev/kvm`: el emulador de Android corre sin pantalla dentro del contenedor.
- Volúmenes con nombre para el caché de Pub, Gradle, Cargo y el SDK (`solokey-pub`, `solokey-gradle`, `solokey-cargo`,
  `solokey-android-sdk`), y el comando de limpieza en `proceso/PRUEBAS.md`.
- `build_release.ps1 -Target android` usa la imagen; `-Target windows|inno` sigue en el host con la DLL que dejó el contenedor.

## Detalle: escaneos (PLA-6 a 8)

Los corre **solo la sesión general**, a diario, al empezar (pasos 1 y 2 de su prompt). Los tres: solo lectura salvo `-Limpiar`,
`.ps1` en ASCII, salida **0 = limpio, 2 = hay algo que contarle al dueño, 1 = error**.

**PLA-6, `tool\escaneo-deps.ps1`**
1. OSV-Scanner en Podman, imagen fijada por versión y digest (`ghcr.io/google/osv-scanner`), repo montado de solo lectura:
   `scan source -r --format json`. Hallazgo = severidad alta o crítica **con versión que lo arregla**; sin arreglo, aviso.
   Probado a mano el 2026-11-15 con `ghcr.io/google/osv-scanner:v2.2.1 scan source --lockfile /src/pubspec.lock`
   (`MSYS_NO_PATHCONV=1` en Git Bash): 203 paquetes, sin vulnerabilidades.
2. `flutter pub outdated --json` (Flutter va en el host): cuenta lo que tiene versión nueva compatible y los mayores pendientes
   (estos últimos alimentan PLA-4).
3. `gh api repos/<dueño>/SoloKey/dependabot/alerts?state=open`: las alertas abiertas de GitHub.
4. Guarda el resultado del día en `.claude\estado\escaneo-deps.json` (local) y con `-Forzar` vuelve a medir.

**PLA-7, Dependabot**
- `.github/dependabot.yml`: `pub` en `/` y `github-actions` en `/`; `target-branch: develop`; los lunes; minor y patch agrupados;
  `cooldown` de 7 días (14 los mayores) para no recibir versiones recién publicadas; `commit-message.prefix: chore`.
- Encender **solo las alertas** (`gh api -X PUT repos/<dueño>/SoloKey/vulnerability-alerts`). Las *security updates*
  automáticas se quedan apagadas: abren su PR contra `main`, que es del dueño; el arreglo entra por `develop` como todo.
- Las PR de Dependabot corren el CI en las máquinas de GitHub (repo público, gratis). La general las revisa: lo que mueva
  autofill, notificaciones, bandeja o cripto se prueba en el dispositivo antes de mergear.

**PLA-8, `tool\escaneo-ramas.ps1`**
- Worktrees y ramas locales y remotas cuya punta ya entró a `develop` con un merge `--no-ff` (una rama recién creada desde
  `develop` NO cuenta); carpetas `..\SoloKey-*` que ya no son worktree; ramas remotas sin merge ni PR de más de 7 días.
- `-Limpiar` borra solo lo terminado y quita los worktrees con `tool\quitar-worktree.ps1` (nunca `git worktree remove` a
  secas); lo que no está mergeado se le pregunta al dueño. Antes de `-Limpiar`, `ListAgents`.
- Nunca toca `main`, `develop` ni las ramas de Dependabot con PR abierta.

**Al construirlos**: prompt de la general (`../PENDIENTES_AGENTE.md`, pasos 1 y 2), tabla de comandos de `CLAUDE.md`, regla
en la skill `solokey` §Máquina y `../seguridad/SEGURIDAD.md` §4.
