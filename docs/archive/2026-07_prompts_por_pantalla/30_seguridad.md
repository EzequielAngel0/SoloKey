# 30 · Seguridad (auditoría, hub, generador, historial)

## 📋 Prompt para pegar en el chat

> Copia **solo** este bloque en un chat nuevo abierto en la raíz del repo. Ya referencia
> el contexto compartido (`00`); no necesitas pegar nada más.

```text
Trabaja en el repo SoloKey (raíz del proyecto). Primero lee y respeta
docs/prompts/00_contexto_compartido.md: reglas duras, arquitectura, gates y método de
trabajo. Luego desarrolla lo descrito en docs/prompts/30_seguridad.md — audita el área,
propón un plan priorizado (impacto/esfuerzo) y ejecútalo por lotes revisables. Deja
`flutter analyze` en 0 y `flutter test` en verde; corre `dart run build_runner build
--delete-conflicting-outputs` y `flutter gen-l10n` cuando toques codegen o `.arb`; y
commitea por lote con el formato del proyecto (una sola línea, ascii sin acentos, sin firma).
```

Enfócate SOLO en el área de Seguridad:
`features/credentials/presentation/security_audit_screen.dart` (con `ScoreRing` +
`StatusChip`), `widgets/security_hub_view.dart` (hub móvil),
`widgets/password_generator_widget.dart`, `password_history_screen.dart`, y el
servicio `core/services/security_audit_service.dart` (débiles / cortas / reutilizadas
/ antiguas / HIBP por k-Anonymity) + `credential_health_provider.dart` (avisos
inline). No hagas cripto en presentación.

Primero **audita** y propón un plan priorizado; luego ejecútalo:

1. **🐞 BUG: el switch "verificar filtraciones (HIBP)" no persiste.** Hoy es estado
   local en `_SecurityAuditScreenState`; al cambiar de módulo y volver se reinicia.
   Muévelo a un `StateProvider<bool>` (o a `AppSecuritySettings` si quieres que
   persista entre sesiones) para que se conserve.
2. **UI/UX** — la auditoría ya tiene **Security Score** (anillo + conteos por
   severidad). Mejora los hallazgos: agrúpalos por severidad, hazlos accionables
   ("arreglar" → editar/rotar), y muestra el **conteo total y tendencia**. El hub
   móvil (`SecurityHubView`) revisa que las tarjetas sean consistentes.
3. **Generador** — controles limpios (slider longitud, toggles de charset), fuerza
   en vivo, copiar grande; recuerda preferencias.
4. **Historial** — `password_history_screen`: línea de tiempo con fecha (relativa),
   revelar/copiar valores anteriores con auth, y opción de restaurar.
5. **Lógica/rendimiento** — el audit descifra la bóveda en RAM: hazlo en isolate si
   procede, con progreso; cachea el último resultado; HIBP es opt-in y no revela el
   password (k-Anonymity, verifícalo).
6. **i18n/a11y** — textos de hallazgos y severidades en `.arb`; contraste del anillo.
7. **Tests** — score baja con hallazgos; el switch HIBP persiste; `security_audit_
   service_test` sigue verde (umbral 180 días para "antiguas").

**Features propuestas (elige 3–5):** (a) **"Watchtower"**: badge global con nº de
problemas en la nav/sidebar; (b) **acciones en lote** ("rotar todas las débiles");
(c) **puntuación por credencial** visible en el detalle; (d) **recordatorio
programado** de auditoría; (e) **exportar reporte** de salud (sin secretos).

**Tests (obligatorio):**

- **Auditoría** → extiende `test/core/security_audit_service_test.dart` (débiles,
  reutilizadas, antiguas; SSH/passkey nunca "weak"; HIBP con `checkBreachCount`
  mockeado — nunca envíes el password completo).
- **Salud inline** → extiende
  `test/features/credentials/credential_health_provider_test.dart`
  (`_isWeak`/`_isCheckable`, reutilización, tipos no-password).
- **Persistencia del switch HIBP** → cúbrela con un test del provider de settings.

**Verificación:** `flutter analyze` 0 + `flutter test` verde; activa HIBP, cambia de
módulo y verifica que sigue activo.

**Guardarraíles:** HIBP nunca envía el password completo; no persistas resultados con
secretos; respeta el opt-in de red.
