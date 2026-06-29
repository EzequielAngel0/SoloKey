# 🎨 Rediseño Integral de UI/UX — SoloKey (Android + Windows)

> Documento de diseño creado el **2026-06-28**. Define el rediseño **completo**
> de la interfaz de las dos aplicaciones (móvil Android y companion de escritorio
> Windows): nueva paleta, sistema de diseño, navegación, flujo, logo nuevo y la
> corrección del ícono de la ventana.
>
> Convención del repo: commits de **una sola línea** `tipo(ambito): desc` en
> español **sin acentos** (ASCII). Cada lote debe dejar `flutter analyze` en 0
> errores y los tests en verde. El cuerpo de este doc sí lleva acentos (igual que
> `pendientes_y_bugs.md`); solo los commits son ASCII.
>
> Leyenda de estado: ⬜ pendiente · 🟦 en progreso · ✅ hecho.
> Leyenda de esfuerzo: 🟢 acotado · 🟡 medio · 🔴 grande.

---

## 0. Decisiones tomadas (input del dueño del producto)

| Decisión | Elección | Implicación |
| :--- | :--- | :--- |
| **Dirección visual** | **Graphite Pro (minimal)** | Grafito/carbón neutro, un acento confiado (azul) + esmeralda para éxito, mucho aire, plano y nítido. **Sin neón.** Sensación de herramienta seria tipo *1Password 8*. |
| **Concepto de logo** | **Monograma "S" + ojo de cerradura** | Una `S` geométrica cuyo espacio negativo forma un *keyhole*. Escalable de favicon 16px a 1024px. |
| **Anti-glassmorphism** | **Prohibido (regla dura)** | Nada de vidrio esmerilado, blur, *gloss*, biseles, 3D ni *rim light* — en la UI **y** en el logo (ver §2.1). |
| **Alcance de navegación** | **Visual + IA nueva** | No solo recolor: `NavigationBar` M3 (móvil), master-detail (escritorio) y hub de Seguridad unificado. |
| **Entrega** | **Rama `feature/rediseno-ui`** | Todo el rediseño aislado; merge a `main` al final. |
| **Tipografía** | **Inter + JetBrains Mono (bundle offline)** | `.ttf` empaquetados en `assets/fonts/`, sin red (coherente con local-first). |
| **Light mode** | **Dark primario, light correcto** *(default)* | Se pulen los 4 temas; `dark` es la referencia de QA. |

