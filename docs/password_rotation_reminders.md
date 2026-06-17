# Recordatorios de Rotación de Contraseñas (Granular / Por Credencial)

Este documento detalla la especificación técnica, el diseño de la interfaz y la arquitectura para la funcionalidad de **Recordatorios de Rotación de Contraseñas a nivel granular (individual por credencial)** y su comportamiento multiplataforma (Móvil y Escritorio).

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

## 3. Comportamiento Multiplataforma y Sincronización Automática

Dado que SoloKey es un administrador de contraseñas Local-First con sincronización bidireccional, los recordatorios **se ejecutarán y mostrarán tanto en la aplicación móvil como en la de escritorio**.

### Sincronización de Expiraciones (Autosileciado Cruzado)
1. Si una credencial expira, **ambos dispositivos** pueden mostrar la notificación de forma independiente (según sus propios chequeos locales en segundo plano).
2. Si el usuario actualiza la contraseña en el celular, la fecha `updatedAt` cambia al timestamp actual.
3. Al realizar la sincronización por WiFi:
   * El cambio viaja a la computadora mediante el protocolo Delta-Sync.
   * La base de datos de escritorio actualiza `updatedAt` y limpia el campo `lastRotationPromptedAt`.
   * **Resultado:** La computadora detecta automáticamente que la contraseña ya no está obsoleta, **cancelando o previniendo futuras notificaciones** para esa cuenta sin necesidad de que el usuario haga nada más.

---

## 4. Flujo de Usuario (UI/UX)

1. **Creación/Edición:**
   * En el formulario de añadir/editar contraseña, debajo del campo de contraseña, hay un interruptor o selector llamado **"Recordatorio de Rotación"**.
   * Si está activo, muestra un Dropdown con las frecuencias predefinidas (1 mes, 3 meses, 6 meses, Personalizado).
   * Al guardar, los datos se almacenan en el registro de la base de datos de esa credencial.

2. **Notificación Local Dirigida:**
   * **En Móvil (Android/iOS):** Lanza una notificación nativa. Al presionarla, abre la app y te lleva a los detalles del elemento.
   * **En Escritorio (Windows/macOS/Linux):** Muestra un banner nativo del sistema operativo (Action Center en Windows, Notification Center en macOS) a través de `local_notifier`.
     * **Título:** `Rotación de Contraseña Requerida`
     * **Mensaje:** `Tu contraseña para "[Título de Cuenta]" ha expirado. Cámbiala ahora por seguridad.`
     * **Acciones rápidas:** 
       * **[Cambiar contraseña]:** Abre la ventana de la aplicación de escritorio y enfoca la pantalla de edición de esa credencial.
       * **[Posponer]:** Silencia por 3 días.

---

## 5. Estructura de Base de Datos (Drift / SQLite)

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

## 6. Implementación Técnica en Segundo Plano

La lógica de fondo se ejecuta de la siguiente manera dependiendo de la plataforma:

### A. En el Móvil (Android/iOS)
Utilizaremos `workmanager` en conjunto con `flutter_local_notifications` para programar una tarea periódica de fondo (ej. cada 24 horas) con bajo consumo de batería.

### B. En el Escritorio (Windows/macOS/Linux)
Aprovecharemos que la aplicación de escritorio cuenta con un Daemon en bandeja (`tray_manager` + `window_manager` oculto). 
* Crearemos un temporizador repetitivo en Dart (`Timer.periodic` cada 6 horas) que se ejecuta en segundo plano mientras la aplicación está minimizada en la bandeja del sistema.
* Este temporizador consultará las credenciales locales de SQLite y despachará banners locales usando `local_notifier`.

---

## 7. Panel de Auditoría

En la sección de **Auditoría de Seguridad (Security Audit)** del menú principal (tanto móvil como escritorio), se creará una pestaña o tarjeta llamada **"Contraseñas Expiradas"**. Aquí se listarán de forma prioritaria todas las credenciales que hayan superado su periodo de rotación, con un botón rápido para editarlas y cambiarlas.
