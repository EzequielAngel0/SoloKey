# Carril E · Calidad y seguridad

Reglas y plantilla: [`README.md`](README.md). Cómo se prueba: [`../proceso/PRUEBAS.md`](../proceso/PRUEBAS.md).

## Aprobado, para desarrollar (en orden)

Nada aprobado todavía.

## Propuestas de la sesión (◇)

| ID | Qué | Para qué | Esf. |
|---|---|---|---|
| CAL-1 ◇ | `test/letra_200_test.dart`: cada pantalla con `textScaler` 2.0, datos largos y los dos temas, sin desbordes | Gate de la v2 | M |
| CAL-2 ◇ | Vectores de prueba de la v1 (KDF, cifrado, verificación, payload) versionados en `test/fixtures/` | Que la v2 (Dart o Rust) demuestre que abre bóvedas de la v1 | S |
| CAL-3 ◇ | Reproducir CI en Linux con Podman (`tool/ci-linux.ps1`, lee la versión de `tests.yml`) | Rojo en CI y verde en local = el SO; hoy solo hay receta en PRUEBAS.md | S |
| SEG-1 ◇ | Modelo de amenazas de la v2 (RAM, disco, portapapeles, sync en la LAN, importación) y revisión con la skill `security-audit` | Que el rediseño no abra huecos; el informe anterior es de julio | M |
| SEG-2 ◇ | Fuzz de los parsers que reciben datos de fuera: CSV de importación, `otpauth://`, `.skvault`, mensajes de sync | Un archivo o un par malicioso no debe tumbar ni filtrar | M |

## Necesita de otros carriles

Nada por ahora.

## No reabre

| Qué | Por qué |
|---|---|
| Correr `vault_e2e_test` a mano | Borra la bóveda real; solo con `run_integration_tests.ps1` (respalda y restaura) |
| Bajar `tool/coverage_min.txt` para que pase un cambio | Es un trinquete: solo sube |
