# ADR-0003: Argon2id + AES-256-GCM sobre el payload completo

Estado: Vigente (2026-03-30) · Decide: el dueño

## Contexto
La bóveda debe resistir el robo del archivo y del equipo apagado, sin que el cifrado congele la interfaz.

## Decisión
- Clave derivada con **Argon2id** (64 MiB, 3 iteraciones, paralelismo 4, 32 bytes) y sal aleatoria de 32 bytes por bóveda
  (mínimos de OWASP).
- **AES-256-GCM** con nonce aleatorio por operación; formato `nonce ‖ ciphertext ‖ tag`.
- Se cifra **el payload entero** de cada credencial (JSON); en claro solo lo necesario para listar, ordenar y avisar de rotación.
- La contraseña maestra no se guarda ni hasheada: se verifica descifrando un dato de prueba.
- Todo lo costoso corre en un `Isolate`; la clave en RAM se pone a cero al bloquear.

## Consecuencias
- Abrir la bóveda tarda lo que Argon2id (a propósito). Cambiar parámetros o formato exige migración y vectores de prueba (CAL-2).
- Dart no permite borrar con garantía un `String`: la contraseña tecleada queda en memoria hasta que el recolector la libere
  (SEC-003, [`../seguridad/SEGURIDAD.md`](../seguridad/SEGURIDAD.md)). El núcleo en Rust de la v2 (DEC-1) lo atacaría.

## Alternativas descartadas
PBKDF2 (más débil ante GPU), cifrar columna por columna (filtra estructura), SQLCipher (otra dependencia nativa por plataforma).
