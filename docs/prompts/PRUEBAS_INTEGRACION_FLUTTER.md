# Pruebas de integración de UI con Flutter (`integration_test`)

Cómo se prueba **la interfaz real** de una app Flutter de punta a punta —contra
el backend de staging, sin que nadie abra la app a mano— y cómo llevar el mismo
patrón a las apps móviles. El caso implementado hoy es el **POS**
([apps/acp_pos_app/integration_test/pos_sale_e2e_test.dart](../../apps/acp_pos_app/integration_test/pos_sale_e2e_test.dart));
esta guía explica el porqué de cada pieza para que puedas replicarla en chofer,
paquetería y cliente.

> Contexto: esta suite es la parte `pos` del **E2E de INTERFAZ**
> ([ops/e2e-ui/README.md](../../ops/e2e-ui/README.md)). La www y el admin de esa
> misma tanda usan Playwright; el POS **no**, y la razón es el punto de partida.

## El punto clave: por qué NO es Playwright

**Playwright automatiza navegadores** (Chromium/Firefox/WebKit): encuentra
elementos por selectores del **DOM** y dispara eventos del navegador. Sirve para
la www y el admin, que son webs.

El POS (y chofer, paquetería, cliente) son **apps Flutter nativas**: no hay DOM
ni navegador. Flutter pinta sobre un canvas propio; Playwright no "ve" nada
dentro. El equivalente oficial es **`integration_test`** de Flutter: en vez de
manejar un navegador, **maneja el árbol de widgets** de la app real desde dentro
del mismo proceso.

```
Web (www/admin)      →  Playwright  →  navegador  →  DOM
Flutter (POS/apps)   →  integration_test  →  app nativa real  →  árbol de widgets
```

Cuando corres `flutter test integration_test -d windows`, Flutter **compila la
app y lanza el ejecutable real de Windows**; el código de la prueba la conduce
por dentro (`WidgetTester`). Por eso, al correr la suite, **la app del POS se
abre sola**, hace login, abre turno y vende: no es una simulación, es el binario
real hablando con la API real de staging.

## `integration_test` vs. un widget test normal

Ya existen widget tests en `apps/*/test/` (ver
[PRUEBAS.md](PRUEBAS.md)). No son lo mismo:

| | `test/*_test.dart` (widget/smoke) | `integration_test/*_test.dart` |
|---|---|---|
| Dónde corre | En la VM de Dart, **sin dispositivo** (`flutter test`) | En un **dispositivo real** (`-d windows`/emulador/teléfono) |
| App | Montas widgets sueltos o `MyApp()` con mocks | La app **completa** vía `app.main()` |
| Red / backend | **Mockeados** (nada sale a internet) | **Reales**: pega al backend de staging |
| Binding | `TestWidgetsFlutterBinding` | `IntegrationTestWidgetsFlutterBinding` |
| Qué valida | Que un widget se pinte / una rama de lógica | Que el **flujo de negocio** funcione extremo a extremo |
| Velocidad | Milisegundos | Segundos a minutos (compila + lanza + red) |

Regla práctica: el widget test protege una pantalla o una regla; el
`integration_test` protege un **recorrido de usuario** (login → turno → venta →
folio) que solo se rompe cuando varias piezas + el backend dejan de encajar.

## Qué se necesita

