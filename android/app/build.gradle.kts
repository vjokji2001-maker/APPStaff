plugins {
    id("com.android.application") 
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val releaseKeystoreFile = rootProject.file("app/upload-keystore.jks")
val releaseKeystoreFile = rootProject.file("app/upload-keystore.jks")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val hasReleaseSigning =
    keystorePropertiesFile.exists() &&
    releaseKeystoreFile.exists() &&
    keystoreProperties["storePassword"] != null &&
    keystoreProperties["keyAlias"] != null &&
    keystoreProperties["keyPassword"] != null

android {
    namespace = "com.example.staff_mate"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable core library desugaring for older API levels
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.pranam.smartmate"
        minSdk = flutter.minSdkVersion                                    // Android 6.0 (API 23) — broad compatibility
        targetSdk = 35
        versionCode = 3
        versionName = "1.2"
        
        // Enable multi-DEX for apps with many dependencies
        multiDexEnabled = true
    }

  signingConfigs {
    if (hasReleaseSigning) {
        create("release") {
            storeFile = releaseKeystoreFile
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
}
buildTypes {
    getByName("release") {
        if (hasReleaseSigning) {
            signingConfig = signingConfigs.getByName("release")
        }
        isMinifyEnabled = false
        isShrinkResources = false   
    }


}


}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.biometric:biometric:1.1.0")
    // Core library desugaring for Java 8+ APIs on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // Multi-DEX support
    implementation("androidx.multidex:multidex:2.0.1")
}
