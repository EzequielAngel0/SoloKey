# Pendientes del agente

**Lo abierto que hacen las sesiones, en tablas.** Lo del dueño está en [`PENDIENTES_DUENO.md`](PENDIENTES_DUENO.md); lo cerrado
sale al archivo ([`archive/`](archive/README.md)); lo que cambió en el código, en [`../CHANGELOG.md`](../CHANGELOG.md).
Regla: [`README.md`](README.md) §"Regla de documentación". **Actualizado: 2026-11-15.**

Estado: `main` = v1.1.0 (2026-07-18). `develop` = integración de la **v2**, con todo decidido el 2026-11-15
([`diseno/REDISENO_V2.md`](diseno/REDISENO_V2.md) §1, ADR [0008 a 0013](adr/README.md)). Solo se publica la **v2.0.0 al final**.

## ▶ Orden

| # | Qué | Sesión | Estado |
|---|---|---|---|
| 0 | Decidir DEC-1 a DEC-10 y aprobar lo de cada carril | General | ✓ 2026-11-15 |
| 1 | Cimientos: renombrar el paquete (PLA-5) y subir dependencias (PLA-4), **sin otro carril tocando código**. En paralelo, ligera: CAL-4 ✓ y CAL-2 | D, y E | ☐ abrir ya |
| 2 | Sistema de diseño (DIS-1, 2, 3, 5) + imagen de build en Podman y escaneo (PLA-3, PLA-6) | B y D | ⊘ espera a 1 |
| 3 | Núcleo cripto en Rust (NUC-1), con la imagen de PLA-3 | A | ⊘ espera a PLA-3 |
| 4 | Pantallas (PAN-10, luego PAN-1 a 9) + formato v2 y migración (NUC-2, NUC-6) + harness E2E (CAL-5, CAL-3) | C, A y E | ⊘ espera a DIS-2 y NUC-1 |
| 5 | Sync v2 (NUC-3), logo (DIS-4), firma (PLA-1), 200%, amenazas y fuzz (CAL-1, SEG-1, SEG-2) | A, B, D y E | ⊘ espera a 4 |
| 6 | v2.0.0 a `main`, con el permiso del dueño | General | ⊘ espera a 5 |

**Como mucho dos sesiones pesadas a la vez** (build de Flutter, Rust, Podman o emulador) y una ligera. Abrir una sesión por
prompt; `ListAgents` antes de tocar el emulador o el celular. Reglas y plantilla: [`sesiones/README.md`](sesiones/README.md).

## Prompts

En orden de carril (General, A a E); **el orden en que se abren es el del ▶**: primero D y E.

Reglas comunes a todos los carriles (van dentro de cada prompt): skill `solokey`; worktree propio; **todo lo que se pueda, en
Podman, nada nuevo en el host** ([ADR-0012](adr/0012-todo-en-podman.md)); **sin pruebas unitarias ni de widgets nuevas en Dart**,
y al reescribir algo se borran sus pruebas viejas y entra su E2E ([ADR-0011](adr/0011-pruebas-e2e-principal.md)); commit de una
línea sin acentos ni firma; merge `--no-ff` a develop y `pull --ff-only` en la carpeta principal; resumen al final con el CI
terminado.

### General

```text
SESION GENERAL de SoloKey (C:\Proyectos\Flutter\SoloKey; la carpeta principal es SOLO tuya). NO desarrollas: decides con el
dueno, verificas y publicas con su permiso.
Carga la skill solokey. ListAgents (el emulador y el celular los comparten otras sesiones).
1. RAMAS: git fetch; git worktree list y git log origin/develop.. en cada worktree: mergear lo terminado y verificado o
   preguntarle. Quitar worktrees solo con .\tool\quitar-worktree.ps1.
2. DEPENDENCIAS: flutter pub outdated y los escaneos PLA-6 a 8 de docs/sesiones/D.md cuando existan (.\tool\escaneo-deps.ps1,
   Dependabot, .\tool\escaneo-ramas.ps1); mientras, OSV-Scanner en Podman como dice D.md. Lo de seguridad, contarselo.
3. DECISIONES: docs/PENDIENTES_DUENO.md y lo marcado ◇ en docs/sesiones/*.md, con AskUserQuestion y la recomendada primero. Lo
   aprobado pasa a "Aprobado, para desarrollar" de su carril, con orden; una decision de fondo, ademas, a docs/adr/ (siguiente
   libre en docs/adr/README.md).
4. VERIFICACIONES: lo que dejaron los carriles, en la app (Windows y el celular); lo que pida cambiar va a su carril.
   Checklist PC + celular: docs/proceso/PRUEBAS_EN_DISPOSITIVOS.md.
5. PUBLICAR a main: solo la v2.0.0 y solo con su permiso en esta sesion (PR develop -> main, .\build_release.ps1;
   docs/publicacion/PUBLICAR.md).
Al cerrar: actualizar el ▶ de docs/PENDIENTES_AGENTE.md, estos prompts y PENDIENTES_DUENO; el resumen para el dueno va AL
FINAL, cuando el CI del ultimo push termine.
```

