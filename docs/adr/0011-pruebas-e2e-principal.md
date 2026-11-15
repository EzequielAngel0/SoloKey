# ADR-0011: E2E como red principal; pruebas unitarias solo en Rust

Estado: Vigente (2026-11-15) · Decide: el dueño · Reemplaza a [ADR-0007](0007-red-de-calidad-y-ci.md) en la v2

## Contexto
La v1 tiene ~30 k líneas de pruebas unitarias y de widgets en Dart, casi todas sobre código que la v2 reescribe. Lo que el dueño
quiere saber es si la app funciona de verdad en sus dos equipos. Lo que protege sus contraseñas (cifrado, formato, migración) se
mueve a Rust ([ADR-0008](0008-nucleo-en-rust.md)).

## Decisión
- **La red de la v2 son pruebas E2E por flujo**, en **Android y Windows**: la app real, de punta a punta.
- **Se borran todas las pruebas unitarias y de widgets de Dart**, pero **al reescribir cada parte**, en la misma rama donde entra
  su E2E. La v1 nunca se queda sin red a medio camino.
- **Solo quedan pruebas unitarias en Rust** (`cargo test`, en Podman): cripto con vectores, formato, migración desde la v1, sync y
  parsers (con fuzz). Es lo que una E2E no ve.
- Dónde corren ([ADR-0012](0012-todo-en-podman.md)):

  | Qué | Dónde |
  |---|---|
  | `cargo test`, fuzz y cobertura de Rust | Podman, en local y en CI |
  | E2E de Android | Podman con emulador sin pantalla (la VM tiene KVM), o el celular por adb en Wi-Fi |
  | E2E de Windows | En local con el Flutter del host, **con una bóveda de prueba aislada**, y en el runner `windows-latest` de GitHub |

- **La v2 nace con un directorio de datos configurable** para las E2E: ninguna prueba puede tocar la bóveda real del dueño.
- Gates nuevos (los fija el carril E en `proceso/PRUEBAS.md`): `flutter analyze` en 0 y `cargo test` verde antes de cada commit;
  las E2E en CI en cada push a `develop`; trinquete de cobertura sobre Rust. El trinquete de Dart se retira cuando no queden
  pruebas Dart.

## Consecuencias
- La CI tarda más (emulador y Windows) y una E2E falla a veces por causas ajenas: se aplican los patrones anti-flaky de
  [`../proceso/PRUEBAS_INTEGRACION.md`](../proceso/PRUEBAS_INTEGRACION.md) en vez de subir timeouts.
- Un error de lógica de interfaz se ve más tarde (en la E2E, no en segundos).
- Se mantiene de ADR-0007: hooks versionados, nunca `--no-verify`, runners de GitHub (repo público, sin runners propios).

## Alternativas descartadas
Todo E2E sin ninguna unitaria (un error de cifrado o de migración en un caso raro corrompería una bóveda sin que nada lo vea),
y conservar la pirámide de la v1 rehecha para la v2.
