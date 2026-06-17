# Guía Base de Desarrollo del Proyecto por Fases (Password Manager)

Este archivo (`CLAUDE.md` / `Cursorrules` / System Prompt) rige cómo cualquier IA debe ejecutar el código de esta aplicación a través de fases de implementación estructuradas. **Al procesar una tarea, identifícate obligatoriamente con los roles de `AGENTS.md` e invoca las skills de `GEMINI.md` correspondientes.**

## 1. Reglas Maestras de Seguridad y Arquitectura
*   **Zero-Print Policy:** Totalmente prohibido hacer `print()` de contraseñas, hashes, IVs o variables de texto plano desencriptado en consola. Cualquier debug se hace en entornos controlados y con logs de jerarquía limpia.
*   **Dominio "Ciego":** La capa `Domain` o `Presentation` **nunca** realizará operaciones criptográficas por cuenta propia. Siempre delegarán esto a la capa de `Data/Infrastructure` (ej. `SecurityService`).
*   **Inmutabilidad (SOLID):** Uso estricto de `freezed` o `equatable` para todo modelo de datos (Entidades, DTOs) y estados del bloque de visualización (`Riverpod`/`BLoC`).

---

## 2. Metodología de Implementación por Fases

Para desarrollar este **Local-First Password Manager en Flutter/Dart**, el avance se dividirá secuencialmente en las siguientes fases. Debes alinear tu forma de pensar y la aplicación de dependencias según las correspondencias listadas:

### ✅ Fase 1: Arquitectura Base y Entidades del Dominio — COMPLETADA (2026-03-30)
- **Agente Principal:** 🏗️ `Arquitecto_Mobile_Sec`.
- **Skills invocadas:** `architecture-patterns`, `flutter-architecting-apps`, `clean-code`.
- **Entregables completados:**
  1. Proyecto Flutter inicializado (`flutter 3.38.5` / `dart 3.10.4`), plataforma Android, org `com.vaultguard`.
  2. Estructura Clean Architecture: `lib/{app,router,theme,core,features,shared}/` + `test/`.
  3. `pubspec.yaml` con 15 dependencias de producción y 6 de desarrollo (freezed, riverpod, drift, get_it, cryptography, local_auth, flutter_windowmanager...).
  4. **6 entidades `@freezed`** inmutables: `Vault`, `MasterKeyConfig` (con `KdfParams`), `VaultSession`, `Credential` (con `CustomField`), `Category`, `AppSecuritySettings`.
  5. **3 interfaces de repositorio**: `IVaultRepository`, `ICredentialRepository` + `ICategoryRepository`, `ISettingsRepository`.
  6. `Failure` union type para manejo de errores.
  7. `AppTheme.dark()` — paleta oscura premium (`#0F0F23` / `#6C63FF`).
  8. `AppRouter` con 8 rutas del MVP (GoRouter + Riverpod provider).
  9. Inyección de dependencias base: `get_it` + `injectable` (`injection.dart` + `injection.config.dart`).
  10. `build_runner` ejecutado — 62 archivos generados. `dart analyze`: **0 issues**.

---

### ✅ Fase 2: Motor Criptográfico y Almacenamiento Seguro — COMPLETADA (2026-03-30)
- **Agentes Principales:** 🛡️ `Auditor_Seguridad_Mobile` y 💾 `Ingeniero_Persistencia`.
- **Skills invocadas:** `security-best-practices`, `flutter-working-with-databases`, `flutter-handling-concurrency`, `flutter-testing-apps`.
- **Entregables completados:**
  1. **`ISecurityService`** (interfaz) + **`SecurityServiceImpl`**: toda operación cripto despacha a `Isolate.run()` — el UI thread nunca se bloquea.
  2. **`crypto_isolate.dart`**: funciones top-level para `Isolate.run()`:
     - `deriveKeyIsolate` — Argon2id (memory=65536KB, iter=3, par=4, keyLen=32).
     - `encryptIsolate` / `decryptIsolate` — AES-256-GCM, IV aleatorio 12B, blob = nonce‖ciphertext‖tag.
     - `generateSaltBase64Isolate` — salt de 32B con `Random.secure()`.
     - `createVerificationDataIsolate` / `verifyKeyIsolate` — flujo de verificación de contraseña maestra sin almacenar la clave.
  3. **`SessionManager`**: clave derivada en RAM (`Uint8List`), zeroing al bloquear, copia independiente en `getKeyCopy()`.
  4. **Drift SQLite DB** (`AppDatabase`): tablas `CredentialEntries` (payload cifrado BLOB) + `CategoryEntries` (plain), DAOs con upsert/delete/search, registrados en get_it vía `RegisterModule`.
  5. **`CredentialDto`**: serializa payload sensible (username, password, website, notes, customFields) a JSON → cifra antes de persistir; descifra al leer.
  6. **`VaultRepositoryImpl`**: persiste `Vault` + `MasterKeyConfig` en Android Keystore (`flutter_secure_storage`, `encryptedSharedPreferences=true`).
  7. **`SettingsRepositoryImpl`**: persiste `AppSecuritySettings` en Keystore.
  8. **17 tests unitarios** pasados (`flutter test`):
     - Salt: unicidad, longitud 32B.
     - AES-GCM: cifrado/descifrado, IVs únicos, detección de tampering, rechazo con clave errónea.
     - Argon2id: determinismo, sensibilidad a contraseña, longitud 256-bit.
     - Verificación: flujo correcto e incorrecto.
     - SessionManager: ciclo completo lock/unlock, aislamiento de copia.
  9. `dart analyze lib/`: **0 issues**.

