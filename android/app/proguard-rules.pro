# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Keep all Chinese, Japanese, Korean, Devanagari text recogniz#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep MediaPipe classes for ML Kit
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Keep Google ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Keep Flutter Gemma classes
-keep class dev.flutterberlin.flutter_gemma.** { *; }
-dontwarn dev.flutterberlin.flutter_gemma.**
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# Keep Play Core classes (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
