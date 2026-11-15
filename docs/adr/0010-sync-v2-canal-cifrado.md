# ADR-0010: Sync de la v2 con el canal entero cifrado y protocolo versionado

Estado: Vigente (2026-11-15) · Decide: el dueño · Reemplaza a [ADR-0006](0006-sync-p2p-en-la-lan.md) en la v2

## Contexto
En la v1 cada mensaje va cifrado, pero el canal es `ws://`: en la red se ven tamaños, horas y la forma del intercambio (SEC-008).
La v2 reescribe la sync en el núcleo Rust, así que puede cerrar ese hueco sin costo extra.

## Decisión
- Se conserva lo bueno de la v1: **P2P en la LAN**, emparejamiento por **QR** y **gana la última escritura**.
- **El canal entero va cifrado y autenticado** con las llaves fijadas en el emparejamiento (protocolo Noise; el carril A elige el
  patrón y documenta el porqué en `arquitectura/`). Nada viaja en claro salvo el descubrimiento en la red.
- **Protocolo versionado** desde el primer mensaje. Un equipo v1 con uno v2 **no se mezclan**: la app dice claro que hay que
  actualizar los dos.

## Consecuencias
- SEC-008 se cierra en la v2.
- Durante la transición, la PC y el celular deben actualizarse juntos para seguir sincronizando.

## Alternativas descartadas
Reimplementar el protocolo de la v1 tal cual (compatible, pero deja SEC-008 abierto), TLS con certificado autofirmado (más piezas
que Noise para el mismo resultado entre dos equipos que ya se conocen).
