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

subprojects {
    fun configureNamespace() {
        val androidExtension = extensions.findByName("android") ?: return

        val namespaceIsMissing =
            runCatching {
                    androidExtension
                        .javaClass
                        .getMethod("getNamespace")
                        .invoke(androidExtension)
                        ?.toString()
                        .isNullOrBlank()
                }
                .getOrDefault(false)

        if (!namespaceIsMissing) {
            return
        }

        val manifestPackage =
            file("src/main/AndroidManifest.xml")
                .takeIf { it.exists() }
                ?.readText()
                ?.let { Regex("""package\s*=\s*"([^"]+)"""").find(it)?.groupValues?.get(1) }

        val fallbackNamespace = manifestPackage ?: "dev.flutter.${project.name.replace('-', '_')}"

        runCatching {
            androidExtension
                .javaClass
                .getMethod("setNamespace", String::class.java)
                .invoke(androidExtension, fallbackNamespace)
        }
    }

    if (state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
