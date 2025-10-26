plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.note"

    // compileSdk'yi Flutter'ın verdiği değerle bırakabilirsin
    compileSdk = flutter.compileSdkVersion

    // 🔧 UYARIYI ÇÖZMEK İÇİN: NDK sürümünü sabitle
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.note"

        // 🔧 Firebase Auth 23.x için minSdk en az 23 olmalı
        minSdk = 23

        // targetSdk'yi Flutter'ın verdiği değerle bırak
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
