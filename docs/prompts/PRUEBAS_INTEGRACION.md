# Pruebas de integración de UI en SoloKey (`integration_test`)

Cómo se prueba **la interfaz real** de SoloKey de punta a punta —sin que nadie abra la
app a mano— y cómo llevar el mismo patrón a móvil y a la ventana de escritorio.

> SoloKey es **local-first sin backend**: no hay API, staging ni túnel. El "servidor"
> contra el que corre la app es la **base de datos cifrada local (Drift/SQLite)** más el
> **Keystore (Android) / DPAPI (Windows)**. Por eso el "estado limpio" de una prueba es
> una **bóveda nueva**, no un seed remoto. La sincronización es **P2P E2EE en la LAN**
> (dispositivo↔dispositivo), no cliente↔servidor.

## El punto clave: por qué NO es Playwright

**Playwright automatiza navegadores** (Chromium/Firefox/WebKit): encuentra elementos por
selectores del **DOM** y dispara eventos del navegador. Sirve para webs.

SoloKey es una **app Flutter nativa** (Android + Windows): no hay DOM ni navegador.
Flutter pinta sobre un canvas propio; Playwright no "ve" nada dentro. El equivalente
oficial es **`integration_test`** de Flutter: en vez de manejar un navegador, **maneja el
árbol de widgets** de la app real desde dentro del mismo proceso.

```
Web                  →  Playwright        →  navegador       →  DOM
SoloKey (nativa)     →  integration_test  →  app real        →  árbol de widgets
```

Cuando corres `flutter test integration_test -d windows`, Flutter **compila la app y lanza
el ejecutable real de Windows**; el código de la prueba la conduce por dentro
(`WidgetTester`). La app se abre sola, crea/desbloquea la bóveda y opera: no es una
simulación, es el binario real hablando con la **DB cifrada real** y el Keystore/DPAPI del
dispositivo.

## `integration_test` vs. un widget test normal

Ya existen widget/unit tests en `test/` (ver el prompt [`95_pruebas.md`](95_pruebas.md)).
No son lo mismo:

| | `test/*_test.dart` (unit/widget) | `integration_test/*_test.dart` |
|---|---|---|
| Dónde corre | En la VM de Dart, **sin dispositivo** (`flutter test`) | En un **dispositivo real** (`-d windows`/emulador/teléfono) |
| App | Widgets sueltos o una pantalla con `ProviderScope` + overrides | La app **completa** vía `app.main()` |
| Estado / datos | **Fakes/overrides** en memoria (sin DB ni Keystore reales) | **Reales**: DB cifrada local + Keystore/DPAPI del dispositivo |
| Binding | `TestWidgetsFlutterBinding` | `IntegrationTestWidgetsFlutterBinding` |
| Qué valida | Que un widget se pinte / una rama de lógica | Que el **recorrido** funcione extremo a extremo |
| Velocidad | Milisegundos | Segundos a minutos (compila + lanza) |

Regla práctica: el widget test protege una pantalla o una regla; el `integration_test`
protege un **recorrido de usuario** (setup → bloquear → desbloquear → crear → buscar →
revelar → bloquear) que solo se rompe cuando varias piezas —cripto, persistencia,
navegación, guard de bloqueo— dejan de encajar.

## Qué se necesita

1. **Dependencia** (aún **no** está en [`pubspec.yaml`](../../pubspec.yaml); agrégala a
   `dev_dependencies`):
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     integration_test:      # el motor E2E
       sdk: flutter
   ```
   El resto ya está en el proyecto (`flutter_secure_storage`, `drift`, `local_auth`,
   `otp`, …).
2. **Flutter en el PATH** y, para `-d windows`, el **toolchain de escritorio Windows**
   (Visual Studio con "Desktop development with C++"): compila C++ nativo del runner.
3. **La carpeta `windows/` del proyecto** (ya existe). ⚠️ Trampa clásica de Flutter:
   `**/windows/flutter/` suele estar en `.gitignore`, así que en un clon/worktree fresco
   puede faltar `windows/flutter/CMakeLists.txt` y el build revienta con *"install FILES
   given directory"*. Se regenera con `flutter create --platforms=windows .` en la raíz.
4. **NO hay stack que levantar.** Al ser local-first, la prueba no depende de red; solo
   necesita un **estado de bóveda conocido** (ver "Datos", abajo).

## Cómo correrlo (uso)

```powershell
# Escritorio Windows (la app se abre y se conduce sola):
flutter test integration_test -d windows