---

### ✅ Fase 3: Interface Interactiva e Integración de Estado — COMPLETADA (2026-03-30)
- **Agente Principal:** 🧑‍💻 `Desarrollador_Flutter_Core`.
- **Skills invocadas:** `flutter-managing-state`, `ui-ux-pro-max`, `frontend-design`, `interface-design`, `flutter-building-forms`.
- **Entregables completados:**
  1. **Casos de uso (Application layer):**
     - `SetupVaultUseCase`: deriva clave Argon2id, genera salt, crea vault + MasterKeyConfig, guarda en Keystore, desbloquea sesión.
     - `UnlockVaultUseCase`: deriva clave, verifica contra `verificationData`, almacena en `SessionManager`.
     - `GetCredentialsUseCase`, `SaveCredentialUseCase`, `DeleteCredentialUseCase`: CRUD completo con descifrado lazy.
  2. **Providers Riverpod:**
     - `VaultNotifier` (`@freezed` union: initial/loading/unlocked/locked/error).
     - `CredentialsNotifier` (`AsyncNotifier<List<Credential>>`): refresh, save, updateCredential, delete.
     - `CredentialSearchNotifier` + `filteredCredentialsProvider` (búsqueda reactiva).
     - `PasswordConfigNotifier` + `GeneratedPasswordNotifier` + `passwordStrengthProvider`.
  3. **Bridge DI:** `provider_overrides.dart` mapea get_it singletons → Riverpod providers en `ProviderScope`.
  4. **Pantallas implementadas (8):**
     - `SplashScreen`: animación de logo con fade+scale, routing inteligente (setup vs unlock).
     - `SetupScreen`: formulario con validación de complejidad (12+ chars, mayúscula, número, símbolo), `PasswordStrengthIndicator`, checklist de requisitos.
     - `UnlockScreen`: biometría automática (`local_auth`) + fallback a contraseña maestra.
     - `HomeScreen`: búsqueda reactiva, FAB "Nueva credencial", botón lock, lista con `CredentialCard`.
     - `CredentialDetailScreen`: vista de campos con reveal/hide y copy-to-clipboard por campo.
     - `CredentialFormScreen`: tipo selector animado (Password/APIKey/Note/Crypto), favorito toggle, validación.
     - `PasswordGeneratorScreen`: slider longitud, toggles de charset, regenerar, copiar, indicador de fortaleza.
     - Settings: placeholder (Fase 4).
  5. **Widgets compartidos premium:** `PasswordStrengthIndicator`, `SecureTextField`, `VaultAppBar`, `CredentialCard`.
  6. **AppRouter** con guard de navegación: redirige a `/unlock` si la sesión está bloqueada.
  7. `build_runner`: 69 archivos generados. `dart analyze lib/`: **0 issues**. Tests: **17/17 verde**.

