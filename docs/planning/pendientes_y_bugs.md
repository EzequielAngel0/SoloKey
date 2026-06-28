# 🐞 Pendientes y Bugs — SoloKey (Estabilización + Companion de escritorio)

> Documento de organización creado el **2026-06-28** a partir de una revisión del
> código real (no del roadmap). Recoge **2 bugs activos**, **1 gap funcional** y
> **3 mejoras solicitadas** alrededor del companion de escritorio y la
> sincronización P2P, más la deuda de cierre del proyecto.
>
> Convención del repo: commits de **una sola línea** `tipo(ambito): desc` en
> español sin acentos (ASCII). Cada lote debe dejar `flutter analyze` en 0
> errores y los tests en verde.
>
> Leyenda de estado: ⬜ pendiente · 🟦 en progreso · ✅ hecho.
> Leyenda de esfuerzo: 🟢 acotado · 🟡 medio · 🔴 grande.

---

## 0. Contexto: el roadmap del `CLAUDE.md` está desfasado

Al revisar el código, varias "Fases Pendientes" del `CLAUDE.md` (9–13) **ya están
implementadas**. Lo que falta de verdad es **estabilizar** y **endurecer** lo que
ya existe, no construir esas fases desde cero.

| Fase en `CLAUDE.md` | Estado real en el código |
| :--- | :--- |
| **9** Export/Import selectivo | ✅ `core/services/vault_export_service.dart`, `csv_import_service.dart` + commits `transfer` |
| **10** Autofill OS (Android) | ✅ `features/autofill/` + canal nativo `com.solokey/autofill` (`main.dart:42`) |
| **11** Teclado seguro anti-keylogger | ✅ `shared/widgets/secure_keyboard/` (usado en `unlock_screen`) |
| **12** Passkeys | ✅ Pantalla + tipo `features/passkeys/` (⚠️ "respaldo", sin WebAuthn real) |
| **13** Auth contextual al copiar | ✅ `AuthHelper.requireAuth()` |
| **(sin documentar)** Companion de escritorio + Sync P2P E2EE | ✅ `features/sync/` completo |

---

## 1. Bugs activos

### B1 — Procesos de escritorio duplicados al reabrir 🔴 síntoma · 🟢 fix · ⬜

**Síntoma (reportado):** abres la app de escritorio, cierras la ventana, la
vuelves a abrir y quedan varios procesos `SoloKey.exe` en segundo plano.

**Causa raíz — no existe control de instancia única:**
- No hay mutex con nombre en el runner nativo `windows/runner/main.cpp`
  (solo fija el AppUserModelID).
- No hay plugin tipo `windows_single_instance` en `pubspec.yaml`.

**Flujo que lo provoca:**
1. Cerrar con la **X** no mata el proceso: `windowManager.setPreventClose(true)`
   (`main.dart:102`) hace que `onWindowClose` solo **oculte** la ventana
   (`app/app.dart:117`). El proceso sigue vivo en la bandeja.
2. Reabrir desde el icono del escritorio **arranca un proceso nuevo** en vez de
   reusar el de la bandeja.
3. Cada proceso crea su propio icono de tray, su propio `Timer.periodic` de
   notificaciones (`notification_service.dart:271`), sus propios hotkeys y su
   propio intento de servidor de sync.
4. Si además está activo el autoarranque (`--minimized`), ya hay uno corriendo
   desde el login → la pila de procesos crece.

**Arreglo propuesto (elegir uno):**
- **Opción A (nativa, robusta):** en `main.cpp`, `CreateMutexW` con nombre fijo;
  si `GetLastError() == ERROR_ALREADY_EXISTS`, buscar la ventana existente
  (`FindWindow`) y mandarle un mensaje para mostrarse/enfocarse, luego `return`.
- **Opción B (Dart, rápida):** paquete `windows_single_instance` — la 2ª
  instancia reenvía sus args por named pipe a la 1ª y sale; la 1ª, en el
  callback, hace `windowManager.show()` + `focus()`.

