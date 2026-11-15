# Pendientes del dueño

**Lo que solo tú puedes hacer o decidir.** Lo de las sesiones está en [`PENDIENTES_AGENTE.md`](PENDIENTES_AGENTE.md).
Cuando cierres algo, la sesión general lo quita de aquí. **Actualizado: 2026-11-15** (DEC-1 a DEC-10 de la v2 decididas: ADR
[0008 a 0013](adr/README.md)).

## ▶ Ahora

| ID | Qué | Para qué | Cómo |
|---|---|---|---|
| DUE-7 | Exportar la bóveda desde la app, en Windows **y** en el celular, y guardar los `.skvault` fuera del equipo | El respaldo de archivos del 2026-11-15 solo se restaura en esta PC con tu usuario de Windows (DPAPI) y no incluye el celular. El export se abre en cualquier equipo con tu contraseña | En la app: Ajustes, Exportar. Respaldo de archivos ya hecho: `%USERPROFILE%\SoloKey-respaldo-20261114-235706` (con `LEEME.txt` y huellas) |
| DUE-8 | Abrir la sesión **D** (fase 1) y, en paralelo, la **E** | Arranca la v2 | Prompts en [`PENDIENTES_AGENTE.md`](PENDIENTES_AGENTE.md) ▶ |

## Cuando puedas

| ID | Qué | Para qué | Cómo |
|---|---|---|---|
| DUE-3 | Guardar el respaldo de la llave de firma de Android cuando D la genere (PLA-1, aprobado) | Sin esa llave no se puede actualizar la app en la tienda ni en tu celular sin desinstalar | La sesión D te avisa; guárdala fuera del equipo y del repo |
| DUE-4 | Revisar las plantillas legales antes de publicarlas | Llevan notas para ti y campos entre corchetes | [`legal/PRIVACIDAD.md`](legal/PRIVACIDAD.md) y [`legal/TERMINOS.md`](legal/TERMINOS.md); idealmente con asesoría legal |
| DUE-2 | (Opcional) Probar la sync de la v1 con la PC y el celular (R1, M1, M3) | La v2 reescribe la sync (ADR-0010); sirve solo si quieres confiar en la v1 mientras tanto | [`proceso/PRUEBAS_EN_DISPOSITIVOS.md`](proceso/PRUEBAS_EN_DISPOSITIVOS.md) |

## En espera (sin fecha)

| ID | Qué | Lo destraba |
|---|---|---|
| DUE-5 | Cuentas de tienda (Google Play 25 USD una vez; Apple 99 USD al año) | Decidir publicar en tiendas ([`publicacion/PUBLICAR.md`](publicacion/PUBLICAR.md)) |
| DUE-6 | Mac o iPhone para empaquetar macOS e iOS | Tener el hardware (PLA-2) |
