plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hand2voice"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.hand2voice"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        multiDexEnabled = true
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    aaptOptions {
        noCompress("tflite")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // // MediaPipe Solutions
    // implementation('com.google.mediapipe:tasks-vision:0.10.29')
    //
    // val camerax_version = "1.3.0"
    // implementation("androidx.camera:camera-core:$camerax_version")
    // implementation("androidx.camera:camera-camera2:$camerax_version")
    // implementation("androidx.camera:camera-lifecycle:$camerax_version")
    // implementation("androidx.camera:camera-view:$camerax_version")

    // MediaPipe Solutions
    implementation("com.google.mediapipe:tasks-vision:0.10.14")
    
    // Image processing
    implementation("androidx.camera:camera-core:1.3.0")
    implementation("androidx.camera:camera-camera2:1.3.0")
    
    // Kotlin coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")

    // TensorFlow Lite
    // implementation("org.tensorflow:tensorflow-lite:2.17.0")
    // implementation("org.tensorflow:tensorflow-lite-support:0.4.4")
    // implementation("org.tensorflow:tensorflow-lite-gpu:2.17.0")
    implementation("com.google.ai.edge.litert:litert:1.0.1")

    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.16.1") {
        exclude(group = "org.tensorflow", module = "tensorflow-lite")
        exclude(group = "org.tensorflow", module = "tensorflow-lite-api")
    }
}