1. **Dependencias** (ya en [apps/acp_pos_app/pubspec.yaml](../../apps/acp_pos_app/pubspec.yaml), `dev_dependencies`):
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     integration_test:      # el motor E2E
       sdk: flutter
     crypto: ^3.0.3          # TOTP RFC 6238 en el login 2FA
     shared_preferences: ^2.3.2      # mock de prefs (tema)
     flutter_secure_storage: ^9.2.2  # mock de la cola offline cifrada
   ```
2. **Flutter en el PATH** y el **toolchain de escritorio Windows** (Visual Studio
   con "Desktop development with C++"): `-d windows` compila C++ nativo.
3. **El stack de staging arriba** (`.\ops\acp.ps1 staging up`): www local `:8088`,
   APIs `:8089`, túnel. La prueba pega a un backend REAL; sin él, falla.
4. **La carpeta `windows/` del proyecto**. ⚠️ Trampa: `**/windows/flutter/` está
   en el `.gitignore` raíz, así que en un clon/worktree fresco falta
   `apps/acp_pos_app/windows/flutter/CMakeLists.txt` y el build revienta con
   *"install FILES given directory"*. Se copia del checkout principal o se
   regenera: `flutter create --platforms=windows .` dentro de `apps/acp_pos_app`.

## Cómo correrlo (uso)

Lo normal es el runner, que además prepara los datos (ver siguiente sección):

```powershell
.\ops\acp.ps1 staging up          # requisito: stack arriba
.\ops\e2e-ui.ps1 -Suite pos       # solo el POS
.\ops\e2e-ui.ps1                  # www + admin + pos
.\ops\e2e-ui.ps1 -Suite pos -Repeat 2   # regla anti-flaky: 2 corridas en verde
```

El runner ([ops/e2e-ui.ps1](../../ops/e2e-ui.ps1), función `Invoke-PosSuite`)
equivale a este comando crudo:

```powershell
cd apps\acp_pos_app
flutter test integration_test -d windows `
  --dart-define=ACP_API_URL=http://localhost:8089/api/internal `
  --dart-define=ACP_CAPTCHA_TEST_TOKEN=XXXX.DUMMY.TOKEN.XXXX
```

Los `--dart-define` son la **configuración** de la corrida (los lee
`AcpApiConfig`/`AcpAuth` en tiempo de compilación):

| Define | Para qué | Por qué ese valor |
|---|---|---|
| `ACP_API_URL` | Base de la API interna | Gateway `:8089` = server **OPS por path**. En `:8088` el SPA de la www respondería `200` falso y las llamadas de la app fallarían silenciosamente. |
| `ACP_CAPTCHA_TEST_TOKEN` | Seam para saltar Turnstile | El widget real de Turnstile no es automatizable. Este token dummy **solo pasa** porque staging valida con el **secret de PRUEBA** de Turnstile (acepta cualquier token). Con el secret real de prod, siteverify lo rechaza → nada se debilita. Ver el seam en `AcpAuth.login`. |
| `E2E_STAFF_EMAIL` / `E2E_STAFF_PASSWORD` | Credenciales del demo | Por defecto `taquilla@ejemplo.com` / `acpstaging123` (seed de staging). El runner exporta la contraseña desde `infra\env\.env`. |

## Cómo está implementado (anatomía del test del POS)

El archivo completo está comentado; aquí el esqueleto y **por qué** cada patrón.

### 1. Arranque: la app real, estado limpio

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();   // motor E2E, no el de widget tests

  testWidgets('POS: login 2FA -> abrir turno -> venta -> folio real', (tester) async {
    await AcpAuth.logout();     // sin sesión ni catálogo cacheado de corridas previas
    await app.main();           // lanza la app COMPLETA (import '...main.dart' as app)
    await waitFor(tester, find.text('ACP Taquilla'));
    ...
```

`app.main()` es la clave: importas el `main.dart` real de la app con un alias y
lo ejecutas. A partir de ahí es la app de verdad, no un montaje de prueba.

### 2. Esperar por CONDICIÓN, nunca `pumpAndSettle`

Con red real de por medio, `pumpAndSettle` **no funciona**: espera a que no haya
frames pendientes, pero los spinners de carga animan indefinidamente y nunca
"asientan" (o time-out). El patrón es bombear frames y revisar un finder:

```dart
Future<void> waitFor(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));   // avanza un frame
    if (finder.evaluate().isNotEmpty) return;               // ¿ya apareció?
  }
  fail('No apareció a tiempo: $finder\nTextos visibles: ${_visibleTexts(tester)}');
}
```

Al fallar, imprime **los textos visibles en pantalla** — diagnóstico barato para
saber en qué estado se quedó. `waitForAny` es la variante que ramifica entre
varios estados posibles (p. ej. hoja de enrolamiento 2FA vs. hoja de código vs.
pantalla de venta) y devuelve el índice del que apareció.

### 3. Encontrar y tocar widgets

