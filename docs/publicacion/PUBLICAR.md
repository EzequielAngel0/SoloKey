# Requisitos de Publicación y Lanzamiento

Este documento detalla los pasos obligatorios y recomendados técnicos, legales y gráficos necesarios para publicar la aplicación en la Google Play Store (Android) y App Store Connect (iOS).

> **Estado (2026-11-14).** Hoy se publica fuera de tiendas: `.\build_release.ps1` deja en `dist/` los APK y el **instalador de
> Windows** (Inno Setup) con `SHA256SUMS.txt`, y se suben a un release de GitHub. Ya resuelto: `applicationId`
> `com.angelezequiel.solokey`, versión en `pubspec.yaml` y la llave de release de Android (PLA-1, 2026-11-20; ver abajo). Falta para tiendas: las
> cuentas (DUE-5), las plantillas legales revisadas (DUE-4) y, para iOS, el hardware (DUE-6). La checklist de abajo es para ese
> momento.

## Firma de Android (PLA-1)

Desde el 2026-11-20 los APK y el `.aab` de `build_release.ps1` salen firmados con la llave de release, que **no está en el
repo**: vive en `%USERPROFILE%\SoloKey-firma\` y el dueño guarda el respaldo de la carpeta entera (DUE-3).

| Archivo | Qué es |
|---|---|
| `solokey-release.jks` | La llave de release: RSA 4096, PKCS12, alias `solokey`, `CN=SoloKey, O=SoloKey`. Certificado SHA-256 `fe207fbb1c3505147937b4c1413c7e15d83569dd22218af0aeda8df9169383c3` |
| `key.properties` | Su contraseña (al azar; nunca se imprime) y el alias. Gradle lo lee por `SOLOKEY_KEY_PROPERTIES`, que solo exporta `tool/build.ps1` |
| `debug.keystore` | Copia de la llave debug con la que se firmó la v1. Certificado SHA-256 `cc9e1130927323bc3a4e643b99c3a2b95a20313d55ff5279096f3146ccc92d80` |
| `solokey.lineage` | La prueba de rotación debug → release, firmada por las dos |

- **Rotación de llave** (Android 9+): la función `firmar` de `tool/build.ps1` firma cada APK con la debug (esquemas v1 y v2, los
  que leen Android 7 y 8) y con la de release más el linaje (v3, `--rotation-min-sdk-version 28`). Así el APK se instala **encima**
  de la app firmada con la debug, sin desinstalar y sin perder la bóveda. En el linaje la debug conserva `installed-data` y no
  tiene `rollback`: un APK firmado solo con la debug ya no se instala encima de uno rotado.
- **Se genera una sola vez**: `.\tool\build.ps1 -GenerarLlave` (en Podman) se niega si ya existe. Si se pierde la carpeta,
  ningún celular puede actualizar sin desinstalar.
- Sin la carpeta, `build_release.ps1 -Target android` falla en vez de sacar APK con la debug; `tool\build.ps1` a secas sale con la
  debug y avisa. `flutter run --release` en el host sigue con la debug.
- Mientras `minSdk` sea menor que 28 (hoy 24) la debug sigue haciendo falta para firmar: es parte del respaldo.
- Play Store: el `.aab` lo firma Gradle con la de release. Si se usa Play App Signing, subir **esta** llave como llave de firma de
  la app (no dejar que Play genere otra), para que los APK de fuera de la tienda y los de Play sigan siendo la misma app.
- Comprobar un APK: `apksigner verify --print-certs -v` dentro de la imagen `solokey-build`: v3 con `fe207fbb…` y v2 con `cc9e1130…`.

## 🚀 1. Requisitos Técnicos y de Compilación (Release Builds)

### 🤖 Android (Google Play Console)
- [ ] **Application ID Diferenciado**: Asegurar que el `applicationId` en `android/app/build.gradle` sea único (ej. `com.tunombre.appname`).
- [x] **Keystore de Producción** (PLA-1, 2026-11-20, ver [Firma de Android](#firma-de-android-pla-1)): Generar y aislar la llave `upload-keystore.jks`. Es vital guardarla fuera de GitHub y configurar el archivo `key.properties` para poder firmar el `.aab`. Si pierdes esta llave nunca podrás actualizar la app.
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
- [x] Logo plano (DIS-4): `flutter test tool/logo/generar_iconos.dart` y luego `dart run flutter_launcher_icons` (adaptativo de Android incluido). iOS no se publica.

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
