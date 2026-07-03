# 41 · Transferencia (exportar / importar)

Enfócate SOLO en `features/vault_transfer/presentation/transfer_screen.dart` (+
`widgets/export_tree.dart`), `core/services/vault_export_service.dart` (formato
cifrado `.skvault`, con zeroing de la export key), y `core/services/csv_import_
service.dart` (Bitwarden / 1Password / Chrome). Se llega desde `Ajustes → Transferir
datos` (escritorio y móvil) y desde el hub de Seguridad (móvil).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **UI/UX** — dos modos claros (Exportar / Importar) con pasos y estados
   (seleccionando · procesando · éxito/resumen · error). `export_tree` debe permitir
   **seleccionar qué exportar** (por carpeta/tipo) con contadores. Import: previsualiza
   cuántos ítems y detecta duplicados antes de aplicar.
2. **Navegación** — accesible desde Ajustes en ambas plataformas (verifícalo) y con
   feedback de dónde quedó el archivo exportado (share/file_picker).
3. **Lógica/seguridad** — el `.skvault` es el **único backup restaurable** (cifrado
   con Argon2id + AES-GCM y la master key). Asegura zeroing de la export key tras
   usarla (ya existe); valida contraseña/objetivo antes de importar; maneja archivos
   corruptos con error claro.
4. **Estados/errores** — mensajes accionables (formato no soportado, archivo
   corrupto, sin permisos).
5. **i18n/a11y** — todo en `.arb`.
6. **Tests** — round-trip export→import preserva credenciales/carpetas/tipos;
   import CSV de cada formato mapea bien; el zeroing ocurre.

**Features propuestas (elige 3–5):** (a) **backup programado** a carpeta elegida
(ya hay `scheduled_backup_service` — intégralo y hazlo visible); (b) **exportación
selectiva por tipo/carpeta** (usar `export_tree`); (c) **importar TOTP** desde
`otpauth://`/Google Authenticator; (d) **verificación de integridad** (hash) del
`.skvault`; (e) **recordatorio de backup** si hace mucho que no exportas (enlaza con
el prompt de desinstalación que ofrece exportar).

**Verificación:** `flutter analyze` 0 + `flutter test` verde; exporta un `.skvault`,
bórralo de la app e impórtalo de vuelta; prueba un CSV real.

**Guardarraíles:** no cambies el formato `.skvault` sin versionar/migrar; nunca
escribas secretos en texto plano a disco; respeta la Zero-Print Policy.
