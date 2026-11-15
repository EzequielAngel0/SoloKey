# ADR-0013: Diseño, idioma y experiencia de la v2

Estado: Vigente (2026-11-15) · Decide: el dueño (DEC-2 a DEC-6 y la experiencia de REDISENO_V2 §4)

## Contexto
El rediseño de julio (Graphite Pro) recoloreó la v1 sin cambiar la experiencia y al dueño no le gustó. La v2 se rehace entera.
Propuesta y tokens de partida: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §3 y §4.

## Decisión

| Tema | Decisión |
|---|---|
| Dirección (DEC-2) | **Tinta y papel**: papel cálido y tinta casi negra; el botón principal es tinta. **El único color es el estado de seguridad** (rojo comprometida o irreversible, ámbar débil, verde sana). Tipos de credencial por icono, no por color |
| Tipografía | **Atkinson Hyperlegible Next** (interfaz) y **Atkinson Hyperlegible Mono** (secretos y códigos), empaquetadas sin red: distinguen l, I y 1, y 0 y O, y aguantan la letra al 200% |
| Temas (DEC-3) | **Claro, oscuro y seguir al sistema** (por defecto). Fuera dim y OLED |
| Idioma (DEC-4) | **Español como idioma fuente** (`app_es.arb` como plantilla) + inglés; textos sin jerga |
| Vibración y sonido (DEC-5) | **Ninguno dentro de la app**; fuera también el shimmer y la animación escalonada. Solo notificaciones del sistema |
| Marca (DEC-6) | Se conserva **SoloKey**; el monograma se redibuja plano en el estilo nuevo |
| Experiencia (§4) | Celular: barra inferior **Bóveda · Seguridad · Ajustes**, carpetas como filtro, copiar en un toque desde la lista. Windows: tres paneles, Ctrl+K y atajos. Biometría o Windows Hello primero; primer uso en 3 pasos |
| Forma | Todo liso (sin degradados, vidrio, brillos ni biseles); borde fino y sombra suave; esquinas de 12; transiciones de 200 ms o menos |

## Consecuencias
- Las pantallas solo usan tokens del tema; un color fijo en una pantalla es un error de revisión.
- Cada pantalla se revisa en los dos temas y con la letra al 200% (CAL-1).
- Los tonos exactos se afinan en la galería de componentes dentro de la app (DIS-3), no en maquetas.

## Alternativas descartadas
Tinta azul noche, Latón y acero, Grafito nocturno (propuestas el 2026-11-15); Grafito renovado y Marca con color (propuesta
original); Inter + JetBrains Mono, IBM Plex, Geist; los cuatro temas de la v1; inglés como fuente; vibración al copiar; nombre nuevo.
