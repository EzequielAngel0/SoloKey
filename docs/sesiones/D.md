# Carril D · Plataforma y entrega

Reglas y plantilla: [`README.md`](README.md). Build: `.\build_release.ps1` (nunca `flutter build windows` suelto; el entregable de
Windows es el instalador de Inno Setup). Herramientas: [ADR-0012](../adr/0012-todo-en-podman.md) (todo en Podman, nada nuevo en
el host).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | PLA-1 | Firma de release de Android (keystore propio fuera del repo, `key.properties` ignorado; el dueño guarda el respaldo) | M | ☐ | Antes de la v2.0.0 |

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
| PLA-9 | `flutter_secure_storage` 11 | S | Que el celular del dueño haya abierto un build con la 10 (la 11 ya no lee EncryptedSharedPreferences de la v9) |
| PLA-10 | Mayores que piden Flutter ≥ 3.47 o AGP 9: `window_manager` 0.7, `tray_manager` 0.9, `hotkey_manager` 0.4, `desktop_drop` 0.8+, `share_plus` 13, `file_picker` 13, `flutter_local_notifications` 23, freezed 4, injectable 3 y `drift_flutter` 0.3 | M | Subir Flutter (y AGP 9 con Kotlin integrado) |

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

### PLA-9 y PLA-10

- Lo que quedó fuera de PLA-4 (hecho el 2026-11-19, ver `../archive/sesiones/D_HECHO.md`). `drift`, `cryptography` y `shelf*`
  se van con el núcleo Rust: subirlos solo si lo exige otra dependencia.
- PLA-9: con la 10 instalada, la 11 solo cambia el plugin de Android; probar la subida 9 → 10 → 11 en el emulador antes de mergear.
- PLA-10: el CI de Windows sigue en `windows-2022`: con Visual Studio 18 (`windows-latest`) `local_auth_windows` y
  `flutter_local_notifications_windows` no compilan (`<experimental/coroutine>`, aviso del carril E).

### PLA-3

Hecho el 2026-11-19 ([`../archive/sesiones/D_HECHO.md`](../archive/sesiones/D_HECHO.md)); cómo se usa, en
[`proceso/PRUEBAS.md`](../proceso/PRUEBAS.md) §"Build y E2E de Android en Podman".
- El job de `windows-latest` es el `e2e-windows` del PR #1 de E (CAL-5, verde): lo mergea E; aquí no se duplicó.
- Las librerías del núcleo salen sin símbolos exportados hasta que A genere el puente de `flutter_rust_bridge`: hoy prueban la
  cadena (NDK, tres ABI y `cargo-xwin`), no se cargan desde la app.
- Hallazgo para la v2: la app espera el permiso de notificaciones **antes** de `runApp` (`main.dart`, `notifications.initialize()`);
  en Android 13+ la primera apertura se queda en el splash hasta contestar el diálogo. El E2E lo esquiva instalando con `-g`.

## Detalle: escaneos (PLA-6 a 8)

Los corre **solo la sesión general**, a diario, al empezar (pasos 1 y 2 de su prompt). Los tres: solo lectura salvo `-Limpiar`,
`.ps1` en ASCII, salida **0 = limpio, 2 = hay algo que contarle al dueño, 1 = error**.

**PLA-6, `tool\escaneo-deps.ps1`** (hecho el 2026-11-19; imagen `ghcr.io/google/osv-scanner:v2.7.0` fijada por digest y
`-Umbral`/`-Imagen` para ver el gate en 2 y en 1)
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
