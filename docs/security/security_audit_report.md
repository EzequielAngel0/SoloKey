# SoloKey — Reporte de Seguridad
**Fecha:** 2026-03-30  
**Versión analizada:** 1.0.0+1  
**Analista:** Auditor_Seguridad_Mobile (Antigravity AI)

---

## 📋 Resumen Ejecutivo

SoloKey presenta una **arquitectura criptográfica sólida y bien diseñada**. El uso de Argon2id, AES-256-GCM, aislamiento en `Isolate`, borrado activo de la clave en memoria (`fillRange(0)`), `FLAG_SECURE` nativo en Android y limpieza automática del portapapeles demuestran un nivel de madurez de seguridad superior al promedio de las aplicaciones móviles.

El análisis no encontró vulnerabilidades críticas que expongan directamente la bóveda de datos. Sin embargo, se identificaron **6 hallazgos de riesgo medio/bajo** con caminos de explotación teóricos que deben ser evaluados antes de una distribución pública amplia.

---

## 🚨 Hallazgos por Severidad

### CRÍTICO — Ninguno ✅

No se encontraron rutas de acceso directo a credenciales sin la contraseña maestra.

---

### 🟠 RIESGO MEDIO

#### [SEC-001] El código de recuperación se copia al portapapeles sin el timer de limpieza automática
- **Archivo:** `lib/features/vault_access/presentation/recovery_screen.dart` — Línea 331
- **Descripción:** Cuando el usuario copia su código de recuperación en la pantalla de setup, se usa `Clipboard.setData()` directamente en lugar del `ClipboardService` con timer de limpieza. Esto significa que el código de 256 bits que puede desbloquear toda la bóveda permanece en el portapapeles del sistema indefinidamente, a diferencia de las contraseñas normales que se limpian automáticamente en 30s.
- **Impacto:** Una app maliciosa o un usuario con acceso físico al dispositivo desbloqueado podría leer el portapapeles y obtener el código de recuperación después de minutos u horas.
- **Código afectado:**
  ```dart
  // recovery_screen.dart L331 — SIN limpieza automática
  Clipboard.setData(ClipboardData(text: code));
  ```
- **Recomendación:** Reemplazar con `getIt<ClipboardService>().copySecure(code)`.

---

#### [SEC-002] El archivo temporal .vgvault no se elimina tras compartirlo
- **Archivo:** `lib/core/services/vault_export_service.dart` — Líneas 62-72
- **Descripción:** El archivo de exportación se crea en `getTemporaryDirectory()` pero no hay ningún `file.delete()` tras el `SharePlus.instance.share()`. En Android, los archivos en directorio temporal son accesibles por otras aplicaciones que tengan permiso de almacenamiento, y algunos fabricantes retienen estos archivos por largo tiempo.
- **Impacto:** Bajo en Android moderno (scoped storage), pero el archivo cifrado de respaldo queda expuesto en el sistema de archivos más tiempo del necesario.
- **Código afectado:**
  ```dart
  // vault_export_service.dart L67-72
  await SharePlus.instance.share(ShareParams(...));
  // ← Aquí falta: await file.delete();
  ```
- **Recomendación:** Envolver en `try/finally` y eliminar el archivo tras compartirlo.

---

#### [SEC-003] La contraseña maestra viaja como `String` en texto plano en memoria
- **Archivo:** `lib/features/vault_access/application/vault_state_provider.dart` — Línea 38
- **Descripción:** El parámetro `masterPassword` es un `String` de Dart. Los `String` en Dart son inmutables e internados en el pool de strings del GC — no pueden ser borrados activamente de memoria como se hace con `Uint8List.fillRange`. Esto significa que la contraseña maestra puede persistir en el heap de la JVM/ART hasta el siguiente ciclo de GC.
- **Impacto:** En escenarios de análisis forense de memoria del proceso (root + herramientas avanzadas), la contraseña en texto plano podría ser extraída de un volcado del heap.
- **Aclaración importante:** Esta es una **limitación fundamental del lenguaje Dart**, no un error de implementación. La misma limitación la tienen Bitwarden y otros gestores en la capa de UI.
- **Código afectado:**
  ```dart
  // vault_state_provider.dart L38
  Future<void> unlock(String masterPassword) async { ... }
  ```
- **Recomendación:** Documentar explícitamente como limitación conocida (ya está comentado en `session_manager.dart`). Como mejora futura, explorar el uso de `Uint8List` desde el form hasta el KDF, convirtiendo el contenido del `TextEditingController` inmediatamente.

---

#### [SEC-007] El secreto TOTP permanece en claro en el widget tree (`_TotpTile`)
- **Archivo:** `lib/features/credentials/presentation/credential_detail_screen.dart` — Línea 123
- **Descripción:** `credential.password!` (el secreto TOTP) se pasa como `String` a `_TotpTile` y es retenido por el widget tree. Como el TOTP se recalcula periódicamente cada segundo para refrescar la visualización del token temporal, este secreto permanece expuesto en el heap durante toda la visualización del detalle de la credencial.
- **Impacto:** Bajo-Medio. Al igual que con SEC-003, un análisis forense de la memoria RAM del proceso (requiere privilegios root) podría revelar el secreto TOTP mientras la pantalla de detalle esté abierta.
- **Recomendación:** Considerar a futuro realizar el cálculo del código OTP en un Isolate secundario de fondo y pasar solo el código temporal generado (String de 6 dígitos) al árbol de widgets, borrando la clave secreta lo antes posible.

