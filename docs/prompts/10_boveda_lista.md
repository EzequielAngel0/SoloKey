# 10 · Bóveda, lista y tarjeta de credencial

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/10_boveda_lista.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en la **pantalla principal de la Bóveda** y su lista:
`features/credentials/presentation/home_screen.dart` (móvil: `NavigationBar` M3 +
búsqueda pill + `SoloFilterChip`), `widgets/credential_card.dart`,
`widgets/credential_list_widget.dart` (`ReorderableListView`),
`widgets/credential_icon.dart`, y el filtro `filteredCredentialsProvider` /
`credentialSearchNotifierProvider`. En escritorio la lista vive en
`core/presentation/layouts/desktop_main_layout.dart` (`_buildMiddleListPane`).

Primero **audita** y propón un plan priorizado (impacto/esfuerzo); luego ejecútalo:

1. **UI/UX de la tarjeta** — el dueño siente que la Bóveda "se ve igual que antes".
   Rediseña `CredentialCard` para que sea claramente más limpia y distinta sin
   perder densidad: jerarquía título/subtítulo, avatar por tipo (color+ícono),
   badge de tipo opcional, TOTP inline con anillo, y el chip de salud
   (`StatusChip` débil/repetida vía `credentialHealthProvider`). Evalúa mover la
   lista a **grupos densos** (contenedor con divisores hairline, estilo 1Password)
   vs. tarjetas sueltas; el `≡` de arrastre satura — móstralo solo en modo
   reordenar o al hover en escritorio.
2. **Navegación/eststructura** — cabecera de Bóveda (saludo + chip de score +
   "usadas recientemente" opcional). Revisa que los chips de filtro (Todos ·
   Favoritos · Contraseñas · TOTP · Passkeys · SSH) y la búsqueda pill se sientan
   una sola unidad; secciones por tipo o alfabéticas plegables.
3. **Lógica/estado** — la búsqueda debe tener **debounce**; el reordenar solo
   aplica sin filtro/búsqueda (ya es así, verifícalo). Rendimiento con bóvedas
   grandes: `ListView.builder`/virtualización, y que `credentialHealthProvider`
   no recompute de más.
4. **Estados** — vacío (bóveda vacía vs. "sin resultados" — ya distinguido con
   `EmptyState`), carga (`ShimmerLoader`), error con reintento.
5. **Accesibilidad/i18n** — `Semantics`/tooltips en íconos, contraste en los 4
   temas, todo texto en `.arb`.
6. **Tests** — widget test de: filtrado por chip, búsqueda con debounce, chip de
   salud aparece en credencial débil/repetida, reorden persiste.
7. **Limpieza** — `credential_icon.dart` hace `Image.network` a
   `google.com/s2/favicons` (fuga de privacidad + falla offline): cámbialo a
   **avatar por tipo por defecto**, favicons **opt-in** y cacheados localmente.

**Features propuestas (elige 3–5):** (a) **filtros/orden persistentes** (recordar
último chip y orden); (b) **selección múltiple** con mover/borrar en lote y
arrastrar a carpeta; (c) **orden configurable** (reciente, alfabético, más usadas);
(d) **"usadas recientemente"** arriba; (e) **etiquetas/tags** además de carpetas.

**Tests (obligatorio):**

- **Lógica de filtro/orden** → extiende `test/features/credentials/vault_view_test.dart`
  (`matchesVaultFilter`, `sortCredentials`).
- **Home/estados** → extiende `test/features/credentials/mobile_home_screen_test.dart`
  (chips, búsqueda con debounce >250ms, vacío/"sin resultados"/carga/error).
- **Tarjeta/lista** → `test/features/credentials/widgets/credential_card_test.dart`
  (favorito, doble-cifrado, chip de salud, TOTP inline — bombea frames, no
  `pumpAndSettle`) y `.../credential_list_widget_test.dart` (filas densas + asa en
  `reorderMode`). Usa el harness `test/support/widget_harness.dart`.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; prueba en móvil y en
la ventana de escritorio (`./build_release.ps1 -Target inno`).

**Guardarraíles:** no toques el descifrado de la lista; los favicons no deben
llamar a la red sin opt-in; mantén el reorden y el guard de bloqueo.
