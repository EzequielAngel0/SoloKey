# Sesiones de desarrollo (desde 2026-11-14)

Cómo se desarrolla SoloKey. Hay una **sesión general** y **carriles**:

- La **general** trabaja en la carpeta principal (`C:\Proyectos\Flutter\SoloKey`, que es SOLO suya). **No desarrolla**: escanea
  dependencias y ramas, decide con el dueño, prueba en los dispositivos (PC + celular) y publica a `main` con su permiso.
- Cada **carril** desarrolla completo lo aprobado de SU área, en su worktree (`..\SoloKey-<carril>`), y tiene su doc aquí.

Los prompts para abrir cada sesión están en [`../PENDIENTES_AGENTE.md`](../PENDIENTES_AGENTE.md) ▶. Ramas y worktrees:
[`../proceso/RAMAS.md`](../proceso/RAMAS.md). El plan que mueve todo esto: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md).

| Carril | Qué toca | Doc |
|---|---|---|
| **A · Núcleo** | Cripto, formato de bóveda, BD, sync; el prototipo y el núcleo en Rust si se aprueba (DEC-1). `lib/core/infrastructure/`, `lib/features/sync/infrastructure/`, `rust/` | [`A.md`](A.md) |
| **B · Diseño** | Sistema de diseño: tokens, tema, tipografía, kit de componentes, logo e iconos, galería en debug. `lib/theme/`, `lib/shared/widgets/`, `assets/` | [`B.md`](B.md) |
| **C · Pantallas** | Flujos y pantallas, móvil y escritorio (son los mismos archivos), textos e idiomas. `lib/features/*/presentation/`, `lib/core/presentation/`, `lib/router/`, `lib/l10n/` | [`C.md`](C.md) |
| **D · Plataforma y entrega** | Lo nativo de Android y Windows (autofill, instancia única, bandeja, instalador), firma, `build_release.ps1`, CI, dependencias. `android/`, `windows/`, `installer/`, `.github/`, `pubspec.yaml` | [`D.md`](D.md) |
| **E · Calidad y seguridad** | Red de pruebas, cobertura, integración, prueba al 200%, auditoría de seguridad y modelo de amenazas. `test/`, `integration_test/`, `tool/` | [`E.md`](E.md) |

## Reglas

1. **Cada carril desarrolla SOLO lo suyo.** Si algo toca dos carriles, cada uno hace su parte y lo escribe en §"Necesita de otros
   carriles" de su doc (qué espera y de quién), para que el dueño sepa qué sesión abrir.
2. **Al empezar, la sesión le pregunta al dueño qué se desarrolla** (`AskUserQuestion` con lo aprobado y lo propuesto de su doc). Lo
   que elija y no estuviera aprobado queda aprobado en ese momento y se mueve a *Aprobado*.
3. **Sin nada aprobado, la sesión propone**: revisa su área en el código y escribe de 3 a 5 mejoras en *Propuestas* (qué, para qué,
   esfuerzo y la comprobación de que no existe ya). No las construye hasta que el dueño las apruebe.
4. **Lo terminado sale del doc en la misma rama que lo cierra**, a `../archive/sesiones/<carril>_HECHO.md`, en una o dos líneas.
   El doc del carril solo tiene lo abierto y lo propuesto.
5. **Un ID no se repite entre carriles** (`grep` en esta carpeta antes de poner uno). Prefijos: A `NUC-`, B `DIS-`, C `PAN-`,
   D `PLA-`, E `CAL-` y `SEG-`.
6. **Máquina**: como mucho DOS sesiones pesadas a la vez (build de Flutter, Rust o emulador) y una ligera (docs, lectura). El
   emulador y el celular de pruebas los comparten otras sesiones: `ListAgents` antes de tomarlos.
7. **Docs compartidos** (`CHANGELOG.md`, `PENDIENTES_AGENTE.md`, `lib/l10n/*.arb`): cada carril escribe en su parte; quien mergea segundo
   rebasa y conserva las líneas de los dos.

## Plantilla de un doc de carril

Tablas, una fila por ID, cada celda en una línea; lo largo va en *Detalle* bajo `### <ID>`. Estado: ☐ por hacer · ◐ a medias ·
✓ construido, falta verificar · ⊘ espera al dueño.

```markdown
## Aprobado, para desarrollar (en orden)
| # | ID | Qué | Esf. | Estado | Detalle |
## Hecho, falta el dueño
| ID | Qué | Falta de ti | Luego el agente |
## En espera
| ID | Qué | Esf. | Lo destraba |
## Necesita de otros carriles
| De | Qué | Para |
## Propuestas de la sesión (◇)
| ID | Qué | Para qué | Esf. |
## No reabre
| Qué | Por qué |
## Detalle
### <ID>
```

Esfuerzo: S horas · M un día · L varios días · XL semanas. Si una tabla no tiene filas, se cambia por una línea ("Nada").
