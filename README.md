# 🛡️ SoloKey

**SoloKey** es un gestor de contraseñas *Local-First* para Android construido en **Flutter**. Diseñado desde cero bajo estrictos estándares de seguridad y con una arquitectura limpia (Clean Architecture), asegura que tus secretos —desde contraseñas y tarjetas hasta códigos TOTP— nunca salgan de tu dispositivo y estén cifrados con grado militar.

---

## ✨ Características Principales

- 📱 **100% Pantalla Nativa y "WOW" Aesthetics:** Diseño oscuro premium con micro-animaciones, menús fluidos y alto contraste.
- 🔐 **Bóveda Cifrada Local-First:** No hay servidores externos, ni sincronización automática en la nube de terceros. Tus datos son enteramente tuyos.
- 🔑 **Soporte TOTP Integrado:** Generador de códigos 2FA embebido. Configúralo pegando el secreto o **escaneando directamente tu código QR**.
- 📂 **Organización por Carpetas:** Clasifica tus secretos en infinitos niveles jerárquicos o guárdalos en tus "Favoritos" para acceso rápido.
- 🔍 **Auditoría de Seguridad Activa:** Analiza en tiempo real contraseñas repetidas, contraseñas débiles y antigüedad de las mismas.
- 🛡️ **Prevención de Capturas de Pantalla:** Aprovecha las banderas nativas de Android (`FLAG_SECURE`) para bloquear grabaciones de tu pantalla.

---

## 🏗️ Arquitectura y Tecnologías

El proyecto fue guiado bajo un estricto principio de **Separación de Responsabilidades** (Dominio, Infraestructura, Presentación) manejado por inyección de dependencias (`get_it` + `injectable`).

- **Framework UI:** [Flutter](https://flutter.dev) (v3.10+)
- **Gestión de Estado:** [Riverpod](https://riverpod.dev) + [Riverpod Generators](https://pub.dev/packages/riverpod_generator)
- **Persistencia SQL:** [Drift (SQLite)](https://drift.simonbinder.eu/) (Guardado de JSONs cifrados y datos opacos)
- **Enrutamiento:** [GoRouter](https://pub.dev/packages/go_router)

---

## 🔒 Postura Criptográfica

SoloKey adopta una postura "Zero-Trust" en el disco, utilizando implementaciones nativas donde es posible:
- **Derivación de Clave (KDF):** Usa **Argon2id** adaptado al procesador.
- **Cifrado Simétrico:** Utiliza **AES-256-GCM**, un algoritmo autenticado (AEAD) asegurando confidencialidad e integridad del payload.
- **Protección de Llaves:** Almacena la *Master Key* Derivada y la Sal temporalmente en RAM de forma oscurecida y confía en el `Android KeyStore` nativo (`flutter_secure_storage`) para persistir llaves criptográficas subyacentes críticas o parámetros locales limitados.

---

## 🚀 Compilación y Ejecución (Getting Started)

### Prerrequisitos
- Flutter SDK `^3.10.4`
- Entorno de desarrollo Android configurado (Android Studio o CLI)

### Generación de archivos (Obligatorio)
Dado que SoloKey usa inyección y modelos inmutables generados (`freezed`, `drift`, `riverpod`), debes correr el `build_runner` tras la primera descarga y antes de compilar:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Ejecutar en dispositivo/emulador
```bash
flutter run
```

### Construcción para Producción (Release)
Si deseas generar el APK con ofuscación de código activada (recomendado por máxima seguridad):
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug_info
```

---

## 💡 Próximos pasos y Roadmap

Toda la documentación está organizada en [docs/](docs/README.md). Puedes visualizar las mejoras planificadas en [docs/planning/feature_ideas.md](docs/planning/feature_ideas.md) y el backlog de estabilización vigente en [docs/planning/pendientes_y_bugs.md](docs/planning/pendientes_y_bugs.md).

---
*Hecho con ♥, Clean Code, y agentes de Arquitectura Segura.*
