# Contexto del Proyecto y Alcance del MVP

> **🕰️ HISTÓRICO (alcance del MVP original).** Este documento describe el
> **MVP inicial** (solo Android, sin sync/autofill/passkeys/import-export). El
> proyecto creció mucho desde entonces: hoy SoloKey es **multiplataforma**
> (Android + companion de escritorio Windows) con sync P2P E2EE, autofill,
> teclado seguro, TOTP, llaves SSH, passkeys (respaldo), import/export, auditoría
> y más. Para el **estado actual** ver `../planning/pendientes_y_bugs.md` y
> `../planning/roadmap_desarrollo.md`. Se conserva como registro de diseño.

## Objetivo
Desarrollar una aplicación de seguridad personal (Password Manager) para Android utilizando Flutter y Dart, diseñada con Clean Architecture para soportar una futura evolución hacia una bóveda digital completa de identidad.

## Fase 1: MVP (Minimum Viable Product)
El MVP tiene como objetivo consolidar las bases de seguridad, abstracción arquitectónica y funcionalidades esenciales:

### Funcionalidades Incluidas
1. **Seguridad General:** Establecimiento y validación de contraseña maestra, desbloqueo biométrico, bloqueo por inactividad, ocultación en segundo plano.
2. **Gestión de Credenciales:** CRUD completo de contraseñas con categorías, notas y campos detallados.
3. **Generador de Contraseñas:** Herramienta para crear contraseñas seguras con parámetros personalizables.
4. **Seguridad Operativa:** Limpieza del portapapeles y cifrado local de todos los datos sensibles.

### Funcionalidades Excluidas (Fuera de Alcance del MVP)
- Sincronización en la nube / backend remoto.
- Autenticación 2FA (TOTP) nativa.
- Notas seguras avanzadas.
- Passkeys, autofill, versiones web/escritorio.
- Importación/exportación y compartir contraseñas.

Esta fase inicial es estrictamente **Local-First**, garantizando que el usuario tenga el control absoluto sobre sus datos cifrados.