---

### 🟡 RIESGO BAJO

#### [SEC-004] `obscureOnBackground` está desactivado por defecto
- **Archivo:** `lib/features/settings/domain/entities/app_security_settings.dart` — campo `obscureOnBackground`
- **Descripción:** El flag `obscureOnBackground` que controla el `FLAG_SECURE` no está activo por defecto según los defaults de `AppSecuritySettings`. Esto significa que en la primera instalación, hasta que el usuario configure sus preferencias, las capturas de pantalla del sistema (y miniaturas del "recent apps" de Android) pueden mostrar el contenido de la bóveda.
- **Impacto:** Un atacante con acceso físico puede ver la bóveda en la vista de aplicaciones recientes.
- **Recomendación:** Cambiar el default de `obscureOnBackground` a `true` en `AppSecuritySettings`.

---

#### [SEC-005] `android:label` del Manifest no usa nombre de branding
- **Archivo:** `android/app/src/main/AndroidManifest.xml` — Línea 10
- **Descripción:** El label de la aplicación en Android es `"password_manager"` (el nombre técnico del paquete) en lugar del nombre de marca `"SoloKey"`. Esto es un problema menor de privacidad: en la lista de aplicaciones instaladas del dispositivo o en notificaciones del sistema, la app puede aparecer con un nombre técnico que la identifica explícitamente como un gestor de contraseñas, lo que puede ser indeseable para usuarios que buscan privacidad.
- **Recomendación:** Cambiar a `android:label="SoloKey"` o mejor aún, usar `android:label="@string/app_name"` con el string definido en `res/values/strings.xml`.

---

#### [SEC-006] Falta `allowBackup="false"` en el Manifest de Android
- **Archivo:** `android/app/src/main/AndroidManifest.xml` — Línea 9
- **Descripción:** El tag `<application>` no incluye `android:allowBackup="false"`. Por defecto en Android, las apps pueden ser respaldadas automáticamente por Google Backup (Android Auto Backup), lo que podría copiar la base de datos SQLite cifrada de Drift a los servidores de Google. Aunque el contenido está cifrado (por lo que el backup no expone datos directamente), la clave derivada puede **no** estar incluida en el backup, lo que puede dejar a usuarios con backups inconsistentes o errores de descifrado tras restaurar.
- **Impacto:** Posible inconsistencia en restauraciones. El `SharedPreferences` y `SecureStorage` generalmente se excluyen automáticamente, pero la DB de Drift puede no estarlo.
- **Recomendación:** Añadir `android:allowBackup="false"` explícitamente en el manifest, o configurar reglas de backup granulares para excluir la base de datos.

---

## ✅ Fortalezas de Seguridad Identificadas

| Área | Implementación | Valoración |
|---|---|---|
| KDF | Argon2id con 64MB RAM / 3 iteraciones (OWASP mínimos) | ✅ Excelente |
| Cifrado en reposo | AES-256-GCM (AEAD autenticado) | ✅ Excelente |
| IV/Nonce | Generado por `aesGcm.newNonce()` por operación | ✅ Correcto — Sin reutilización |
| Aislamiento de ops costosas | `Isolate.run()` para Argon2id y AES | ✅ Correcto |
| Clave en memoria | `Uint8List.fillRange(0)` al bloquear | ✅ Buena práctica |
| Portapapeles | `ClipboardService` con borrado automático configurable | ✅ Excelente |
| Captura de pantalla | `FLAG_SECURE` vía MethodChannel nativo en Android | ✅ Correcto |
| Biometría | `local_auth` con AES key en SecureStorage | ✅ Maduro |
| Auto-lock | Timer de inactividad + lock al background | ✅ Implementado |
| Código de recuperación | Hash SHA-256 del código + encrypt de master key | ✅ Diseño seguro |
| GCM Tag validation | `SecretBox` de `cryptography` valida la autenticidad | ✅ Correcto |
| Logs en producción | Sin `print()` ni `debugPrint()` en código crítico | ✅ Limpio |
| GoRouter debug | `debugLogDiagnostics: false` en el router | ✅ Correcto |

---

## 🗺️ Plan de Acción Recomendado

| ID | Prioridad | Esfuerzo | Acción |
|---|---|---|---|
| SEC-001 | Alta | Muy bajo | Reemplazar `Clipboard.setData()` por `ClipboardService.copySecure()` en recovery_screen |
| SEC-004 | Media | Muy bajo | Cambiar default de `obscureOnBackground` a `true` |
| SEC-006 | Media | Muy bajo | Añadir `android:allowBackup="false"` al Manifest |
| SEC-005 | Baja | Muy bajo | Cambiar `android:label` a `"SoloKey"` |
| SEC-002 | Baja | Bajo | Eliminar archivo temporal `.vgvault` tras exportar |
| SEC-003 | Informativo | Alto | Documentar como limitación conocida de Dart |
| SEC-007 | Informativo | Medio | Calcular códigos TOTP en isolates secundarios para no exponer el secreto en el widget tree |

---

*Reporte generado el 2026-03-30 para SoloKey v1.0.0+1*
