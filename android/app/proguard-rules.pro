# Prevent R8 from stripping away ML Kit components
-keep class com.google.mlkit.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Keep the GMS (Google Play Services) internal classes that ML Kit relies on
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# Keep annotations to prevent metadata errors
-keepattributes *Annotation*

# Optional: Suppress warnings for missing optional components
-dontwarn com.google.mlkit.**