### ✅ Fase 4: UX Perfeccionada y Seguridad Operacional — COMPLETADA (2026-03-30)
- **Agentes Principales:** Mezcla de 🧑‍💻 `Desarrollador_Flutter_Core` y 🛡️ `Auditor_Seguridad_Mobile`.
- **Skills invocadas:** `flutter-animations`, `flutter-animating-apps`.
- **Entregables completados:**
  1. **`AppLifecycleObserver`** (`WidgetsBindingObserver`, `@lazySingleton`):
     - Activa `FLAG_SECURE` en Android al inicializar → impide capturas de pantalla nativas.
     - Timer de inactividad configurable (default 5 min): se resetea en cada `onPointerDown` desde el `Listener` raíz en `App`.
     - Detecta tiempo en segundo plano (`didChangeAppLifecycleState`): bloquea si supera `autoLockMinutes`.
     - `onLockRequested` callback conectado a `VaultNotifier.lock()` + navegación a `/unlock`.
  2. **`ClipboardService`** (`@lazySingleton`):
     - `copySecure(value)`: copia al portapapeles y activa timer auto-clear (lee `clearClipboardSeconds` de settings).
     - Integrado en `_SecretTile._copy()` con SnackBar informativo del countdown.
  3. **Animaciones premium:**
     - `SlideUpFadeTransition` (custom `PageTransitionsBuilder`): slide desde abajo (offset 0→0.06) + fade, con scale inverso en pantalla saliente (1→0.92). Aplicado globalmente en `App`.
     - `StaggeredListItem`: entrada slide+fade con delay indexado (`i × 40ms`). Usado en `HomeScreen`.
     - `CopyFeedbackButton`: ripple ring expandiente + scale TweenSequence + checkmark verde por 1.5s. Reemplaza `IconButton` de copia en `CredentialDetailScreen`.
  4. **`SettingsScreen`** completa:
     - `SettingsNotifier` (`@riverpod`): carga/guarda `AppSecuritySettings` vía `ISettingsRepository`.
     - Slider "Bloqueo por inactividad" (1–60 min) + slider "Limpiar portapapeles" (10–120s).
     - Toggle "Desbloqueo biométrico" + toggle "Ocultar en segundo plano".
     - Zona peligrosa: botón "Bloquear ahora" con borde rojo.
     - `settingsRepositoryProvider` bridgeado en `provider_overrides.dart`.
  5. **Router actualizado**: `/settings` sirve `SettingsScreen` (reemplaza placeholder).
  6. `build_runner`: outputs regenerados. `dart analyze lib/`: **0 issues**. Tests: **17/17 verde**.

### ✅ Fase 5: Sistema de Organización de Bóveda (Carpetas) — COMPLETADA (2026-03-30)
- **Agentes Principales:** 💾 `Ingeniero_Persistencia` y 🧑‍💻 `Desarrollador_Flutter_Core`.
- **Entregables completados:**
  1. Integración de la tabla `folder_entries` en Drift para gestión local estructurada.
  2. Construcción del `FolderDao` y su `FolderRepositoryImpl` expuestos vía Riverpod.
  3. Modificación interactiva en `HomeScreen` reemplazando barra plana por un **Navigation Drawer** lateral gestionable (`FolderDrawer`) con enlace a Favoritos interactivo (campo `isFavorite` dentro de entidades Credential).
  4. Selector adaptativo en el formulario `CredentialFormScreen` para instanciar la llave referencial del id de carpeta.

### ✅ Fase 6: Expansión Criptográfica (TOTP / 2FA) — COMPLETADA (2026-03-30)
- **Agentes Principales:** 🛡️ `Auditor_Seguridad_Mobile` y 🧑‍💻 `Desarrollador_Flutter_Core`.
- **Entregables completados:**
  1. Cambio de enums eliminando tipos residuales (CryptoWallet) en reemplazo por `totp`.
  2. Implementación de algoritmo visual en `_TotpTile` integrando la librería nativa `otp` y cálculo de desfase horario para rendering circular de 30 segundos.
  3. Soporte extendido para cifrado estricto de secretos en Keystore sin fugas UI con limpieza rápida del buffer por 2 segundos.

### ✅ Fase 7: Central de Auditoría (Security Audit) — COMPLETADA (2026-03-30)
- **Agentes Principales:** 🛡️ `Auditor_Seguridad_Mobile`.
- **Entregables completados:**
  1. `SecurityAuditService`: inyector evaluador lógico sobre la bóveda completa y descriptada temporalmente en RAM para detectar duplicadas, débiles (< 8 letras sin números) o muy antiguas.
  2. `SecurityAuditScreen`: listado severo de problemas categorizando acciones a corregir e identificadores visuales adaptados a "clean layout".

