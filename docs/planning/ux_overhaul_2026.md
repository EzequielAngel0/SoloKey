# 🧭 Rediseño UX (pantalla por pantalla) — SoloKey

> Creado el **2026-06-29**. Este documento sucede a `rediseno_ui_2026.md`.
>
> **Distinción clave:** `rediseno_ui_2026.md` fue la **capa visual** (Graphite Pro:
> tokens, tipografía, navegación M3/master-detail, hub de Seguridad). Quedó hecho y
> mergeado a `main`. **PERO** el dueño aclaró que "rediseño completo" significaba
> **rehacer la UX de cada pantalla**, no recolorear. Las pantallas heredadas sólo
> se repintaron; sus *flujos* siguen viejos. Esto es ese trabajo.
>
> Convención del repo: commits de **una línea** `tipo(ambito): desc` en español
> **sin acentos** (ASCII). Cada lote: `flutter analyze` en 0 y tests en verde.
> Leyenda: ⬜ pendiente · 🟦 en progreso · ✅ hecho · 🟢/🟡/🔴 esfuerzo.

---

## 0. Decisiones del dueño (2026-06-29)

| Tema | Decisión |
| :--- | :--- |
| **Qué cambiar** | **Pantallas y flujos** (estructura/UX). El look grafito + azul **se mantiene** si se ejecuta bien — no es un cambio de paleta. |
| **Referencia** | Sin app fija: se le presentan **2 direcciones** y elige. |
| **Método** | **Prototipo primero** (HTML navegable) → aprobar dirección → recién entonces codear Flutter. |
| **Rama** | `feature/ux-overhaul` (nueva), por lotes con revisión. |

**Prototipo entregado:** `docs/planning/ux_overhaul_preview.html` — presenta dos
direcciones coherentes sobre las pantallas que más molestan:

- **Dirección A — "Amplia / guiada":** tarjetas con aire, acción primaria grande
  (el código TOTP como héroe), ideal para móvil/dedos.
- **Dirección B — "Compacta / pro":** filas key/value densas estilo 1Password, más
  datos por pantalla, encaja con el master-detail de escritorio.

> ✅ **DIRECCIÓN ELEGIDA (2026-06-29):** **mezcla** —
> **Detalle de credencial → Dirección B (filas densas / "pro" estilo 1Password)**;
> **Carpetas → Dirección A (breadcrumbs / migas)**. Estos dos patrones se aplican
> de forma consistente a TODAS las pantallas que correspondan.
>
> ✅ **ALCANCE AMPLIADO:** el dueño pidió **mejorar por completo TODAS las pantallas**
> de la app (no sólo las dolorosas). Cada pantalla se rehace de verdad (layout +
> estados + interacciones), no se recolorea. Se trabaja en `feature/ux-overhaul`
> por lotes revisables.

---

## 1. Dolores concretos confirmados en el código

| # | Dolor | Dónde | Causa real |
| :-- | :--- | :--- | :--- |
| UX-A | **Detalle de TOTP se ve como contraseña**, no como el código en vivo | `credential_detail_screen.dart` (`_SecretTile` con `obscureText:true` + `_TotpTile` secundario) | El secreto (semilla) se muestra como password; el código de 6 dígitos no es el protagonista. |
| UX-B | **Carpetas: navegación atrapada** ("para ir a otra hay que volver a la raíz") | `folder_screen.dart` (push de pantalla completa por subcarpeta) | Sin breadcrumbs ni back-stack ni árbol; cada subcarpeta apila otra `FolderScreen`. |
| UX-C | **Pantallas genéricas** sin estados ni jerarquía por tipo | varias | Layout único heredado; falta detalle por tipo, estados vacío/carga/error. |
| BUG-WIN | **Logo no se ve en la barra de tareas** de Windows (sí en la barra de título) | `windows/runner/win32_window.cpp`, instalador | Falta refuerzo `WM_SETICON` (big/small) y/o `AppUserModelID` correcto en el acceso directo; el `.ico` multi-tamaño solo, no basta para la taskbar del proceso vivo. |

---

## 2. Detalle por tipo (el corazón del rediseño)

Cada tipo de credencial tiene una **acción primaria distinta**; el detalle debe
reflejarlo (no un layout único):

| Tipo | Acción primaria (héroe) | Secundarios | Escondido/Avanzado |
| :--- | :--- | :--- | :--- |
| **TOTP** | Código de 6 dígitos en vivo + anillo 30s + copiar | Cuenta, emisor | Secreto/semilla (revelar con biometría) |
| **Login** | Usuario + contraseña (revelar/copiar) | Sitio (abrir) | Notas, historial, rotación |
| **API Key** | La key (copiar) | Servicio, endpoint, scopes | Notas |
| **SSH** | Llave pública (copiar) | Tipo, fingerprint, host | Llave privada (biometría), passphrase |
| **Passkey** | Estado/servicio (informativo) | RP ID, credential ID | Nota de que la privada no sale del disp. |
| **Nota** | Cuerpo de la nota | — | — |

