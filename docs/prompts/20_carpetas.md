# 20 · Carpetas (móvil + escritorio)

Enfócate SOLO en la navegación y gestión de carpetas:
`features/folders/presentation/folder_screen.dart` (móvil, con
`widgets/folder_breadcrumbs.dart`), `widgets/folder_tree.dart` (árbol de escritorio),
`widgets/folder_list_view.dart`, `folder_options_sheet.dart`, `folder_picker_sheet.dart`,
`application/folders_provider.dart`, y la integración en
`core/presentation/layouts/desktop_main_layout.dart` (pestaña Carpetas: árbol +
credenciales de la carpeta + panel de detalle).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **🐞 BUG (alta prioridad): en Windows no se pueden editar ni eliminar carpetas.**
   El árbol (`FolderTree`) solo selecciona; falta acceso a renombrar/eliminar/
   favorito/cambiar color. Añade **clic derecho (menú contextual)** y/o un botón
   "⋯" por nodo que reutilice la lógica ya existente en móvil
   (`FolderScreen._renameFolder` / `_deleteFolder` / `toggleFavorite` /
   `foldersNotifierProvider`). Considera **arrastrar credenciales al nodo** para
   moverlas.
2. **UI/UX** — móvil ya tiene breadcrumbs (gustan); pulir tarjetas de subcarpeta,
   color e ícono de carpeta, contador de items (con **plurales ICU**). Escritorio:
   el árbol debe mostrar color por carpeta, estado seleccionado y "+ subcarpeta".
3. **Navegación** — breadcrumbs saltan a cualquier ancestro (móvil pop N,
   escritorio setea provider); verifica que abrir una credencial dentro de una
   carpeta muestre su detalle (ya arreglado en escritorio).
4. **Lógica/estado** — crear subcarpeta bajo el nodo seleccionado (no solo raíz);
   mover credenciales entre carpetas; borrar carpeta debe ofrecer "liberar
   credenciales" vs. "mover a padre" (revisa la semántica actual del provider).
5. **Estados** — carpeta vacía (`EmptyState`), sin carpetas, error.
6. **i18n/a11y** — menús y diálogos en `.arb`; navegación por teclado en el árbol
   (flechas para expandir/colapsar/seleccionar).
7. **Tests** — crear/renombrar/eliminar carpeta y subcarpeta; mover credencial;
   breadcrumbs saltan bien; el árbol expande ancestros del seleccionado.

**Features propuestas (elige 3–5):** (a) **arrastrar y soltar** credenciales a
carpetas (escritorio); (b) **color/emoji** por carpeta; (c) **carpetas
inteligentes** (por tipo/etiqueta/salud, solo-lectura); (d) **contador y tamaño**
por carpeta; (e) **ordenar carpetas** manualmente.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; en escritorio
(`./build_release.ps1 -Target inno`) crea/edita/elimina carpetas y mueve credenciales.

**Guardarraíles:** eliminar carpeta NO debe borrar credenciales sin confirmación;
respeta `parentId`/`categoryId`; no rompas el sync de carpetas (`delta_sync_manager`
serializa `color_hex`, `parentId`, etc.).
