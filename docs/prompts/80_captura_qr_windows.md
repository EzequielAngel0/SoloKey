# 80 · Captura de QR desde la pantalla (Windows) para crear TOTP

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/80_captura_qr_windows.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

**Feature nueva.** En Windows no hay cámara práctica para escanear el QR de un TOTP,
así que el usuario tiene que copiar el secreto a mano. Objetivo: un botón
**"Escanear QR de la pantalla"** que capture una región de la pantalla (donde está el
QR de `otpauth://…`), lo **decodifique** y **prefille** el formulario de TOTP
(secreto, emisor, cuenta, algoritmo, dígitos, periodo).

Primero **audita** viabilidad y propón un plan (impacto/esfuerzo + dependencias);
luego ejecútalo por fases.

## Enfoque técnico sugerido

1. **Captura de pantalla (Windows):** usa un paquete de captura de escritorio, p. ej.
   **`screen_capturer`** (leanflutter, misma familia que `window_manager`/
   `screen_retriever` que ya usas) para capturar **una región seleccionada** o toda
   la pantalla y obtener la imagen (PNG/bytes). Alternativa: canal nativo con
   GDI `BitBlt` en `windows/runner/` si prefieres cero dependencias.
2. **Decodificación del QR:** decodifica desde la imagen estática con un decoder
   **puro Dart** que corra en escritorio, p. ej. **`zxing2`** (port de ZXing) sobre
   los bytes RGBA de la captura. (Evita `mobile_scanner`/MLKit: son de cámara/móvil.)
3. **Parseo `otpauth://`:** implementa (o reutiliza) un parser de
   `otpauth://totp/Issuer:account?secret=...&issuer=...&algorithm=SHA1&digits=6&period=30`
   → mapéalo a los campos del `CredentialFormScreen` (tipo TOTP).
4. **Flujo UX:** botón en el formulario de TOTP (y opcionalmente acción global /
   `Ctrl+Shift+Q`): al pulsarlo, oculta la ventana de SoloKey un instante, deja
   seleccionar la región (overlay) o captura toda la pantalla, decodifica y:
   - si hay un QR válido → prefilla el form y avisa "TOTP detectado".
   - si no → error claro ("no se encontró un QR de TOTP en la captura").
5. **Solo escritorio:** protégelo con `Platform.isWindows`/`ResponsiveLayout`; en
   móvil sigue el escaneo por cámara (`qr_scanner_screen.dart`).

## Requisitos

- Añade la dependencia elegida a `pubspec.yaml` (y config nativa si aplica);
  documenta permisos. Corre `flutter pub get`.
- i18n es/en para todos los textos nuevos.
- Zero-Print: nunca loguees el secreto capturado.

**Tests (obligatorio):**

- **Parser `otpauth://`** → extiende
  `test/features/credentials/otpauth_parser_test.dart` y
  `test/core/otpauth_import_service_test.dart` (casos válidos e inválidos,
  algoritmos/digits/period, `otpauth-migration://` si lo abordas).
- **Decodificación de QR desde imagen** → extiende
  `test/features/credentials/qr_image_decoder_test.dart` (bytes de una imagen de
  QR de prueba → `otpauth://`) y `test/features/credentials/screen_qr_scanner_test.dart`
  (mapeo al formulario TOTP). Zero-Print: asserta contra el secreto esperado, no lo
  imprimas.
- **Campos TOTP del form** → extiende
  `test/features/credentials/widgets/totp_fields_section_test.dart` (prefill de
  secreto/emisor/cuenta y aviso de parámetros no estándar). Usa el harness
  `test/support/widget_harness.dart`.

## Features relacionadas (elige 1–2 extra)

- **Pegar `otpauth://` del portapapeles** y autocompletar (más simple, hazlo primero).
- **Importar múltiples TOTP** desde una captura con varios QR / desde export de
  Google Authenticator (`otpauth-migration://`).
- **Atajo global** para "capturar QR" incluso con la ventana en segundo plano.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; compila Windows
(`./build_release.ps1 -Target inno`) y prueba capturando un QR real en pantalla →
debe prefillar el TOTP y generar el código correcto.

**Guardarraíles:** el secreto va cifrado como cualquier TOTP; no lo escribas a disco
ni al log; la captura de pantalla es puntual y en memoria (no la persistas).
