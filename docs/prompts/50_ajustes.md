# 50 · Ajustes

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/50_ajustes.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en `features/settings/presentation/settings_screen.dart` (y
`SettingsView` embebido en la pestaña móvil), el provider `SettingsNotifier` y la
entidad `AppSecuritySettings` (freezed; persiste en Keystore como JSON). Ya está
**agrupado** en secciones con `_SettingsCard`/`_SectionHeader`/`_ToggleTile`/
`_SliderTile` (Apariencia, Idioma, Auto-bloqueo, Portapapeles, Privacidad, Quick-Fill).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **✨ Feature (pedida): apartado de "Atajos de teclado" (escritorio).** Hoy los
   atajos (`Ctrl+K` paleta, `Ctrl+N` nueva, `Ctrl+L` bloquear) están fijos en
   `desktop_main_layout.dart`. Añade una sección en Ajustes (solo escritorio) que
   **los liste** y, si el esfuerzo lo permite, permita **reasignarlos** (widget de
   captura de combinación → persistir en `AppSecuritySettings` → aplicar dinámicamente
   en el `CallbackShortcuts`). Empieza por el visor y evalúa el remapeo.
2. **UI/UX** — selector de tema con **preview** en vivo (muestras de los 4 temas);
   agrupa mejor (Seguridad · Apariencia · Sync · Datos · Acerca de); "zona peligrosa"
   separada.
3. **Feature: toggle de densidad** (cómoda/compacta) → nuevo campo en
   `AppSecuritySettings` aplicado como `visualDensity`/escala en el tema
   (`app.dart`). Requiere `build_runner`.
4. **Navegación** — entradas a Transferir datos, Auditoría, Recuperación, Sync,
   Archivos seguros bien ubicadas; "Acerca de" con versión.
5. **i18n/a11y** — el título ya se localizó (`navSettings`); revisa que TODO esté en
   `.arb`; foco y switches accesibles.
6. **Tests** — guardar cada setting persiste y aplica su efecto (auto-lock, clipboard,
   biometría, tema, densidad, atajos).
7. **Limpieza** — considera migrar `_SettingsCard`/`_SectionHeader` al kit compartido
   si conviene unificar con el resto.

**Features propuestas (elige 3–5):** (a) **atajos configurables** (arriba);
(b) **densidad** (arriba); (c) **bloqueo por inactividad global visible** con
countdown; (d) **exportar/importar ajustes**; (e) **"Acerca de"** con changelog y
verificación de versión; (f) **modo pánico** (borrado rápido con frase).

**Verificación:** `flutter analyze` 0 + `flutter test` verde; cambia tema/densidad/
atajos y verifica que aplican y persisten tras reiniciar.

**Guardarraíles:** cambiar `AppSecuritySettings` exige `build_runner`; efectos con
side-effect (biometría/autostart/screen-protection) ya viven en `SettingsNotifier.save`
— no los rompas.
