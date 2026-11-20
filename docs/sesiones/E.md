# Carril E · Calidad y seguridad

Reglas y plantilla: [`README.md`](README.md). Cómo se prueba: [`../proceso/PRUEBAS.md`](../proceso/PRUEBAS.md). Decisión:
[ADR-0011](../adr/0011-pruebas-e2e-principal.md) (E2E como red principal, unitarias solo en Rust) y
[ADR-0012](../adr/0012-todo-en-podman.md) (Podman).

Hecho: [`../archive/sesiones/E_HECHO.md`](../archive/sesiones/E_HECHO.md).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | CAL-5 | Harness E2E de la v2: Android en Podman (emulador sin pantalla o celular por adb en Wi-Fi), Windows en local con bóveda aislada y en `windows-latest`; gates nuevos en `PRUEBAS.md` | L | ◐ CI de Windows hecho (`windows-2022`); Android espera a PLA-3, Windows local a NUC-6 | [ver](#cal-5) |
| 2 | CAL-1 | E2E con la letra al 200% (Android `font_scale` 2.0; Windows escala de texto) y los dos temas, con datos largos, por pantalla | M | ⊘ espera a las PAN de C y al harness Android de CAL-5 | Gate de cada PAN |
| 3 | SEG-2 | Fuzz en Rust (`cargo-fuzz` en Podman) de los parsers de fuera: CSV, `otpauth://`, `.skvault`, mensajes de sync | M | ◐ sync, código de recuperación y cabecera hechos; CSV, `otpauth://` y `.skvault` esperan a sus parsers en el núcleo (A) | [ver](#seg-2) |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| A | Directorio de datos configurable (NUC-6) | CAL-5: ninguna E2E toca la bóveda real |
| D | Imagen `solokey-build` con emulador (PLA-3) | CAL-5 en Android |
| A | Acotar los parámetros de Argon2id al leer la cabecera (SEC-012) | SEG-2: que `cabecera_kdf` pase a verde |
| A | Parsers de CSV, `otpauth://` y `.skvault` en el núcleo | SEG-2: sus objetivos de fuzz |

## No reabre

| Qué | Por qué |
|---|---|
| Correr `vault_e2e_test` a mano | Borra la bóveda real; solo con `run_integration_tests.ps1` (respalda y restaura) |
| Bajar `tool/coverage_min.txt` para que pase un cambio | Es un trinquete: solo sube (se retira cuando no queden pruebas Dart) |
| Nuevas pruebas unitarias o de widgets en Dart | ADR-0011: en la v2 solo E2E y unitarias de Rust |

## Detalle

### CAL-5

- Hecho (2026-11-15): job `e2e-windows` de `tests.yml` en `windows-2022` (VS 2022 como el release; runner desechable: `app_boot_test` y dos corridas de
  `vault_e2e_test`, cada una en su paso).
- Un flujo por PAN (C escribe la suya con este harness); los patrones anti-flaky de `PRUEBAS_INTEGRACION.md`.
- Android: emulador sin pantalla en la imagen de D (la VM de Podman tiene KVM) o el celular por `adb connect` en Wi-Fi. Nunca
  desinstalar la app del celular del dueño.
- Windows: `run_integration_tests.ps1` pasa a usar el directorio de datos aislado de NUC-6; deja de necesitar respaldar la
  bóveda real (se conserva el respaldo como cinturón).
- Reescribir `proceso/PRUEBAS.md` con la red nueva (§"La red", §"Gates") cuando haya pruebas de la v2 que poner en ella.

### SEG-2

- Hecho (2026-11-19): `rust/fuzz.ps1` y el crate `rust/solokey-core/fuzz` (cómo se corre: [`PRUEBAS.md`](../proceso/PRUEBAS.md)).
  `sync_trama`, `sync_mensaje`, `codigo_recuperacion` y `cabecera_boveda` verdes; `cabecera_kdf` rojo por SEC-012 (de A).
- Falta: un objetivo por parser cuando A los pase al núcleo (CSV, `otpauth://`, `.skvault`), con semillas reales de la v1
  (`vectores/v1/`). Al acotar SEC-012, revisar que `sync_mensaje` (crea su bóveda con 64 KiB para ir rápido) siga pudiendo.
- No se cubre con fuzz: la doble envoltura, la migración y el descifrado del canal (cada entrada exige Argon2id o cripto válida;
  los cubren las pruebas de A con los vectores).
