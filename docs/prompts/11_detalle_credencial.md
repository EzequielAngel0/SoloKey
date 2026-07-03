# 11 · Detalle de credencial

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/11_detalle_credencial.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en `features/credentials/presentation/credential_detail_screen.dart`
(y el kit `DetailGroup`/`SectionHeader`/`KvRow`/`StatusChip`). Ya está rehecho **por
tipo** con filas densas: TOTP muestra el **código en vivo + anillo** como héroe y la
semilla va en "Avanzado"; hay `_DetailRow` con revelar/copiar y descifrado de doble
sobre. En escritorio se muestra en el panel derecho de `desktop_main_layout.dart`.

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **UI/UX** — pulir jerarquía por tipo (login / TOTP / API key / SSH / passkey /
   nota): la **acción primaria** de cada tipo debe ser obvia. Añade **"Abrir sitio"**
   en login/API (`url_launcher` ya es dependencia). Revisa el header (avatar+título+
   subtítulo+badge) y el bloque de rotación.
2. **Navegación** — en escritorio, al cambiar de credencial el subárbol debe
   reiniciar (ya se añadió `didUpdateWidget` al TOTP; considera además
   `key: ValueKey(selectedId)` en el panel derecho para limpiar secretos revelados).
   Botón "atrás"/cerrar coherente en escritorio (hoy el leading se oculta).
3. **Lógica/estado** — auto-ocultar secretos revelados tras ~20–30 s y al ir a
   segundo plano; limpiar `_decryptedValue` de RAM al ocultar (ya se hace, verifica
   todos los caminos); un **único ticker** si hubiera varios TOTP.
4. **Seguridad** — revelar/copiar con `AuthHelper.requireAuth`; portapapeles con
   autolimpieza; nunca loguear el valor.
5. **i18n/a11y** — labels de campos y "Avanzado" en `.arb`; `Semantics` en los
   íconos de revelar/copiar; contraste del código TOTP.
6. **Tests** — widget test: TOTP renderiza código válido y "código inválido" en
   semilla mala; revelar exige auth; cambiar de credencial en escritorio no muestra
   el TOTP anterior.
7. **Limpieza** — de-duplicar helpers de color/ícono por tipo con los de
   `credential_card.dart`.

**Features propuestas (elige 3–5):** (a) **historial de cambios** más rico (diff de
campos, no solo password); (b) **campos personalizados tipados** (texto/secreto/URL/
fecha) con acción por tipo; (c) **"revelar por 10 s"** con cuenta regresiva visible;
(d) **QR de la credencial** (p. ej. exportar un TOTP a otro dispositivo) protegido
por auth; (e) **marca de "verificado sin filtración"** integrando el resultado HIBP.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; prueba abrir varios
TOTP seguidos en escritorio.

**Guardarraíles:** el descifrado sigue en la capa de datos; no dejes texto plano en
RAM tras ocultar; no cambies el formato de `double_enc_v1:`.
