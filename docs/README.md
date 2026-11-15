# Documentación de SoloKey

**Empieza por aquí:** [`PENDIENTES_AGENTE.md`](PENDIENTES_AGENTE.md) (qué hacen las sesiones y sus prompts ▶),
[`PENDIENTES_DUENO.md`](PENDIENTES_DUENO.md) (qué falta de ti) y [`arquitectura/ARQUITECTURA.md`](arquitectura/ARQUITECTURA.md)
(cómo está hecha la app). Reorganizada el 2026-11-14.

```
docs/
├── PENDIENTES_AGENTE.md   Lo abierto de las sesiones, por carril, y los prompts ▶
├── PENDIENTES_DUENO.md    Lo que solo el dueño puede hacer o decidir
├── arquitectura/          Cómo está hecha: ARQUITECTURA (central), SYNC_P2P, ROTACION
├── adr/                   Decisiones de fondo con su porqué (no se reescriben)
├── producto/              Qué hace (PRODUCTO) y qué podría hacer (IDEAS)
├── diseno/                La v2: REDISENO_V2 (decisiones aprobadas, dirección, orden)
├── sesiones/              Un doc por carril (A Núcleo, B Diseño, C Pantallas, D Plataforma, E Calidad)
├── seguridad/             SEGURIDAD (amenazas, hallazgos con estado) y el plan de WEBAUTHN
├── proceso/               RAMAS, PRUEBAS, PRUEBAS_INTEGRACION, PRUEBAS_EN_DISPOSITIVOS
├── publicacion/           PUBLICAR (tiendas y release) e IOS
├── legal/                 PRIVACIDAD y TERMINOS (plantillas por revisar)
├── portafolio/            CASO_DE_ESTUDIO, CV y RESUMEN para el portafolio del dueño
└── archive/               Lo cerrado de la v1, solo para consulta
```

| Si vas a... | Lee |
|---|---|
| Abrir una sesión | [`PENDIENTES_AGENTE.md`](PENDIENTES_AGENTE.md) ▶ y [`sesiones/README.md`](sesiones/README.md) |
| Tocar cripto, BD o sync | [`arquitectura/ARQUITECTURA.md`](arquitectura/ARQUITECTURA.md), [`adr/`](adr/README.md) y [`seguridad/SEGURIDAD.md`](seguridad/SEGURIDAD.md) |
| Diseñar una pantalla | [`diseno/REDISENO_V2.md`](diseno/REDISENO_V2.md) y la skill `solokey` §3 |
| Probar | [`proceso/PRUEBAS.md`](proceso/PRUEBAS.md) (y la integración, solo con `run_integration_tests.ps1`) |
| Mergear o publicar | [`proceso/RAMAS.md`](proceso/RAMAS.md) y [`publicacion/PUBLICAR.md`](publicacion/PUBLICAR.md) |
| Proponer algo nuevo | [`producto/IDEAS.md`](producto/IDEAS.md) para comprobar que no existe ya |

## Regla de documentación

1. **Un hecho, una fuente.** Cada tipo de hecho se escribe completo en UN archivo; los demás enlazan, no resumen.

   | Hecho | Fuente única |
   |---|---|
   | Qué cambió en el código | `../CHANGELOG.md` (`[Unreleased]` hasta publicar) |
   | Qué falta | `PENDIENTES_AGENTE.md` + el doc de su carril, y `PENDIENTES_DUENO.md` |
   | Cómo está hecha la app hoy | `arquitectura/ARQUITECTURA.md` (manda el código si difieren) |
   | Qué hace la app | `producto/PRODUCTO.md` |
   | Qué se decidió y por qué | `adr/` (una ADR no se reescribe: se reemplaza por otra) |
   | Riesgos y hallazgos de seguridad | `seguridad/SEGURIDAD.md` |
   | Cómo se prueba | `proceso/PRUEBAS.md` |

2. **En línea, solo lo vigente.** Lo terminado de un carril sale en la misma rama que lo cierra a
   `archive/sesiones/<carril>_HECHO.md`, en una o dos líneas. Un doc que ya no se usa pero sirve de consulta va a `archive/` con su
   fila en [`archive/README.md`](archive/README.md); **lo que ya quedó absorbido por otro doc se borra** (queda en git).
3. **Tablas, no párrafos.** Celdas de una línea; lo largo, abajo en *Detalle*. Nombres de archivo en MAYÚSCULAS y sin acentos,
   carpetas en minúsculas.
4. **Al cerrar una feature**, en su misma rama: `CHANGELOG.md`, su carril, `PENDIENTES_AGENTE.md` ▶, el doc que la describa
   (`ARQUITECTURA`, `PRODUCTO`, `SEGURIDAD`) y un `grep` de `docs/` por lo que cambió.
5. Sin raya larga en lo que se redacta para el dueño: comas, dos puntos o paréntesis.
