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

// PENTING: dua blok subprojects TERPISAH. Menggabungnya (evaluationDependsOn
// di blok yang sama dengan redirect build dir) menyebabkan :app dievaluasi
// sebelum build dir di-redirect -> libapp.so di-drop dari APK/AAB.
// Lihat flutter issue #186810 & #187388 (gradle_libapp_so_packaging_test).
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Blok TERPISAH (jangan digabung dengan blok redirect build dir / evaluationDependsOn):
// samakan JVM target Java & Kotlin (17) untuk semua modul plugin.
// Mengatasi error "Inconsistent JVM-target compatibility detected" pada
// tflite_flutter (Java 1.8) & package_info_plus (Java 17) saat Kotlin 2.x
// default ke JDK 17. afterEvaluate didaftarkan SEBELUM evaluationDependsOn
// agar tidak terjadi "project already evaluated".
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
