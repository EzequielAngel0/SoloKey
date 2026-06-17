# Recordatorios de Rotación de Contraseñas (Password Rotation Reminders)

Este documento detalla la especificación técnica, el diseño de la interfaz y la arquitectura para la funcionalidad de **Recordatorios de Rotación de Contraseñas**. Su objetivo es incentivar a los usuarios a actualizar sus credenciales sensibles de manera periódica, mejorando la seguridad general de sus bóvedas locales.

---

## 1. Opciones de Configuración

La frecuencia de los recordatorios se configurará dentro de la pantalla de **Ajustes de Seguridad**. El usuario dispondrá de las siguientes opciones:

| Opción | Comportamiento | Intervalo Técnico |
| :--- | :--- | :--- |
| **No enviar** | Desactiva por completo los recordatorios de rotación. | `none` |
| **Recordar cada mes** | Evalúa credenciales no modificadas en los últimos 30 días. | `30 días` |
| **Recordar cada 2 meses** | Evalúa credenciales no modificadas en los últimos 60 días. | `60 días` |
| **Personalizado** | Permite definir un intervalo a medida en días o meses. | `X días` (mínimo 7 días) |

---

## 2. Flujo de Usuario (UI/UX)

1. **Configuración en Ajustes:**
   * En **Ajustes de Seguridad**, se añade una sección llamada **"Rotación de Contraseñas"**.
   * Un control dropdown (menú desplegable) muestra las opciones disponibles.
   * Si se selecciona **"Personalizado"**, se despliega un campo numérico para ingresar la cantidad de días o meses junto con un selector de unidad.

2. **Notificación Push Local:**
   * Al cumplirse el plazo establecido sin cambios en credenciales críticas, el sistema despacha una notificación push local en el dispositivo (móvil o escritorio).
   * **Título:** `SoloKey: Rotación de Seguridad`
   * **Mensaje:** `Tienes contraseñas que no has actualizado en más de X meses. Te recomendamos revisarlas para mantener tu bóveda segura.`
   * **Acciones rápidas (Quick Actions) en la notificación:**
     * *[Acción 1]* **Revisar ahora:** Abre la aplicación directamente en la sección de auditoría de seguridad para filtrar por fecha de actualización.
     * *[Acción 2]* **Recordar en 1 día:** Pospone la alerta (snooze) por 24 horas.

---

## 3. Modelo de Datos y Persistencia

Para persistir las preferencias de rotación del usuario, modificaremos la entidad `AppSecuritySettings` en Drift (`SettingsTable`) agregando los siguientes campos sin cifrar (funcionales):

```dart
// lib/features/settings/domain/entities/app_security_settings.dart

enum RotationInterval {
  none,
  monthly,       // 30 días
  biMonthly,     // 60 días
  custom,        // Especificado por el usuario
}

class AppSecuritySettings {
  // ... campos existentes (autoLockMinutes, biometricEnabled, etc.)
  
  final RotationInterval rotationInterval;
  final int customRotationDays; // Solo aplica si rotationInterval == RotationInterval.custom
  final int lastRotationCheck;  // Timestamp Epoch MS de la última notificación/evaluación
}
```

---

## 4. Arquitectura e Implementación Local-First

Dado que la aplicación sigue el paradigma **Local-First con Seguridad Extrema**, no delegaremos la lógica a servidores externos. Todo el proceso ocurrirá localmente en el dispositivo:

### A. Programación en Segundo Plano (Mobile)
Utilizaremos `workmanager` en conjunto con `flutter_local_notifications` para programar una tarea periódica de fondo (ej. cada 24 horas) con bajo consumo de batería:

```dart
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // 1. Inicializar base de datos local y configuración de GetIt
    // 2. Comprobar si los recordatorios están activos (rotationInterval != none)
    // 3. Consultar credenciales cuya fecha 'updatedAt' exceda el intervalo
    // 4. Si existen contraseñas obsoletas y el tiempo transcurrido desde 
    //    'lastRotationCheck' es mayor al intervalo, lanzar notificación local.
    return Future.value(true);
  });
}
```

### B. Notificación en Escritorio
En Windows, macOS y Linux, utilizaremos notificaciones del sistema a través de integraciones del OS (usando paquetes compatibles como `local_notifier` o la API nativa de Windows/macOS) en conjunto con el ciclo de vida del System Tray.

---

## 5. Auditoría Visual (UI en la Bóveda)
Además de la notificación, se creará un filtro dinámico dentro de la pantalla de **Security Audit (Auditoría de Seguridad)** que agrupe y muestre de manera visual las contraseñas marcadas como "Expiradas" o "Pendientes de Rotación", facilitando al usuario su edición rápida uno por uno.