---

## 3. Plan por lotes — TODAS las pantallas

Patrones fijos: detalle = **filas densas (B)**; carpetas = **breadcrumbs (A)**.
Cada lote: rama `feature/ux-overhaul`, revisable, `flutter analyze` 0 + tests verde,
commit de una línea ASCII.

| Lote | Pantallas / archivos | Qué se rehace | Estado |
| :-- | :--- | :--- | :--- |
| **L0 — Kit** | `shared/widgets/` (`KvRow`/`DetailGroup`, `SectionHeader`, `EmptyState`, `StatHeader`, `StatusChip`) | Componentes compartidos extraídos de L1/L2 para que las 12 pantallas sean **consistentes** y el resto de lotes vaya más rápido | ⬜ |
| **L1 — Detalle** | `credential_detail_screen.dart` | Detalle **por tipo** en filas densas; **TOTP con código en vivo** como primera fila (semilla en "Avanzado", revelar con biometría); login/API/SSH/passkey/nota a medida | ✅ |
| **L2 — Carpetas** | `folder_screen.dart`, `folder_breadcrumbs.dart` (nuevo) | **Breadcrumbs** con salto a cualquier ancestro (escritorio: setea provider; móvil: pop N) → fin del "volver a la raíz" | ✅ |
| **L3 — Bóveda/lista** | `home_screen.dart`, `credential_card.dart`, `credential_health_provider.dart` (nuevo) | **Avisos de salud inline** (débil/repetida) en tarjeta y detalle vía provider barato en memoria; estados vacíos distinguen "sin resultados" de "bóveda vacía" | ✅ |
| **L4 — Formulario** | `credential_form_screen.dart` + `widgets/` | Crear/editar **por tipo**, validación y estados claros, secciones densas | ⬜ |
| **L5 — Seguridad** | `security_audit_screen.dart` (+ `ScoreRing`/`StatusChip`) | **Security Score** (anillo + conteos por severidad) arriba de la auditoría; hallazgos siguen accionables (tap → editar) | ✅ |
| **L6 — Ajustes** | `settings_screen.dart` | Lista agrupada, selector de tema con preview, secciones densas | ⬜ |
| **L7 — Sync/Transfer/Archivos/Passkeys** | `pairing_screen.dart`, `transfer_screen.dart`, `secure_files_screen.dart`, `passkeys_screen.dart` | Estados (vacío/conectando/error), pasos claros, filas densas | ⬜ |
| **L8 — Acceso** | `splash_screen.dart`, `setup_screen.dart`, `unlock_screen.dart`, `recovery_screen.dart` | Onboarding/stepper limpios, Hello/biometría primero, estados de error | ⬜ |
| **L9 — Escritorio + extras** | `desktop_main_layout.dart`, `quick_fill_screen.dart`, `qr_scanner_screen.dart`, `autofill_onboarding_screen.dart` | Master-detail con filas densas + árbol de carpetas; overlays/onboarding | ⬜ |
| **WIN-ICON** | `windows/runner/win32_window.cpp`, instalador | `WM_SETICON` big/small añadido (ICON_BIG taskbar/AltTab + ICON_SMALL título). Falta **rebuild de Windows** para verificar en la barra de tareas | 🟦 |

Tras cada lote se reporta para que el dueño valide antes de seguir.

---

## 4. Estándares transversales (aplican a TODAS las pantallas)

Acordados con el dueño el 2026-06-29 como mejoras de calidad sobre la dirección
elegida (filas densas + breadcrumbs, look grafito intacto):

**Ergonomía y consistencia**
1. **Densidad responsiva:** denso en *información*, pero con objetivos de toque
   ≥44px y algo más de aire en móvil; más compacto en escritorio.
2. **Kit de componentes (L0):** `KvRow`/`DetailGroup`, `SectionHeader`,
   `EmptyState`, `StatHeader`, `StatusChip`, breadcrumbs — reutilizados en todos
   los lotes para que no diverjan.
3. **Tipo nunca sólo por color:** siempre **color + ícono + etiqueta**; verificar
   contraste del texto muted sobre grafito (a11y / daltonismo).
4. **Acción primaria real:** login añade **"Abrir sitio"** (`url_launcher`, ya es
   dependencia); en móvil, acciones secundarias (favorito/ocultar/editar/borrar)
   van a un menú **"⋯"** en vez de saturar la AppBar.
14. **Responsive intermedio:** breakpoint tablet/ventana mediana para que el
    master-detail no salte feo entre teléfono y escritorio.

**Seguridad / privacidad**
7. **Favicons sin fuga:** por defecto **avatar por tipo**; favicons **opt-in** y
   **cacheados localmente**, nunca llamando a Google en silencio (hoy
   `CredentialIcon` hace `Image.network` a `google.com/s2/favicons` por cada
   credencial — fuga de dominios + falla offline).
