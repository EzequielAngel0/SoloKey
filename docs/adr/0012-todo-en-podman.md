# ADR-0012: Todo se compila y se prueba en Podman; nada nuevo en el host

Estado: Vigente (2026-11-15) · Decide: el dueño

## Contexto
Regla del dueño para todos sus proyectos: lo instalado en Windows deja restos que no se limpian; lo de Podman se borra con un
comando. La v2 suma Rust, el NDK y emuladores, y la idea era instalar `rustup` en el host. El dueño lo descartó: todo se prueba
dentro de Podman.

## Decisión
- **No se instala nada nuevo en el host.** Rust, `cargo-ndk`, `cargo-xwin`, el SDK y el NDK de Android y el emulador viven en
  imágenes de Podman con prefijo `solokey-` y volúmenes con nombre.
- Lo que corre en contenedor:

  | Qué | Cómo |
  |---|---|
  | Núcleo Rust: `cargo test`, fuzz, cobertura | Imagen de Rust |
  | APK de Android con el núcleo | Imagen de build (Flutter + SDK y NDK de Android + Rust + `cargo-ndk`) |
  | DLL del núcleo para Windows | Compilación cruzada con `cargo-xwin` en la misma imagen |
  | E2E de Android | Emulador sin pantalla dentro de Podman (la VM tiene `/dev/kvm`) |
  | Escaneo de dependencias | OSV-Scanner (PLA-6) |
  | CI de Linux en local | Imagen con el SDK de `tests.yml` (CAL-3) |

- **Excepciones, por qué no hay otra forma**: una app de Windows no se compila ni corre en un contenedor Linux. Quedan en el host,
  como ya estaban: **Flutter SDK, Visual Studio 2022 (C++)** e **Inno Setup 6** para compilar, probar (E2E local con bóveda
  aislada) y empaquetar Windows; **adb** de platform-tools para el celular por USB.
- Cada imagen y su comando de limpieza quedan en [`../proceso/PRUEBAS.md`](../proceso/PRUEBAS.md).

## Consecuencias
- El primer build de Android en Podman descarga varios GB (SDK, NDK, Rust): se guardan en volúmenes con nombre para no repetirlo.
- El APK de entrega también sale del contenedor; `build_release.ps1` lo orquesta (carril D).
- El SDK de Android del host deja de hacer falta para compilar; si se quita, se decide aparte con el dueño.

## Alternativas descartadas
`rustup` y el NDK en el host (lo que preveía la propuesta original de la v2), y compilar Windows solo en CI (el dueño quiere poder
probar Windows en su PC).
