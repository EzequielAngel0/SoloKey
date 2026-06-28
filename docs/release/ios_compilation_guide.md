# Guía de Adaptación y Compilación para iOS (SoloKey)

Dado que la aplicación SoloKey está fuertemente orientada a las APIs nativas de seguridad de cada sistema operativo (Keychain, Biometría, Autofill), la compilación y adaptación para el entorno de la manzana incluye configuraciones vitales sin las cuales la compilación fallaría o denegaría el acceso del sandbox.

Asegúrate de poseer tu entorno de Xcode configurado o, en su defecto, coordinarlo con el **Arquitecto_Mobile_Sec** a la hora de compilar remotamente (Codemagic o Github Actions).

## 1. Inicialización de la Carpeta iOS
Si la plataforma `ios` aún no existe o hay conflictos crudos, asegúrate de correr en la raíz de Flutter:
```bash
flutter create --platforms=ios .
```
> **Tip:** Usa siempre compilaciones limpias con `flutter clean` seguido de `flutter pub get` antes de transicionar de Android a iOS.

## 2. Permisos Críticos en el `Info.plist`
Por políticas de App Store Review y funcionalidad (Fase 13 y anteriores), en el archivo `ios/Runner/Info.plist` se deben insertar explícitamente las justificaciones a las protecciones del dispositivo:

```xml
<key>NSFaceIDUsageDescription</key>
<string>SoloKey requiere acceso a Face ID/Touch ID para desencriptar localmente la llave maestra y asegurar su bóveda con biometría.</string>

<key>NSCameraUsageDescription</key>
<string>SoloKey requiere acceso a la cámara para capturar los códigos QR de autenticadores 2FA (TOTP).</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Permiso utilizado únicamente si se desea escanear imágenes de códigos QR exportados guardados en galería local.</string>
```

## 3. Requerimientos de Podfile y Versiones Compatibles
Apple deprica estándares rápidamente. Las dependencias SQLite (Drift), criptográficas o los adaptadores biométricos exigen iOS target alto.
En el archivo `ios/Podfile`:

1. Descomentar y actualizar la versión global:
   ```ruby
   platform :ios, '14.0' # 13+ es pasable, 14+ se requiere para soporte robusto de Passkeys
   ```
2. Instalar los CocoaPods luego de inicializar:
   ```bash
   cd ios
   pod repo update
   pod install
   cd ..
   ```

## 4. Capacidades del Sandbox (Xcode Capabilities)
Al abrir el área de diseño (`ios/Runner.xcworkspace`) deberás firmar la aplicación con un perfil de **Apple Developer Program** en activo e instalar las correspondientes "Capabilities" (+ Capability):

- **AutoFill Credential Provider**: Requisito **absoluto** para la *Fase 10*. Esto le dice a iOS Settings que SoloKey es un proveedor capaz de sustituir a iCloud Keychain en apps externas o en Safari.
- **Keychain Sharing** (Recomendado): Permite configurar las directivas para la librería `flutter_secure_storage`. Es en el Keychain interno donde el KDF Parámetros y pedazos oscurecidos de la Key descansan al bloquear y desbloquear.

## 5. Directrices sobre el Almacenamiento Criptográfico (IOSOptions)
Mientras en Android dependes del `EncryptedSharedPreferences`, en iOS es la API subyacente la protagonista. Al construir el `ISecurityService` recuerda instanciar especificidades o sobreescribirlas según la OS:

```dart
const storage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock, 
    // Asegura accesibilidad fluida pero deniega en el re-inicio hasta código
  ),
);
```

## 6. Aislamiento Biométrico y Exportaciones (`.skvault`)
- El puente nativo (MethodChannel `com.solokey/security`) funcionará si lo duplicas en el `AppDelegate.swift` bajo la arquitectura concurrente para enmascarar en iOS el recuadro "Switcher" difusamente.
- Al generar tus archivos binarios custom para transferir, asegúrate que las rutas del Sandbox apunten siempre a `NSApplicationSupportDirectory` o directorios temporales puros ya que no queremos que los archivos encriptados pululen desprovistos en el explorador de iCloud publicamente a menos de ser comandado bajo el botón "Share".
