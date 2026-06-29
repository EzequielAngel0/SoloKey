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

> ⏳ **PENDIENTE DE ELECCIÓN:** el dueño debe elegir **A** o **B** (o una mezcla)
> sobre el prototipo. Hasta entonces no se codea.

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

## 3. Plan por fases (tras elegir A/B)

| # | Fase | Alcance | Esf. | Estado |
| :-- | :--- | :--- | :--- | :--- |
| UX-0 | **Prototipo + dirección** | `ux_overhaul_preview.html`; el dueño elige A/B | 🟢 | 🟦 (espera elección) |
| UX-1 | **Detalle por tipo** | Reescribir `credential_detail_screen` con detalle por tipo; TOTP con código héroe; semilla en "Avanzado" | 🔴 | ⬜ |
| UX-2 | **Carpetas** | Breadcrumbs + atrás real (móvil) / árbol en sidebar (escritorio); fin del "volver a la raíz" | 🔴 | ⬜ |
| UX-3 | **Formulario** | Crear/editar por tipo con validación y estados claros | 🟡 | ⬜ |
| UX-4 | **Bóveda / lista** | Secciones, orden, estados vacío/carga/error pulidos | 🟡 | ⬜ |
| UX-5 | **Escritorio** | Reflejar A/B en el master-detail; árbol de carpetas en sidebar si B | 🟡 | ⬜ |
| UX-6 | **Resto** | Generador, Auditoría, Ajustes, Sync: jerarquía y estados | 🟡 | ⬜ |
| WIN-ICON | **Ícono taskbar** | `WM_SETICON` big/small en `win32_window.cpp` + AUMID en instalador + rebuild | 🟢 | ⬜ |

Cada fase: rama `feature/ux-overhaul`, lote revisable, `flutter analyze` 0 + tests
verde, commit de una línea ASCII.

---

## 4. Qué NO se toca

- Lógica de cripto/persistencia/sync (sólo presentación).
- Paleta/tokens Graphite Pro (se mantienen; esto es UX, no recolor).
- Logo e íconos ya generados (salvo el fix de taskbar, que es runner nativo).

*Generado el 2026-06-29. Sucede a `rediseno_ui_2026.md` (capa visual, hecha).*
