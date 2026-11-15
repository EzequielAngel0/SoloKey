# Carril E · Hecho

Lo terminado del carril E (Calidad y seguridad), una o dos líneas por ID. Lo abierto: [`../../sesiones/E.md`](../../sesiones/E.md).

| ID | Qué | Cuándo |
|---|---|---|
| CAL-4 | `run_integration_tests.ps1` respalda y restaura con hash `secure_files\` y el `.dat` de la identidad actual (la regex de `Runner.rc` no la leía); falla cerrado y sale con 2 si algo no vuelve igual. Prueba: `tool\probar-respaldo-boveda.ps1` | 2026-11-15 |
| CAL-3 | `tool\ci-linux.ps1`: el CI de Linux de `tests.yml` en Podman (imagen propia `solokey-ci-linux`, cirruslabs no tiene la 3.44.4); visto en rojo con un fallo a propósito y con las comillas rotas de PowerShell 5.1 | 2026-11-15 |
