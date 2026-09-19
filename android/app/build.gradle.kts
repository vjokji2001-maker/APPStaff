plugins {
    id("com.android.application") 
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
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

    // kotlinOptions replaced below android block

    defaultConfig {
        applicationId = "com.pranam.smartmate"
        minSdk = flutter.minSdkVersion // Required for google_mlkit_text_recognition and mobile_scanner
        targetSdk = 35
        versionCode = 4
        versionName = "1.2.1"
        
        // Enable multi-DEX for apps with many dependencies
        multiDexEnabled = true
    }

    lint {
        // Suppress warnings about compileSdk version mismatches in dependencies
        disable.addAll(listOf(
            "GradleCompatible",
            "MissingDimensionActivityCreator",
            "MissingDimensionBuildType",
            "MissingDimensionFlavor"
        ))
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
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
