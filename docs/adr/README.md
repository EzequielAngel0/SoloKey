# Decisiones de arquitectura (ADR)

Una decisión que cuesta revertir, con su porqué. **No se reescriben**: si cambia, se agrega una nueva que la reemplaza y la vieja
pasa a *Reemplazada por ADR-XXXX*. Las decisiones de la v2 (DEC-1 a DEC-6 de
[`../diseno/REDISENO_V2.md`](../diseno/REDISENO_V2.md)) entran aquí cuando el dueño las apruebe (la siguiente libre es la 0008).

| ADR | Decisión | Estado |
|---|---|---|
| [0001](0001-local-first-sin-nube.md) | Local-first: sin servidor, sin cuentas, sync solo P2P en la LAN | Vigente (2026-03) |
| [0002](0002-sin-datos-personales.md) | Sin datos personales como tipo: ni tarjetas, ni identidades, ni herencia digital | Vigente (2026-06) |
| [0003](0003-cifrado-de-la-boveda.md) | Argon2id + AES-256-GCM sobre el payload completo, en un isolate | Vigente (2026-03) |
| [0004](0004-un-solo-codigo-flutter.md) | Un solo código Flutter para Android y Windows; Windows con instalador | Vigente (2026-07) |
| [0005](0005-datos-en-sqlite-con-payload-cifrado.md) | drift sobre SQLite con el payload cifrado en un BLOB; llaves en el almacén seguro | Vigente (2026-03) |
| [0006](0006-sync-p2p-en-la-lan.md) | Sync P2P en la LAN: QR, X25519, AES-GCM por mensaje, gana la última escritura | Vigente (2026-07) |
| [0007](0007-red-de-calidad-y-ci.md) | Hooks, trinquete de cobertura y CI en runners de GitHub (repo público: sin runners propios) | Vigente (2026-07) |

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
