# 40 · Sincronización P2P (pairing + delta sync)

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/40_sincronizacion.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en el módulo de sync: `features/sync/presentation/pairing_screen.dart`,
`application/pairing_notifier.dart`, `infrastructure/delta_sync_manager.dart`,
`domain/pairing_payload.dart`, y su relación con `credentialsNotifierProvider` /
`foldersNotifierProvider` / la DB Drift. Es E2EE en LAN (QR para vincular, LWW por
timestamp para resolver conflictos). **No cambies el protocolo/serialización sin
avisar** (romperías la compatibilidad PC↔móvil).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **🐞 BUG (alta): la Bóveda de Windows NO se auto-actualiza al sincronizar.** Tras
   un sync entran filas nuevas a la DB pero la lista no refresca hasta cerrar/abrir.
   Causa típica: los providers (`credentialsNotifierProvider`/`foldersNotifier
   provider`) no se invalidan tras aplicar el delta. Arréglalo: cuando
   `DeltaSyncManager` aplique cambios, **invalida/refresca** esos providers (o emite
   un evento/stream al que la UI escuche). Verifica que aplique en ambos sentidos y
   en escritorio (donde el server puede ser residente en background).
2. **✨ Feature (pedida): ver QUÉ se sincronizó.** Al terminar un sync, muestra un
   **resumen** de credenciales y carpetas afectadas (nuevas / actualizadas /
   borradas), con nombres. Guarda un pequeño **log/historial de sync** (fecha,
   dispositivo, contadores, ítems) accesible desde la pantalla de Sincronizar.
   `DeltaSyncManager` ya conoce el manifiesto aplicado — expón ese detalle a la UI.
3. **UI/UX** — estados claros del pairing: servidor activo · esperando · conectando
   · sincronizando · éxito(con resumen) · error(con detalle). QR prominente; lista
   de **dispositivos vinculados** (nombre, última sync, desvincular).
4. **Lógica/estado** — asegura que el **servidor de sync arranque en background**
   (no solo al abrir la pantalla) para WiFi-unlock / sync continua; reconexión sin
   re-escanear QR; indicador global de estado de sync (un provider) que el sidebar
   pueda mostrar.
5. **i18n/a11y** — todos los estados y el resumen en `.arb`.
6. **Tests** — aplicar un delta invalida los providers (la lista cambia sin
   reabrir); el resumen refleja los ítems aplicados; LWW sigue resolviendo como en
   `delta_sync_manager_test`.
7. **Seguridad** — sigue E2EE; nunca loguear secretos ni la clave de sesión de sync.

**Features propuestas (elige 3–5):** (a) **auto-sync** periódico/al desbloquear;
(b) **notificación** "N cambios sincronizados"; (c) **resolución de conflictos
visible** (elige versión) además del LWW automático; (d) **estado por dispositivo**
en tiempo real; (e) **sync selectiva** por carpeta/tipo.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; prueba real PC↔móvil en
la misma red: crea algo en un lado y confirma que aparece en el otro **sin reabrir**,
con resumen de lo sincronizado.

**Guardarraíles:** no cambies `PairingPayload`/claves JSON ni el handshake sin
versionar; LWW debe seguir determinista; el server no debe filtrar datos sin cifrar.
