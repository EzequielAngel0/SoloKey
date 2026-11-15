# Carril D · Plataforma y entrega

Reglas y plantilla: [`README.md`](README.md). Build: `.\build_release.ps1` (nunca `flutter build windows` suelto; el entregable de
Windows es el instalador de Inno Setup).

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía.

## Aprobado, sin desarrollar (el dueño dice cuándo)

Aprobados el 2026-11-14 como un paquete ("los escaneos"), redactados y **sin construir** hasta que el dueño lo pida. Plan abajo,
en *Detalle: escaneos*.

| ID | Qué | Esf. |
|---|---|---|
| PLA-6 | `tool\escaneo-deps.ps1`: OSV-Scanner en Podman sobre `pubspec.lock` (y `Cargo.lock` si hay Rust) + `flutter pub outdated` + alertas de Dependabot abiertas | S |
| PLA-7 | Dependabot: `.github/dependabot.yml` (pub y Actions, semanal, a `develop`) y encender las alertas del repo | S |
| PLA-8 | `tool\escaneo-ramas.ps1`: worktrees y ramas ya mergeadas, carpetas `..\SoloKey-*` huérfanas, ramas viejas sin PR | S |

## En espera

| ID | Qué | Esf. | Lo destraba |
|---|---|---|---|
| PLA-1 | Firma de release de Android (keystore propio fuera del repo, `key.properties` ignorado); hoy los APK van con la clave debug | M | El dueño la pospuso (2026-07-18): avisa cuándo |
| PLA-2 | Empaquetado macOS, Linux e iOS | XL | Hardware; diferido por el dueño |
| PLA-3 | Toolchain de Rust (rustup, MSVC, `cargo-ndk`) en el host y paso de Rust en CI | M | DEC-1 = R1 (o NUC-0 aprobado) |

## Propuestas de la sesión (◇)

| ID | Qué | Para qué | Esf. |
|---|---|---|---|
| PLA-4 ◇ | Subir dependencias mayores (Riverpod 2 a 3, go_router 14 a la actual, freezed 2 a 3, `window_manager`, `tray_manager`) en una rama, antes de rehacer pantallas | No rehacer la interfaz sobre APIs que van a cambiar; medir primero con `flutter pub outdated` | L |
| PLA-5 ◇ | Renombrar el paquete Dart `password_manager` a `solokey` (imports) | Coherencia; el `applicationId` ya es `com.angelezequiel.solokey` | S |

## No reabre

| Qué | Por qué |
|---|---|
| `-ExecutionPolicy Bypass` en los scripts | Lo bloquea el clasificador; `RemoteSigned` ya permite los `.ps1` locales |

## Detalle: escaneos (PLA-6 a 8)

Los corre **solo la sesión general**, a diario, al empezar (paso 1 y 2 de su prompt). Los tres: solo lectura salvo `-Limpiar`,
`.ps1` en ASCII, salida **0 = limpio, 2 = hay algo que contarle al dueño, 1 = error**.

**PLA-6, `tool\escaneo-deps.ps1`**
1. OSV-Scanner en Podman, imagen fijada por versión y digest (`ghcr.io/google/osv-scanner`), repo montado de solo lectura:
   `scan source -r --format json`. Hallazgo = severidad alta o crítica **con versión que lo arregla**; sin arreglo, aviso.
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

**Al construirlos**: prompt de la general (`../PENDIENTES_AGENTE.md` ▶, pasos 1 y 2), tabla de comandos de `CLAUDE.md`, regla
en la skill `solokey` §Máquina y `../seguridad/SEGURIDAD.md` §4.
