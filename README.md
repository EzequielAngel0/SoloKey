# 🛡️ SoloKey

**SoloKey** es un gestor de contraseñas *Local-First* **multiplataforma** (Android + companion de escritorio en Windows) construido en **Flutter**. Diseñado desde cero bajo estrictos estándares de seguridad y con una arquitectura limpia (Clean Architecture), asegura que tus secretos —desde contraseñas y llaves SSH hasta códigos TOTP— nunca salgan de tus dispositivos y estén cifrados con grado militar. No usa la nube: la sincronización entre tu celular y tu PC es **opcional, punto a punto (P2P) y cifrada de extremo a extremo** sobre tu red local.

---

## ✨ Características Principales

- 📱🖥️ **Móvil + Escritorio:** app Android y companion de escritorio (Windows) que comparten la misma lógica y bóveda cifrada. Layout responsive (lista/maestro-detalle), bandeja del sistema, hotkeys globales y Quick-Fill.
- 🔐 **Bóveda Cifrada Local-First:** sin servidores en la nube. Tus datos son enteramente tuyos; la sincronización es opcional y solo por tu red local.
- 🔄 **Sincronización P2P E2EE:** empareja por QR (X25519 + token) y sincroniza credenciales/carpetas por WebSocket cifrado (AES-256-GCM) con resolución Last-Write-Wins. Reconexión sin re-escanear y sync continua mientras están en la misma red.
- 📲 **Desbloqueo / aprobación desde el celular:** desbloquea o aprueba el inicio de sesión del escritorio con la biometría del celular (token DUK; la contraseña maestra nunca viaja). La PC puede pedir aprobación y el celular recibe una **notificación local** (sin FCM).
- 🔑 **Tipos de credencial:** contraseñas, API keys, notas seguras, TOTP (pegando el secreto o **escaneando el QR**), llaves SSH y respaldo de passkeys.
- 🗂️ **Organización:** carpetas jerárquicas, favoritos, **ocultar/archivar** y **reordenar** credenciales; archivos seguros cifrados.
- 🔍 **Auditoría de Seguridad:** detecta contraseñas repetidas, débiles y antiguas; verificación opt-in de brechas (HaveIBeenPwned, k-Anonymity).
- 🛡️ **Seguridad operacional:** Argon2id + AES-256-GCM, doble sobre por PIN, anti-fuerza-bruta con wipe, auto-lock, teclado seguro anti-keylogger, recordatorios de rotación y `FLAG_SECURE` en Android.

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
- Para móvil: entorno de desarrollo Android configurado (Android Studio o CLI)
- Para escritorio: Windows con "Desktop support" de Flutter habilitado (`flutter config --enable-windows-desktop`)

### Generación de archivos (Obligatorio)
Dado que SoloKey usa inyección y modelos inmutables generados (`freezed`, `drift`, `riverpod`), debes correr el `build_runner` tras la primera descarga y antes de compilar:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Ejecutar en dispositivo/emulador
```bash
flutter run                 # móvil (Android)
flutter run -d windows      # companion de escritorio (Windows)
```

> El instalador de Windows se genera con Inno Setup (`installer/SoloKey.iss`) e
> incluye una tarea opcional para abrir el puerto del servidor de sync en el firewall.
> El empaquetado para macOS/Linux/iOS está pendiente.

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
