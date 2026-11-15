# ADR-0001: Local-first, sin servidor ni cuentas

Estado: Vigente (2026-03-30) · Decide: el dueño

## Contexto
Un gestor de contraseñas con nube concentra el riesgo en un servidor ajeno y exige cuentas, pagos y disponibilidad. El dueño
quiere control total de sus datos.

## Decisión
- La bóveda vive solo en los equipos del usuario. No hay backend, cuentas, telemetría ni analítica.
- Entre dispositivos se sincroniza **P2P en la red local**, cifrado de extremo a extremo (`../arquitectura/ARQUITECTURA.md` §5).
- Única salida a internet: HaveIBeenPwned, **opcional** y por k-anonimato (5 caracteres del SHA-1), y los favicons de marcas.

## Consecuencias
- Si el usuario pierde todos sus equipos y su respaldo, pierde la bóveda: por eso existen el código de recuperación, el export
  `.skvault` y el respaldo programado.
- Sin push del servidor: avisos y aprobaciones entre equipos viajan por el canal P2P.

## Alternativas descartadas
Nube propia o de terceros (Bitwarden-like), relay en internet para la sync.
