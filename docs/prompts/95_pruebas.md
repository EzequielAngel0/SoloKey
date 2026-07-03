# 95 · Pruebas (lógica + UI + integración) — todo en un chat

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más. Este prompt es **grande a
> propósito**: cubre lógica, widget e integración y termina actualizando los prompts.
> Trabaja **por fases y por lotes**, dejando los gates verdes y commiteando cada lote.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md (reglas duras, arquitectura, gates y método) y
docs/prompts/PRUEBAS_INTEGRACION.md (guía del motor integration_test y patrones
anti-flaky, ya adaptada a SoloKey local-first). Luego
desarrolla lo descrito en docs/prompts/95_pruebas.md: audita la cobertura de tests,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo POR FASES y POR LOTES
revisables — Fase 1 lógica, Fase 2 widget, Fase 3 integración, Fase 4 actualizar los
prompts para mantener los tests. Deja `flutter analyze` en 0 y `flutter test` en verde en
cada lote; corre `dart run build_runner build --delete-conflicting-outputs` y
`flutter gen-l10n` cuando aplique; y commitea por lote con el formato del proyecto (una
sola línea, ascii sin acentos, sin firma).
```

---

Objetivo: construir una **red de pruebas real** para SoloKey (pirámide unit → widget →
integración) y dejar el proceso **auto-sostenible**, de modo que cada trabajo futuro por
pantalla **cree/edite** los tests que le tocan. Hazlo en **un solo chat, por fases**.

SoloKey es **local-first sin backend**: el "backend" es la **DB cifrada local
(Drift/SQLite) + el Keystore/DPAPI**, y el estado limpio es una **bóveda nueva** (no un
seed remoto). La guía `PRUEBAS_INTEGRACION.md` ya está escrita con este supuesto.

## Convenciones y gotchas (léelos antes de escribir tests)

- **Ubicación:** `test/**` espeja `lib/**`; los `integration_test/**` van aparte.
- **Zero-Print también en tests:** nunca imprimas secretos/claves/texto plano.
- **Determinismo:** nada de `sleep` sueltos ni reloj de pared. Para TOTP/rotación
  **inyecta el tiempo**; si un servicio usa `DateTime.now()` interno, dale un `now`
  opcional (compatible) antes de testear.
- **Aleatoriedad:** `Random.secure()` no es sembrable → para `PasswordGenerator` verifica
  **invariantes** (longitud, charset, unicidad), nunca un string fijo.
- **Sin red:** unit y widget corren offline; ningún test abre sockets.
- **Widget tests — envoltura obligatoria** (si falta algo, revienta con errores crípticos
  de `Localizations`/`Theme`/`UnimplementedError`):
  ```dart
  ProviderScope(
    overrides: [
      // los use-case providers lanzan UnimplementedError por diseno (get_it en runtime):
      getCredentialsUseCaseProvider.overrideWithValue(fakeGet),
      saveCredentialUseCaseProvider.overrideWithValue(fakeSave),
      deleteCredentialUseCaseProvider.overrideWithValue(fakeDelete),
      credentialHealthProvider.overrideWithValue({'id': {CredentialHealth.weak}}),
      // o, mas simple, filteredCredentialsProvider / credentialsNotifierProvider.
    ],
    child: MaterialApp(
      theme: AppTheme.dark(), // registra la ThemeExtension AppPalette (context.palette)
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MobileHomeScreen(),
    ),
  );
  ```
  - **NO uses `pumpAndSettle`** donde haya `Timer.periodic` (la tarjeta TOTP corre uno de
    1s) o animaciones: cuelga/time-out. Bombea frames: `await tester.pump(Duration(...))`.
  - Tras `enterText` en la búsqueda, avanza > 250 ms para disparar el **debounce**.
  - Prefiere overrides de Riverpod a `get_it`; si un widget usa `get_it`, registra fakes
    en `setUp` y `GetIt.I.reset()` en `tearDown`.
- **Integration tests:** agrega `integration_test` a `dev_dependencies` (aún no está),
  crea `integration_test/`, usa `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
  y `app.main()`. **Espera por condición** (helper `waitFor` de la guía), nunca
  `pumpAndSettle`. Estado limpio = bóveda nueva (borra/inicializa DB + Keystore).
- **Gates por lote:** `flutter analyze` 0, `flutter test` verde. Integración: dos corridas
  en verde antes de commitear.

## Ya cubierto (extiéndelo, no lo dupliques)

Cripto/servicios (`security_service`, `double_envelope`, `recovery`,
`ssh_key_generator`, `brute_force_guard`, `csv_import`, `security_audit`), sync
(`pairing_payload`, `delta_sync_manager`, `delta_sync_integration`), vista de bóveda
(`vault_view_test`, orden/filtro) y temas (`theme_smoke_test`). **Casi no hay widget
tests ni un solo `integration_test`** — ahí está el mayor hueco.

---

## Fase 1 — Lógica (unit tests puros)

Sigue el estilo de `test/features/credentials/vault_view_test.dart` (helper `_c(...)`,
`group(...)`, asserts de invariantes). Usa `ProviderContainer(overrides: [...])` +
`addTearDown(container.dispose)` para providers.

1. **`PasswordGenerator`** (`features/password_generator/domain/password_generator.dart`):
   longitud exacta; solo chars del pool activo; **≥1 char por charset habilitado**;
   `length < 4` lanza; pool vacío lanza; unicidad entre corridas. `evaluate()` → umbrales
   `PasswordStrength` en casos límite.
2. **`AutofillMatcher.match`/`extractDomain`**
   (`features/autofill/application/autofill_matcher.dart`): match por dominio (ambos
   sentidos + host igual), fallback por cola de package (`com.spotify.music` → `spotify`;
   colas ≤2 no hacen ruido), solo tipo `password`, ignora website vacío, respeta `limit`.
3. **`credentialHealthProvider`**: `_isWeak`/`_isCheckable` y conteo de reutilizadas;
   SSH/passkey/TOTP nunca "weak/reused"; dos con igual password → `reused`.
4. **Rotación debida** (`core/services/notification_service.dart`, `findDueRotations`):
   vencimiento por `rotationInterval`/`customRotationDays` + cooldown de 24h. Añade un
   `now` inyectable si hace falta.
5. **`CredentialDto`** (payload cifrado ↔ JSON): round-trip de todos los campos + tipos
   (SSH/passkey), sin volcar texto plano.
6. **Árbol de carpetas** (`FolderTree`/`folder_list_view`): jerarquía padres/hijos,
   huérfanos, orden. Extrae la lógica a una función pura si está enredada en el widget.

## Fase 2 — Widget tests

Prioriza las pantallas de mayor tráfico/estado. Usa la envoltura de arriba.

1. **`CredentialCard`** (estados): título/subtítulo, favorito, doble-cifrado, **chip de
   salud** (débil vs. reutilizada vía `credentialHealthProvider`), y el **TOTP inline**
   (renderiza código válido con semilla buena; "código inválido" con semilla mala —
   bombea frames, no `pumpAndSettle`).
2. **Lista agrupada** (`CredentialListWidget`): que rinda las filas en el contenedor
   denso; que en `reorderMode` aparezca el asa (`drag_indicator`) y fuera de él no.
3. **`MobileHomeScreen` / Bóveda**: filtrado por chip (Todos/Favoritos/Passwords/TOTP/…),
   **búsqueda con debounce** (avanza > 250 ms), estados **vacío** (bóveda vacía vs. "sin
   resultados") con `EmptyState`, **carga** (`ShimmerLoader`) y **error**. Cambio de
   orden (manual/A–Z/reciente) reordena la lista.
4. **`PasswordStrengthIndicator`** y **`SecureTextField`**: reflejan fuerza y revelar/
   ocultar.
5. **Formulario** (`credential_form_screen`): validación (título requerido), selector de
   tipo cambia campos, generar contraseña rellena el campo.

## Fase 3 — Integración (`integration_test`, recorridos reales)

Sigue el motor y los patrones de `PRUEBAS_INTEGRACION.md` (ya adaptado a SoloKey local-first).

1. **Setup** dev-dep + carpeta `integration_test/` + helper `waitFor` por condición.
2. **Recorrido feliz** (`vault_e2e_test.dart`): **crear bóveda** (setup con contraseña
   maestra) → **bloquear** → **desbloquear** (por contraseña, no biometría) → **crear
   credencial** → aparece en la lista → **buscar** y encontrarla → abrir **detalle** →
   **revelar/copiar** (por el camino de contraseña) → **bloquear**. Asegura estado limpio
   (bóveda nueva) al inicio.
3. **Seams inevitables** (documenta/introduce, no hardcodees): biometría (`local_auth`)
   no automatizable → conduce por la contraseña maestra y/o `--dart-define=
   TEST_DISABLE_BIOMETRIC=1`; secure storage funciona headless en Windows (DPAPI) y
   emulador (Keystore).
4. **Dispositivos:** `-d windows` (VS "Desktop development with C++" + carpeta `windows/`)
   o Android `-d emulator-5554`. Corre la suite **dos veces en verde**.

## Fase 4 — Dejar los tests auto-sostenibles (actualizar los prompts)

Para que el trabajo futuro **mantenga** los tests, edita la documentación de prompts:

1. **`00_contexto_compartido.md`** — en "Gates por cada cambio" añade que **cada cambio de
   lógica/UI debe crear o actualizar sus tests** (unit para lógica, widget para UI) y
   dejar `flutter test` verde; y menciona la pirámide y `integration_test` para recorridos.
2. **Cada prompt de pantalla (10–90)** — asegúrate de que su sección de **Tests** exista y
   sea concreta: qué **crear nuevo**, qué **suite existente extender** y qué **editar** si
   el código de esa pantalla cambia (referenciando las suites de las Fases 1–3). Varios ya
   tienen un punto "Tests"; vuélvelo accionable y enlazado a los archivos reales.
3. **`README.md`** — refleja en el índice/estado que existe la suite y el prompt `95`, y
   la regla de "toca código → toca sus tests".

**Verificación final:** `flutter analyze` 0 + `flutter test` verde; la suite de
integración dos veces en verde en al menos un dispositivo; resumen de suites nuevas y, si
corres `flutter test --coverage`, el antes/después.

**Guardarraíles:** no debilites cripto/persistencia/sync ni imprimas secretos; los seams
de test se limitan a `--dart-define` acotados; cambios de producción, solo seams de tiempo
mínimos y compatibles.