### ✅ Fase 8: Resiliencia (Recuperación Maestra) — COMPLETADA (2026-03-30)
- **Agentes Principales:** 🛡️ `Auditor_Seguridad_Mobile` y 🏗️ `Arquitecto_Mobile_Sec`.
- **Entregables completados:**
  1. Implementación modular de `RecoveryService`: generador Pseudo-Random de un bloque de 32 Bytes guardado mediante Hash SHA-256 extraído desde Keystore nativo.
  2. Emisión única (Zero-trust) del "Recovery Code" embebido obligatoriamente post-creación de bóveda en `SetupScreen`.
  3. Flujo "Olvidé mi Contraseña" habilitado en `UnlockScreen` rehidratando la clave original AES para re-derivar e instanciar nuevos KdfParams limpios.

---

## 🛠️ Fases Pendientes (Roadmap Futuro)

### ✅ Fase 8.5: Interfaz de Carpetas Avanzadas y Favoritos — COMPLETADA (2026-03-31)
- **Agentes Principales:** Mezcla de 🧑‍💻 `Desarrollador_Flutter_Core` y 💾 `Ingeniero_Persistencia`.
- **Entregables completados:**
  1. Refactorización a Navegación Profunda (`FolderScreen`) evitando flat lists anidadas complejas y mejorando el rendimiento.
  2. Implementación modal interactivo `_FolderPickerSheet` para la selección y creación al vuelo de sub-carpetas en el flujo de credenciales.
  3. Adopción de la columna de persistencia de Base de datos SQLite v4 (`isFavorite: boolean`) conectada full-stack hasta el Repositorio de Drift.
  4. Redirección reactiva (`GoRouter`) de alertas generadas por Auditorias de la capa `SecurityService` directamente en su pantalla editora.
  5. Controles contextuales unificados para Alternar (Toggles) de "Favoritos" incrustados en las barras superiores de cada pantalla de descripción.

---

### ✅ Fase 8.6: Pulido Integral — Seguridad, UX Premium y Calidad de Codigo — COMPLETADA (2026-06-17)
- **Agentes Principales:** Mezcla de 🛡️ `Auditor_Seguridad_Mobile`, 🧑‍💻 `Desarrollador_Flutter_Core` y 🏗️ `Arquitecto_Mobile_Sec`.
- **Entregables completados:**
  1. **Seguridad:** Zeroing de `exportKey` (Argon2id) tras uso en export/import (`vault_export_service.dart`) para minimizar ventana de exposicion en RAM.
  2. **Generador de contrasenas:** Reescritura de `PasswordGenerator.generate()` con distribucion natural aleatoria desde el pool completo, eliminando la division equitativa entre charsets.
  3. **Design System:** Creacion de `AppColors` centralizado (`lib/theme/app_colors.dart`) con constantes semanticas; extension `HexColorParsing` en `lib/shared/extensions/color_extensions.dart`.
  4. **Tipo Passkey:** Agregado `CredentialType.passkey` a los mapas de labels/colores/iconos en `TypeBadge`, `CredentialCard` y `TypeSelector`.
  5. **Home Screen:** FAB contextual por pestana activa (nueva credencial / nueva carpeta / oculto en favoritas); haptic feedback en lock; migracion a `HexColorParsing` extension eliminando duplicacion.
  6. **Error handling global:** `FlutterError.onError` + `PlatformDispatcher.onError` + `runZonedGuarded` en `main.dart`.
  7. **Lint estricto:** `avoid_print: true` (Zero-Print Policy), `prefer_const_constructors`, `prefer_final_locals`, `annotate_overrides` en `analysis_options.yaml`.
  8. **Formulario premium:** Rediseno completo de `CredentialFormScreen` con secciones agrupadas por tipo con bordes acentuados, selector horizontal animado con scale, boton gradient con sombra, transiciones slide+fade entre tipos, haptic feedback y hints contextuales.
  9. **HaveIBeenPwned:** Integracion opt-in de verificacion de breaches usando k-Anonymity (SHA-1 prefix) en `SecurityAuditService` y switch en `SecurityAuditScreen`.
  10. **Auth Biometrico en Copiado:** Requerir validacion biometrica con `AuthHelper.requireAuth()` antes de copiar credenciales desde el BottomSheet de HomeScreen.
  11. **Importacion CSV:** Servicio `CsvImportService` para parsear e importar formatos de Bitwarden, 1Password y Google Chrome.
  12. **Iconos de Marca (Favicons):** Widget `CredentialIcon` para visualizacion automatica de favicons de marcas desde URL con fallback local.
  13. **Refactorizacion de Pantallas:** Extraccion de subwidgets de `HomeScreen` y `CredentialFormScreen` a archivos individuales en `widgets/`, reduciendo la complejidad.
  14. **Shimmer Loader:** Widget `ShimmerLoader` custom animado integrado como esqueleto de carga en `HomeScreen`.
  15. **Bugfix de Recuperacion:** Solucion a excepcion en decodificacion de recovery codes cambiando de `base64Url` a `base64` estandar para evitar colision de guiones.

