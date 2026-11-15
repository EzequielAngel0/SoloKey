# 12 · Formulario crear/editar credencial

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/12_formulario.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en `features/credentials/presentation/credential_form_screen.dart` y
sus `widgets/` (`type_selector_premium.dart`, `password_row_widget.dart`,
`password_generator_widget.dart`, `form_section.dart`, `save_button.dart`,
`folder_picker_sheet.dart`). Ya es **por tipo** (selector + secciones) y theme-aware
(migrado a `context.palette`). Es un archivo grande (~1500 líneas).

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **UI/UX** — homogeneiza las secciones por tipo con el lenguaje de filas del
   detalle (`DetailGroup`/`KvRow`); el selector de tipo arriba, plano (sin sombras);
   hints contextuales; el botón guardar como CTA claro. Revisa que en móvil los
   campos multilínea (SSH/nota) sean cómodos.
2. **Navegación/estado** — al crear desde una carpeta, prefijar `folderId` (ya se
   hace en escritorio); en escritorio, `key: ValueKey(existingId)` para no arrastrar
   estado entre ediciones. Confirmación al salir con cambios sin guardar.
3. **Lógica** — **validación inline** por campo (no solo al guardar): requisitos de
   contraseña, formato de URL, secreto TOTP válido (base32) con feedback inmediato;
   estado "guardando"; manejo de errores del guardado.
4. **Generador** — integra `PasswordGeneratorWidget` con fuerza en vivo; recuerda
   preferencias de generación.
5. **i18n/a11y** — todos los labels/hints/errores en `.arb`; foco y orden de tab
   correctos; `Semantics` en toggles de revelar/generar.
6. **Tests** — validaciones (password débil, URL inválida, secreto TOTP inválido),
   guardar credencial de cada tipo, editar preserva campos.
7. **Limpieza** — reduce el tamaño del archivo extrayendo los builders por tipo a
   `widgets/` separados; elimina `Colors.white` residuales por `context.palette`.

**Features propuestas (elige 3–5):** (a) **autoguardado / borrador** para no perder
lo escrito; (b) **detección de duplicados** al crear (mismo sitio/usuario);
(c) **pegar desde portapapeles** un `otpauth://` y autocompletar el TOTP;
(d) **plantillas** por servicio popular (icono + campos); (e) **evaluación de fuerza
y filtración** del password antes de guardar (aviso, no bloqueo).

**Tests (obligatorio):**

- **Formulario** → extiende `test/features/credentials/credential_form_screen_test.dart`
  (título requerido, el selector de tipo cambia los campos, el generador se revela).
  El `FormSection` es opaco: usa `tolerateInkHiddenPaintWarnings()` del harness.
- **Mapeo del payload** → si tocas `CredentialDto`/campos cifrados, extiende
  `test/features/credentials/credential_dto_test.dart` (round-trip payload + tipos).
- **Generación** → los invariantes viven en
  `test/features/password_generator/password_generator_test.dart`.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; crea/edita una de cada
tipo en móvil y escritorio.

**Guardarraíles:** no cambies el `CredentialDto`/mapeo de payload cifrado sin migrar;
el secreto TOTP se guarda en `password`; respeta el doble sobre opcional.
