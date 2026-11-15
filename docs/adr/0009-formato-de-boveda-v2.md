# ADR-0009: Formato de bóveda propio de la v2, con migración única desde la v1

Estado: Vigente (2026-11-15) · Decide: el dueño · Reemplaza a [ADR-0005](0005-datos-en-sqlite-con-payload-cifrado.md) en la v2

## Contexto
El formato de la v1 (drift, `vault_guard_db` v10) deja en claro el tipo, la carpeta, las fechas y el orden de cada registro, no
tiene versión propia del formato y lo maneja Dart. Con el núcleo en Rust ([ADR-0008](0008-nucleo-en-rust.md)) el formato pasa a ser
suyo. Se discutió leer el v1 primero y migrar después; el dueño eligió formato nuevo desde el inicio.

## Decisión
- La v2 usa un **formato propio desde su primer arranque**, definido y manejado por `solokey-core`:
  - **Cabecera versionada** (versión del formato y parámetros de KDF), para migrar en el futuro sin adivinar.
  - **Lo mínimo en claro**: id y versión de cada registro. Tipo, carpeta, fechas y orden van **cifrados**.
  - Sigue siendo SQLite (vía `rusqlite`): robusto y con migraciones; el nombre del archivo deja de ser `vault_guard_db`.
- **Migración única**: al primer arranque la v2 lee la bóveda v1, hace **una copia automática antes de tocar nada**, convierte,
  verifica que todo descifra igual y solo entonces da la v1 por migrada. Si algo falla, se queda la v1 intacta.
- La lectura de la v1 se prueba con **vectores de prueba generados por la app v1** (CAL-2) y con una copia de una bóveda real,
  nunca con la real.

## Consecuencias
- Quien roba el archivo ya no ve qué tipo de secretos hay ni cuándo cambiaron.
- Listar y buscar exige descifrar los metadatos en RAM al desbloquear (índice en memoria del núcleo, con `zeroize` al bloquear).
- No hay vuelta atrás automática a la v1 una vez migrada: la copia previa y el export `.skvault` son la red.

## Alternativas descartadas
Leer el v1 para siempre (arrastra metadatos en claro y sin versión), y leer el v1 primero y migrar después (más seguro, pero el
dueño prefirió no pasar por un paso intermedio).
