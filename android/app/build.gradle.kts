import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Nucleo Rust (ADR-0008, NUC-1): libsolokey_core.so por ABI, de .\tool\build.ps1 -Nucleo -Salida rust\dist.
val solokeyCoreLibs = file("../../rust/dist/jniLibs")
if (!solokeyCoreLibs.isDirectory) {
    throw GradleException("Falta $solokeyCoreLibs: corre .\\tool\\build.ps1 -Nucleo -Salida rust\\dist")
}

android {
    namespace = "com.angelezequiel.solokey"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    sourceSets["main"].jniLibs.srcDir(solokeyCoreLibs)

    compileOptions {
        // Required by flutter_local_notifications (uses java.time APIs).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.angelezequiel.solokey"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Llave de release (PLA-1): vive fuera del repo (%USERPROFILE%\SoloKey-firma) y solo la monta
    // tool/build.ps1, que exporta SOLOKEY_KEY_PROPERTIES. Sin ella, release se firma con la debug
    // (flutter run --release en el host). Los APK los re-firma build.ps1 con la rotacion desde la debug.
    val firma = System.getenv("SOLOKEY_KEY_PROPERTIES")?.let { file(it) }?.takeIf { it.exists() }
    signingConfigs {
        if (firma != null) {
            val p = Properties().apply { firma.inputStream().use { load(it) } }
            create("release") {
                storeFile = File(firma.parentFile, p.getProperty("storeFile"))
                storePassword = p.getProperty("storePassword")
                keyAlias = p.getProperty("keyAlias")
                keyPassword = p.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (firma != null) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.credentials:credentials:1.2.2")
    implementation("androidx.credentials:credentials-play-services-auth:1.2.2")
    // Inline autofill suggestions (chips inside the keyboard, Android 11+).
    implementation("androidx.autofill:autofill:1.1.0")
    // Biometric gate before injecting credentials into the target field.
    implementation("androidx.biometric:biometric:1.1.0")
}
