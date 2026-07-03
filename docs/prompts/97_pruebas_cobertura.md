# 97 · Subir cobertura y elevar smoke → behavioral

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`) y el prompt de pruebas (`95`).

```text
Trabaja en el repo SoloKey (raíz). Lee y respeta docs/prompts/00_contexto_compartido.md y
docs/prompts/95_pruebas.md. Desarrolla lo descrito en docs/prompts/97_pruebas_cobertura.md:
sube la cobertura desde ~41% cubriendo el flujo de guardado del formulario y widgets/lógica
restante, y ELEVA los smoke tests más flojos a behaviorales (interacción real), sin caer en
coverage theater. Trabaja por lotes; deja `flutter analyze` en 0 y `flutter test` verde;
sube tool/coverage_min.txt al nuevo piso; commitea por lote con el formato del proyecto.
```

---

Objetivo: seguir subiendo la cobertura (base actual ~41.7%) **con aserciones que atrapen
bugs**, no solo "renderiza". El prompt 95 dejó una red sólida; aquí se profundiza.

## Contexto: qué hay hoy

- Existen **smoke tests de render** (build sin reventar) para muchas pantallas
  (`credential_detail`, `settings`, `security_audit`, `secure_files`, `desktop_main_layout`,
  `unlock`, `command_palette`, `quick_fill`, `autofill_onboarding`, …). Son buen **piso de
  regresión**, pero los más flojos solo verifican `takeException == null`.
- Kit de apoyo: `test/support/widget_harness.dart` (`pumpApp`, `scaffolded`,
  `tolerateInkHiddenPaintWarnings`) y `test/support/fake_credential_repository.dart`.

## Plan sugerido (por lotes)

1. **Guardado del formulario** (`credential_form_screen.dart`, ~565 líneas, hoy solo render):
   - Override `saveCredentialUseCaseProvider` con un fake que **capture** el `Credential`
     guardado; registra en get_it los servicios que usa el guardado
     (`DoubleEnvelopeService`, `SshKeyGeneratorService`) con fakes.
   - Verifica que guardar arma el `Credential` correcto **por tipo** (password/apiKey/totp/
     ssh/nota), con doble-sobre on/off, favorito y rotación. Reutiliza
     `test/features/credentials/credential_form_screen_test.dart`.
2. **Elevar smoke → behavioral** donde importe (empieza por los de mayor tráfico):
   - `credential_detail`: revelar/copiar un campo con `AuthHelper`/biometría **mockeada**
     (registra un fake de `BiometricAuthService` en get_it); verifica que el valor aparece y
     que se limpia al ocultar (Zero-Print: asserta contra un valor conocido, no lo imprimas).
   - `settings`: cambiar un slider/switch persiste vía el fake `ISettingsRepository`.
   - `security_audit`: togglear HIBP y navegar a la credencial de un issue.
3. **Lógica/servicios restantes con lógica pura** (unit tests, alto ROI):
   - `core/services/vault_export_service.dart` (`parseCsvBackup`, construcción de backup) con
     fakes; `csv_import_service` ya está — extiéndelo si tocas formatos.
4. **Layout móvil real**: donde un smoke usó superficie ancha para evitar overflow, agrega
   una variante a ancho de teléfono (~390–430px) y **arregla o documenta** el overflow real.

## Regla honesta

Cobertura ≠ correctitud. Prioriza aserciones que fallen cuando el comportamiento cambie;
un test que solo sube el % sin poder afirmar nada útil **no** vale el mantenimiento.

## Gates + ratchet

- `flutter analyze` 0 · `flutter test` verde · `build_runner`/`gen-l10n` si aplica.
- Sube `tool/coverage_min.txt` al nuevo piso (`flutter test --coverage && dart run
  tool/check_coverage.dart 0`). El gate `pre-push`/CI lo hace obligatorio.

## Guardarraíles

- No debilites cripto/persistencia; los fakes de auth/servicios son solo de test.
- Zero-Print incluso en tests: nunca vuelques secretos/claves/texto plano descifrado.
