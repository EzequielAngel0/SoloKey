# 📚 Documentación de SoloKey

Índice de toda la documentación del proyecto, organizada por propósito.
Última reorganización: **2026-07-03**.

```
docs/
├── spec/          Especificación fundacional (set secuenciado 00–05)
├── architecture/  Evolución arquitectónica
├── design/        Rediseño de UI/UX (Graphite Pro) — planes + previews
├── prompts/       Prompts detallados por pantalla (uno por chat) ← EMPEZAR AQUI para mejorar
├── security/      Auditorías e informes de seguridad
├── features/      Planes/diseño de features concretas
├── planning/      Roadmap, backlog vigente e ideas
└── release/       Empaquetado y publicación por plataforma
```

> **¿Vas a mejorar una pantalla?** Ve a [`prompts/`](prompts/README.md): trae un
> prompt detallado por pantalla (móvil + escritorio) con audit → plan → ejecución,
> features propuestas y guardarraíles. Úsalo uno por chat.

---

## 🟢 Estado del proyecto (2026-07-03)

Estabilización **cerrada**, i18n **completo** (es/en, UI + servicios), `flutter
analyze` sin issues y **61 tests verde**. Artefactos de release generados en
`dist/` (APKs + instalador Windows) vía `build_release.ps1`. **Rediseño UI/UX
Graphite Pro** mergeado a `main` (ver [`design/`](design/)); trabajo continuo por
pantalla vía [`prompts/`](prompts/README.md).

**Pendiente real / próximo:** auto-refresh de la Bóveda de Windows al sincronizar,
editar/eliminar carpetas en escritorio, ver qué se sincronizó, captura de QR en
Windows para TOTP (todo con prompt en `prompts/`); probar el flujo PC↔celular en
dispositivos; empaquetado macOS/Linux/iOS (diferido).

## 🟢 Empezar por aquí

- **¿Qué falta / estado vigente?** → [planning/pendientes_y_bugs.md](planning/pendientes_y_bugs.md) — backlog con estado de cada item, build de release y notas.
- **¿Qué se ha hecho y en qué orden?** → [planning/roadmap_desarrollo.md](planning/roadmap_desarrollo.md) — documento vivo de lotes.
- **Ideas a futuro** → [planning/feature_ideas.md](planning/feature_ideas.md) (ya separa "implementado" de "pendiente").

> Documentos **vivos** (se mantienen al día): los de `planning/` y este índice.
> Documentos **históricos / punto-en-el-tiempo** (no se reescriben): `spec/` (la
> especificación fundacional), `security/security_audit_report.md` y los planes de
> `features/`. El roadmap "Fases 9–13" del `CLAUDE.md` raíz quedó histórico — la
> fuente de verdad del estado es `planning/`.

---

## 📂 Por carpeta

### `spec/` — Especificación fundacional
| Doc | Contenido |
| :--- | :--- |
| [00_requirements_confirmation.md](spec/00_requirements_confirmation.md) | Confirmación de requisitos iniciales |
| [01_project_context_and_scope.md](spec/01_project_context_and_scope.md) | Contexto y alcance del proyecto |
| [02_architecture.md](spec/02_architecture.md) | Arquitectura base (Clean Architecture, capas) |
| [03_domain.md](spec/03_domain.md) | Modelo de dominio (entidades, repositorios) |
| [04_security.md](spec/04_security.md) | Especificación de seguridad (cripto, KDF, RAM) |
| [05_ux_and_flows.md](spec/05_ux_and_flows.md) | UX y flujos de pantalla |

### `architecture/` — Evolución arquitectónica
| Doc | Contenido |
| :--- | :--- |
| [architecture_v2.md](architecture/architecture_v2.md) | Revisión arquitectónica posterior |

### `design/` — Rediseño de UI/UX (Graphite Pro)
| Doc | Contenido |
| :--- | :--- |
| [rediseno_ui_2026.md](design/rediseno_ui_2026.md) | Capa visual Graphite Pro (tokens, tema, nav) — **hecho** |
| [rediseno_preview.html](design/rediseno_preview.html) | Preview visual del sistema de diseño |
| [ux_overhaul_2026.md](design/ux_overhaul_2026.md) | Rediseño UX pantalla por pantalla (lotes L0–L9) — **hecho** |
| [ux_overhaul_preview.html](design/ux_overhaul_preview.html) | Prototipo A/B del rediseño UX |

### `prompts/` — Prompts de mejora por pantalla
| Doc | Contenido |
| :--- | :--- |
| [README.md](prompts/README.md) | Índice + cómo usar (uno por chat) |
| [00_contexto_compartido.md](prompts/00_contexto_compartido.md) | Preámbulo (reglas/gates) a pegar antes de cada prompt |
| 10–90 | Prompts detallados: bóveda, detalle, formulario, carpetas, seguridad, sync, transferencia, ajustes, archivos/passkeys, acceso, escritorio, captura QR, transversal |

### `security/` — Auditorías
| Doc | Contenido |
| :--- | :--- |
| [security_audit_report.md](security/security_audit_report.md) | Informe de auditoría de seguridad |

### `features/` — Planes de feature
| Doc | Contenido |
| :--- | :--- |
| [desktop_companion_planning.md](features/desktop_companion_planning.md) | Plan maestro del companion de escritorio + sync P2P E2EE |
| [password_rotation_reminders.md](features/password_rotation_reminders.md) | Recordatorios nativos de rotación de contraseñas |

### `planning/` — Roadmap y backlog
| Doc | Contenido |
| :--- | :--- |
| [roadmap_desarrollo.md](planning/roadmap_desarrollo.md) | Documento vivo de lotes y estado |
| [pendientes_y_bugs.md](planning/pendientes_y_bugs.md) | Backlog de estabilización vigente (bugs + mejoras) |
| [feature_ideas.md](planning/feature_ideas.md) | Ideas y características futuras |

### `release/` — Publicación
| Doc | Contenido |
| :--- | :--- |
| [publishing_requirements.md](release/publishing_requirements.md) | Requisitos de publicación |
| [ios_compilation_guide.md](release/ios_compilation_guide.md) | Guía de compilación para iOS |
