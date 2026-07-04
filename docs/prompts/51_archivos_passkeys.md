# 51 · Archivos seguros y Passkeys

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/51_archivos_passkeys.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

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

**Tests (obligatorio):**

- **Archivos seguros — lógica de import** → extiende
  `test/features/secure_files/secure_file_import_test.dart` (límite de tamaño,
  dedupe de nombre, cifrado/descifrado round-trip; nunca vuelques bytes en claro).
- **Archivos seguros — pantalla/estados** → extiende
  `test/features/secure_files/secure_files_screen_test.dart` (vacío/carga/error,
  `EmptyState`, auth antes de exportar/previsualizar). Usa el harness
  `test/support/widget_harness.dart`.
- **Passkeys — pantalla** → extiende
  `test/features/passkeys/passkeys_screen_test.dart` (lista densa, `EmptyState`
  explicativo, copiar Credential ID). Si añades WebAuthn real, crea un unit test
  del flujo de registro/firma con un authenticator fake (no toques la red).

**Verificación:** `flutter analyze` 0 + `flutter test` verde; sube/descarga un
archivo y crea/borra un passkey de respaldo.

**Guardarraíles:** los archivos y metadatos van cifrados; no escribas contenido
descifrado a disco fuera de un export explícito con auth; respeta Zero-Print.
