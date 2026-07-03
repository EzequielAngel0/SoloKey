# 70 · Escritorio (layout, sidebar, master-detail, paleta de comandos)

Enfócate SOLO en la experiencia de escritorio (Windows):
`core/presentation/layouts/desktop_main_layout.dart` (sidebar colapsable + 3
columnas: nav · lista/árbol · detalle), `desktop_layout_state.dart` (providers de
selección/colapso), `features/credentials/presentation/widgets/command_palette.dart`
(Ctrl+K), y la integración con `ResponsiveLayout`.

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **🔧 Sidebar mal organizada (pedido): rediséñala.** Hoy los ítems van sueltos
   (Bóveda, Carpetas, Favoritas, Auditoría, Archivos, Ajustes, Sincronizar) y el
   orden mezcla. Agrúpalos con encabezados de sección (ocultos al colapsar), p. ej.:
   **BÓVEDA** (Bóveda · Carpetas · Favoritas) — **SEGURIDAD** (Auditoría · Archivos
   seguros) — **DISPOSITIVOS** (Sincronizar) — y **Ajustes** abajo, junto a
   "Bloquear". Añade el estado de sync (punto) y, si aplica, un badge de problemas de
   auditoría (Watchtower).
2. **Master-detail** — el detalle a la derecha ya adopta filas densas; asegura
   `key: ValueKey(selectedId)` para reiniciar estado al cambiar de credencial;
   densidad afinada a ventana ancha; 3 columnas en anchos grandes, 2 en angostos.
3. **Paleta de comandos (Ctrl+K)** — mejora `CommandPalette`: navegación con
   flechas + Enter, más acciones (ir a Auditoría/Sync/Ajustes, crear carpeta, cerrar
   sesión), y resultados agrupados (credenciales / acciones). Resalta coincidencias.
4. **Atajos y clic derecho** — ya hay `Ctrl+K/N/L` y menú contextual en tarjetas;
   suma **Ctrl+E** (editar), copiar usuario/clave, y clic derecho en carpetas del
   árbol (ver prompt 20).
5. **Estado/persistencia** — recuerda sidebar colapsado, última pestaña y tamaño/
   posición de ventana (`window_manager`).
6. **a11y** — navegación completa por teclado, foco visible, `Semantics`/tooltips en
   botones de solo-ícono.
7. **Tests** — smoke de que las 3 columnas construyen; la paleta filtra; el detalle
   reinicia al cambiar de selección.

**Features propuestas (elige 3–5):** (a) **title bar custom** integrada al tema
grafito; (b) **arrastrar** credenciales a carpetas del árbol; (c) **múltiples
ventanas/pop-out** de una credencial; (d) **modo compacto** de densidad; (e) **tray
menu** con acciones rápidas (nueva, bloquear, sync).

**Verificación:** `flutter analyze` 0 + `flutter test` verde; compila y prueba en la
ventana real: `./build_release.ps1 -Target inno`.

**Guardarraíles:** no rompas el guard de bloqueo ni el arranque en tray; el ícono de
taskbar depende de `windows/runner/` (no lo pises).
