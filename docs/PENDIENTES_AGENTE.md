# Pendientes del agente

**Lo abierto que hacen las sesiones, en tablas.** Lo del dueño está en [`PENDIENTES_DUENO.md`](PENDIENTES_DUENO.md); lo cerrado
sale al archivo ([`archive/`](archive/README.md)); lo que cambió en el código, en [`../CHANGELOG.md`](../CHANGELOG.md).
Regla: [`README.md`](README.md) §"Regla de documentación". **Actualizado: 2026-11-14.**

Estado: `main` = v1.1.0 (2026-07-18). `develop` = integración de la **v2 (rediseño completo)**, sin nada aprobado todavía.

## ▶ Orden y prompts para arrancar

| # | Qué | Sesión | Estado |
|---|---|---|---|
| 0 | Decidir DEC-1 a DEC-6 de [`diseno/REDISENO_V2.md`](diseno/REDISENO_V2.md) §1 y aprobar lo de cada carril | General | ☐ |
| 1 | Sistema de diseño (DIS-1 a DIS-3) y, si se aprueba, el prototipo Rust (NUC-0), en paralelo | B y A | ⊘ espera a 0 |
| 2 | Pantallas por flujo (PAN-1 a PAN-10) | C | ⊘ espera a B |
| 3 | Plataforma y entrega; calidad y seguridad, todo el tiempo | D y E | ⊘ espera a 0 |

Carriles, reglas y plantilla: [`sesiones/README.md`](sesiones/README.md). Abrir **una sesión por prompt**; como mucho dos pesadas a la vez.

```text
SESION GENERAL de SoloKey (C:\Proyectos\Flutter\SoloKey; la carpeta principal es SOLO tuya). NO desarrollas: decides con el
dueno, verificas y publicas con su permiso.
Carga la skill solokey. ListAgents (el emulador y el celular los comparten otras sesiones).
1. RAMAS: git fetch; worktrees y ramas de sesiones cortadas (git worktree list; git log origin/develop.. en cada uno):
   mergear lo terminado y verificado o preguntarle. Quitar worktrees solo con .\tool\quitar-worktree.ps1.
2. DEPENDENCIAS: flutter pub outdated (y el escaneo de PLA-6 cuando exista); lo que tenga arreglo de seguridad, contarselo.
3. DECISIONES: repasar con el dueno docs/PENDIENTES_DUENO.md, docs/diseno/REDISENO_V2.md §1 (DEC-1 a DEC-6) y lo marcado ◇ en
   docs/sesiones/*.md, con AskUserQuestion y la recomendada primero. Lo aprobado pasa a "Aprobado, para desarrollar" de su
   carril, con orden; una decision de fondo, ademas, a docs/adr/.
4. VERIFICACIONES: lo que dejaron los carriles, en la app (Windows y el celular); lo que pida cambiar va a su carril.
   La checklist PC + celular: docs/proceso/PRUEBAS_EN_DISPOSITIVOS.md.
5. PUBLICAR a main: solo con su permiso en esta sesion (PR develop -> main, .\build_release.ps1; docs/publicacion/PUBLICAR.md).
Al cerrar: actualizar este ▶, los prompts y PENDIENTES_DUENO; el resumen para el dueno va AL FINAL, cuando el CI del ultimo
push termine.
```

```text
SESION <A|B|C|D|E> de SoloKey (<Nucleo|Diseno|Pantallas|Plataforma y entrega|Calidad y seguridad>). Desarrollas COMPLETO lo
aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-<letra> -b <tipo>/<letra>-<tema> origin/develop (la carpeta principal es de la general).
Carga la skill solokey. Lee docs/sesiones/README.md, docs/sesiones/<letra>.md y docs/arquitectura/ARQUITECTURA.md.
ListAgents y avisa que carril eres.
AL EMPEZAR, preguntale al dueno que se desarrolla (AskUserQuestion con lo aprobado y lo propuesto de tu doc). Sin nada
aprobado ni propuesto, propon 3 a 5 mejoras nuevas y no las construyas.
Gates: flutter analyze en 0, flutter test verde, build_runner si tocas freezed/riverpod/drift, flutter gen-l10n si tocas .arb;
prueba que tu prueba falla. Rama corta, commit de una linea sin acentos ni firma, merge --no-ff a develop y push; luego
git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop (si esta en develop y limpia).
Al cerrar cada item: CHANGELOG [Unreleased], lo hecho al archivo de tu carril, este ▶ y el doc de docs/ que describa lo que
cambiaste (ARQUITECTURA, SEGURIDAD, PRODUCTO). Quita tu worktree con .\tool\quitar-worktree.ps1 cuando todo este mergeado.
Resumen AL FINAL, con el CI del ultimo push terminado (gh run watch).
```

## Por carril

| Carril | Doc | Abierto |
|---|---|---|
| A · Núcleo | [`sesiones/A.md`](sesiones/A.md) | NUC-0 a 3 en espera de DEC-1; NUC-4 y 5 propuestas |
| B · Diseño | [`sesiones/B.md`](sesiones/B.md) | DIS-1 a 5 propuestas |
| C · Pantallas | [`sesiones/C.md`](sesiones/C.md) | PAN-1 a 10 propuestas |
| D · Plataforma y entrega | [`sesiones/D.md`](sesiones/D.md) | PLA-1 a 3 en espera; PLA-4 a 6 propuestas |
| E · Calidad y seguridad | [`sesiones/E.md`](sesiones/E.md) | CAL-1 a 3 y SEG-1 a 2 propuestas; SEC-003, 007 y 008 abiertos ([`seguridad/SEGURIDAD.md`](seguridad/SEGURIDAD.md)) |
