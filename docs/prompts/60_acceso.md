# 60 · Acceso (splash / setup / unlock / recovery)

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/60_acceso.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en el flujo de acceso: `features/vault_access/presentation/`
(`splash_screen.dart`, `setup_screen.dart`, `unlock_screen.dart`,
`recovery_screen.dart`), sus use cases (`setup_vault_use_case`,
`unlock_vault_use_case`, `wipe_vault_use_case`), `SessionManager`, `brute_force_guard`
y el teclado seguro (`shared/widgets/secure_keyboard/`). El splash ya es plano
(logo + fade). **Flujos sensibles: cambia UX, no la seguridad.**

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **Unlock** — **Windows Hello / biometría primero** (botón grande) con contraseña
   maestra como fallback; estados de error claros (intentos restantes, bloqueo por
   fuerza bruta); opción de "olvidé mi contraseña" → recovery. Copys por plataforma.
2. **Setup** — **stepper** limpio de 2–3 pasos (crear master → mostrar Recovery Code
   una sola vez → listo) con indicador de fortaleza y checklist de requisitos.
3. **Recovery** — flujo de 2 pasos con estados; mensaje claro de que el código se
   mostró una sola vez.
4. **Splash** — routing inteligente (setup vs unlock); animación sutil (sin scale
   exagerado, ya hecho).
5. **UI/UX** — todo plano Graphite Pro, logo mark plano (sin glow, ya hecho).
6. **i18n/a11y** — todos los copys en `.arb`; foco inicial en el campo correcto;
   `Semantics` en biometría.
7. **Tests** — no romper `session_manager`/cripto; los tests de unlock/verify siguen
   verdes.

**Features propuestas (elige 3–5):** (a) **auto-lock configurable ya existe** —
súmale desbloqueo con Windows Hello nativo real; (b) **PIN corto** opcional además de
la master (con re-auth periódica); (c) **teclado seguro** activable para la master;
(d) **onboarding** de primer uso (tour breve); (e) **bloqueo de emergencia** por
atajo.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; prueba setup nuevo,
unlock con biometría y fallback, y el flujo de recovery.

**Guardarraíles:** NO toques la derivación Argon2id, el verify sin almacenar clave,
el zeroing de RAM ni `brute_force_guard`. El Recovery Code se muestra una sola vez.
