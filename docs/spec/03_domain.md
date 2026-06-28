# Entidades del Dominio

Las siguientes entidades representan el núcleo lógico de la aplicación y garantizan la escalabilidad para futuras características (como TOTP o Passkeys).

## 1. Vault
Representa el contenedor maestro en el dispositivo.
- `id`: Identificador único.
- `createdAt`: Fecha de creación.
- `updatedAt`: Fecha de modificación.
- `isInitialized`: Estado de configuración inicial.

## 2. MasterKeyConfig
Almacena exclusivamente metadatos criptográficos, **nunca** la clave.
- `salt`: Sal aleatoria para derivación de clave.
- `kdfAlgorithm`: Algoritmo empleado (ej. Argon2id).
- `kdfParams`: Parámetros (iteraciones, memoria).
- `verificationData`: Hash seguro o texto cifrado de prueba para verificar si la contraseña maestra introducida es correcta.

## 3. Credential
La entidad principal de almacenamiento de información sensible.
- `id`: Identificador único.
- `type`: Tipo de credencial (ej. `Password`, `API_Key`, `Secure_Note`, `Crypto_Wallet`).
- `title`: Nombre reconocible.
- `username`: Nombre de usuario o correo (opcional).
- `password`: Contraseña, Token o API Key principal (cifrada).
- `website`: URL o host de la aplicación.
- `notes`: Información adicional (cifrada).
- `customFields`: Lista de campos clave-valor (ej. "Access Token", "Client Secret") cifrados.
- `categoryId`: Referencia a la categoría.
- `isFavorite`: Bandera booleana.
- `createdAt`, `updatedAt`: Timestamps de auditoría.

## 4. Category
Clasificación lógica de credenciales.
- `id`: Identificador.
- `name`: Nombre (ej. "Trabajo", "Personal").
- `icon`: Icono representativo.
- `createdAt`: Timestamp.

## 5. AppSecuritySettings
Configuraciones del usuario relativas a seguridad operativa.
- `autoLockMinutes`: Tiempo de inactividad antes de bloquear.
- `clearClipboardSeconds`: Tiempo antes de vaciar el portapapeles tras copiar algo.
- `biometricEnabled`: Si está activado o no el acceso rápido con huella/rostro.
- `obscureOnBackground`: Si se debe aplicar un overlay seguro al cambiar de app.

## 6. VaultSession
Gestiona la validez temporal del estado "Desbloqueado".
- `isUnlocked`: Estado booleano.
- `unlockedAt`: Momento en que se desbloqueó.
- `expiresAt`: Límite de validez del ticket de sesión.