# Android (emulador o telefono por USB):
flutter devices                         # copia el id del dispositivo
flutter test integration_test -d emulator-5554
```

Los `--dart-define` son la **configuración** de la corrida. SoloKey no tiene URL de API;
los defines aquí son **seams de prueba** que la propia suite puede introducir para lo que
no se puede automatizar:

| Define | Para qué | Por qué |
|---|---|---|
| `TEST_DISABLE_BIOMETRIC=1` | Saltar el auto-prompt biométrico del desbloqueo | `integration_test` no puede tocar los diálogos nativos de `local_auth`; el flujo se conduce por la **contraseña maestra**. El seam solo desactiva el *auto-prompt*, no debilita la cripto. |
| `TEST_MASTER_PASSWORD=...` | (opcional) contraseña de la bóveda de prueba | Evita hardcodearla en el test; úsala solo en builds de test. |

> Regla: los seams se limitan a `--dart-define` de test y **nunca** exponen claves ni
> abren puertas traseras en release.

## Cómo se implementa (anatomía de un E2E de SoloKey)

### 1. Arranque: la app real, estado limpio

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();   // motor E2E, no el de widget tests

  testWidgets('setup -> bloquear -> desbloquear -> crear -> buscar -> revelar', (tester) async {
    await resetVault();         // estado limpio = boveda NUEVA (ver "Datos")
    await app.main();           // lanza la app COMPLETA
    await waitFor(tester, find.byType(/* SetupScreen o UnlockScreen */));
    // ...conduce el flujo real...
  });
}
```

`app.main()` es la clave: importas el `main.dart` real con un alias y lo ejecutas. A
partir de ahí es la app de verdad, no un montaje de prueba.

### 2. Esperar por CONDICIÓN, nunca `pumpAndSettle`

SoloKey tiene **timers que nunca "asientan"**: el `Timer.periodic(1s)` de la tarjeta TOTP
(`_TotpVisualizer`), el temporizador de auto-bloqueo (`AutoLockManager`/
`AppLifecycleObserver`) y el daemon de sync en escritorio. `pumpAndSettle` espera a que no
haya frames pendientes → **cuelga o time-out**. Bombea frames y revisa un finder:

```dart
Future<void> waitFor(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));   // avanza un frame
    if (finder.evaluate().isNotEmpty) return;               // ¿ya aparecio?
  }
  fail('No aparecio a tiempo: $finder\nTextos visibles: ${_visibleTexts(tester)}');
}
```

Al fallar, imprime **los textos visibles** — diagnóstico barato del estado en que se
quedó. `waitForAny` es la variante que ramifica entre varios estados posibles (setup vs.
unlock, biometría vs. contraseña) y devuelve el índice del que apareció.

### 3. Encontrar y tocar widgets

- **Por texto localizado**: la UI es i18n, así que resuelve la clave del `.arb` en vez de
  hardcodear (`AppLocalizations.of(context)`), o usa iconos/tipos estables:
  `find.byIcon(Icons.lock_rounded)`, `find.byType(CredentialCard)`.
- **Por tipo**: `find.byType(SoloFilterChip)`, `find.byType(CredentialListWidget)`.
- **Campos por etiqueta** (más estable que por posición):
  ```dart
  Finder _fieldByLabel(String label) => find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText ?? '') == label);
  ```
- **Tap seguro en hojas/listas que scrollean** (el botón puede quedar bajo el borde y el
  tap se pierde en silencio):
  ```dart
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(finder);
  }
  ```

### 4. El desbloqueo: contraseña maestra, no biometría

Al desbloquear, `UnlockScreen` lanza biometría automáticamente y ofrece **fallback a
contraseña maestra**. `integration_test` no puede tocar el diálogo nativo de `local_auth`,
así que corre con `--dart-define=TEST_DISABLE_BIOMETRIC=1` (para saltar el auto-prompt) y
conduce el flujo por la contraseña. Así el test valida el **flujo de derivación de clave
Argon2id + verificación** de verdad, sin puertas traseras.

### 5. Leer ESTADO del widget para decidir

En vez de hardcodear "la credencial 3", lee la lista y elige por título —robusto ante
corridas previas:

```dart
final titles = tester.widgetList<CredentialCard>(find.byType(CredentialCard))
    .map((c) => c.credential.title);
final target = titles.firstWhere((t) => t.contains('GitHub'));
await tapVisible(tester, find.text(target));
```

### 6. Aserciones que prueban el resultado REAL

No basta con "no crasheó". La prueba exige que el dato **sobreviva el ciclo cifrado**: que
la credencial creada **reaparezca tras bloquear y desbloquear** (o sea: se persistió
cifrada y se descifró bien), y que al revelar/copiar salga el valor correcto:

```dart
// crear -> bloquear -> desbloquear -> debe seguir ahi (round-trip cifrado real)
await waitFor(tester, find.text('GitHub'));
// revelar exige auth (por contrasena, con el seam biometrico desactivado)
await tapVisible(tester, find.byIcon(Icons.visibility_rounded));
await waitFor(tester, find.textContaining(expectedUsername));
```

> **Zero-Print también en E2E:** no vuelques el secreto revelado al log; asserta contra un
> valor esperado que ya conoces, no imprimas el descifrado.

