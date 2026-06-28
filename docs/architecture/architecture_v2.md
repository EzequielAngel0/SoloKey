# SoloKey - Actualización Arquitectónica de Interfaz y Datos (v2)

Registro de decisiones arquitectónicas referentes a las estructuras de organización y flujos UI, correspondientes a los cambios realizados en Marzo de 2026.

## 1. Patrón de Navegación "FolderScreen"
### El Problema
Mantener un listado enorme en memoria (en forma de "Árbol Desplegable") suponía problemas visuales de limpieza de pantalla, clics accidentales y sobrecarga de estado.
### La Solución
Implementación de navegación profunda.
* Cada carpeta se visualiza a través de un ruteo directo `/folders/:id`.
* En la UI la credencial está vinculada en la base de datos a `categoryId` que referencia `FolderEntries`. El filtrado ahora filtra todo localmente a través de `Riverpod`.
* Se implementaron BottomSheets jerárquicos (`_FolderPickerSheet`) dentro del Modal de Creación que permiten "navegar" al interior para seleccionar jerarquías o crear las carpetas al vuelo usando el patrón `Navigator.push`.

## 2. Persistencia en Esquema de DB: Migración Versión 4
La estructura requería permitir a los usuarios aislar y resaltar carpetas o secretos fundamentales.
* Añadido booleano `isFavorite` a `FolderEntries`.
* Drift (Sqflite wrapper) se configuró para la V4.
* En `folder_repository_impl.dart`, los metadatos ahora se parsean correctamente desde `FolderEntry` de Drift directo hacia el `Folder` (y viceversa). Esta fue la principal fuente de un bug persistente porque el DOM/Memoria sobreescribía SQLite a base temporal (Ram), pero no persistía a disco.

## 3. Convergencia UX Predictiva
La aplicación adopta atajos interactivos enfocados a usabilidad premium:
1. **Auditoría Reactiva:** Las advertencias críticas o semanales en `/security-audit` actúan ahora como DeepLinks internos que insertan el Route al "Modo Editor" de contraseñas.
2. **"Toggles" Duales de Favoritos:** La estrella dorada está presente en dos lugares primordiales (como `ActionIconButton` de las Barras Superiores de Detalles y dentro de las Sheet Menus tras un *LongPress* sobre listas).
3. **Pestañas (NavBar) Transparentes:** El nombre de la Pestaña general cambió a `Credenciales`. La segunda es `Carpetas` y la tercera es el aglomerador virtual de lo guardado como `Favoritas`.

Estas decisiones solidifican a la app para escalar hasta 1000 secretos sin desestructuración.
