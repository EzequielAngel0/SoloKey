# Carril D · Hecho

Lo terminado del carril D ([`../../sesiones/D.md`](../../sesiones/D.md)), una o dos líneas por ID. Detalle técnico en
[`../../../CHANGELOG.md`](../../../CHANGELOG.md).

| ID | Qué | Fecha | Verificado |
|---|---|---|---|
| PLA-5 | Paquete Dart `password_manager` → `solokey` (`pubspec.yaml` + 89 imports); `Runner.rc`, `BINARY_NAME` y `applicationId` intactos | 2026-11-15 | analyze 0, 510 pruebas, la app de Windows abre la bóveda real |
| PLA-4 | Dependencias mayores: go_router 18, local_auth 3, flutter_secure_storage 10, Riverpod 3, freezed 3.2, file_picker 11, get_it 9 y el resto; fuera `context_menus` y `screen_protector` | 2026-11-19 | analyze 0, 510 pruebas, migración v9 → v10 y desbloqueo en el emulador, APK release limpio, build de Windows |
| PLA-6 | `tool/escaneo-deps.ps1`: OSV-Scanner en Podman + `pub outdated` + Dependabot, salida 0/2/1 | 2026-11-19 | las tres salidas vistas (2 bajando el umbral, 1 con una imagen que no existe) y el resultado del día reutilizado |
