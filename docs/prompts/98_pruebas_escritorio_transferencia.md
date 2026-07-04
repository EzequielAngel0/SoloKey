# 98 · Behavioral: escritorio, transferencia y archivos seguros

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`) y el prompt de pruebas (`95`).

```text
Trabaja en el repo SoloKey (raíz). Lee y respeta docs/prompts/00_contexto_compartido.md y
docs/prompts/95_pruebas.md. Desarrolla lo descrito en
docs/prompts/98_pruebas_escritorio_transferencia.md: eleva de smoke (solo "renderiza") a
behavioral (interacción real con aserciones) las tres pantallas de mayor superficie sin
cubrir — transfer_screen, desktop_main_layout y secure_files_screen — usando fakes/overrides
para los seams (file_picker/share_plus, biometría, syncStatusProvider). Nada de coverage
theater. Trabaja por lotes; deja `flutter analyze` en 0 y `flutter test` verde; sube
tool/coverage_min.txt al nuevo piso; commitea por lote con el formato del proyecto (una
línea, ascii sin acentos, sin firma).
```

---

Objetivo: cerrar los **huecos de UI más grandes que hoy solo tienen smoke** (base actual
~57%). El prompt 97 subió el guardado del formulario, el detalle y ajustes; aquí seguimos
por las pantallas de escritorio/transferencia, que solo verifican `takeException == null`.

## Contexto: qué hay hoy (extiéndelo, NO lo dupliques)

- `test/features/vault_transfer/transfer_screen_test.dart` — **smoke**: monta la pantalla y
  comprueba que existe el `TabBar`. `transfer_screen.dart` (~395 líneas sin cubrir) es el
  mayor hueco de UI restante.
- `test/core/desktop_main_layout_test.dart` — **smoke** del shell de escritorio
  (`desktop_main_layout.dart`, ~166 sin cubrir): sidebar + master-detail.
- `test/features/secure_files/secure_files_screen_test.dart` — **smoke**
  (`secure_files_screen.dart`, ~296 sin cubrir). La lógica de import ya tiene
  `secure_file_import_test.dart` (extiéndela si tocas formatos).
- Kit de apoyo: `test/support/widget_harness.dart` (`pumpApp`, `scaffolded`,
  `tolerateInkHiddenPaintWarnings`), `fake_credential_repository.dart`,
  `fake_folder_repository.dart`, y el `fake_sync_service.dart` que dejó el prompt 96.

## Plan sugerido (por lotes)

1. **`transfer_screen` behavioral** (export/import selectivo):
   - **Exportar:** override de `getCredentialsUseCaseProvider`/`foldersNotifierProvider` con
     fakes; selecciona un subconjunto por tipo/carpeta y dispara "Exportar". Introduce un
     **seam** para `VaultExportService` (o su método de construcción de `.skvault`) que
     **capture** el binario producido en vez de tocar `share_plus`/`file_picker`. Asserta que
     el export contiene SOLO lo seleccionado (por conteo/ids, nunca volcando el binario).
   - **Importar:** alimenta un `.skvault`/CSV de prueba por el seam de `file_picker` y verifica
     que las credenciales aparecen (reutiliza `csv_import_service_test`/`vault_export_service_test`
     para los datos; no repitas el parseo puro).
   - Zero-Print: valida contra ids/títulos conocidos, jamás imprimas el contenido cifrado.
2. **`desktop_main_layout` behavioral** (navegación real, superficie de escritorio > 720px):
   - Toca cada item del sidebar (bóveda / carpetas / salud / sincronizar / ajustes) y asserta
     que el **panel de detalle** cambia (master-detail). Selecciona una credencial de la lista
     y verifica que su detalle se abre en el panel derecho.
   - **Badge de sync:** override de `syncStatusProvider` (o `syncEventsSourceProvider` con el
     `FakeSyncService`) para forzar `active/syncing/error` y asserta el indicador del sidebar.
3. **`secure_files_screen` behavioral** (bóveda de archivos):
   - Override del `SecureFilesNotifier` (o su provider) con una lista fake; registra un fake de
     biometría en get_it (patrón de `autofill_onboarding_screen_test`). Cubre **agregar**,
     **revelar** (pide auth → aparece; ocultar → se limpia) y **eliminar**; asserta que la lista
     refleja el cambio. Estado **vacío** con `EmptyState`.
4. **(Si queda margen) Command palette / shortcuts behavioral**: extiende
   `command_palette_test`/`app_shortcuts_test` con la ejecución real de una acción (navegar,
   copiar) en vez de solo abrir la paleta.

## Regla honesta

Cobertura ≠ correctitud. Cada test nuevo debe **fallar si el comportamiento cambia** (el
export exporta de más/de menos, la navegación no cambia el panel, revelar no pide auth). Un
test que sube el % sin poder afirmar nada útil **no** vale el mantenimiento.

## Gates + ratchet

- `flutter analyze` 0 · `flutter test` verde · `dart run build_runner build
  --delete-conflicting-outputs` y `flutter gen-l10n` si aplica.
- Mide con `flutter test --coverage && dart run tool/check_coverage.dart 0` y **sube
  `tool/coverage_min.txt`** al nuevo piso alcanzado. CI lo hace obligatorio.
- **No `pumpAndSettle`** donde haya `Timer.periodic`/animaciones (TOTP, AnimatedSwitcher,
  daemon de sync): bombea frames con `tester.pump(Duration(...))`.

## Guardarraíles

- No debilites cripto/persistencia/sync ni el formato `.skvault`; los seams (fakes de
  file_picker/share_plus, biometría, providers) son **solo de test** y no cambian producción.
- Ningún test abre sockets, cámara ni diálogos nativos del SO.
- Zero-Print incluso en tests: nunca vuelques secretos, claves ni el binario de export
  descifrado; asserta contra valores/ids conocidos.