> Esto **rompe a propósito** con el logo neón actual (llave verde/cian/morada sobre
> escudo), que ya era inconsistente con el rumbo "de-neon'd" del código
> (`app_palette.dart:91`: *"de-neon'd: indigo becomes the brand color, replacing
> the legacy neon green"*).

---

## 1. Diagnóstico del estado actual

**Qué hay hoy (para saber qué se reescribe vs. qué se retoca):**

| Pieza | Archivo | Estado actual |
| :--- | :--- | :--- |
| Tokens de color | `lib/theme/app_palette.dart` | `AppPalette` como `ThemeExtension` con 4 paletas (light/dark/dim/oled). Marca índigo `#6C63FF` + teal `#03DAC6`. **Bien estructurado → solo se retunea.** |
| Tokens legacy | `lib/theme/app_colors.dart` | Constantes estáticas duplicadas. A deprecar en favor de `context.palette`. |
| Tema | `lib/theme/app_theme.dart` | `AppTheme.fromPalette()` M3. `centerTitle: true`, radios 12–16, botón full-width 52px. **Se ajusta.** |
| Navegación móvil | `home_screen.dart:196` | `BottomNavigationBar` (componente M2) de 3 pestañas: Credenciales / Carpetas / Favoritos. **Se reemplaza por `NavigationBar` M3 y se reordena el flujo.** |
| Navegación escritorio | `core/presentation/layouts/desktop_main_layout.dart` | `NavigationRail`. **Se moderniza a sidebar + master-detail.** |
| Logo | `assets/logo/SoloKey.png` (1.0 MB) | Llave neón sobre escudo. **Se reemplaza por completo.** |
| Ícono `.exe` | `windows/runner/resources/app_icon.ico` | **BUG:** una sola imagen 256×256 → barra de título/taskbar en blanco (ver §7). |

**Tipografía:** hoy se usa la fuente del sistema (Roboto/Segoe). Parte del rediseño.

---

## 2. Sistema de diseño "Graphite Pro"

### 2.1 Principios

1. **Calma y confianza:** superficies grafito neutras, un solo acento. El color se
   reserva para acciones y estados, no para decorar.
2. **Aire:** rejilla base de **4 pt**, padding generoso, jerarquía por tamaño y
   peso tipográfico — no por cajas de colores.
3. **100% plano — NADA de glassmorphism:** prohibido el vidrio esmerilado
   (*frosted glass*), el blur de fondo, los paneles translúcidos, los brillos /
   *gloss*, los biseles, el relieve 3D, el *rim light* y el skeuomorfismo. La
   profundidad se logra **solo** con bordes hairline y sombras muy suaves. Cero
   glow, cero neón.
4. **Bordes suaves:** radios 12–20. Pills (999) para chips y la búsqueda.
5. **Datos legibles:** secretos, TOTP y llaves en fuente **monoespaciada tabular**.

> ⛔ **Regla dura (no negociable): NADA de glassmorphism.** Ni vidrio esmerilado,
> ni blur de fondo, ni paneles translúcidos, ni brillos/*gloss*, ni biseles 3D, ni
> *rim light*, ni efecto "frosted". Superficies **sólidas y planas** separadas por
> bordes hairline. Esto aplica a **toda la UI y también al logo**.

### 2.2 Paleta — valores concretos (listos para `app_palette.dart`)

Se mantienen **todos** los campos actuales de `AppPalette` (cambio de bajo riesgo:
solo se sustituyen los valores hex). 

**Dark (default):**

| Rol | Hex | Rol | Hex |
| :--- | :--- | :--- | :--- |
| primary / accent | `#3B82F6` | textPrimary | `#F3F4F7` |
| secondary | `#10B981` | textBody | `#C7C8D1` |
| onPrimary | `#FFFFFF` | textMuted | `#8A8B97` |
| background | `#0B0B0F` | textDisabled | `#56575F` |
| surface | `#121218` | textEmpty | `#262630` |
| card | `#17171F` | danger | `#F26D6D` |
| cardDark | `#0F0F14` | error | `#EF4444` |
| drawer | `#121218` | warning | `#F5A524` |
| divider | `#262630` | success | `#10B981` |
| scrim | `#88000000` | info | `#38BDF8` |
| shimmerBase | `#17171F` | shimmerHighlight | `#262630` |

**Tipos de credencial (calmados, sin saturar):**
`typePassword #3B82F6` · `typeApiKey #10B981` · `typeNote #F5A524` ·
`typeTotp #8B5CF6` · `typePasskey #14B8A6` · `typeSshKey #0EA5E9`.

**Light:** `primary #2563EB` · `secondary #059669` · `background #F7F7F9` ·
`surface #FFFFFF` · `card #FFFFFF` · `divider #E6E6EC` · `textPrimary #15161A` ·
`textMuted #6B6C77` · `error #DC2626` · `warning #B45309` · `success #059669`.

**Dim** (oscuro suave): `background #14151A` · `surface #1B1C22` · `card #1F2027` ·
`divider #2C2D36` · `primary #5B96F8` (más claro, menor contraste).

**OLED** (negro puro): `background #000000` · `surface #08080B` · `card #0C0C10` ·
`divider #1C1C24` · `primary #3B82F6`.

### 2.3 Tipografía

| Uso | Fuente | Notas |
| :--- | :--- | :--- |
| UI general | **Inter** | `.ttf` empaquetada en `assets/fonts/` y declarada en `pubspec.yaml` (**bundle offline, sin red**). Grotesk limpia, moderna. |
| Secretos / códigos / TOTP / SSH | **JetBrains Mono** | Empaquetada igual que Inter. Monoespaciada tabular para alinear dígitos y blobs. |

Escala (peso/tamaño): Display 28–32 Bold · Headline 22–24 SemiBold · Title 18 w600 ·
Body 15–16 Regular · Label 13 w600 · Caption 12. `letterSpacing` ligeramente
negativo en titulares (−0.2 a −0.4) para el look "pro".

### 2.4 Espaciado, radios, elevación

- **Grid:** 4 pt. Paddings comunes 12 / 16 / 20 / 24.
- **Radios:** card 16 · botón 14 · input 12 · chip/búsqueda 999 (pill) · bottom sheet 24 (top).
- **Elevación:** sin sombras duras. Card = `surface` + borde `divider` 1px. Sheets/menús = sombra suave `0 8 24 rgba(0,0,0,.35)`.
- **Bordes hairline:** 1px `divider` es el separador por defecto (no líneas gruesas ni fondos contrastados).

### 2.5 Componentes (reglas de rediseño)

| Componente | Antes | Después (Graphite Pro) |
| :--- | :--- | :--- |
| **AppBar** | `centerTitle: true`, título 20 | **Large title** alineado a la izquierda (estilo iOS/M3 large), fondo `background`, sin sombra. |
| **Botón primario** | Filled índigo, 52px full-width | Filled azul `#3B82F6`, radio 14, estados hover/pressed con −8%/−14% de luz. |
| **Botón secundario** | — | *Tonal* (`primary` @ 12% sobre `card`) o *ghost* (solo texto). |
| **Input** | Filled `card`, focus borde índigo | Filled `card`, borde hairline en reposo, **anillo de foco** azul 1.5px. |
| **Card / tile** | `card`, elevation 0, radio 16 | Igual base + **borde hairline** `divider`, press-state con `cardDark`. |
| **Chips de filtro** | — | Pills seleccionables (Todos/Favoritos/Tipo) en la cabecera de la Bóveda. |
| **Selector de tipo** | Selector horizontal animado | Segmented control / chips, sin gradientes ni sombras fuertes. |
| **FAB** | `FloatingActionButton.extended` índigo | Se mantiene en móvil, restyle azul + sombra suave. En escritorio se reemplaza por botón "Nuevo" en la barra de la lista. |
| **Bottom nav** | `BottomNavigationBar` (M2) | **`NavigationBar` (M3)** con indicador pill. |
| **Empty states** | Texto plano | Ícono grande `textEmpty` + título + subtítulo + acción. |
| **Shimmer** | Ya existe (`shimmer_loader.dart`) | Retunear a `shimmerBase/Highlight` nuevos. |

### 2.6 Motion

- Transiciones de página: mantener `SlideUpFadeTransition` pero **más sutil** (offset 0→0.03, 180–220ms, curva `easeOutCubic`).
- Listas: `StaggeredListItem` con delay reducido (i×24ms) — menos "show off", más pro.
- Micro-interacciones: copiar/revelar con `CopyFeedbackButton` (checkmark) ya existe; recolorear a azul/esmeralda.

---

## 3. Rediseño de navegación y flujo

### 3.1 Android (móvil)

**Hoy:** 3 pestañas (Credenciales / Carpetas / Favoritos) en `BottomNavigationBar`.
**Problema:** Favoritos como pestaña entera desperdicia un slot; las herramientas
de seguridad (auditoría, generador, import/export, recuperación) están dispersas
y escondidas.

**Nuevo — `NavigationBar` M3 de 4 destinos:**

| # | Destino | Contenido |
| :-- | :--- | :--- |
| 1 | **Bóveda** | Búsqueda persistente (pill) + **fila de chips de filtro** (Todos · Favoritos · Contraseñas · TOTP · Passkeys · SSH) + lista con secciones. Favoritos pasa a ser un chip, ya no una pestaña. |
| 2 | **Carpetas** | Navegación profunda existente (`FolderScreen`). |
| 3 | **Seguridad** | **Hub nuevo**: tarjeta de *Security Score* + accesos a Auditoría, Generador, Import/Export, HIBP y Recuperación (hoy dispersos). |
| 4 | **Ajustes** | `SettingsScreen` (tema, auto-lock, biometría, sync…). |

- **Búsqueda** sube al tope de Bóveda como barra pill siempre visible.
- **FAB contextual** se mantiene (nueva credencial / nueva carpeta).
- **Dashboard ligero** opcional en la cabecera de Bóveda: saludo + chip de score +
  "usadas recientemente".

### 3.2 Windows (escritorio)

**Hoy:** `NavigationRail` estrecho + navegación a pantallas completas.
**Problema:** desaprovecha el ancho; ver una credencial saca de la lista.

**Nuevo — sidebar + master-detail:**

```
┌────────────┬───────────────────────┬─────────────────────────┐
│  SIDEBAR   │   LISTA (master)      │   DETALLE (detail)      │
│  240px     │                       │                         │
│            │  [búsqueda global]    │   Credencial seleccion. │
│ ◆ Bóveda   │  ───────────────────  │   campos, reveal/copy,  │
│ ▸ Carpetas │  ▸ GitHub             │   TOTP, historial…      │
│ ▸ Seguridad│  ▸ AWS  (seleccion.)  │                         │
│ ▸ Sincroniz│  ▸ Gmail              │   (sin salir de la      │
│ ▸ Ajustes  │  ▸ …                  │    lista)               │
│            │                       │                         │
│ ─────────  │                       │                         │
│ ⏻ Bloquear │                       │                         │
│ ⇅ Sync: ●  │                       │                         │
└────────────┴───────────────────────┴─────────────────────────┘
```

- **Sidebar** expandible (240px) / colapsable (72px, solo íconos). Abajo: estado de
  sync (punto verde/gris) + botón "Bloquear ahora".
- **2 paneles** (lista + detalle) en anchos normales; **3 columnas** (sidebar + lista
  + detalle) en ventanas anchas. El detalle se actualiza *in-place* al seleccionar.
- **Paleta de comandos / búsqueda global** (Ctrl+K): formalizar el hotkey ya
  existente (`main.dart:140` registra Ctrl+Shift+K spotlight) como overlay de
  búsqueda + acciones.
- **Densidad:** modo compacto (filas más bajas) apropiado para escritorio.
- Mantener el ícono de la ventana arreglado (§7) y, opcionalmente, una title bar
  custom integrada al tema grafito (fase posterior, mayor riesgo).

### 3.3 Flujos clave (revisados)

| Flujo | Cambio |
| :--- | :--- |
| **Onboarding / Setup** | Stepper limpio de 2–3 pasos (crear master → mostrar Recovery Code → listo). Indicador de fortaleza retuneado. |
| **Unlock** | Minimal: **Windows Hello / biometría primero** (botón grande), master password como fallback. Copys: "Usar Windows Hello" en escritorio. |
| **Buscar** | Búsqueda persistente arriba en móvil; global (Ctrl+K) en escritorio. |
| **Crear/Editar** | Formulario por secciones agrupadas por tipo, pero plano (sin gradientes/sombras fuertes del rediseño previo). |
| **Seguridad** | Un solo hub en lugar de entradas dispersas. |

---

## 4. Rediseño pantalla por pantalla

| Pantalla | Archivo | Acción de rediseño |
| :--- | :--- | :--- |
| Splash | `splash_screen.dart` | Nuevo logo + animación sutil (fade, sin scale exagerado). |
| Setup | `setup_screen.dart` | Stepper grafito, indicador de fortaleza nuevo. |
| Unlock | `unlock_screen.dart` | Biometría/Hello primero, layout minimal. |
| Home/Bóveda | `home_screen.dart` | `NavigationBar` M3 + chips de filtro + búsqueda pill + lista con secciones. |
| Carpetas | `folder_screen.dart` | Retoque de tarjetas/listas a tokens nuevos. |
| Detalle credencial | `credential_detail_screen.dart` | Tiles planos, reveal/copy recoloreados, TOTP mono. |
| Form credencial | `credential_form_screen.dart` | Secciones planas, segmented type selector. |
| Seguridad (hub) | **nuevo** + `security_audit_screen.dart` | Tarjeta de score + accesos consolidados. |
| Generador | `password_generator_screen.dart` (*) | Sliders/toggles a tokens nuevos. |
| Ajustes | `settings_screen.dart` | Lista agrupada, selector de tema con previews. |
| Sincronizar | `pairing_screen.dart` | QR + estado, tokens nuevos. |
| Escritorio (layout) | `desktop_main_layout.dart` | Sidebar + master-detail (§3.2). |

(*) Verificar ruta exacta del generador al implementar.

---

## 5. Logo nuevo — prompt para Nano Banana (Gemini Image)

**Concepto:** monograma `S` geométrico cuyo espacio negativo forma un *ojo de
cerradura* (círculo arriba + ranura vertical). Estilo Graphite Pro: **plano**,
premium, sin neón, **sin glassmorphism**.

> 🔁 **Historial de iteraciones:**
> - **Iter 1 (rechazada — `...z42noqz42n.png`):** se leía como **"8"/infinito**,
>   acabado **glossy/3D + borde de vidrio**, **doble contorno** y **marca de agua** ✦.
> - **Iter 2 con prompt v2 (rechazada):** el v2 (demasiados negativos) volvió a
>   producir el **monoline en espiral tipo "8"** — no funcionó.
> - **Iter 2 (prompt estilo v1):** "S" sólida y gruesa — buena base.
> - **Iter 3 (✅ FINAL — `Gemini_Generated_Image_x93ausx93ausx93a.png`):** "S" sólida con
>   keyhole bien embebido, plana, sobre squircle grafito. **Procesada con PIL:** se
>   **extrajo solo la "S" azul** por dominancia del canal azul — eso elimina de un golpe la
>   marca de agua ✦ **y** el fondo — y se recompuso sobre un squircle grafito limpio
>   (`#15151C→#0B0B0F`). Verificada a 1024 y a 32/48px (legible en taskbar/favicon).
>
> **Assets generados (`assets/logo/`):** `solokey_icon.png` (squircle branded → fuente del
> launcher), `solokey_mark.png` + `SoloKey.png` (marca **transparente** para splash/unlock/in-app),
> `solokey_adaptive_fg.png` (foreground adaptive Android). `.ico` **multi-tamaño (16–256)** en
> `windows/runner/resources/app_icon.ico` (+ `assets/logo/SoloKey.ico`).
> `pubspec` actualizado y `dart run flutter_launcher_icons` ejecutado → Android legacy + adaptive
> (fondo `#0E0E13`, inset 16%) regenerados. El prompt v3 de abajo queda como referencia.

### 5.1 Prompt principal v3 (CANÓNICO — reproduce la versión elegida, sin marca de agua)

```
A flat, minimalist app icon for a password manager called "SoloKey". The icon is
a single BOLD uppercase letter "S" as one solid filled shape with thick, even,
rounded stroke weight — it must read instantly and unmistakably as the letter S
(never an 8, a figure-eight, an ampersand, or an infinity symbol). Do NOT use a
thin monoline, a swirl, a spiral, or any double-loop; it is a chunky, confident,
solid S. A keyhole is cut out of the lower-center of the S as clean negative
space — a small circle with a short tapered slot below it — letting the dark
background show through. Fill the S with a smooth, matte vertical gradient from
blue #3B82F6 at the top to #2563EB at the bottom; flat color, no shine. Center
the S with generous even padding on a near-black graphite rounded-square (iOS
squircle) background, subtly graded from #15151C to #0B0B0F. Keep it completely
flat and modern: no glassmorphism, no frosted glass, no glossy highlight, no rim
light, no bevel, no 3D extrusion, no heavy drop shadow, no texture, no outline.
Crisp vector look, high contrast, perfectly legible as an "S" even at 16px.
1:1 square. No text, no letters other than the single S, and absolutely no
watermark or sparkle.
```

### 5.2 Prompt negativo (qué evitar)

```
no 8, no ampersand, no infinity symbol, no monoline, no swirl, no spiral,
no double-loop, no double outline, no inner stroke,
no glassmorphism, no frosted glass, no background blur, no translucent panel,
no glossy shine, no 3D, no bevel, no emboss, no extrusion, no rim light,
no inner glow, no neon, no glow, no bloom, no lens flare, no realistic metal key,
no photographic key, no skeuomorphism, no drop shadow, no texture,
no gradient mesh, no border, no watermark, no Gemini sparkle, no signature,
no text or letters other than a single S.
```

### 5.3 Variantes a pedir (mismo concepto)

1. **Monoline:** la `S`/keyhole solo como trazo (sin relleno) sobre el squircle grafito.
2. **Sobre fondo claro:** versión para tema claro (squircle casi blanco `#F7F7F9`, marca en azul `#2563EB`).
3. **Monocromo:** marca en un solo tono (blanco sobre grafito y grafito sobre blanco) para usos planos.
4. **Lockup horizontal:** la marca + el wordmark "SoloKey" en Inter SemiBold, espaciado equilibrado, para splash y about.

### 5.4 Entregables esperados del logo

- **Maestro** `SoloKey.png` 1024×1024, fondo transparente (solo la marca, con safe
  area ~66% para el adaptive icon de Android).
- Versión **con squircle** 1024×1024 (para Windows/iconos que no recortan).
- Tras aprobarlo, alimentar `flutter_launcher_icons` (ver §6) y regenerar.

> Nota 1: Nano Banana suele necesitar 2–3 iteraciones para el *keyhole en negativo*.
> Si la "S" se lee poco, pedir explícitamente: *"make the keyhole cutout more
> obvious; the circle and vertical slot must be clearly visible as empty space, and
> the letter must clearly read as an S"*.
>
> Nota 2 — **marca de agua:** las imágenes de Gemini llevan una estrella ✦ visible
> (abajo a la derecha) y un SynthID invisible. Para el ícono final hay que entregar
> una versión **sin** la estrella (regenerar pidiendo "no watermark", recortar el
> margen, o redibujar la marca como vector limpio a partir de la referencia).

---

## 6. Fix del ícono de la ventana en Windows (bug reportado)

**Síntoma:** "sigue sin verse el logo cuando tengo la ventana abierta" → la barra
de tareas y la barra de título muestran un cuadro en blanco/genérico.

> ✅ **Resuelto (2026-06-28):** `app_icon.ico` regenerado **multi-tamaño (16–256, 7
> frames)** desde el logo nuevo (PIL `save(..., format="ICO", sizes=[...])`). En
> `pubspec` se puso `windows.generate: false` para que el plugin no lo vuelva a pisar
> con un solo frame. **Falta solo:** rebuild de Windows (`flutter build windows`) para
> verlo en barra de título/taskbar, y —opcional— el refuerzo `WM_SETICON` de abajo.

**Causa raíz (confirmada):** `windows/runner/resources/app_icon.ico` contenía
**una sola imagen de 256×256** (lo generaba `flutter_launcher_icons` con
`icon_size: 256`). Windows necesita *frames* pequeños (16/24/32/48) para la barra de
título y la taskbar pequeña; al no encontrarlos, no rasterizaba bien y mostraba el
ícono vacío.

Verificación hecha (header ICO): `images=1 → 256x256 32bpp`. Eso lo confirma.

**Arreglo (en orden):**

1. **Generar un `.ico` multi-tamaño de verdad** (16, 24, 32, 48, 64, 128, 256).
   Con ImageMagick, tras tener el PNG nuevo del logo:
   ```bash
   magick assets/logo/SoloKey.png -background none \
     -define icon:auto-resize=256,128,64,48,32,24,16 \
     windows/runner/resources/app_icon.ico
   ```
   (Alternativa sin ImageMagick: cualquier generador que produzca un .ico
   multi-resolución; **no** confiar en `icon_size: 256` solo.)

2. **Reforzar en el runner nativo** (cinturón y tirantes): en
   `windows/runner/win32_window.cpp`, tras `CreateWindow(...)` (≈ línea 137),
   cargar y fijar explícitamente ícono grande y pequeño:
   ```cpp
   HICON icon_big = (HICON)LoadImage(
       GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON),
       IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_SHARED);
   HICON icon_small = (HICON)LoadImage(
       GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON),
       IMAGE_ICON, GetSystemMetrics(SM_CXSMICON),
       GetSystemMetrics(SM_CYSMICON), LR_SHARED);
   SendMessage(window, WM_SETICON, ICON_BIG,   (LPARAM)icon_big);
   SendMessage(window, WM_SETICON, ICON_SMALL, (LPARAM)icon_small);
   ```
   (Requiere `#include "resource.h"` — ya está.) Esto garantiza que el título y la
   taskbar usen el frame correcto aunque `window_manager` recree la ventana.
   *Alternativa Dart:* `windowManager.setIcon(<ruta .ico en disco>)` tras
   `waitUntilReadyToShow` (menos robusto: requiere el archivo en disco).

3. **Rebuild limpio:** `flutter clean && flutter build windows` y verificar:
   barra de título (16px), Alt+Tab (32px) y taskbar muestran la marca.

4. **Instalador / taskbar agrupada:** asegurar que el acceso directo de
   `installer/SoloKey.iss` use el mismo `AppUserModelID`
   (`com.angelezequiel.solokey`, `main.cpp:13`) y el ícono nuevo, para que el
   agrupado por AUMID muestre el ícono correcto al fijar.

**Android (de paso):** al regenerar con `flutter_launcher_icons`:
- `adaptive_icon_background: "#0B0B0F"` (grafito, hoy `#111111`).
- `adaptive_icon_foreground`: la marca **sola** con padding de safe area (no el PNG
  completo, para que no se recorte en el círculo/squircle del launcher).

---

## 7. Plan de implementación por fases

> Orden pensado para minimizar riesgo: tokens primero (cambio global barato), luego
> componentes, luego navegación, luego logo/ícono. Cada fase deja `flutter analyze`
> en 0 y tests en verde.

| # | Fase | Alcance | Esfuerzo | Estado |
| :-- | :--- | :--- | :--- | :--- |
| UI-1 | **Retune de tokens** | Sustituir hex en `app_palette.dart` (dark/light/dim/oled) por Graphite Pro. Deprecar `app_colors.dart` → `context.palette`. | 🟢 | ✅ |
| UI-2 | **Tema + tipografía** | Inter + JetBrains Mono; large titles, botones/inputs/cards a tokens nuevos en `app_theme.dart`. | 🟡 | ✅ |
| UI-3 | **Componentes compartidos** | `vault_app_bar`, `secure_text_field`, `password_strength_indicator`, `shimmer_loader`, chips de filtro, segmented type selector. | 🟡 | ✅ |
| UI-4 | **Navegación móvil** | `BottomNavigationBar` → `NavigationBar` M3; Favoritos → chip; hub de Seguridad; búsqueda pill. | 🟡 | ⬜ |
| UI-5 | **Navegación escritorio** | `desktop_main_layout.dart`: sidebar + master-detail; paleta de comandos Ctrl+K. | 🔴 | ⬜ |
| UI-6 | **Pantallas** | Aplicar a setup/unlock/detalle/form/ajustes/sync (§4). | 🔴 | ⬜ |
| UI-7 | **Logo nuevo** | Generar con Nano Banana (§5), aprobar maestro, sustituir `assets/logo/`. | 🟢 | ✅ |
| UI-8 | **Íconos** | `.ico` multi-tamaño (16–256) ✅ + adaptive Android ✅ + `flutter_launcher_icons` ✅. Pendiente: rebuild Windows para verificar + (opcional) `WM_SETICON`. | 🟢 | 🟦 |
| UI-9 | **QA visual** | Revisar en Android, Windows ventana grande/angosta, los 4 temas, RTL/es-en, accesibilidad de contraste. | 🟡 | ⬜ |

### Commits sugeridos (ASCII, una línea)

```
feat(ui): retune de paleta a Graphite Pro (grafito + azul) en app_palette dark/light/dim/oled
feat(ui): tema con Inter + JetBrains Mono, large titles y botones/inputs/cards planos
feat(ui): NavigationBar M3 en home, Favoritos como chip de filtro y hub de Seguridad
feat(ui): layout de escritorio con sidebar colapsable y master-detail
feat(branding): nuevo logo monograma S + keyhole en assets/logo
fix(windows): icono de ventana visible con .ico multi-tamano y WM_SETICON big/small
```

---

## 8. Riesgos y notas

- **Bajo riesgo en tokens:** `AppPalette` ya es la única fuente; cambiar hex propaga
  a toda la UI que use `context.palette`. Cazar usos directos de `AppColors`
  (legacy) y migrarlos.
- **Riesgo medio en escritorio:** el master-detail cambia el modelo de navegación
  (de push de pantallas a selección en panel). Hacerlo detrás de la abstracción del
  layout para no tocar la lógica de las pantallas.
- **Logo:** generar primero, **aprobar el maestro**, y solo entonces correr los
  generadores de íconos (no automatizar a ciegas).
- **i18n:** cualquier copy nuevo (chips, hub de Seguridad, "Usar Windows Hello")
  debe entrar a los `.arb` es/en — la app está 100% es/en hoy.
- **Tests:** el rediseño es visual; los tests de cripto/lógica no deberían tocarse.
  Revisar tests de widget si los hubiera.

---

*Generado el 2026-06-28. Dirección: Graphite Pro · Logo: monograma "S" + keyhole.
Actualizar el estado (⬜/🟦/✅) de las fases UI-1..UI-9 conforme se implementen.*
