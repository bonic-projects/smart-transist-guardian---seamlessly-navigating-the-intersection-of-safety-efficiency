# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# General rules for third-party libraries
-keepattributes *Annotation*
-keep class androidx.lifecycle.** { *; }
-dontwarn org.jetbrains.annotations.**
-dontwarn okhttp3.**

# Prevent removal of application resources
-keep class com.your.package.name.** { *; }  # Replace with your actual package name
-keepresources *.png
-keepresources *.xml

# Enable optimizations
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
