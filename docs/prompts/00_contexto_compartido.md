# 00 · Contexto compartido (reglas, arquitectura y gates)

> **No necesitas pegar este archivo manualmente.** Cada prompt de pantalla (10–90)
> trae al inicio un bloque **“📋 Prompt para pegar en el chat”** que ya referencia
> este `00` por su ruta: el agente lo lee solo. Este documento es la fuente de
> verdad de las reglas, la arquitectura y los gates; edítalo aquí y todos los
> prompts lo heredan.

---

Trabajas en **SoloKey**, un gestor de contraseñas **local-first** en **Flutter/Dart**
para **Android** y **Windows** (companion de escritorio), con **sincronización P2P
E2EE** en la red local. El repo ya está avanzado y estable; tu trabajo es **mejorar**,
no reescribir de cero.

## Arquitectura

- **Clean Architecture por feature** en `lib/features/<f>/{domain,application,infrastructure,presentation}`,
  más `lib/core/`, `lib/shared/`, `lib/theme/`, `lib/router/`, `lib/l10n/`.
- **Estado:** Riverpod (providers/notifiers). **Modelos:** `freezed` (inmutables).
- **DB:** Drift (SQLite) en `core/infrastructure/database/`. **Secretos:**
  `flutter_secure_storage` (Android Keystore / Windows DPAPI).
- **DI:** `get_it` + `injectable` (`app/di/`). **Cripto:** AES-256-GCM + Argon2id
  en `Isolate` (`core/infrastructure/security/`). La clave maestra vive en RAM
  (`SessionManager`) y se zeroiza al bloquear.
- **Navegación:** GoRouter (`router/app_router.dart`) con guard de bloqueo.
  Responsive: `ResponsiveLayout` decide móvil vs escritorio; el escritorio usa
  `core/presentation/layouts/desktop_main_layout.dart` (sidebar + master-detail).

## Reglas duras (no negociables)

1. **Zero-Print:** jamás `print()` de contraseñas, secretos, IVs ni texto plano
   descifrado. `avoid_print` está activo.
2. **Dominio ciego:** `presentation`/`domain` **no** hacen cripto; delegan en
   `SecurityService` / capa de datos.
3. **Diseño Graphite Pro, 100% plano:** **prohibido glassmorphism** (blur, vidrio,
   gloss, biseles, 3D, rim-light, glow). Profundidad solo con bordes hairline
   (`divider`) y sombras suaves.
4. **Colores SIEMPRE por token:** usa `context.palette.<rol>` (`AppPalette`), nunca
   hex sueltos ni `Colors.*` salvo `Colors.white/black` justificados (texto sobre
   color, fondo de QR). Tipografías: `AppTheme.fontFamily` (Inter) y
   `AppTheme.monoFamily` (JetBrains Mono) para secretos/códigos.
5. **Kit compartido:** reutiliza `lib/shared/widgets/`: `DetailGroup`, `KvRow`,
   `SectionHeader`, `EmptyState`, `StatusChip`, `ScoreRing`, `SoloFilterChip`,
   `FolderBreadcrumbs`, `FolderTree`, `CopyFeedbackButton`, `VaultAppBar`. Extrae
   al kit cualquier patrón nuevo reutilizable.
6. **i18n obligatorio es/en:** todo texto visible va a `lib/l10n/app_en.arb` (+
   `app_es.arb`) y se usa vía `AppLocalizations.of(context)`. Corre
   `flutter gen-l10n` tras tocar los `.arb`. Nada hardcodeado.
7. **Densidad responsiva:** denso (estilo 1Password) pero con toque ≥44px en móvil.
8. **Seguridad de secretos:** revelar/copiar secretos pide `AuthHelper.requireAuth`
   (biometría/PIN); el texto plano se limpia de RAM al ocultar; el portapapeles se
   autolimpia (`ClipboardService`/`showClipboardCountdownSnackBar`).

## Gates por cada cambio (obligatorio dejarlo verde)

- `flutter analyze` → **0 issues**.
- `flutter test` → **verde**.
- `dart run build_runner build --delete-conflicting-outputs` si tocas
  freezed / riverpod-annotation / drift.
- `flutter gen-l10n` si tocas `.arb`.
- **Tocaste código → tocaste sus tests.** Todo cambio de lógica crea/actualiza un
  **unit test**; todo cambio de UI, un **widget test**; y `flutter test` queda
  verde. Seguimos la **pirámide** unit → widget → integración: la mayoría son unit
  (rápidos, `test/**` espeja `lib/**`), varios widget (con el harness compartido
  `test/support/widget_harness.dart`) y unos pocos recorridos e2e en
  `integration_test/**` (motor `integration_test`, ver `PRUEBAS_INTEGRACION.md`).
  El prompt **95** construye y mantiene esta red; su sección "Tests" en cada prompt
  dice qué crear/extender.

## Commits

- **UNA línea:** `tipo(ambito): descripcion` (`feat|fix|chore|docs|test`).
- **Español SIN acentos (ASCII).** Sin cuerpo multipárrafo. **Sin** pies de firma
  (nada de "Co-Authored-By" ni "Generated with…").

## Empaquetado / prueba en escritorio

- Release: `./build_release.ps1` (APKs Android + instalador Windows Inno). Para
  probar solo Windows: `./build_release.ps1 -Target inno` → `dist/…-setup.exe`.
  **No** entregues `flutter build windows` suelto. **No** uses `-ExecutionPolicy
  Bypass` (la política `RemoteSigned` ya permite el `.ps1`).
- El fix del ícono/taskbar vive en `windows/runner/` (nativo) — requiere rebuild.

## Método de trabajo (para todos los prompts)

1. **Audita** la pantalla/área: lee los archivos, lista problemas de UI/UX,
   navegación, lógica/estado, a11y, i18n y deuda.
2. **Propón un plan priorizado** por impacto/esfuerzo (tabla corta).
3. **Ejecuta por lotes** revisables; deja analyze/tests verdes y commitea por lote.
4. **No rompas** cripto, persistencia ni sync sin avisar y justificar.
