# ADR-0007: Red de calidad local con trinquete de cobertura y CI en máquinas de GitHub

Estado: Vigente (2026-07; runners confirmados el 2026-11-14) · Decide: el dueño

## Contexto
Un gestor de contraseñas no puede romper la bóveda en una actualización, y lo desarrollan agentes en paralelo.

## Decisión
- **Hooks versionados** en `.githooks/`: el pre-commit corre `flutter analyze` y `flutter test` si hay `.dart`; el pre-push, la
  cobertura. Nunca `--no-verify`.
- **Trinquete de cobertura**: el piso de `tool/coverage_min.txt` solo sube.
- **CI** (`.github/workflows/tests.yml`) en **runners de GitHub** (`ubuntu-latest`), en cada push a `main` y `develop` y en cada PR.
- Las pruebas de integración (necesitan dispositivo) se corren a demanda en Windows con `run_integration_tests.ps1`, que respalda
  la bóveda real del dueño. Las de dispositivo (celular, emulador), con el método de [`../proceso/PRUEBAS.md`](../proceso/PRUEBAS.md).

## Consecuencias
- El commit tarda lo que tarda la suite; a cambio, `develop` casi nunca está en rojo.
- Rojo en CI y verde en local suele ser el sistema operativo: se reproduce en un contenedor Linux con el mismo SDK.

## Alternativas descartadas
**Runners propios** (en el equipo del dueño, encendidos bajo demanda): en un **repo público** cualquiera puede abrir una PR que
corra código en esa máquina, y los de GitHub son gratis en repos públicos. Se reconsideran solo si el repo pasa a privado.