---

### ✅ Fase 8.7: Llaves SSH y Cifrado de Sobre Doble — COMPLETADA (2026-06-17)
- **Agentes Principales:** Mezcla de 🛡️ `Auditor_Seguridad_Mobile`, 🧑‍💻 `Desarrollador_Flutter_Core` y 💾 `Ingeniero_Persistencia`.
- **Entregables completados:**
  1. **Llaves SSH:** Añadido `CredentialType.sshKey`, modelo de metadatos `SshKeyMetadata`, mapeo de payload, soporte en selector visual de tipos, formulario con campos monoespacio multilínea, y vista detallada con copiado independiente.
  2. **Cifrado de Sobre Doble:** Creado `DoubleEnvelopeService` (Argon2id + AES-256-GCM a nivel de registro). Migración drift de base de datos a v6 añadiendo columna `isDoubleEncrypted`.
  3. **Seguridad RAM:** Desencriptado al vuelo en widget `_SecretTile` al revelar/copiar pidiendo PIN o Huella dactilar; eliminación de RAM instantánea del texto plano al ocultarse.
  4. **Protección de Auditoría:** Ignorado de claves SSH y Passkeys en chequeo de contraseñas débiles y envíos HaveIBeenPwned en `SecurityAuditService`.
  5. **Pruebas Unitarias:** Creado `double_envelope_service_test.dart` y verificado en verde. 32/32 tests unitarios pasando con éxito.

---

## 🛠️ Fases Pendientes (Roadmap Futuro)

### ⏳ Fase 9: Exportación/Importación Selectiva Segura
- **Agentes Principales:** 💾 `Ingeniero_Persistencia` y 🛡️ `Auditor_Seguridad_Mobile`.
- **Skills involucradas (`GEMINI.md`):** `flutter-working-with-databases`, `clean-code`, `security-best-practices`.
- **Entregables / Objetivos:**
  1. Permitir al usuario seleccionar el tipo de credenciales (ej. solo inicios de sesión o tarjetas) a transferir.
  2. Uso de dependencias `share_plus` y `file_picker`.
  3. Encriptación binaria custom (extensión `.skvault` o `.vgvault` bytes), empacando la base SQLite parcial más metadata AES pre-sincronizada para evitar inyección de archivos corruptos. Valorado en estricto cumplimiento del principio del `Auditor_Seguridad_Mobile`.

### ⏳ Fase 10: Integración del Servicio Autocompletado (Autofill OS API)
- **Agentes Principales:** 🏗️ `Arquitecto_Mobile_Sec` y 🧑‍💻 `Desarrollador_Flutter_Core`.
- **Skills involucradas (`GEMINI.md`):** `flutter-interoperating-with-native-apis`, `flutter-architecting-apps`.
- **Entregables / Objetivos:**
  1. Conexión nativa con `AutofillService` en Android y `AutoFill Credential Provider` en iOS.
  2. Parseo de URLs y Hash de paqueterías instaladas para matchear dinámicamente credenciales pertinentes.
  3. Desbloqueo rápido mediante biometría directamente desde el teclado o prompt del sistema operativo antes de inyectar las claves a la aplicación destino.

### ⏳ Fase 11: Teclado Seguro Interno (Anti-Keylogger)
- **Agentes Principales:** 🛡️ `Auditor_Seguridad_Mobile` y 🧑‍💻 `Desarrollador_Flutter_Core`.
- **Skills involucradas (`GEMINI.md`):** `interface-design`, `flutter-building-forms`, `security-best-practices`.
- **Entregables / Objetivos:**
  1. Implementación de un `VirtualKeyboard` propio en las capas de Flutter para entrada en pantallas críticas (Input del Master Password).
  2. Opción de "Scrambled Layout" (Posiciones relocalizadas al azar en forma de PIN y QWERTY alterado) frustrando screen-recording loggers y ataques basados en toques sucios en pantalla.
  3. Limpieza inmediata de los buffers visuales en cada "KeyPress".