- **Por texto**: `find.text('...')`, `find.textContaining('ACP-')`,
  `find.widgetWithText(FilledButton, 'Entrar')`.
- **Por tipo**: `find.byType(ListTile).first`, `find.byType(PosSeatMap)`.
- **Campos por etiqueta** (más estable que por posición):
  ```dart
  Finder _fieldByLabel(String label) => find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText ?? '') == label);
  ```
- **Tap seguro en hojas que scrollean**: el botón puede quedar bajo el borde y
  el tap se pierde en silencio, así que primero se asegura en pantalla:
  ```dart
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(finder);
  }
  ```

### 4. El 2FA real, calculado en la prueba

staging corre con `STAFF_2FA=on`. El runner **resetea** el TOTP del demo antes de
cada corrida, así que el login siempre recorre el **enrolamiento completo**: la
UI muestra la clave base32 ("ingreso manual"), la prueba la lee de la pantalla y
calcula el código igual que el backend (RFC 6238, HMAC-SHA1, espejo de
`domain/totp`):

```dart
final secret = tester.widgetList<SelectableText>(find.byType(SelectableText))
    .map((w) => w.data ?? '')
    .firstWhere((t) => t.length >= 16 && RegExp(r'^[A-Z2-7]+=*$').hasMatch(t));
await tester.enterText(_fieldByLabel('Código de tu app (para confirmar)'), totpCode(secret));
```

Así el test valida el **flujo 2FA de verdad**, sin puertas traseras: si el
enrolamiento o la verificación se rompen, la prueba se cae.

### 5. Leer ESTADO del widget para decidir (asiento libre)

En vez de hardcodear "asiento 5", la prueba lee el propio mapa y elige uno libre
—robusto ante corridas que van llenando el autobús:

```dart
final map = tester.widget<PosSeatMap>(find.byType(PosSeatMap));
final numbers = map.cells!.where((c) => c.number != null && c.sellable).map((c) => c.number!);
final free = numbers.firstWhere((n) => !map.occupied.contains(n));
await tester.tap(find.descendant(of: find.byType(PosSeatMap), matching: find.text(free)));
```

### 6. Aserciones que prueban el resultado REAL

No basta con "no crasheó". La prueba exige el **folio real** emitido por el
server y que la venta **no se haya encolado** (o sea: se vendió EN LÍNEA, no
offline):

```dart
final pendingBefore = OfflineQueue.pending.value;      // línea base al inicio
...
await waitFor(tester, find.textContaining('ACP-'), timeout: const Duration(seconds: 45));
final folio = ...firstWhere((t) => RegExp(r'^ACP-[A-Z0-9]+-\d{8}-\d{6}').hasMatch(t));
expect(folio, isNotEmpty, reason: 'no apareció folio ACP-<TAQ>-YYYYMMDD-HHmmss');
expect(OfflineQueue.pending.value, pendingBefore,
    reason: 'la venta se encoló (¿sin red?): debía venderse EN LÍNEA');
```

## Datos: siempre del seed, nunca prod

El runner, **antes de cada corrida** (`Reset-TestData`):

1. **Resetea el 2FA** del staff demo (`…@ejemplo.com`) por psql contra el
   contenedor → el login es repetible (siempre enrola desde cero).
2. **Re-aplica el seed** re-ejecutable de salidas
   ([backend/db/seed/seed_departures_dev.sql](../../backend/db/seed/seed_departures_dev.sql):
   HOY y mañana, camión 11; no duplica).

La suite **escribe de verdad** en staging (abre turno, vende boletos), pero
staging es efímero y sembrable por diseño —igual que el E2E de API—. **Nunca
toca prod.**

## Cómo aplicarlo a las apps MÓVILES (chofer, paquetería, cliente)

El motor es idéntico; cambian el **dispositivo** y algunos matices de plataforma.

### 1. Correr en un dispositivo/emulador Android

```powershell
flutter devices                         # lista lo conectado; copia el id
cd apps\acp_driver_app
flutter test integration_test -d emulator-5554 `
  --dart-define=ACP_API_URL=http://10.0.2.2:8089/api/internal `   # 10.0.2.2 = host desde el emulador
  --dart-define=ACP_CAPTCHA_TEST_TOKEN=XXXX.DUMMY.TOKEN.XXXX