### A · Núcleo en Rust (fase 3; luego 4 y 5)

```text
SESION A de SoloKey (Nucleo: cripto, boveda, BD y sync en Rust). Desarrollas COMPLETO lo aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-A -b feat/a-nucleo-cripto origin/develop.
Carga la skill solokey. Lee docs/sesiones/README.md, docs/sesiones/A.md, docs/adr/0003, 0008, 0009, 0010, 0011 y 0012,
docs/arquitectura/ARQUITECTURA.md y docs/seguridad/SEGURIDAD.md. ListAgents y avisa que eres el carril A.
AL EMPEZAR, confirma con el dueno (AskUserQuestion) el orden de docs/sesiones/A.md: NUC-1, NUC-2 (con NUC-6), NUC-3; NUC-5
despues de la v2.0.0.
- Rust NO se instala en el host: cargo test, fuzz y builds en Podman (imagen solokey-build de D, PLA-3; si aun no existe,
  docker.io/library/rust para cargo test). La DLL de Windows sale cruzada con cargo-xwin.
- Solo crates auditados (RustCrypto, zeroize, snow); nada de cripto propia. Las pruebas unitarias viven SOLO en Rust; al
  reemplazar la cripto o la BD de Dart, borra sus pruebas Dart en la misma rama.
- NUC-2: formato v2 propio desde el inicio, migracion unica con copia previa; probar con los vectores de CAL-2 y con una COPIA
  de una boveda real, NUNCA con la real del dueno (vive en este equipo).
Gates: cargo test verde en Podman, flutter analyze en 0, lo que quede de flutter test en verde; prueba que tu prueba falla.
Rama corta por ID, commit de una linea sin acentos ni firma, merge --no-ff a develop y push; luego
git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop (si esta en develop y limpia).
Al cerrar cada ID: CHANGELOG [Unreleased], lo hecho a docs/archive/sesiones/A_HECHO.md, el ▶ de docs/PENDIENTES_AGENTE.md,
docs/arquitectura/ARQUITECTURA.md y docs/seguridad/SEGURIDAD.md. Quita tu worktree con .\tool\quitar-worktree.ps1 al final.
Resumen AL FINAL, con el CI terminado.
```

### B · Diseño (fase 2)

```text
SESION B de SoloKey (Diseno, sistema visual). Desarrollas COMPLETO lo aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-B -b feat/b-tokens-tinta-y-papel origin/develop.
Carga la skill solokey (§3 gustos del dueno) y las skills interface-design, mobile-android-design y flutter-theming-apps. Lee
docs/sesiones/README.md, docs/sesiones/B.md, docs/adr/0013 y docs/diseno/REDISENO_V2.md §3 y §4. ListAgents y avisa que eres B.
Antes de empezar comprueba en el ▶ que D termino PLA-5 y PLA-4; si no, no toques codigo.
AL EMPEZAR, confirma con el dueno (AskUserQuestion) el orden de docs/sesiones/B.md: DIS-1, DIS-2, DIS-3, DIS-5, DIS-4.
- Decidido, no re-preguntar: Tinta y papel (el unico color es el estado de seguridad), Atkinson Hyperlegible Next y Mono
  empaquetadas, claro + oscuro + sistema, sin vibraciones, todo liso, esquinas de 12, borde fino y sombra suave.
- El dueno revisa en la app, no en maquetas: deja la galeria (DIS-3) corriendo en Windows y dile donde abrirla. Afina los
  tonos con el ahi. Letra al 200% y modo oscuro siempre.
- Al reescribir el tema borra sus pruebas Dart viejas; sin pruebas unitarias ni de widgets nuevas (ADR-0011).
Gates: flutter analyze en 0, lo que quede de flutter test en verde, build_runner si tocas freezed/riverpod. Rama corta por ID,
commit de una linea sin acentos ni firma, merge --no-ff a develop y push; luego
git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop (si esta en develop y limpia).
Al cerrar cada ID: CHANGELOG [Unreleased], lo hecho a docs/archive/sesiones/B_HECHO.md y el ▶ de docs/PENDIENTES_AGENTE.md
(avisa cuando DIS-2 este listo: destraba a C). Quita tu worktree con .\tool\quitar-worktree.ps1 al final. Resumen AL FINAL,
con el CI terminado.
```

