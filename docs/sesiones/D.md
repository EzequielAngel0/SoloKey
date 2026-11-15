# Carril D · Plataforma y entrega

Reglas y plantilla: [`README.md`](README.md). Build: `.\build_release.ps1` (nunca `flutter build windows` suelto; el entregable de
Windows es el instalador de Inno Setup).

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía.

## En espera

| ID | Qué | Esf. | Lo destraba |
|---|---|---|---|
| PLA-1 | Firma de release de Android (keystore propio fuera del repo, `key.properties` ignorado); hoy los APK van con la clave debug | M | El dueño la pospuso (2026-07-18): avisa cuándo |
| PLA-2 | Empaquetado macOS, Linux e iOS | XL | Hardware; diferido por el dueño |
| PLA-3 | Toolchain de Rust (rustup, MSVC, `cargo-ndk`) en el host y paso de Rust en CI | M | DEC-1 = R1 (o NUC-0 aprobado) |

## Propuestas de la sesión (◇)

| ID | Qué | Para qué | Esf. |
|---|---|---|---|
| PLA-4 ◇ | Subir dependencias mayores (Riverpod 2 a 3, go_router 14 a la actual, freezed 2 a 3, `window_manager`, `tray_manager`) en una rama, antes de rehacer pantallas | No rehacer la interfaz sobre APIs que van a cambiar; medir primero con `flutter pub outdated` | L |
| PLA-5 ◇ | Renombrar el paquete Dart `password_manager` a `solokey` (imports) | Coherencia; el `applicationId` ya es `com.angelezequiel.solokey` | S |
| PLA-6 ◇ | Escaneo de dependencias con OSV-Scanner en Podman sobre `pubspec.lock` (y `Cargo.lock` si hay Rust) para la sesión general | Que la sesión general vea lo vulnerable con un comando | S |

## No reabre

| Qué | Por qué |
|---|---|
| `-ExecutionPolicy Bypass` en los scripts | Lo bloquea el clasificador; `RemoteSigned` ya permite los `.ps1` locales |
