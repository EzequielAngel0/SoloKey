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
| **L1 — Detalle** | `credential_detail_screen.dart` | Detalle **por tipo** en filas densas; **TOTP con código en vivo** como primera fila (semilla en "Avanzado", revelar con biometría); login/API/SSH/passkey/nota a medida | ✅ |
| **L2 — Carpetas** | `folder_screen.dart`, `home_screen` (tab Carpetas), `folder_list_view.dart` | **Breadcrumbs + atrás real**; subcarpetas claras; fin del "volver a la raíz"; en escritorio, árbol en el sidebar | ⬜ |
| **L3 — Bóveda/lista** | `home_screen.dart`, `credential_card.dart`, `credential_list_widget.dart` | Lista densa con secciones, orden, estados vacío/carga/error; cabecera y chips pulidos | ⬜ |
| **L4 — Formulario** | `credential_form_screen.dart` + `widgets/` | Crear/editar **por tipo**, validación y estados claros, secciones densas | ⬜ |
| **L5 — Seguridad** | `security_audit_screen.dart`, `security_hub_view.dart`, generador, `password_history_screen.dart` | Score + hallazgos accionables; generador y historial con jerarquía y estados | ⬜ |
| **L6 — Ajustes** | `settings_screen.dart` | Lista agrupada, selector de tema con preview, secciones densas | ⬜ |
| **L7 — Sync/Transfer/Archivos/Passkeys** | `pairing_screen.dart`, `transfer_screen.dart`, `secure_files_screen.dart`, `passkeys_screen.dart` | Estados (vacío/conectando/error), pasos claros, filas densas | ⬜ |
| **L8 — Acceso** | `splash_screen.dart`, `setup_screen.dart`, `unlock_screen.dart`, `recovery_screen.dart` | Onboarding/stepper limpios, Hello/biometría primero, estados de error | ⬜ |
| **L9 — Escritorio + extras** | `desktop_main_layout.dart`, `quick_fill_screen.dart`, `qr_scanner_screen.dart`, `autofill_onboarding_screen.dart` | Master-detail con filas densas + árbol de carpetas; overlays/onboarding | ⬜ |
| **WIN-ICON** | `windows/runner/win32_window.cpp`, instalador | `WM_SETICON` big/small + AUMID + rebuild (independiente del diseño) | ⬜ |

Tras cada lote se reporta para que el dueño valide antes de seguir.

---

## 4. Qué NO se toca

- Lógica de cripto/persistencia/sync (sólo presentación).
- Paleta/tokens Graphite Pro (se mantienen; esto es UX, no recolor).
- Logo e íconos ya generados (salvo el fix de taskbar, que es runner nativo).

*Generado el 2026-06-29. Sucede a `rediseno_ui_2026.md` (capa visual, hecha).*
