# Arquitectura del Sistema

La aplicación utilizará **Clean Architecture** para garantizar la separación de conceptos y la escalabilidad futura.

## Capas de Arquitectura

1. **Presentation Layer:**
   - Framework: Flutter.
   - Responsabilidad: Interfaz de usuario, animaciones, navegación.
   - Gestión de estado: Riverpod.

2. **Application Layer:**
   - Responsabilidad: Orquestación de casos de uso (Use Cases) y flujos específicos de la aplicación.
   - Componentes: Providers de Riverpod, controladores de estado que coordinan la vista y el dominio.

3. **Domain Layer:**
   - Responsabilidad: Lógica de negocio pura. Totalmente independiente de Flutter y librerías externas.
   - Componentes: Entidades (Entities), Value Objects, contratos de repositorios (Interfaces).

4. **Infrastructure Layer:**
   - Responsabilidad: Implementación de repositorios, almacenamiento, bases de datos y criptografía.
   - Componentes: 
     - **Base de Datos Local:** SQLite (Drift).
     - **Almacenamiento Seguro:** Android Keystore via `flutter_secure_storage`.
     - **Criptografía:** Implementaciones concretas de algoritmos seguros (AES-GCM, Argon2id/PBKDF2).

## Estructura de Directorios (lib/)

- `app/`: Configuración general, entry points.
- `router/`: Configuración de enrutamiento (ej. GoRouter).
- `theme/`: Definición de diseño visual, colores, tipografía.
- `core/`: 
  - `constants/`, `utils/`, `security/`, `error_handling/`
- `features/`: 
  - `vault_access/`
  - `credentials/`
  - `password_generator/`
  - `settings/`
- `shared/`: 
  - `widgets/`, `models/`
