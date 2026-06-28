# Requisitos de Publicación y Lanzamiento

Este documento detalla los pasos obligatorios y recomendados técnicos, legales y gráficos necesarios para publicar la aplicación en la Google Play Store (Android) y App Store Connect (iOS).

## 🚀 1. Requisitos Técnicos y de Compilación (Release Builds)

### 🤖 Android (Google Play Console)
- [ ] **Application ID Diferenciado**: Asegurar que el `applicationId` en `android/app/build.gradle` sea único (ej. `com.tunombre.appname`).
- [ ] **Keystore de Producción**: Generar y aislar la llave `upload-keystore.jks`. Es vital guardarla fuera de GitHub y configurar el archivo `key.properties` para poder firmar el `.aab`. Si pierdes esta llave nunca podrás actualizar la app.
- [ ] **Configuración de R8 / ProGuard**: Activar la ofuscación de código y reducción de tamaño para la versión `--release`.
- [ ] **Versionado**: Incrementar el `versionCode` sistemáticamente en el `pubspec.yaml`.
- [ ] **Compilación del AAB**: Generar el paquete base final de instalación (`flutter build appbundle --release`).

### 🍏 iOS (App Store Connect)
- [ ] **Cuenta Apple Developer**: Suscripción activa a la consola de Apple ($99/año).
- [ ] **Bundle Identifier**: Configurar un "Bundle ID" que coincida en el Apple Developer Portal y en Xcode.
- [ ] **Certificados y Perfiles**: Generar *Distribution Certificates* y *Provisioning Profiles* directamente desde las cuentas en Xcode, asegurando los Capabilities si se llegase usar Autofill.
- [ ] **Versionado**: El bloque de versión debe ser estricto en el `pubspec.yaml` (ej. `1.0.0+1`).
- [ ] **IPA Encriptado**: Ejecutar `flutter build ipa --release` y distribuir los binarios empleando herramientas como *Transporter* o *Xcode Organizer*.

## 🎨 2. Activos Gráficos (Assets y Logos)

> *Nota: Ya contamos con unos logos base que podremos procesar para esta etapa.*

### Iconos de la App (Launcher Icons)
- [ ] Procesar el logo maestro utilizando scripts como `flutter_launcher_icons` o añadiéndolos manualmente asegurando soporte para resolución Adaptativa (Android M+) y cuadratura estricta para iOS.

### Splash Screen (Pantalla de Carga)
- [ ] Configurar pantalla inicial que use el nuevo logo para evitar transiciones de pantalla en blanco, a través de `flutter_native_splash`.

### Capturas de Pantalla (Screenshots) e Imágenes Promocionales
- [ ] **Play Store**: Requiere sets de capturas para teléfono móvil. Al final también se exige un "Feature Graphic" de cabecera panorámico (1024x500px).
- [ ] **App Store**: Las capturas tienen resoluciones muy estrictas exigiendo al menos muestras de 6.5" y 5.5". Tienen alto control de calidad (no puede haber transparencias raras).

## ⚖️ 3. Requisitos Legales y de Privacidad

- [ ] **URL de Política de Privacidad Web**: Alojar una página sencilla (puede ser gratis con GitHub Pages). **Importante:** Tu política debe declarar y certificar abiertamente el modelo *Local-First* diciendo que de forma literal: **"Ninguna clave o cuenta es subida, monitoreada o almacenada remotamente en ningún servidor, jamás"**.
- [ ] **Cuestionarios Cero-Datos**: Completar exhaustivamente la sección de "Seguridad de Datos" en Google Play, indicando el cifrado local, y asegurando el "App Privacy Details" en Apple. 
- [ ] **Datos de Contacto**: Establecer un correo permanente u organizativo obligatorio para el soporte de ambas tiendas.

## ⚙️ 4. Marketing de Tienda (ASO) y Estructura

- [ ] **Nombre Corto Final**: Nuevo título (30 caracteres de largo en ambas consolas combinadas visualmente).
- [ ] **Descripción Corta / Subtítulo**: (Android: 80 caracteres. iOS: 30 caracteres). Idea central a vender ("Tu gestor de credenciales blindado 100% offline").
- [ ] **Descripción Completa**: Indicar las características robustas (Clean Architecture, algoritmos como Argon2id, el AES-256 local y enfoque estricto en no compartir la metadata con el servidor).