**Recomendación:** Opción B por velocidad de integración; A si se quiere cero
dependencias nativas extra. Probar: doble clic repetido al icono con la app en
bandeja → debe enfocar la ventana existente y mantener **un solo** `SoloKey.exe`.

---

### B2 — No se pueden vincular los celulares con la computadora 🔴 síntoma · 🟡 fix · ⬜

**Síntoma (reportado):** el emparejamiento por QR no funciona.

Emparejamiento en `features/sync/infrastructure/sync_service.dart`. Tres causas
probables, en orden de sospecha:

**a) mDNS rompe la generación del QR en Windows (la más probable).**
En `startServer()` (`sync_service.dart:112-121`), tras levantar el servidor se
llama `nsd.register(...)`. El paquete `nsd ^5.0.0` en Windows depende de
**Bonjour / `dnssd.dll`**, que **no viene en Windows por defecto**. Si
`nsd.register` lanza, `startServer()` falla **aunque el servidor HTTP ya esté
escuchando** → el `PairingNotifier` muestra "No se pudo iniciar el servidor
local" y nunca aparece el QR.
- **Fix:** envolver `nsd.register` (y `startDiscovery`) en try/catch para que el
  fallo de mDNS **no impida** devolver el `PairingPayload` ni mostrar el QR. El
  QR ya lleva IP+puerto+token, así que el emparejamiento inicial **no necesita
  mDNS**; el mDNS solo sirve para el re-descubrimiento posterior.

**b) Firewall de Windows bloquea la conexión entrante.**
El servidor escucha en `0.0.0.0:8283+`, pero el instalador es per-user
(`PrivilegesRequired=lowest`, `installer/SoloKey.iss:46`) y **no agrega regla de
firewall**. El celular no puede abrir `ws://<ip>:<puerto>/ws`.
- **Fix:** regla de firewall inbound. Como el instalador no eleva, opciones:
  (i) paso opcional con elevación en el `.iss` que ejecute `netsh advfirewall
  firewall add rule ...`; (ii) intentar crear la regla la primera vez que se
  abre el servidor; (iii) documentar el permiso manual. Verificar también que el
  rango de puertos (`_findAvailablePort` desde 8283) esté contemplado.

**c) IP equivocada en el QR.**
`_getLocalIp()` (`sync_service.dart:961`) toma la primera IP 192.168/10/172. Con
VPN, WSL, VirtualBox o Hyper-V puede elegir un adaptador virtual inalcanzable
desde el celular.
- **Fix:** preferir el adaptador con gateway por defecto / Wi-Fi físico, o
  permitir al usuario elegir la IP/adaptador cuando hay varias candidatas.

**Cómo distinguir la causa rápido:** si en la PC **no llega a salir el QR** y sale
"No se pudo iniciar el servidor local" → es **(a)**. Si **sí sale el QR** pero el
celular no conecta → es **(b)** o **(c)** (mismo Wi-Fi, sin aislamiento de AP,
IP correcta).

---

## 2. Gap funcional

### G1 — El servidor de sync no arranca en segundo plano 🟡 · ⬜

El servidor de escritorio **solo se levanta al abrir la pantalla de Sincronizar**
(`pairing_screen.dart:53-62`), no al arrancar la app. Consecuencias:
- El **desbloqueo remoto (WiFi-unlock)** desde la pantalla de bloqueo no funciona
  en un arranque normal, porque el servidor no está escuchando mientras la bóveda
  está bloqueada (`unlock_screen.dart:91` se suscribe a eventos, pero nadie
  levantó el servidor).
- La **sincronización constante** (M1) es imposible sin servidor residente.

**Arreglo:** levantar el servidor en `main.dart` al arrancar en escritorio
(condicionado por una preferencia "sync en segundo plano"), independiente de la
pantalla de Sincronizar. Cuidado con el ciclo de vida: detenerlo al salir
(`dispose`) y reusar el `SyncService` singleton.

---

## 3. Mejoras solicitadas

