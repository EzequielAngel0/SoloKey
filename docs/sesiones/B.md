# Carril B · Diseño (sistema visual)

Reglas y plantilla: [`README.md`](README.md). Plan: [`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md) §3. Antes de diseñar:
skills `interface-design` y `mobile-android-design`, y la skill `solokey` §3.

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía: depende de DEC-2 a DEC-6 (dirección, temas, idiomas, vibraciones, logo).

## Propuestas de la sesión (◇)

| ID | Qué | Para qué | Esf. |
|---|---|---|---|
| DIS-1 ◇ | Tokens nuevos en `AppPalette` (claro y oscuro de la dirección elegida) y `AppTheme` reescrito; fuera `app_colors.dart` legado y los 6 colores de tipo | Una sola fuente de color, con significado | M |
| DIS-2 ◇ | Kit de componentes nuevo en `lib/shared/widgets/` (botones, campo secreto, fila de credencial, tarjeta, aviso, chip de estado, barra superior) sin degradados ni movimiento decorativo | Que las pantallas de C solo ensamblen piezas | L |
| DIS-3 ◇ | Galería de componentes en la build debug (ruta oculta) con los dos temas y la letra al 200% | Que el dueño revise el sistema en la app, no en maquetas | M |
| DIS-4 ◇ | Logo e iconos redibujados planos (app, bandeja, instalador, adaptativo de Android, `.ico` multi-tamaño) | Que la marca siga al estilo nuevo | M |
| DIS-5 ◇ | Quitar vibraciones (22 `HapticFeedback`), shimmer y animación escalonada si DEC-5 se aprueba | Calma: la app no distrae | S |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| E | Prueba de humo de tema y letra al 200% sobre el kit (`test/theme/`) | DIS-1 y DIS-2 |

## No reabre

| Qué | Por qué |
|---|---|
| Degradados, vidrio, brillos, biseles | El dueño los rechazó: todo liso |
