// ✅ ADICIONE ESTE BLOCO NO INÍCIO:
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
    }
}

// ✅ SEU CÓDIGO ATUAL CONTINUA AQUI:
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define o diretório de build (opcional)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Ajusta o diretório de build dos subprojetos
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Tarefa para limpar o build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}