# Carril E · Calidad y seguridad

Reglas y plantilla: [`README.md`](README.md). Cómo se prueba: [`../proceso/PRUEBAS.md`](../proceso/PRUEBAS.md). Decisión:
[ADR-0011](../adr/0011-pruebas-e2e-principal.md) (E2E como red principal, unitarias solo en Rust) y
[ADR-0012](../adr/0012-todo-en-podman.md) (Podman).

Hecho: [`../archive/sesiones/E_HECHO.md`](../archive/sesiones/E_HECHO.md).

## Aprobado, para desarrollar (en orden)

| # | ID | Qué | Esf. | Estado | Detalle |
|---|---|---|---|---|---|
| 1 | CAL-5 | Harness E2E de la v2: Android en Podman (emulador sin pantalla o celular por adb en Wi-Fi), Windows en local con bóveda aislada y en `windows-latest`; gates nuevos en `PRUEBAS.md` | L | ☐ | [ver](#cal-5) |
| 2 | CAL-1 | E2E con la letra al 200% (Android `font_scale` 2.0; Windows escala de texto) y los dos temas, con datos largos, por pantalla | M | ☐ | Gate de cada PAN |
| 3 | SEG-1 | Modelo de amenazas de la v2 (RAM, disco, portapapeles, sync Noise, migración, importación) con la skill `security-audit` | M | ☐ | El informe anterior es de julio |
| 4 | SEG-2 | Fuzz en Rust (`cargo-fuzz` en Podman) de los parsers de fuera: CSV, `otpauth://`, `.skvault`, mensajes de sync | M | ☐ | Cuando A los tenga en el núcleo |

## Necesita de otros carriles

| De | Qué | Para |
|---|---|---|
| A | Directorio de datos configurable (NUC-6) | CAL-5: ninguna E2E toca la bóveda real |
| D | Imagen `solokey-build` con emulador (PLA-3) | CAL-5 en Android |

## No reabre

| Qué | Por qué |
|---|---|
| Correr `vault_e2e_test` a mano | Borra la bóveda real; solo con `run_integration_tests.ps1` (respalda y restaura) |
| Bajar `tool/coverage_min.txt` para que pase un cambio | Es un trinquete: solo sube (se retira cuando no queden pruebas Dart) |
| Nuevas pruebas unitarias o de widgets en Dart | ADR-0011: en la v2 solo E2E y unitarias de Rust |

## Detalle

### CAL-5

- Un flujo por PAN (C escribe la suya con este harness); los patrones anti-flaky de `PRUEBAS_INTEGRACION.md`.
- Android: emulador sin pantalla en la imagen de D (la VM de Podman tiene KVM) o el celular por `adb connect` en Wi-Fi. Nunca
  desinstalar la app del celular del dueño.
- Windows: `run_integration_tests.ps1` pasa a usar el directorio de datos aislado de NUC-6; deja de necesitar respaldar la
  bóveda real (se conserva el respaldo como cinturón).
- Reescribir `proceso/PRUEBAS.md` con la red nueva (§"La red", §"Gates") y actualizar `tests.yml`.
