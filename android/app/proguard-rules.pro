# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Kotlin metadata
-keepclassmembers class kotlin.Metadata { *; }

# Keep classes referenced by reflection (common in Android)
-keepattributes *Annotation*, InnerClasses
-keepattributes SourceFile,LineNumberTable

# Keep TensorFlow Lite (CPU & GPU)
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