## Datos: siempre bóveda nueva, nunca datos ajenos

Como no hay backend, el "seed" es **crear la bóveda dentro del propio test**. Antes de
`app.main()`, garantiza estado limpio:

- Borra la **DB local** (el archivo de Drift bajo `path_provider`) y limpia el
  **secure storage** (`FlutterSecureStorage().deleteAll()`), o reutiliza
  `WipeVaultUseCase` si aplica.
- El primer recorrido crea la bóveda (`SetupScreen`) con una contraseña conocida
  (`TEST_MASTER_PASSWORD`), de modo que los siguientes pasos son repetibles.

La suite **escribe de verdad** (crea la bóveda, guarda credenciales cifradas en la DB
local), pero todo vive **en el dispositivo de prueba** y se borra al reiniciar el estado.
No hay nada remoto que tocar.

> ⚠️ **`resetVault` es DESTRUCTIVO y apunta al MISMO almacenamiento que la app real
> de escritorio** (secure storage + `Documents/vault_guard_db.sqlite`). En una
> máquina con una bóveda real **borraría los datos del usuario**. Por eso el helper
> `resetVault()` y el test `vault_e2e_test.dart` están **gateados tras
> `--dart-define=E2E_ALLOW_WIPE=1`**: sin ese define, `resetVault` es un **no-op** y
> el recorrido feliz se **omite** (`skip`). Aun con el define, `resetVault` copia
> cada archivo a un `.e2e-backup` antes de borrar. **Corre el e2e destructivo solo en
> un equipo/emulador desechable.** El `app_boot_test.dart` NO borra nada (solo
> verifica que el arranque llega a Setup o Unlock) y es seguro en cualquier equipo.

## Qué NO se puede automatizar (y cómo sortearlo)

- **Biometría (`local_auth`)**: los diálogos nativos no son automatizables → conduce por
  contraseña maestra + seam `TEST_DISABLE_BIOMETRIC`.
- **Diálogos de permisos del SO** (Android 13+: `POST_NOTIFICATIONS`): concédelos al
  instalar (`adb shell pm grant <pkg> android.permission.POST_NOTIFICATIONS`) o diseña el
  camino feliz para no pedirlos en medio del recorrido.
- **Cámara / escaneo QR** (`mobile_scanner`, TOTP en móvil): la cámara del emulador no lee
  un QR real → cubre esa rama con **widget test** + entrada manual de la semilla en el E2E.
- **`FLAG_SECURE` / screen protection**: no bloquea la automatización, pero **impide
  screenshots** (tenlo presente si capturas en Android).
- **Sync P2P de 2 dispositivos**: emparejar y sincronizar dispositivo↔dispositivo en una
  sola máquina es frágil (dos instancias en la misma LAN/loopback). Cubre la **lógica** de
  sync con los tests que ya existen (`delta_sync_manager_test`,
  `delta_sync_integration_test`, `pairing_payload_test`) y deja el 2-device E2E como
  manual/avanzado.

## Anti-flaky (regla del repo)

Cambios a esta suite deben pasar **dos corridas seguidas en verde** antes de commitear. Lo
que la hace estable:

- Esperas **siempre por condición** (`waitFor`/`waitForAny`), cero `sleep` sueltos.
- Estado limpio al inicio (bóveda nueva: DB borrada + secure storage limpio).
- Decisiones leídas del propio estado (credencial elegida por título de la lista), no
  hardcodeadas por índice.
- Tiempo determinista donde importe (TOTP/rotación): inyecta el instante, no dependas del
  reloj de pared.
- **Windows: corre UN archivo por invocación.** `main()` usa
  `WindowsSingleInstance.ensureSingleInstance`, así que lanzar toda la carpeta
  (`flutter test integration_test -d windows`) falla al abrir la 2.ª app
  ("Unable to start the app on the device"): la primera instancia bloquea la
  segunda. Ejecuta cada archivo por separado
  (`flutter test integration_test/vault_e2e_test.dart -d windows ...`) y mata
  cualquier `SoloKey.exe` colgado entre corridas.

## Si algún día se quiere en CI

Hoy la regla es **a demanda en local**: `-d windows` necesita Visual Studio con C++, y
Android necesita un emulador. Para meterlo a CI haría falta un **emulador en el runner**
(p. ej. `reactivecircus/android-emulator-runner`) o un runner Windows con el toolchain de
escritorio. Es viable pero lento; por eso, a lo sumo, un **nightly** —nunca en cada push—.

## Referencias

- Prompt que construye toda la suite (unit → widget → integración) en un chat:
  [`95_pruebas.md`](95_pruebas.md).
- Reglas, arquitectura y gates del proyecto: [`00_contexto_compartido.md`](00_contexto_compartido.md).
- Docs oficiales de Flutter: [Integration testing](https://docs.flutter.dev/testing/integration-tests).