### C · Pantallas (fase 4)

```text
SESION C de SoloKey (Pantallas y flujos, movil y escritorio). Desarrollas COMPLETO lo aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-C -b feat/c-espanol-fuente origin/develop.
Carga la skill solokey (§3) y las skills interface-design, mobile-android-design y flutter-build-responsive-layout. Lee
docs/sesiones/README.md, docs/sesiones/C.md, docs/adr/0011 y 0013 y docs/diseno/REDISENO_V2.md §4. ListAgents y avisa que eres C.
Antes de empezar comprueba en el ▶ que B termino DIS-1 y DIS-2; si no, no toques pantallas.
AL EMPEZAR, confirma con el dueno (AskUserQuestion) que PAN se hace hoy, en el orden de docs/sesiones/C.md (PAN-10 primero).
- Solo piezas del kit de B; si falta una, pidela a B en su doc. Solo tokens del tema, ningun color fijo.
- Cada PAN: movil Y escritorio, textos en espanol (fuente) e ingles, su E2E en Android y Windows con el harness de E (CAL-5), y
  borra las pruebas Dart viejas de lo que reemplaza. Sin pruebas unitarias ni de widgets nuevas.
- Dejala corriendo en Windows (y en el celular si ListAgents lo permite) y dile al dueno donde verla; letra al 200% y oscuro.
Gates: flutter analyze en 0, flutter gen-l10n si tocas .arb, E2E en verde. Rama corta por PAN, commit de una linea sin acentos
ni firma, merge --no-ff a develop y push; luego git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop.
Al cerrar cada PAN: CHANGELOG [Unreleased], lo hecho a docs/archive/sesiones/C_HECHO.md, el ▶ de docs/PENDIENTES_AGENTE.md y
docs/producto/PRODUCTO.md si cambio lo que la app hace. Quita tu worktree con .\tool\quitar-worktree.ps1 al final. Resumen AL
FINAL, con el CI terminado.
```

### D · Plataforma y entrega (fase 1, abrir primero; luego 2 y 5)

```text
SESION D de SoloKey (Plataforma y entrega). Desarrollas COMPLETO lo aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-D -b chore/d-renombrar-paquete origin/develop (la carpeta principal es de la general).
Carga la skill solokey. Lee docs/sesiones/README.md, docs/sesiones/D.md, docs/adr/0011 y 0012, y
docs/arquitectura/ARQUITECTURA.md. ListAgents y avisa que eres el carril D.
AL EMPEZAR, confirma con el dueno (AskUserQuestion) el orden de docs/sesiones/D.md: PLA-5, PLA-4, PLA-6, PLA-3, PLA-1.
- PLA-5 y PLA-4 van SOLOS: ningun otro carril toca codigo mientras tanto (cambian casi todos los archivos). Una rama por ID.
- PLA-5: SOLO el paquete Dart. NO toques CompanyName/ProductName de windows/runner/Runner.rc, BINARY_NAME ni el applicationId:
  de ahi sale la ruta de la boveda real del dueno (la app arrancaria vacia). Detalle en docs/sesiones/D.md §PLA-5.
- PLA-4: una mayor por commit; flutter_secure_storage 11 debe seguir leyendo el .dat de la v1 (probar con una COPIA).
- PLA-3 y PLA-6: imagenes y volumenes de Podman con prefijo solokey-, comando de limpieza en docs/proceso/PRUEBAS.md. NADA
  nuevo en el host: Rust, NDK y emulador solo en contenedor. La VM de Podman tiene /dev/kvm.
- PLA-1: la llave queda fuera del repo; el dueno guarda el respaldo (avisale cuando la generes).
Gates: flutter analyze en 0 y las pruebas que existan en verde; build_runner si tocas freezed/riverpod/drift; prueba que tu
prueba falla. Rama corta, commit de una linea sin acentos ni firma, merge --no-ff a develop y push; luego
git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop (si esta en develop y limpia).
Al cerrar cada ID: CHANGELOG [Unreleased], lo hecho a docs/archive/sesiones/D_HECHO.md, el ▶ de docs/PENDIENTES_AGENTE.md y el
doc de docs/ que describa lo que cambiaste. Al terminar PLA-5 y PLA-4 avisa en el ▶ que la fase 2 puede arrancar.
Quita tu worktree con .\tool\quitar-worktree.ps1 cuando todo este mergeado. Resumen AL FINAL, con el CI terminado.
```

