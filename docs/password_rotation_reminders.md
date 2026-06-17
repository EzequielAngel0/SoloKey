# Recordatorios de Rotación de Contraseñas (Granular / Por Credencial)

Este documento detalla la especificación técnica, el diseño de la interfaz y la arquitectura para la funcionalidad de **Recordatorios de Rotación de Contraseñas a nivel granular (individual por credencial)**. 

---

## 1. Recomendación de Diseño: Enfoque Granular vs. Global

Para evitar la "fatiga de notificaciones" (el usuario ignora las alertas cuando recibe demasiados recordatorios sin importancia), se ha diseñado un **enfoque granular por credencial**:

1. **Uso de canales críticos:** El usuario puede activar recordatorios estrictos (ej. cada 30 días) para cuentas bancarias, correos principales o accesos de trabajo.
2. **Silencio para cuentas secundarias:** Las cuentas de ocio o servicios no críticos permanecen configuradas en "No recordar" por defecto.
3. **Personalización total:** Cada credencial controla su propia expiración de forma independiente.

---

## 2. Opciones de Configuración (En el Formulario de la Credencial)

Al crear o editar una credencial en el formulario (`CredentialFormScreen`), se incluye un campo desplegable en una sección colapsable de **"Seguridad avanzada"** con las siguientes opciones:

| Opción | Comportamiento | Días de Expiración |
| :--- | :--- | :--- |
| **No recordar** (Default) | No genera alertas de rotación para esta cuenta. | `none` |
| **Cada mes** | Alerta si la contraseña no se ha editado en 30 días. | `30` |
| **Cada 3 meses** | Alerta si la contraseña no se ha editado en 90 días. | `90` |
| **Cada 6 meses** | Alerta si la contraseña no se ha editado en 180 días. | `180` |
| **Personalizado** | Campo numérico para definir la cantidad exacta de días o meses. | `X` (mínimo 7 días) |

---

## 3. Flujo de Usuario (UI/UX)

1. **Creación/Edición:**
   * En el formulario de añadir/editar contraseña, debajo del campo de contraseña, hay un interruptor o selector llamado **"Recordatorio de Rotación"**.
   * Si está activo, muestra un Dropdown con las frecuencias predefinidas (1 mes, 3 meses, 6 meses, Personalizado).
   * Al guardar, los datos se almacenan en el registro de la base de datos de esa credencial.

2. **Notificación Local Dirigida:**
   * La notificación push local se despacha con el nombre específico de la cuenta que expira:
     * **Título:** `Rotación de Contraseña Requerida`
     * **Mensaje:** `Tu contraseña para "[Título de Cuenta/ej: Gmail]" no ha sido actualizada en más de X meses. Cámbiala ahora para mantener tu seguridad.`
     * **Acciones rápidas:** 
       * **[Cambiar contraseña]:** Abre el formulario de edición de esta credencial directamente.
       * **[Posponer]:** Evita volver a notificar por 3 días.

---

## 4. Estructura de Base de Datos (Drift / SQLite)

Modificaremos la tabla de credenciales (`CredentialEntries`) en Drift agregando campos para persistir esta configuración a nivel de fila:

```dart
// lib/core/infrastructure/database/app_database.dart

class CredentialEntries extends Table {
  // ... campos existentes (id, title, encryptedPayload, updatedAt, etc.)

  // Tipo de intervalo (none, monthly, quarterly, semiAnnually, custom)
  TextColumn get rotationInterval => text().withDefault(const Constant('none'))();
  
  // Días personalizados si el intervalo es 'custom'
  IntColumn get customRotationDays => integer().nullable()();
  
  // Timestamp Epoch MS de la última vez que se le notificó al usuario sobre esta contraseña
  IntColumn get lastRotationPromptedAt => integer().nullable()();
}
```

---

## 5. Implementación del Worker en Segundo Plano

La lógica de fondo se ejecuta periódicamente (ej: una vez al día) en el dispositivo a través de `workmanager` (móvil) o el hilo del daemon de bandeja (escritorio):

1. **Lectura:** Obtiene todas las credenciales activas del almacén.
2. **Cálculo de Expiración:** Para cada credencial con un intervalo asignado:
   * Calcula la fecha de expiración: `fechaExpiracion = updatedAt + intervalInDays`.
   * Verifica si la fecha actual supera `fechaExpiracion`.
3. **Prevención de Alertas Repetitivas:** Compara la fecha actual con `lastRotationPromptedAt` para asegurarse de no molestar al usuario repetidamente si ya se le notificó hace menos de 7 días.
4. **Despacho:** Lanza una notificación local dirigida para cada credencial expirada.

---

## 6. Panel de Auditoría

En la sección de **Auditoría de Seguridad (Security Audit)** del menú principal, se creará una pestaña o tarjeta llamada **"Contraseñas Expiradas"**. Aquí se listarán de forma prioritaria todas las credenciales que hayan superado su periodo de rotación, con un botón rápido para editarlas y cambiarlas.
