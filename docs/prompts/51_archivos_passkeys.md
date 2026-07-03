# 51 · Archivos seguros y Passkeys

Dos pantallas relacionadas (puedes hacerlas en el mismo chat o separarlas):
`features/secure_files/presentation/secure_files_screen.dart` (+ provider
`secureFilesNotifierProvider`, DAO `secure_file_dao`, cifrado de archivos) y
`features/passkeys/presentation/passkeys_screen.dart` (respaldo cifrado de passkeys;
**hoy NO hay WebAuthn real**, solo almacenamiento de metadatos cifrados).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

## Archivos seguros
1. **UI/UX** — lista/grid con ícono por tipo de archivo, tamaño, fecha (relativa),
   favorito; `EmptyState` claro; drag-and-drop (ya hay `desktop_drop`) con feedback.
2. **Lógica** — cifrado/descifrado con progreso para archivos grandes; exportar con
   auth; límite de tamaño y aviso.
3. **Estados** — vacío/carga/error; conflicto de nombre al importar.
4. **Features:** (a) **previsualización** de imágenes/PDF descifrada en memoria;
   (b) **carpetas** para archivos; (c) **compartir** temporal seguro; (d) miniaturas.

## Passkeys
1. **UI/UX** — lista densa (servicio + RP ID), `EmptyState` que explique qué es un
   passkey, filas informativas (credential ID, verificación).
2. **Lógica** — es "respaldo"; deja claro que la clave privada no sale del
   dispositivo. Estados vacío/carga/error.
3. **Feature grande (evalúa esfuerzo):** **WebAuthn/FIDO2 real** vía Windows Hello /
   Android Credential Manager (registro y firma), no solo respaldo. Propón un plan
   por fases si lo abordas.

**Comunes:** i18n es/en, `Semantics` en íconos, tests de CRUD y estados.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; sube/descarga un
archivo y crea/borra un passkey de respaldo.

**Guardarraíles:** los archivos y metadatos van cifrados; no escribas contenido
descifrado a disco fuera de un export explícito con auth; respeta Zero-Print.