### M1 — Sincronización constante (no manual) 🔴 · ⬜

Hoy el sync es **manual y de un disparo**: el celular toca "Sincronizar Bóveda",
hace un delta-sync y termina. Para sync continuo en LAN se necesita:
1. Servidor de escritorio residente (ver **G1**).
2. WebSocket **persistente con heartbeat + reconexión** automática
   (hoy `connectToPairedDesktop` reconecta a demanda, sin keep-alive).
3. Disparo automático al detectar cambios: escuchar los streams de Drift
   (`watch`) y empujar deltas cuando cambian credenciales/carpetas.

**Limitación honesta:** en el **celular** el SO suspende conexiones en segundo
plano. "Constante" solo es realista con ambas apps activas en la misma red. Un
always-on real (app cerrada) requeriría un relay en la nube, lo que rompe el
modelo *local-first*.

---

### M2 — Login en la PC con PIN / Windows Hello 🟢 · ⬜ (ya casi está)

El desbloqueo biométrico usa `local_auth`, que **en Windows ES Windows Hello
(PIN, huella, cara)**. El flujo ya:
- Guarda la llave maestra tras DPAPI en `bio_master_key`
  (`unlock_vault_use_case.dart:85-89`).
- Muestra el botón biométrico si `canCheckBiometrics` es true
  (`unlock_screen.dart:150`).

**Lo que falta:** verificar que `local_auth_windows` esté registrado en el
plugin registrant de Windows, asegurar que el toggle biométrico aparezca y se
pruebe en escritorio, y pulir copys ("Usar Windows Hello" en vez de
"biometría"). Es **activar y pulir lo existente**, no construir de cero.

---

### M3 — Notificación push al celular para aprobar el login 🔴 · ⬜

Ya existe el **desbloqueo remoto (WiFi-unlock)**, pero es **PULL**: el celular
inicia, pide biometría y manda un token DUK (`sync_service.dart:780`). La PC
nunca ve la contraseña — diseño correcto.

Lo solicitado es **PUSH** (la PC pregunta "¿apruebas el inicio?" al celular):
- **Ambas apps en la misma red y abiertas:** la PC empuja un `challenge` por el
  WebSocket y el celular muestra una notificación local. Reutiliza casi todo lo
  existente; depende de **G1** (servidor residente).
- **App del celular cerrada:** requiere FCM (push de Firebase) → componente en la
  nube, que rompe el local-first puro. Decisión de producto pendiente.

---

## 4. Deuda de cierre del proyecto

| Item | Detalle | Esfuerzo | Estado |
| :--- | :--- | :--- | :--- |
| Tests del módulo sync | No hay tests de `SyncService` / `DeltaSyncManager` (re-cifrado, deltas, multi-peer). | 🟡 | ⬜ |
| Empaquetado multiplataforma | Solo hay instalador Windows (`installer/SoloKey.iss`). Falta macOS/Linux (ver `../features/desktop_companion_planning.md`) e iOS (`../release/ios_compilation_guide.md`). | 🔴 | ⬜ |
| i18n del módulo sync/transfer | Pendiente según `roadmap_desarrollo.md §6` (misma carpeta). | 🟡 | ⬜ |
| Passkeys WebAuthn real | Hoy es "respaldo de passkey", sin firma FIDO2 (Credential Manager / AuthenticationServices). | 🔴 | ⬜ |
| Actualizar `CLAUDE.md` | Roadmap desfasado (corregido junto a este doc el 2026-06-28). | 🟢 | ✅ |

---

## 5. Backlog consolidado (prioridad y orden sugerido)

