# ADR-0006: Sync P2P en la LAN, cifrada por mensaje, gana la última escritura

Estado: Vigente en la v1 (2026-07); en la v2 la reemplaza ADR-0010 · Decide: el dueño

## Contexto
Sin nube ([ADR-0001](0001-local-first-sin-nube.md)), el celular y la PC tienen que ponerse de acuerdo solos, en la misma red.

## Decisión
- El escritorio abre un **servidor WebSocket** (Shelf, desde el puerto 8283); el celular se **empareja con un QR** (IP, puerto,
  token de un uso y llave pública).
- **X25519 + HMAC-SHA256** dan una `K_sync` por dispositivo; **cada mensaje va cifrado con AES-256-GCM**.
- Conflictos: **gana la última escritura** (fecha, desempate por UUID), igual en los dos lados.
- Detalle: [`../arquitectura/ARQUITECTURA.md`](../arquitectura/ARQUITECTURA.md) §5.

## Consecuencias
- Solo sincroniza con los dos equipos encendidos y en la misma red.
- Si se edita lo mismo en los dos equipos sin conexión, gana el último y lo otro se pierde (sin historial de versiones).
- El canal es `ws://` sin TLS: el contenido va cifrado, pero se ven tamaños y horas (SEC-008, a decidir en SEG-1).

## Alternativas descartadas
Servidor propio o nube (rompe ADR-0001), Syncthing o carpetas compartidas (expone el archivo de la bóveda entero), CRDT (mucho
más complejo para un solo usuario con dos equipos), TLS con certificado fijado (planeado en junio, no construido; queda en SEG-1).