### ⏳ Fase 12: Soporte para Passkeys (FIDO2 / WebAuthn)
- **Agentes Principales:** 🏗️ `Arquitecto_Mobile_Sec` y 🛡️ `Auditor_Seguridad_Mobile`.
- **Skills involucradas (`GEMINI.md`):** `flutter-interoperating-with-native-apis`, `security-best-practices`.
- **Entregables / Objetivos:**
  1. Añadir tipo de credencial especializada para soporte local de perfiles Passkeys.
  2. Integración de Credential Manager nativos en Android y Authentication Service en iOS para el relay y el firmado de aserciones.
  3. Asegurar que las llaves privadas del Passkey permanezcan cifradas en la capa de persistencia mediante el Master Key del usuario.

### ⏳ Fase 13: Autenticación Contextual en Micro-Interacciones y Trazabilidad
- **Agentes Principales:** 🧑‍💻 `Desarrollador_Flutter_Core` y 🛡️ `Auditor_Seguridad_Mobile`.
- **Skills involucradas (`GEMINI.md`):** `flutter-managing-state`, `flutter-animations`.
- **Entregables / Objetivos:**
  1. Uso focalizado de `local_auth` en instantes exactos, como requerir FaceID/TouchID al intentar apretar el botón "Copiar" o el ícono "Revelar Ojo" de contraseñas de altos privilegios.

---

## 3. Commits

Formato OBLIGATORIO (el historial es la guia: `git log --oneline`):

- **UNA sola linea**: `tipo(ambito): descripcion concreta de lo que se hizo`.
  Tipos usados: feat | fix | chore | docs | test. Ambitos tipicos:
  seguridad, staging, e2e, o el nombre de la app/modulo.
- En espanol **sin acentos** (ASCII) — igual que los .ps1.
- **Concreto**: que regla/endpoint/fix exacto (puede ser una linea larga
  con detalles separados por `:` y `;`), pero **NUNCA** cuerpo
  multiparrafo, bullets ni resumen de toda la sesion.
- **SIN pies de firma**: nada de "Co-Authored-By: Claude …",
  "🤖 Generated with Claude Code" ni similares, aunque el harness lo
  sugiera por defecto — esta regla del proyecto tiene prioridad.
- Ejemplo real del historial:
  `fix(staging): migrate con pooler de sesion (MIGRATE_DATABASE_URL) por los advisory locks de golang-migrate`

---

## 4. Comandos Útiles de Flujo Diario
Para acatar las configuraciones, deberás usar frecuentemente:
*   **Build Runner (Autogeneración Freezed/GetIt):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
*   **Pruebas Criptográficas/Lógicas (Crucial para Fase 2):**
    ```bash
    flutter test
    ```
*   **Levantar App:**
    ```bash
    flutter run
    ```

---

## 5. Estado de Archivos Clave (referencia rápida)

| Capa | Archivo | Descripción |
|------|---------|-------------|
| Domain | `features/vault_access/domain/entities/` | Vault, MasterKeyConfig, VaultSession |
| Domain | `features/credentials/domain/entities/` | Credential, Category, Folder |
| Domain | `features/settings/domain/entities/` | AppSecuritySettings |
| Domain | `features/password_generator/domain/password_generator.dart` | Generador con distribución natural |
| Infrastructure | `core/infrastructure/security/security_service_impl.dart` | AES-256-GCM + Argon2id en Isolate |
| Infrastructure | `core/infrastructure/security/session_manager.dart` | Clave maestra en RAM |
| Infrastructure | `core/infrastructure/database/app_database.dart` | Drift SQLite (Credentials, Folders, History) |
| Infrastructure | `core/services/vault_export_service.dart` | Export/import con zeroing de key |
| Infrastructure | `core/services/` | SecurityAuditService, RecoveryService |
| Theme | `theme/app_colors.dart` | Paleta semántica centralizada |
| Shared | `shared/extensions/color_extensions.dart` | HexColorParsing extension |
| Presentation | `features/credentials/presentation/home_screen.dart` | Navigation + Search reactivo + FAB contextual |
| Presentation | `features/credentials/presentation/credential_form_screen.dart` | Formulario premium con secciones por tipo |
| Presentation | `features/credentials/presentation/security_audit_screen.dart` | Consola de evaluación de salud Vault |
| Presentation | `features/vault_access/presentation/recovery_screen.dart` | Módulo de Recuperación por Token 32B |
| DI | `app/di/injection.dart` + `register_module.dart` | get_it + injectable |
| Build | `build_runner` | Entidades y DTO generados en sync |
| Config | `analysis_options.yaml` | Lint estricto: avoid_print, prefer_const |

*FIN DEL CONTEXTO Y MANUAL DE OPERACIONES. Fase actual: **8.7 — Llaves SSH y Cifrado Doble COMPLETADO. Listo para planificar la aplicación de escritorio.***
