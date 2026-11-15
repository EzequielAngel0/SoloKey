# Archivo

Lo que ya no es accionable. No se reescribe; se lee como registro de cómo se llegó aquí. Lo vivo está en
[`../PENDIENTES_AGENTE.md`](../PENDIENTES_AGENTE.md); la historia técnica, en [`../../CHANGELOG.md`](../../CHANGELOG.md).

## Cómo se ordena

| Carpeta | Qué guarda |
|---|---|
| `v1/` | El trabajo de la v1 (marzo a julio de 2026), ya en `main` |
| `sesiones/` | Lo hecho por cada carril, `<carril>_HECHO.md`, una o dos líneas por ítem (se crea al cerrar el primero) |
| `v2/` | Se crea al publicar la v2, con sus planes ya cumplidos |

Nombres en MAYÚSCULAS y carpetas en minúsculas, igual que el resto de `docs/`. Un doc se archiva cuando ya no queda nada abierto
en él; lo que siga abierto pasa antes a `PENDIENTES_AGENTE.md` o a `PENDIENTES_DUENO.md`.

## v1

| Qué | Dónde | Fechas | Por qué se archivó |
|---|---|---|---|
| Roadmap por lotes (temas, i18n, companion de escritorio) | [`v1/ROADMAP.md`](v1/ROADMAP.md) | 2026-04 a 07 | Hecho; queda en el CHANGELOG |
| Pendientes y bugs de la estabilización (B1 a B3, G1, M1 a M3) | [`v1/PENDIENTES_Y_BUGS.md`](v1/PENDIENTES_Y_BUGS.md) | 2026-07 | Cerrados; lo abierto pasó a los `PENDIENTES_*` |
| Rediseño visual Graphite Pro (con maqueta) | [`v1/diseno/GRAPHITE_PRO.md`](v1/diseno/GRAPHITE_PRO.md) · [maqueta](v1/diseno/GRAPHITE_PRO_MAQUETA.html) | 2026-06 | Hecho; la v2 lo reemplaza ([`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md)) |
| UX pantalla por pantalla, lotes L0 a L9 (con maqueta) | [`v1/diseno/UX_POR_PANTALLA.md`](v1/diseno/UX_POR_PANTALLA.md) · [maqueta](v1/diseno/UX_POR_PANTALLA_MAQUETA.html) | 2026-06 a 07 | Hecho; idem |
| Prompts por pantalla 00 a 99 | [`v1/prompts/`](v1/prompts/README.md) | 2026-07 | Todos hechos; la v2 trabaja por carriles ([`../sesiones/`](../sesiones/README.md)) |

Los docs de `v1/` citan rutas de entonces (`lib/...`, pantallas y servicios de la v1): siguen valiendo para el código de `main`,
no para la v2.
