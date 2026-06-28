# Requerimientos e Implementación de Seguridad

## 1. Gestión de la Contraseña Maestra
- La contraseña maestra **nunca se almacena en el dispositivo ni en texto plano ni hasheada directamente**.
- Se utiliza un algoritmo **KDF (Key Derivation Function)** seguro como Argon2id o PBKDF2 junto con un `salt` aleatorio único por instalación para derivar una **Clave de Cifrado de Datos (DEK)**.
- Para verificar si la contraseña maestra es correcta al abrir la app, la app intentará descifrar un fragmento de datos conocido de `MasterKeyConfig` o validar un hash Argon2.

## 2. Cifrado de Datos Sensibles
- Todas las credenciales almacenadas en SQLite estarán cifradas empleando **AES de 256-bit** en modo autenticado (por ejemplo, **AES-GCM**). Esto protegerá contraseñas, **API Keys**, **Access Tokens**, notas y campos personalizados.
- Se recomienda cifrar la carga útil (payload) de la credencial completa (ej. serializada en JSON) para garantizar que todo dato sensible quede ofuscado de raíz.
- La lógica de negocio (`Domain`) manipulará las entidades en texto plano solo mientras la sesión esté activa, mientras que la capa de `Infrastructure` se encargará de encriptar/desencriptar a la hora de guardar/leer de SQLite.

## 3. Almacenamiento Seguro (Keystore)
- Se integrará el `Android Keystore` a través de librerías como `flutter_secure_storage` para proteger metadatos sensibles, como parámetros criptográficos o derivadores secundarios para el desbloqueo biométrico.
- El vector de inicialización (IV) de cada cifrado debe ser aleatorio y generado de forma segura.

## 4. Seguridad Operativa
- **Limpieza de Portapapeles:** Se empleará un timer para limpiar automáticamente el clipboard transcurridos los segundos configurados en `AppSecuritySettings`.
- **Bloqueo por Inactividad:** Un canal nativo o `WidgetsBindingObserver` global conectado al ciclo de vida de Flutter monitoreará los eventos de pausa/resumen e inactividad touch.
- **Background Obscuring:** Uso de métodos nativos (`FLAG_SECURE` en Android) o wrappers como `flutter_windowmanager` para evitar capturas de pantalla o previsualizaciones en la vista de apps recientes (App Switcher).
- **Protección de Logs:** Cuidado extremo de no hacer `print()` o registrar variables que contengan datos en texto plano.