```

Notas de red: desde el **emulador** Android, `localhost` es el propio emulador;
el host es `10.0.2.2`. Desde un **teléfono físico** por USB, apunta a la IP LAN
de tu PC (o al túnel de staging).

### 2. dart-defines por app (no son iguales)

Cada app necesita sus defines; el runner de builds ya sabe cuáles
—míralos sin compilar con `.\ops\flutter.ps1 <app> defines staging`—:

| App | API | Extra |
|---|---|---|
| POS / chofer / paquetería | interna (`ACP_API_URL`) | chofer además `ACP_QR_PUBLIC_KEY_PEM` (verificación QR offline) |
| cliente | **pública** (informativa) | — |

Replica en el `flutter test integration_test` los mismos `--dart-define` que usa
esa app en `ops/flutter.ps1`.

### 3. Qué NO se puede automatizar en un emulador (y cómo sortearlo)

- **Impresión térmica Bluetooth**: no hay impresora en un emulador. Prueba el
  flujo **hasta antes de imprimir**, o inyecta un transporte simulado. Ojo: el
  patrón G1 pide el **permiso BT al imprimir**, no al arrancar, justo para que el
  resto del flujo sea testeable sin BT.
- **Cámara / escaneo QR** (`mobile_scanner`, chofer): la cámara del emulador no
  sirve para leer un QR real. Cubre esa rama con un widget test y usa la entrada
  manual/HID en el E2E.
- **Diálogos de permisos del SO** (Android 12+): `integration_test` **no puede
  tocar** los diálogos nativos de permisos. Concédelos al instalar
  (`adb shell pm grant <pkg> android.permission.BLUETOOTH_CONNECT`, etc.) o
  diseña el flujo para no pedirlos en el camino feliz (que es justo lo que hace
  el permiso-al-imprimir).
- **Firma/foto** (paquetería): la firma se **dibuja en el pad real** (ver el test
  unitario `deliver_flow_test.dart`, que usa `runAsync` para `toImage`); la foto
  se puede mockear con un `image_picker` de prueba.

### 4. Si algún día se quiere en CI

Hoy en CI solo corre un **nightly de la www** por el túnel
([e2e-ui-nightly.yml](../../.github/workflows/e2e-ui-nightly.yml)); admin y POS
**no** corren en runners hospedados (el reset del TOTP va por psql al contenedor
de staging y el POS necesita escritorio Windows). Para meter una app móvil a CI
haría falta un **emulador en el runner** (p. ej. la action
`reactivecircus/android-emulator-runner`) y exponer el backend de staging al
runner. Es viable pero lento; por eso la regla del repo es **a demanda en local**
y, a lo sumo, nightly —nunca en cada push—.

## Anti-flaky (regla del repo)

Cambios a estas suites deben pasar **`-Repeat 2`** (dos corridas seguidas en
verde) antes de commitear. Lo que lo hace estable:

- Esperas **siempre por condición** (`waitFor`/`waitForAny`), cero `sleep` sueltos.
- Estado limpio al inicio (`AcpAuth.logout()`), datos del seed, TOTP reseteado.
- Decisiones leídas del propio estado (asiento libre del mapa), no hardcodeadas.
- `workers: 1` / sin retries en Playwright; staging es **UNO** —dos sesiones
  simultáneas sobre el stack se pisan y producen fallas fantasma—.

## Referencias

- Operación y decisiones de la tanda E2E de interfaz: [ops/e2e-ui/README.md](../../ops/e2e-ui/README.md)
- El test del POS, comentado: [apps/acp_pos_app/integration_test/pos_sale_e2e_test.dart](../../apps/acp_pos_app/integration_test/pos_sale_e2e_test.dart)
- Estrategia de pruebas global (unit → widget → E2E): [PRUEBAS.md](PRUEBAS.md)
- Docs oficiales de Flutter: [Integration testing](https://docs.flutter.dev/testing/integration-tests)
