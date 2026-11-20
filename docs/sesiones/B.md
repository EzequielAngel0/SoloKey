# Carril B · Diseño (sistema visual)

Reglas y plantilla: [`README.md`](README.md). Decisión de diseño: [ADR-0013](../adr/0013-diseno-idioma-y-experiencia-v2.md); tokens
de partida en [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §3. Antes de diseñar: skills `interface-design`,
`mobile-android-design` y `flutter-theming-apps`, y la skill `solokey` §3.

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | DIS-3 | Galería de componentes en la build debug (ruta oculta) con los dos temas y la letra al 200% | M | ☐ | Donde el dueño afina tonos en la app |
| 2 | DIS-5 | Quitar las 22 vibraciones, el shimmer y la animación escalonada | S | ☐ | DEC-5 aprobado |
| 3 | DIS-4 | Logo e iconos redibujados planos (app, bandeja, instalador, adaptativo de Android, `.ico` multi-tamaño) | M | ☐ | Skills `logo-design-guide` y `svg-logo-designer` |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| E | E2E de la galería con letra al 200% y los dos temas (CAL-1) | DIS-2 y DIS-3 |
| C | Al rehacer cada pantalla, dejar los alias de la v1 (`palette.primary`, `accent`, `typeX`, `AppTheme.rCard`...) por los tokens de DIS-1; cuando no quede ninguno, B los borra | Quitar los alias |
| C | `Colors.white` sobre `accent` (botón guardar, formulario de credencial, archivos, emparejar) no se lee en oscuro: el principal ahora es tinta clara; usar `onInk` | Pantallas en oscuro |
| C | Claves `themeDim` y `themeOled` de los `.arb` quedaron sin uso (DEC-3) | Limpiar textos |

## No reabre

| Qué | Por qué |
|---|---|
| Degradados, vidrio, brillos, biseles | El dueño los rechazó: todo liso |
| Otra dirección o letra (Tinta azul, Latón, Grafito; Inter, Plex, Geist) | Decidido el 2026-11-15 (ADR-0013) |
| Temas dim y OLED | DEC-3: solo claro, oscuro y sistema |

## Detalle

Tokens vigentes: `lib/theme/app_palette.dart` (color) y `lib/theme/app_tokens.dart` (espacio, esquinas, sombra, movimiento).
Componentes: `lib/shared/widgets/kit/` (un import, `kit.dart`; textos por parámetro). Lo hecho: [`../archive/sesiones/B_HECHO.md`](../archive/sesiones/B_HECHO.md).
