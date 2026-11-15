# Carril D · Plataforma y entrega

Reglas y plantilla: [`README.md`](README.md). Build: `.\build_release.ps1` (nunca `flutter build windows` suelto; el entregable de
Windows es el instalador de Inno Setup). Herramientas: [ADR-0012](../adr/0012-todo-en-podman.md) (todo en Podman, nada nuevo en
el host).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | PLA-5 | Renombrar el paquete Dart `password_manager` a `solokey` (imports, `pubspec.yaml`, CI) | S | ☐ | **Solo, sin otro carril tocando código**: cambia casi todos los archivos |
| 2 | PLA-4 | Subir dependencias mayores (Riverpod 3, go_router 18, freezed 3, flutter_secure_storage 11, local_auth 3, `window_manager`, `tray_manager`, drift 2.35) | L | ☐ | [ver](#pla-4) |
| 3 | PLA-6 | `tool/escanear-deps.ps1`: OSV-Scanner en Podman sobre `pubspec.lock` y `Cargo.lock` | S | ☐ | [ver](#pla-6) |
| 4 | PLA-3 | Imagen `solokey-build` en Podman (Flutter, SDK y NDK de Android, Rust, `cargo-ndk`, `cargo-xwin`); APK y DLL del núcleo salen de ahí; CI con Rust, E2E de Android y `windows-latest` | L | ☐ | [ver](#pla-3) |
| 5 | PLA-1 | Firma de release de Android (keystore propio fuera del repo, `key.properties` ignorado; el dueño guarda el respaldo) | M | ☐ | Antes de la v2.0.0 |

## En espera

| ID | Qué | Esf. | Lo destraba |
|---|---|---|---|
| PLA-2 | Empaquetado macOS, Linux e iOS | XL | Hardware; diferido por el dueño |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| A | Estructura de `rust/` (NUC-1) | PLA-3 y el `Cargo.lock` de PLA-6 |

## No reabre

| Qué | Por qué |
|---|---|
| `-ExecutionPolicy Bypass` en los scripts | Lo bloquea el clasificador; `RemoteSigned` ya permite los `.ps1` locales |
| `rustup`, NDK o SDK nuevos en el host | ADR-0012 |
| Betas intermedias publicadas | DEC-10: solo la v2.0.0 al final |

## Detalle

### PLA-4

- Una rama, una mayor por commit, cada una con analyze y pruebas en verde. Leer el CHANGELOG de cada paquete antes.
- Escaneo de seguridad del 2026-11-15 (OSV-Scanner v2.2.1, 203 paquetes): **sin vulnerabilidades conocidas**. Es mantenimiento.
- `drift`, `cryptography` y `shelf*` se van con el núcleo Rust: subirlos solo si lo exige otra dependencia.
- `flutter_secure_storage` 11: comprobar que sigue leyendo el `.dat` de la v1 (DPAPI) antes de mergear; probar con una copia.

### PLA-6

Comando probado el 2026-11-15:
`podman run --rm --name solokey-osv -v "<repo>/pubspec.lock:/src/pubspec.lock:ro" ghcr.io/google/osv-scanner:v2.2.1 scan source --lockfile /src/pubspec.lock`
(con `MSYS_NO_PATHCONV=1` en Git Bash). El script borra la imagen al final si se le pide y se documenta en `proceso/PRUEBAS.md`.

### PLA-3

- La VM de Podman tiene `/dev/kvm`: el emulador de Android corre sin pantalla dentro del contenedor.
- Volúmenes con nombre para el caché de Pub, Gradle, Cargo y el SDK (`solokey-pub`, `solokey-gradle`, `solokey-cargo`,
  `solokey-android-sdk`), y el comando de limpieza en `proceso/PRUEBAS.md`.
- `build_release.ps1 -Target android` usa la imagen; `-Target windows|inno` sigue en el host con la DLL que dejó el contenedor.
