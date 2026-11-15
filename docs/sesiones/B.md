# Carril B · Diseño (sistema visual)

Reglas y plantilla: [`README.md`](README.md). Decisión de diseño: [ADR-0013](../adr/0013-diseno-idioma-y-experiencia-v2.md); tokens
de partida en [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §3. Antes de diseñar: skills `interface-design`,
`mobile-android-design` y `flutter-theming-apps`, y la skill `solokey` §3.

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | DIS-1 | Tokens **Tinta y papel** (claro y oscuro) en `AppPalette`, `AppTheme` reescrito, seguir al sistema; fuentes **Atkinson Hyperlegible Next y Mono** empaquetadas; fuera `app_colors.dart`, dim, OLED y los 6 colores de tipo | M | ☐ | [ver](#dis-1) |
| 2 | DIS-2 | Kit de componentes en `lib/shared/widgets/` (botones, campo secreto, fila de credencial, tarjeta, aviso, chip de estado, barra superior, barra inferior, panel de escritorio), liso | L | ☐ | Que C solo ensamble piezas |
| 3 | DIS-3 | Galería de componentes en la build debug (ruta oculta) con los dos temas y la letra al 200% | M | ☐ | Donde el dueño afina tonos en la app |
| 4 | DIS-5 | Quitar las 22 vibraciones, el shimmer y la animación escalonada | S | ☐ | DEC-5 aprobado |
| 5 | DIS-4 | Logo e iconos redibujados planos (app, bandeja, instalador, adaptativo de Android, `.ico` multi-tamaño) | M | ☐ | Skills `logo-design-guide` y `svg-logo-designer` |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| D | PLA-5 y PLA-4 terminados (paquete renombrado y dependencias subidas) antes de empezar | DIS-1 |
| E | E2E de la galería con letra al 200% y los dos temas (CAL-1) | DIS-2 y DIS-3 |

## No reabre

| Qué | Por qué |
|---|---|
| Degradados, vidrio, brillos, biseles | El dueño los rechazó: todo liso |
| Otra dirección o letra (Tinta azul, Latón, Grafito; Inter, Plex, Geist) | Decidido el 2026-11-15 (ADR-0013) |
| Temas dim y OLED | DEC-3: solo claro, oscuro y sistema |

## Detalle

### DIS-1

- Partir de la tabla de tokens de REDISENO_V2 §3 y nombrarlos por su rol en el mundo de la app (papel, tinta, tinta suave, borde,
  comprometida, débil, sana), no `gray-700`.
- Cuatro niveles de texto, escala de bordes, tokens propios para controles y foco; esquinas de 12, borde fino + sombra suave.
- Las pruebas de widgets del tema de la v1 se borran en esta misma rama; la verificación pasa a la galería (DIS-3) y a la E2E de E.
- Fuentes con licencia OFL dentro de `assets/fonts/`, sin descargar nada en tiempo de ejecución.
