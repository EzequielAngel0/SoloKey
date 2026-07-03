# 90 · Transversal + features de aplicación

Prompt para mejoras que cruzan varias pantallas (hazlas en su propio chat, un tema a
la vez). Aplica a toda la app; respeta el contexto compartido (00).

Primero **audita** el tema elegido en toda la app y propón un plan priorizado; luego
ejecútalo por lotes.

## Temas transversales

1. **Búsqueda global** — móvil: incluir carpetas y resaltar coincidencias, recientes,
   limpiar; escritorio: la paleta `Ctrl+K` ya es global — unifícalas conceptualmente
   y con `filteredCredentialsProvider`.
2. **Accesibilidad** — `Semantics`/tooltips en todos los botones de solo-ícono;
   navegación por teclado en listas y árbol; foco visible; contraste verificado en
   **los 4 temas** (dark/light/dim/oled) — amplía `test/theme/theme_smoke_test.dart`.
3. **Rendimiento** — búsqueda con debounce; descifrado perezoso; listas virtualizadas;
   evita recomputar providers de más (`credentialHealthProvider`, audit).
4. **i18n** — auditoría de textos hardcodeados; **fechas relativas** ("hace 2 días")
   y **plurales ICU** ("1 elemento" / "3 elementos") en es/en.
5. **Consistencia de kit** — que TODAS las pantallas usen `DetailGroup`/`KvRow`/
   `EmptyState`/`StatusChip`/`SectionHeader`; poda componentes duplicados.
6. **Copiado y confirmaciones uniformes** — toda copia con countdown de limpieza;
   toda acción destructiva con confirm + auth + **Snackbar "Deshacer"**.
7. **Seguridad operacional** — auto-ocultar secretos revelados por timeout y al ir a
   segundo plano; `FLAG_SECURE`/screen protection consistente; revisar Zero-Print en
   todo el código.

## Features de app (elige 3–5 por chat)

- **Watchtower global:** badge con nº de problemas de seguridad en nav/sidebar.
- **Selección múltiple** con acciones en lote (mover/borrar/exportar).
- **Etiquetas/tags** además de carpetas; filtros combinados.
- **Autollenado** más completo (Android ya existe; pulir match por dominio/paquete).
- **Modo pánico / borrado de emergencia** por frase o atajo.
- **Bloqueo por inactividad visible** con countdown; **desbloqueo Windows Hello**
  nativo real.
- **Notificaciones** de sync ("N cambios") y de rotación (ya existe base).
- **Tema por credencial/carpeta** (color) y **densidad** configurable.

**Verificación:** por cada lote, `flutter analyze` 0 + `flutter test` verde; smoke en
los 4 temas; prueba en móvil y en la ventana de escritorio.

**Guardarraíles:** nada de romper cripto/persistencia/sync; los cambios son
transversales pero incrementales y revisables por lote.
