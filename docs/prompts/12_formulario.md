# 12 · Formulario crear/editar credencial

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

**Verificación:** `flutter analyze` 0 + `flutter test` verde; crea/edita una de cada
tipo en móvil y escritorio.

**Guardarraíles:** no cambies el `CredentialDto`/mapeo de payload cifrado sin migrar;
el secreto TOTP se guarda en `password`; respeta el doble sobre opcional.