8. **Auto-ocultar secretos revelados** tras ~20–30 s y al ir a segundo plano.
9. **Avisos de salud inline:** chip de débil/reutilizada/filtrada en la **lista y
   el detalle**, no sólo en Auditoría.
13. **Copiado y confirmaciones uniformes:** toda copia con countdown de limpieza
    de portapapeles; toda acción destructiva con confirm + auth, igual en
    credenciales/carpetas/archivos.

**Escritorio / accesibilidad**
10. **Teclado y a11y:** `Semantics`/tooltips en botones de sólo-ícono, navegación
    por teclado en listas (flechas/Enter/Esc), foco visible.
12. **Persistir estado de UI:** sidebar colapsado, última pestaña, tamaño/posición
    de ventana.

**Búsqueda y rendimiento**
11. **Búsqueda mejor:** en móvil incluir carpetas + resaltar coincidencias +
    recientes (escritorio ya tiene Ctrl+K global).
5. **TOTP eficiente en listas:** un único ticker compartido, no N `Timer`s.
6. **QA:** validar en tema claro (smoke test) y repaso en dispositivo/ventana real
   tras L3 antes de ir a lo ancho.

**Organización y power-user (estándar)**
15. **Selección múltiple + mover/borrar en lote** y **drag-and-drop** de
    credenciales a carpetas en escritorio. (L3 / L9)
16. **Deshacer en borrados:** Snackbar *"Eliminado — Deshacer"* además del
    confirm + auth. (transversal)
17. **Menús contextuales (clic derecho) en escritorio** con `context_menus` (ya es
    dependencia): copiar / editar / mover / borrar. (L9)
18. **Atajos de teclado (escritorio):** Ctrl+N nueva, Ctrl+L bloquear, Ctrl+E
    editar, copiar usuario/clave. (L9)
19. **Fechas relativas + plurales ICU** es/en ("hace 2 días", "3 elementos").
    (transversal)

**Opcionales (calidad)**
20. **Toggle de densidad** (cómoda/compacta) en Ajustes. (L6)
21. **Rendimiento en bóvedas grandes:** búsqueda con debounce, descifrado perezoso,
    listas virtualizadas. (desde L3)
22. **Smoke test por pantalla** rediseñada para cazar regresiones. (cada lote)

> ✅ **Decisión resuelta (2026-06-29):** carpetas en **escritorio = breadcrumbs +
> árbol expandible** en el panel/sidebar (L9; el árbol permite saltar a cualquier
> carpeta sin pasar por la raíz).

---

## 5. Detalle por pantalla (qué se rehace en cada lote)

- **L3 · Bóveda/lista:** filas de credencial densas e informativas (avatar por
  tipo, título, subtítulo usuario/emisor, badge de tipo, **código TOTP inline**);
  agrupación opcional por secciones bajo los chips; estados vacío/carga/error y
  vista de "ocultas" más claros.
- **L4 · Formulario:** secciones densas **por tipo** con el lenguaje de filas del
  detalle; selector de tipo arriba; sólo campos relevantes; **validación inline**;
  secretos con revelar/generar; estado "guardando".
- **L5 · Seguridad:** Auditoría con cabecera de **Security Score** + hallazgos
  **accionables** (débiles/reutilizadas/filtradas/antiguas) que saltan a la
  credencial; Generador con controles limpios y fuerza en vivo; Historial como
  línea de tiempo con revelar/copiar valores anteriores.
- **L6 · Ajustes:** secciones agrupadas (Seguridad · Apariencia · Sync · Datos ·
  Acerca de) con control a la derecha; **selector de tema con preview**; zona
  peligrosa separada.
- **L7 · Sync/Transfer/Archivos/Passkeys:** Sync con estados claros (activo ·
  esperando · conectando · sincronizando · error) + QR prominente + lista de
  dispositivos; Transfer con dos modos y progreso; Archivos en grid con estado
  vacío; Passkeys lista densa + estado vacío explicativo.
- **L8 · Acceso:** Setup stepper (crear master → recovery code → listo) con
  fortaleza y checklist; Unlock con **Hello/biometría primero** + fallback; Recovery
  de 2 pasos con estados; Splash ya plano (sólo pulido).
- **L9 · Escritorio + extras:** detalle con filas densas; **carpetas como árbol**
  en el sidebar/panel (según decisión abierta); densidad afinada a ventana ancha;
  Quick-fill / QR / onboarding limpios.

---

## 6. Qué NO se toca

- Lógica de cripto/persistencia/sync (sólo presentación).
- Paleta/tokens Graphite Pro (se mantienen; esto es UX, no recolor).
- Logo e íconos ya generados (salvo el fix de taskbar, que es runner nativo).

*Generado el 2026-06-29. Sucede a `rediseno_ui_2026.md` (capa visual, hecha).*
