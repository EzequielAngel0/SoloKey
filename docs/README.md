# Documentación de SoloKey

Reorganizada el **2026-11-14**: sesiones por carril y un hecho, una fuente.

**Empieza por aquí:** [`PENDIENTES.md`](PENDIENTES.md) (lo abierto y los prompts de cada sesión) y
[`design/REDISENO_V2.md`](design/REDISENO_V2.md) (la propuesta de la v2).

```
docs/
├── PENDIENTES.md   Lo abierto, del dueño y por carril, y los prompts ▶
├── sesiones/       Un doc por carril (A Núcleo, B Diseño, C Pantallas, D Plataforma, E Calidad)
├── design/         Propuesta de la v2
├── proceso/        Ramas, pruebas, integración
├── planning/       Checklist en dispositivos, ideas, plan de WebAuthn
├── features/       Diseño de features ya construidas (companion, rotación)
├── spec/           Especificación fundacional (histórica)
├── security/       Informe de auditoría (julio 2026)
├── release/        Publicación y guía de iOS
├── legal/          Privacidad y términos
├── portfolio/      Caso de estudio y CV
└── archive/        Lo cerrado
```

| Doc | Para qué |
|---|---|
| [`PENDIENTES.md`](PENDIENTES.md) | Qué falta, de quién, y cómo abrir cada sesión |
| [`sesiones/README.md`](sesiones/README.md) | Carriles, reglas y plantilla |
| [`design/REDISENO_V2.md`](design/REDISENO_V2.md) | Decisiones de la v2 (stack, dirección visual, temas, idiomas) |
| [`proceso/RAMAS.md`](proceso/RAMAS.md) | `main` / `develop` / ramas cortas, commits, worktrees |
| [`proceso/PRUEBAS.md`](proceso/PRUEBAS.md) | La red de pruebas, gates y reglas |
| [`proceso/PRUEBAS_INTEGRACION.md`](proceso/PRUEBAS_INTEGRACION.md) | Motor `integration_test` en Windows y Android |
| [`planning/pruebas_dispositivos_reales.md`](planning/pruebas_dispositivos_reales.md) | Checklist PC + celular (R1, M1, M3) |
| [`planning/feature_ideas.md`](planning/feature_ideas.md) | Ideas sueltas (lo aprobado va a un carril) |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Qué cambió en el código, por versión |

## Regla de documentación

1. **Un hecho, una fuente.** Cada tipo de hecho se escribe completo en UN archivo; los demás enlazan, no resumen.

   | Hecho | Fuente única |
   |---|---|
   | Qué cambió en el código | `CHANGELOG.md` (`[Unreleased]` hasta publicar) |
   | Qué falta | `PENDIENTES.md` y el doc de su carril en `sesiones/` |
   | Qué se decidió y por qué | `adr/` (se crea con la primera decisión: DEC-1) |
   | Cómo se prueba | `proceso/PRUEBAS.md` |

2. **En línea, solo lo abierto.** Lo terminado sale al archivo en la misma rama que lo cierra, en una o dos líneas
   (`archive/sesiones/<carril>_HECHO.md`). Un doc que ya no es accionable va a `archive/` con su fila en
   [`archive/README.md`](archive/README.md); no se borra del git.
3. **Tablas, no párrafos.** Pendientes y carriles van en tablas de celdas de una línea; lo largo, abajo en *Detalle*.
4. **Al cerrar una feature**, en su misma rama: `CHANGELOG.md`, su carril, `PENDIENTES.md` ▶ y un `grep` de `docs/` por lo que
   cambió (nombres de pantallas, rutas, comandos).
5. Sin raya larga en lo que se redacta para el dueño: comas, dos puntos o paréntesis.
