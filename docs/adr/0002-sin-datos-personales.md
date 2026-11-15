# ADR-0002: Sin datos personales como tipo de registro

Estado: Vigente (2026-06-28) · Decide: el dueño

## Contexto
Otros gestores guardan tarjetas, identidades, cuentas bancarias y "acceso de emergencia". Eso amplía el riesgo legal y de
diseño (datos personales, herencia) sin ser el uso que el dueño busca.

## Decisión
SoloKey guarda **secretos de acceso**: contraseñas, API keys, notas seguras, TOTP, llaves SSH, passkeys (respaldo) y archivos
seguros. No habrá tipos "tarjeta", "identidad" o "banco", ni acceso de emergencia o herencia digital.

## Consecuencias
El usuario puede guardar lo que quiera en una nota segura, pero la app no lo modela ni le da pantallas propias.

## Alternativas descartadas
Tipos de tarjeta e identidad con autocompletado de formularios.
