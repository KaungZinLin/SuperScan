plugins {
    // Change '8.1.0' to '8.11.1' to match what Flutter/Gradle is already using
    id("com.android.application") version "8.11.1" apply false
    id("com.android.library") version "8.11.1" apply false

    // Ensure your Kotlin version is high enough (1.9.0+ is usually safe for AGP 8.x)
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false

    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}

// ... the rest of your file (allprojects, subprojects, etc.)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
