# 99 · Acceso, auto-bloqueo y servicios de fondo (behavioral + lógica)

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`) y el prompt de pruebas (`95`).

```text
Trabaja en el repo SoloKey (raíz). Lee y respeta docs/prompts/00_contexto_compartido.md y
docs/prompts/95_pruebas.md. Desarrolla lo descrito en docs/prompts/99_pruebas_acceso_fondo.md:
cubre el tail de acceso y de servicios de fondo — unlock_screen (contrasena/biometria/
desbloqueo remoto), la decision pura de auto-bloqueo de AppLifecycleObserver, y la logica de
notificaciones de rotacion/sync — extrayendo a funciones puras lo que hoy este enredado con
timers/plugins y probandolo con tiempo inyectable. Nada de coverage theater. Trabaja por
lotes; deja `flutter analyze` en 0 y `flutter test` verde; sube tool/coverage_min.txt al
nuevo piso; commitea por lote con el formato del proyecto (una linea, ascii sin acentos, sin
firma).
```

---

Objetivo: cubrir los caminos de **acceso** (arranque de la app: setup/unlock) y los
**servicios de fondo** (auto-bloqueo, rotación, notificaciones) que hoy quedan en smoke o sin
cubrir (base actual ~57%). Estos son los que solo se rompen cuando cripto + persistencia +
lifecycle dejan de encajar, así que valen aserciones de verdad.

## Contexto: qué hay hoy (extiéndelo, NO lo dupliques)

- `test/features/vault_access/unlock_screen_test.dart` — **smoke** de `unlock_screen.dart`
  (~197 líneas sin cubrir). Ya existen `vault_notifier_test`, `vault_use_cases_test`,
  `recovery_screen_test`, `setup_screen_test`, `master_password_policy_test`.
- `test/core/notification_rotation_test.dart` cubre `findDueRotations` (vencimiento + cooldown
  24h). `notification_service.dart` (~143 sin cubrir) tiene aún `runBackgroundRotationCheck`,
  `showSyncCompleted` y el canal nativo sin cubrir.
- `AppLifecycleObserver` (`core/infrastructure/security/app_lifecycle_observer.dart`) no tiene
  test: timer de inactividad + decisión de bloqueo al volver de segundo plano.
- `qr_scanner_screen.dart` (~117 sin cubrir): la cámara no se automatiza, pero
  `qr_image_decoder_test`/`screen_qr_scanner_test` ya cubren el decode — extiende la rama de
  error/entrada manual.
- Reutiliza `test/support/fake_sync_service.dart` (prompt 96) para el desbloqueo remoto.

## Plan sugerido (por lotes)

1. **`unlock_screen` behavioral** (conduce por contraseña, biometría desactivada):
   - Override de los use-case providers (`unlockVaultUseCaseProvider` / `vaultNotifierProvider`)
     con fakes: **contraseña correcta → desbloqueado**, **incorrecta → error visible** (verifica
     el mensaje y que NO se navega). El auto-prompt biométrico se salta con el seam ya usado en
     e2e (`TEST_DISABLE_BIOMETRIC`) o mockeando `BiometricAuthService` en get_it.
   - **Desbloqueo remoto (WiFi-unlock):** registra el `FakeSyncService` y emite
     `serverEvents.add('remote_unlock_key:<base64>')`; asserta que la pantalla llama a
     `unlockWithRawKey` (fake que captura la clave) y limpia el buffer. Zero-Print: usa una
     clave de test conocida, no la imprimas.
   - Enlace "Olvidé mi contraseña" → navega a recovery (reutiliza `recovery_screen_test`).
2. **Auto-bloqueo: lógica pura** (`AppLifecycleObserver`):
   - **Extrae** la decisión "¿bloquear al volver de segundo plano?" a una función pura del
     estilo `shouldLockAfterBackground(backgroundedAt, now, autoLockMinutes)` y úsala en
     `didChangeAppLifecycleState`. Unit-testéala con instantes inyectados (vencido/no vencido/
     borde exacto), **sin** depender del reloj de pared. Comportamiento de producción idéntico.
   - Si el timer de inactividad tiene lógica testeable (resetea solo con sesión activa/biometría),
     extráela igual y cúbrela. No abras el `MethodChannel` real (envuélvelo/ignóralo en test).
3. **Notificaciones de fondo** (`notification_service.dart`):
   - Donde `runBackgroundRotationCheck`/`showSyncCompleted` mezclen decisión con el plugin,
     **extrae la parte pura** (qué rotaciones notificar respetando el cooldown; el texto/conteo
     del banner de sync) y unit-testéala con una DB in-memory / fakes. Deja el envío nativo como
     seam. NO dupliques `findDueRotations`.
4. **(Si queda margen) `qr_scanner_screen`**: widget test de la rama de **error / permiso
   denegado / entrada manual de semilla** (la cámara real no se automatiza), extendiendo
   `screen_qr_scanner_test`.

## Regla honesta

Cobertura ≠ correctitud. Prioriza aserciones que atrapen bugs: contraseña incorrecta que NO
desbloquea, auto-bloqueo que vence en el borde exacto, cooldown que suprime una segunda
notificación. Un test que solo sube el % **no** vale el mantenimiento.

## Gates + ratchet

- `flutter analyze` 0 · `flutter test` verde · `dart run build_runner build
  --delete-conflicting-outputs` y `flutter gen-l10n` si aplica.
- Mide con `flutter test --coverage && dart run tool/check_coverage.dart 0` y **sube
  `tool/coverage_min.txt`** al nuevo piso. CI lo hace obligatorio.
- **Tiempo determinista:** inyecta el `now` (nunca `DateTime.now()` real en el test). **No
  `pumpAndSettle`** con timers/animaciones vivas: bombea frames.

## Guardarraíles

- No debilites la derivación Argon2id ni la verificación de la contraseña maestra; los fakes de
  auth/use-cases y los seams de tiempo son **solo de test** y compatibles con producción.
- Extracciones de lógica pura: **comportamiento idéntico** al inline actual (refactor, no
  rediseño). Ningún test abre sockets, cámara ni diálogos nativos.
- Zero-Print: jamás vuelques la clave desbloqueada, secretos ni texto plano descifrado.