| # | Item | Tipo | Prioridad | Esfuerzo | Estado |
| --: | :--- | :--- | :--- | :--- | :--- |
| B1 | Instancia única en escritorio (`windows_single_instance` en `main.dart`) | Bug | 🔴 | 🟢 | ✅ |
| B2 | Vinculación: mDNS no bloquea el QR + IP no virtual + regla de firewall opt-in en el instalador | Bug | 🔴 | 🟡 | ✅ |
| B3 | Export: árbol agrupaba por `folderId` (muerto) en vez de `categoryId` → credenciales aparecían "Sin carpeta" | Bug | 🔴 | 🟡 | ✅ |
| F1 | Ocultar/archivar + reordenar (drag) credenciales — migración Drift v10 (`isHidden`/`sortOrder`) | Mejora | 🟡 | 🔴 | ✅ |
| G1 | Servidor de sync residente al arrancar el escritorio (si hay dispositivo emparejado) | Gap | 🟡 | 🟡 | ✅ |
| R1 | Reconexión sin QR: K_sync persistida por dispositivo (escritorio) + handshake resume (HMAC challenge) | Base | 🔴 | 🔴 | 🟦 |
| M2 | Login PC con PIN / Windows Hello (`isDeviceSupported` + PIN permitido en escritorio) | Mejora | 🟡 | 🟢 | ✅ |
| M1 | Sincronización constante (resume + heartbeat + auto-sync 60s + auto-reconexión) | Mejora | 🟡 | 🔴 | 🟦 |
| M3 | Push al celular para aprobar login (notificación local, sin FCM) | Mejora | 🟢 | 🔴 | 🟦 |
| — | Tests del módulo sync (lógica pura: LWW + PairingPayload + SyncManifestItem) | Deuda | 🟡 | 🟡 | ✅ |
| — | Tests de integración del sync (deltas/apply/LWW con DB en memoria) | Deuda | 🟡 | 🟡 | ✅ |
| — | i18n de los textos NUEVOS (ocultar/mostrar + aprobación) en home/detalle/unlock | Deuda | 🟢 | 🟢 | ✅ |
| — | i18n: pantalla de Sincronizar (pairing) + textos del layout de escritorio | Deuda | 🟢 | 🟡 | ✅ |
| — | i18n restante: notificaciones y SecurityAuditService (strings en capa de servicio, sin BuildContext) | Deuda | 🟢 | 🟡 | ⬜ |
| — | Lint preexistente (crypto dep, deprecaciones Flutter 3.4x, underscores) | Deuda | 🟢 | 🟢 | ✅ |
| — | Reorden (drag) de credenciales en el companion de escritorio | Deuda | 🟢 | 🟡 | ✅ |
| — | Empaquetado macOS/Linux/iOS (diferido: sin Mac/iPhone) | Deuda | 🟢 | 🔴 | ⏸️ |

> Estado 2026-06-28: **B1, B2, B3, F1, G1, M2** completos. **R1/M1/M3 implementados**
> pero marcados 🟦 porque el flujo cruzado PC↔celular (handshake resume, sync continua,
> push de aprobación) **no se pudo probar en dispositivos reales** desde este entorno —
> requieren verificación con un celular y un PC en la misma red antes de confiar en ellos.
> Tests de sync (lógica pura + integración con DB en memoria), i18n de la pantalla de
> Sincronizar y del escritorio, reorden por drag en escritorio, y limpieza del lint
> preexistente: **hechos**. `isHidden`/`sortOrder` ahora viajan en el sync.
> `flutter analyze`: **sin issues** (lib+test); **56/56 tests verde**.
>
> Único i18n que queda: strings en capa de servicio (notificaciones de rotación/aprobación
> y `SecurityAuditService`), que no tienen `BuildContext`; localizarlos requiere devolver
> claves en vez de texto (refactor aparte). El resto de la app está en es/en.
>
> **Cómo funciona M3 sin FCM:** el celular (app abierta/conectada por resume) recibe la
> petición por el canal E2EE y muestra una **notificación local**; al tocarla abre Sincronizar
> y, con biometría, envía el DUK que ya tenía → el escritorio descifra su master key y se
> desbloquea. FCM solo haría falta para despertar la app si está **totalmente cerrada**.

---

*Generado tras revisión del código el 2026-06-28. Actualizar el estado
(⬜/🟦/✅) conforme se resuelva cada item.*