### E · Calidad y seguridad (fase 1 en paralelo, ligera; luego fases 4 y 5)

```text
SESION E de SoloKey (Calidad y seguridad). Desarrollas COMPLETO lo aprobado de tu carril y nada de otro.
Worktree: git worktree add ..\SoloKey-E -b test/e-respaldo-archivos-seguros origin/develop.
Carga la skill solokey. Lee docs/sesiones/README.md, docs/sesiones/E.md, docs/adr/0009, 0011 y 0012, docs/proceso/PRUEBAS.md
y PRUEBAS_INTEGRACION.md. ListAgents y avisa que eres el carril E.
AL EMPEZAR, confirma con el dueno (AskUserQuestion) que se hace hoy, en el orden de docs/sesiones/E.md: CAL-4, CAL-2, CAL-5,
CAL-3, CAL-1, SEG-1, SEG-2 (CAL-5 en adelante esperan a NUC-6 de A y a PLA-3 de D: mira el ▶).
- CAL-4 primero: que run_integration_tests.ps1 respalde y restaure secure_files/ con hash; verlo fallar antes del arreglo.
- CAL-2: vectores generados con la app v1 en un entorno de prueba, NUNCA con la boveda real del dueno.
- La boveda real vive en este equipo: nada de vault_e2e_test a mano. Sin pruebas unitarias ni de widgets nuevas en Dart: la
  red de la v2 son E2E (Android en Podman, Windows en local con boveda aislada y en windows-latest) y cargo test en Podman.
Rama corta por ID, commit de una linea sin acentos ni firma, merge --no-ff a develop y push; luego
git -C C:\Proyectos\Flutter\SoloKey pull --ff-only origin develop (si esta en develop y limpia).
Al cerrar cada ID: CHANGELOG [Unreleased], lo hecho a docs/archive/sesiones/E_HECHO.md, el ▶ de docs/PENDIENTES_AGENTE.md y
docs/proceso/PRUEBAS.md o docs/seguridad/SEGURIDAD.md segun toque. Quita tu worktree con .\tool\quitar-worktree.ps1 al final.
Resumen AL FINAL, con el CI terminado (gh run watch).
```

## Por carril

| Carril | Doc | Aprobado, en orden |
|---|---|---|
| A · Núcleo | [`sesiones/A.md`](sesiones/A.md) | NUC-1, NUC-2, NUC-3, NUC-6; NUC-5 después de la v2.0.0 |
| B · Diseño | [`sesiones/B.md`](sesiones/B.md) | DIS-1, DIS-2, DIS-3, DIS-5, DIS-4 |
| C · Pantallas | [`sesiones/C.md`](sesiones/C.md) | PAN-10, PAN-1 a PAN-9 |
| D · Plataforma y entrega | [`sesiones/D.md`](sesiones/D.md) | PLA-5, PLA-4, PLA-6, PLA-3, PLA-1; PLA-7 y 8 aprobados, el dueño dice cuándo |
| E · Calidad y seguridad | [`sesiones/E.md`](sesiones/E.md) | CAL-2, CAL-5, CAL-3, CAL-1, SEG-1, SEG-2 (CAL-4 ✓); SEC-003 y SEC-008 los cierra la v2 |
