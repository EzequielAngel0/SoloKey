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

> **Testing:** el prompt **95** construye la red de pruebas completa en **un solo
> chat** (lógica, widget e integración) y, al final, actualiza los demás prompts para
> que cada cambio futuro **cree/edite** sus tests. Guía técnica del motor
> `integration_test` y patrones anti-flaky: [`PRUEBAS_INTEGRACION.md`](PRUEBAS_INTEGRACION.md).

## Estado conocido (bugs/pedidos ya identificados a resolver en estos prompts)

- **Bóveda de Windows no se auto-actualiza al sincronizar** (hay que cerrar/abrir). → prompt **40**.
- **Carpetas en Windows no permiten editar ni eliminar.** → prompt **20**.
- **Al sincronizar no se ve qué credenciales/carpetas se sincronizaron.** → prompt **40**.
- **Falta capturar el QR desde la pantalla en Windows** para crear TOTP sin copiar el código. → prompt **80**.
- **Switch de "verificar filtraciones" no persiste** al cambiar de módulo. → prompt **30**.
- **Sidebar de escritorio mal organizada.** → prompt **70**.
