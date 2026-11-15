# Decisiones de arquitectura (ADR)

Una decisión que cuesta revertir, con su porqué. **No se reescriben**: si cambia, se agrega una nueva que la reemplaza y la vieja
pasa a *Reemplazada por ADR-XXXX*. Las decisiones de la v2 (DEC-1 a DEC-10 de
[`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md)) se aprobaron el 2026-11-15 (0008 a 0013). La siguiente libre es la 0014.

| ADR | Decisión | Estado |
|---|---|---|
| [0001](0001-local-first-sin-nube.md) | Local-first: sin servidor, sin cuentas, sync solo P2P en la LAN | Vigente (2026-03) |
| [0002](0002-sin-datos-personales.md) | Sin datos personales como tipo: ni tarjetas, ni identidades, ni herencia digital | Vigente (2026-06) |
| [0003](0003-cifrado-de-la-boveda.md) | Argon2id + AES-256-GCM sobre el payload completo, en un isolate | Vigente (2026-03); en la v2 lo ejecuta Rust (0008) |
| [0004](0004-un-solo-codigo-flutter.md) | Un solo código Flutter para Android y Windows; Windows con instalador | Vigente (2026-07) |
| [0005](0005-datos-en-sqlite-con-payload-cifrado.md) | drift sobre SQLite con el payload cifrado en un BLOB; llaves en el almacén seguro | v1; en la v2 la reemplaza 0009 |
| [0006](0006-sync-p2p-en-la-lan.md) | Sync P2P en la LAN: QR, X25519, AES-GCM por mensaje, gana la última escritura | v1; en la v2 la reemplaza 0010 |
| [0007](0007-red-de-calidad-y-ci.md) | Hooks, trinquete de cobertura y CI en runners de GitHub (repo público: sin runners propios) | v1; en la v2 la reemplaza 0011 |
| [0008](0008-nucleo-en-rust.md) | v2: núcleo en Rust (`solokey-core`) con interfaz Flutter, sin prototipo previo | Vigente (2026-11-15) |
| [0009](0009-formato-de-boveda-v2.md) | v2: formato de bóveda propio y versionado, metadatos cifrados, migración única desde la v1 | Vigente (2026-11-15) |
| [0010](0010-sync-v2-canal-cifrado.md) | v2: sync con el canal entero cifrado (Noise) y protocolo versionado; v1 y v2 no se mezclan | Vigente (2026-11-15) |
| [0011](0011-pruebas-e2e-principal.md) | v2: E2E en Android y Windows como red principal; unitarias solo en Rust | Vigente (2026-11-15) |
| [0012](0012-todo-en-podman.md) | Todo se compila y se prueba en Podman; en el host solo lo que Windows exige | Vigente (2026-11-15) |
| [0013](0013-diseno-idioma-y-experiencia-v2.md) | v2: Tinta y papel, Atkinson Hyperlegible, dos temas, español fuente, sin vibraciones, logo redibujado | Vigente (2026-11-15) |

## Plantilla

```markdown
# ADR-XXXX: <decisión en una línea>

Estado: Propuesta | Vigente (AAAA-MM-DD) | Reemplazada por ADR-YYYY
Decide: el dueño

## Contexto
## Decisión
## Consecuencias
## Alternativas descartadas
```
