# 🧩 Prompts de mejora por pantalla — SoloKey

Colección de **prompts detallados y auto-contenidos** para mejorar cada pantalla /
área de SoloKey (móvil Android + companion Windows) en **un chat independiente**.
Cada prompt sigue el mismo método: **audita → plan priorizado (impacto/esfuerzo) →
ejecuta por lotes**, cubriendo UI/UX, navegación, lógica/estado, accesibilidad,
i18n, tests y limpieza, y **propone 3–5 features nuevas** de alto valor.

## Cómo usar

1. Abre un chat nuevo con el agente en la raíz del repo.
2. Abre el prompt de la pantalla que quieras y copia **solo** el bloque
   **“📋 Prompt para pegar en el chat”** que aparece al inicio del archivo.
3. Pégalo y envíalo. Ese bloque **ya referencia** el contexto compartido
   (`00_contexto_compartido.md`), así que **no** hace falta pegar nada más.
4. Deja que audite y proponga el plan; apruébalo o ajústalo; luego que ejecute.

> Un chat por pantalla. Cada prompt lleva su propio bloque listo para pegar (no
> tienes que escribir “en base a docs/…”); el agente lee el `00` y el prompt por su
> ruta. Si algún archivo/provider se movió, el agente localiza el equivalente con
> búsqueda estructural.

## Índice de prompts

| # | Prompt | Pantallas / archivos | Incluye features destacadas |
| :-- | :--- | :--- | :--- |
| 00 | [Contexto compartido](00_contexto_compartido.md) | (preámbulo para todos) | reglas, gates, arquitectura |
| 10 | [Bóveda, lista y tarjeta](10_boveda_lista.md) | `home_screen`, `credential_card`, `credential_list_widget` | filtros persistentes, orden, densidad |
| 11 | [Detalle de credencial](11_detalle_credencial.md) | `credential_detail_screen` | por tipo, TOTP, abrir URL, historial |
| 12 | [Formulario crear/editar](12_formulario.md) | `credential_form_screen` + `widgets/` | validación, generación, autoguardado |
| 20 | [Carpetas (móvil + escritorio)](20_carpetas.md) | `folder_screen`, `folder_tree`, `desktop_main_layout` | **editar/eliminar en Windows**, arrastrar, favoritos |
| 30 | [Seguridad](30_seguridad.md) | `security_audit_screen`, `security_hub_view`, generador, historial | score, avisos inline, watchtower |
| 40 | [Sincronización](40_sincronizacion.md) | `pairing_screen`, `delta_sync_manager`, providers | **auto-refresh al sync**, **ver lo sincronizado** |
| 41 | [Transferencia (import/export)](41_transferencia.md) | `transfer_screen`, `vault_export_service`, `csv_import_service` | selección por tipo, backup programado |
| 50 | [Ajustes](50_ajustes.md) | `settings_screen` | atajos configurables, densidad, temas |
| 51 | [Archivos seguros y Passkeys](51_archivos_passkeys.md) | `secure_files_screen`, `passkeys_screen` | previews, WebAuthn real |
| 60 | [Acceso (splash/setup/unlock/recovery)](60_acceso.md) | `vault_access/presentation/*` | Hello primero, onboarding, teclado seguro |
| 70 | [Escritorio (layout/sidebar/paleta)](70_escritorio.md) | `desktop_main_layout`, `command_palette` | sidebar agrupada, master-detail, atajos |
| 80 | [Captura de QR en Windows para TOTP](80_captura_qr_windows.md) | **feature nueva** | escanear QR desde la pantalla |
| 90 | [Transversal + features de app](90_transversal.md) | toda la app | búsqueda global, a11y, perf, biometría |
| 95 | [Pruebas (lógica + UI + integración)](95_pruebas.md) | `test/**`, `integration_test/**` | pirámide unit→widget→e2e; **un solo chat**; deja el proceso auto-sostenible |
| 96 | [Pruebas del módulo Sync](96_pruebas_sync.md) | `sync_service`, `pairing_screen`, `test/support` | fake reutilizable de `SyncService`, lógica pura, widget tests de pairing |
| 97 | [Subir cobertura + smoke→behavioral](97_pruebas_cobertura.md) | `credential_form`, detalle, ajustes, servicios | guardado por tipo, revelar con auth mockeada, eleva smoke a behavioral |
| 98 | [Behavioral: escritorio y transferencia](98_pruebas_escritorio_transferencia.md) | `transfer_screen`, `desktop_main_layout`, `secure_files_screen` | export/import selectivo real, navegación master-detail, archivos con auth |
| 99 | [Acceso, auto-bloqueo y fondo](99_pruebas_acceso_fondo.md) | `unlock_screen`, `app_lifecycle_observer`, `notification_service` | unlock por contraseña/remoto, decisión pura de auto-bloqueo, rotación |

> **Testing:** la red de pruebas **ya existe** — pirámide unit → widget → e2e en
> `test/**` (espeja `lib/**`, con harness compartido `test/support/widget_harness.dart`)
> e `integration_test/**` (motor `integration_test`, corre con `-d windows`). Regla
> viva: **toca código → toca sus tests** (unit para lógica, widget para UI); cada
> prompt 10–90 trae una sección **Tests** que dice qué crear/extender. El prompt **95**
> construyó y mantiene esta red. Guía técnica del motor y patrones anti-flaky:
> [`PRUEBAS_INTEGRACION.md`](PRUEBAS_INTEGRACION.md).

## Estado conocido (bugs/pedidos identificados — TODOS resueltos)

- ✅ **Bóveda de Windows no se auto-actualiza al sincronizar.** Resuelto en `1b740da`
  (`syncStatusProvider` invalida credenciales/carpetas tras aplicar el delta).
- ✅ **Carpetas en Windows no permiten editar ni eliminar.** Resuelto en `b3b55dc` +
  `1083e2b` + `fbc95a5` (menú contextual, editor con color, borrado sin huerfanar).
- ✅ **No se ve qué se sincronizó.** Resuelto en `1b740da` + `0df7554` (`SyncSummary` +
  historial persistido + notificación "N cambios sincronizados").
- ✅ **Captura de QR desde la pantalla en Windows** para TOTP. Resuelto en `104432f` +
  `780c4dc` (screen_capturer + zxing2, botón en el formulario).
- ✅ **Switch de "verificar filtraciones" no persiste.** Resuelto 2026-07-18: vive en
  `AppSecuritySettings.hibpCheckEnabled` (Keystore) y la pantalla de auditoría lo
  lee/escribe vía `SettingsNotifier`.
- ✅ **Sidebar de escritorio mal organizada.** Resuelto en `5d702e9` (secciones, badge
  Watchtower, tooltips i18n).

**Lo que queda de verdad** (fuera del alcance de estos prompts): validar R1/M1/M3 en
dispositivos reales con la checklist de
[`../planning/pruebas_dispositivos_reales.md`](../planning/pruebas_dispositivos_reales.md),
la firma de release de Android (pendiente a pedido del dueño) y el empaquetado
macOS/Linux/iOS (diferido por hardware).
