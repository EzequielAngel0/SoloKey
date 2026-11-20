# Carril D · Hecho

Lo terminado del carril D ([`../../sesiones/D.md`](../../sesiones/D.md)), una o dos líneas por ID. Detalle técnico en
[`../../../CHANGELOG.md`](../../../CHANGELOG.md).

| ID | Qué | Fecha | Verificado |
|---|---|---|---|
| PLA-5 | Paquete Dart `password_manager` → `solokey` (`pubspec.yaml` + 89 imports); `Runner.rc`, `BINARY_NAME` y `applicationId` intactos | 2026-11-15 | analyze 0, 510 pruebas, la app de Windows abre la bóveda real |
| PLA-4 | Dependencias mayores: go_router 18, local_auth 3, flutter_secure_storage 10, Riverpod 3, freezed 3.2, file_picker 11, get_it 9 y el resto; fuera `context_menus` y `screen_protector` | 2026-11-19 | analyze 0, 510 pruebas, migración v9 → v10 y desbloqueo en el emulador, APK release limpio, build de Windows |
| PLA-6 | `tool/escaneo-deps.ps1`: OSV-Scanner en Podman + `pub outdated` + Dependabot, salida 0/2/1 | 2026-11-19 | las tres salidas vistas (2 bajando el umbral, 1 con una imagen que no existe) y el resultado del día reutilizado |
| PLA-3 | Imagen `solokey-build` (etapas Rust, Flutter y SDK en paralelo) y `solokey-e2e` con emulador; `tool/build.ps1` (APK, `-Nucleo`, `-E2e`); `build_release.ps1 -Target android` por Podman; jobs `rust` y `e2e-android` en el CI; fuera `rust/Containerfile` | 2026-11-19 | APK release y entregable de Android desde el contenedor, las dos E2E verdes en el emulador del contenedor, clippy limpio, `.so` de tres ABI y DLL, CI verde |
| PLA-3 (fix) | El build en Podman firma con la llave debug del host (montada en solo lectura): el APK se instala encima del del celular | 2026-11-20 | certificado SHA-256 del APK del contenedor igual al de `debug.keystore` del host |
