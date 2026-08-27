allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir("dirs" to "${rootProject.projectDir}/unityLibrary/libs")
    }
    
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    plugins.withId("com.android.library") {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespace.invoke(android)
                if (currentNamespace == null || (currentNamespace as? String)?.isEmpty() == true) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val fallbackNamespace = when (project.name) {
                        "flutter_unity_widget" -> "com.xraph.plugin.flutter_unity_widget"
                        else -> "com.plugin.${project.name.replace("-", "_").replace(":", "_")}"
                    }
                    setNamespace.invoke(android, fallbackNamespace)
                }
            } catch (_: Exception) {
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

