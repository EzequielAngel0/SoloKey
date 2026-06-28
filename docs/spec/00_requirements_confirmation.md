# Confirmación de Requisitos y Diseño del Sistema

Hola. Como arquitecto senior de software y seguridad, he analizado detenidamente todos los requisitos para la aplicación de gestión de contraseñas. Antes de escribir ninguna línea de código, confirmo mi comprensión de los siguientes puntos clave:

## 1. Comprensión general de los requisitos
Confirmo que el objetivo es desarrollar una aplicación móvil (Android inicial) de gestión de contraseñas, con foco estricto en la **seguridad, la arquitectura limpia (Clean Architecture) y la escalabilidad**. El desarrollo será iterativo, empezando por un MVP que servirá como base sólida para transformarse en una bóveda digital de identidad completa.

## 2. Alcance del MVP
El MVP será una **bóveda local segura** con un generador de contraseñas.
**Incluye:**
- Creación y validación de contraseña maestra.
- Desbloqueo mediante biometría y bloqueo por inactividad/background.
- CRUD completo de credenciales (id, título, usuario, contraseña, sitio web, notas, categoría, favoritos, timestamps).
- Generador de contraseñas avanzado (longitud, tipos de caracteres, fortaleza).
- Limpieza automática del portapapeles y ocultación en segundo plano.

**Excluye en esta fase:** Sincronización en la nube, autofill, 2FA (TOTP), notas seguras, passkeys, web/escritorio, entre otros.

## 3. Arquitectura Propuesta
Se implementará **Clean Architecture** estructurada en 4 capas:
1. **Presentation:** Interfaz de usuario y widgets compartidos.
2. **Application:** Casos de uso y orquestación, gestión de estado con **Riverpod**.
3. **Domain:** Entidades puras y contratos de repositorios (agregados independientes del framework).
4. **Infrastructure:** Implementación de bases de datos locales (SQLite/Drift), almacenamiento seguro (Android Keystore / Secure Storage) y algoritmos criptográficos contrastados.

Estructura de módulos: `core`, `features` (vault_access, credentials, password_generator, settings), `shared`.

## 4. Entidades del Dominio
El modelo conceptual está bien definido e incluye:
- `Vault`: Representación del contenedor de la bóveda.
- `MasterKeyConfig`: Configuración criptográfica (sal, iteraciones de KDF, hash de validación), **nunca** la clave en claro.
- `Credential`: Objeto de valor/entidad para cada credencial almacenada.
- `Category`: Categorización de las credenciales.
- `AppSecuritySettings`: Preferencias de seguridad del usuario (tiempos de bloqueo, biometría, etc.).
- `VaultSession`: Estado temporal de la sesión desbloqueada.

## 5. Pantallas Principales
El flujo incluye 8 pantallas clave para el MVP:
1. Splash / Bootstrap
2. Setup Master Password
3. Unlock Screen
4. Home / Vault List
5. Credential Detail
6. Add / Edit Credential
7. Password Generator
8. Settings

## 6. Confirmación de arquitectura Local-First
**Confirmo:** El sistema será estrictamente **local-first** en esta fase MVP. No existirá ningún backend, conexión a la nube ni envío de datos de telemetría o credenciales fuera del dispositivo. Todos los datos sensibles se cifrarán localmente y se almacenarán en el dispositivo del usuario.

## 7. Preparación para Evolución Futura
**Confirmo:** El diseño de dominio e infraestructura modular permite la fácil extensión planificada (Fases 2 a 5). Separar `MasterKeyConfig` de `Vault` y `VaultSession` permitirá en el futuro implementar sincronización cifrada o múltiples tipos de ítems (como TOTP o notas seguras) simplemente añadiendo nuevas entidades de dominio y repositorios sin alterar el núcleo de seguridad.

---
**Conclusión:**
Los requisitos son claros, robustos y alineados con las mejores prácticas de seguridad ofuscada y zero-knowledge. Quedo a la espera de su confirmación para proceder con la inicialización del proyecto Flutter y la implementación del primer módulo (Core / Setup).
