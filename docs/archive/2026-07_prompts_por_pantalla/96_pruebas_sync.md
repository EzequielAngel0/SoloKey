# 96 · Pruebas del módulo Sync (sync_service + pairing) — tail duro

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`), el prompt de pruebas (`95`) y la guía de integración.

```text
Trabaja en el repo SoloKey (raíz). Lee y respeta docs/prompts/00_contexto_compartido.md,
docs/prompts/95_pruebas.md y docs/prompts/PRUEBAS_INTEGRACION.md. Desarrolla lo descrito
en docs/prompts/96_pruebas_sync.md: cubre con tests el tail duro del módulo de
sincronización (sync_service y pairing_screen), que quedó sin cubrir por el acoplamiento a
getIt<SyncService> (streams). Construye un fake reutilizable de SyncService en
test/support, extrae la lógica pura que esté enredada, y agrega widget tests de pairing.
Trabaja por lotes revisables; deja `flutter analyze` en 0 y `flutter test` verde; sube el
umbral en tool/coverage_min.txt al nuevo piso; commitea por lote con el formato del
proyecto (una línea, ascii sin acentos, sin firma).
```

---

Objetivo: cerrar el **mayor hueco de cobertura restante** — `sync_service.dart` (~616
líneas) y `pairing_screen.dart` (~539) — que la red de pruebas del prompt 95 dejó fuera
por su acoplamiento a red y a `getIt<SyncService>`.

## Por qué es difícil (blockers concretos)

- `PairingNotifier` (StateNotifier) **llama `getIt<SyncService>()` en su constructor**, así
  que hasta `ref.watch(pairingNotifierProvider)` lo dispara.
- `_MobilePairingViewState` y `_DesktopPairingView` en `initState` **se suscriben a
  `getIt<SyncService>().clientEvents` / `.serverEvents`** (streams) y llaman
  `hasPairingKey()`, `startServer()`, etc.
- `SyncService` es una clase **concreta** (`@lazySingleton`) con dependencias (DB,
  security, mDNS), no una interfaz → no se puede overridear por Riverpod sin más.

## Plan sugerido (por lotes)

1. **Fake reutilizable** `test/support/fake_sync_service.dart`:
   - Opción A (preferida): **extrae una interfaz `ISyncService`** con los miembros que la
     UI usa (`clientEvents`, `serverEvents`, `hasPairingKey`, `startServer`, `stopServer`,
     `pairWithDesktop`, `pairWithPc`, `removePairingKey`, `requestApproval`, `isServerRunning`)
     y haz que `SyncService implements ISyncService`; registra el fake por esa interfaz.
   - Opción B: subclasea `SyncService` con `super(...)` mínimo si el constructor lo permite.
   - El fake expone `StreamController`s para empujar eventos (`clientEvents`/`serverEvents`)
     desde el test y stubs configurables para el resto. **Sin sockets ni mDNS.**
2. **Registro en get_it** (`GetIt.I.registerSingleton<...>(fake)` en `setUp`,
   `GetIt.I.reset()` en `tearDown`), como en
   `test/features/autofill/autofill_onboarding_screen_test.dart`.
3. **Widget tests de pairing** (`test/features/sync/pairing_screen_test.dart`):
   - Móvil y escritorio (por `surfaceSize`): render, y estados **idle → pairing → success →
     error** empujando eventos por el `StreamController`. **No `pumpAndSettle`** (hay
     timers/streams); bombea frames. QR en escritorio (render de `qr_flutter`), escaneo en
     móvil cubierto por widget + entrada manual (la cámara no se automatiza).
4. **Lógica pura de `sync_service`**: extrae a funciones puras lo testeable que hoy esté
   mezclado con la red (parseo de payloads/handshake, construcción de manifiestos, decisión
   de qué servir) y unit-testéalo; reutiliza y NO dupliques `delta_sync_manager_test`,
   `delta_sync_integration_test`, `pairing_payload_test`. La parte de sockets (shelf /
   web_socket) queda como seam / integración a demanda.

## Tests (entregables)

- Nuevo `test/support/fake_sync_service.dart` (+ `ISyncService` si eliges la opción A).
- Nuevo `test/features/sync/pairing_screen_test.dart`.
- Unit tests de la lógica pura extraída de `sync_service.dart`.

## Gates + ratchet

- `flutter analyze` 0 · `flutter test` verde · `dart run build_runner build
  --delete-conflicting-outputs` si tocas freezed/riverpod/drift.
- Sube `tool/coverage_min.txt` al nuevo piso alcanzado (mídelo con
  `flutter test --coverage && dart run tool/check_coverage.dart 0`).

## Guardarraíles

- **No debilites el protocolo P2P E2EE** ni el pairing real; los seams (interfaz/fake) son
  solo para test y no cambian el comportamiento de producción.
- Ningún test abre sockets/mDNS; todo corre offline con streams falsos.
- Zero-Print: nunca vuelques claves ni payloads descifrados.
