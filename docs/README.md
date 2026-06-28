# 📚 Documentación de SoloKey

Índice de toda la documentación del proyecto, organizada por propósito.
Última reorganización: **2026-06-28**.

```
docs/
├── spec/          Especificación fundacional (set secuenciado 00–05)
├── architecture/  Evolución arquitectónica
├── security/      Auditorías e informes de seguridad
├── features/      Planes/diseño de features concretas
├── planning/      Roadmap, backlog vigente e ideas
└── release/       Empaquetado y publicación por plataforma
```

---

## 🟢 Empezar por aquí

- **¿Qué falta y qué está roto?** → [planning/pendientes_y_bugs.md](planning/pendientes_y_bugs.md) — backlog de estabilización vigente (bugs activos B1/B2, gap G1, mejoras M1–M3) con causas raíz y arreglos.
- **¿Qué se ha hecho y en qué orden?** → [planning/roadmap_desarrollo.md](planning/roadmap_desarrollo.md) — documento vivo de lotes (temas, rename, autofill, seguridad, i18n…).
- **Ideas a futuro** → [planning/feature_ideas.md](planning/feature_ideas.md).

> Nota: el roadmap "Fases 9–13" del `CLAUDE.md` raíz quedó **histórico**; la
> mayoría ya está implementada. La fuente de verdad del trabajo pendiente es
> `planning/pendientes_y_bugs.md`.

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
