# ── Flutter ────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Firebase (Auth, Messaging, Firestore, Core) ─────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── flutter_secure_storage (AndroidX Security / EncryptedSharedPreferences) ──
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn androidx.security.crypto.**

# ── mobile_scanner (ML Kit barcode) ─────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-dontwarn com.google.mlkit.**

# ── json_serializable models ────────────────────────────────────────────────
# Models are plain Dart (compiled to native, not reflected) so no Java keeps are
# strictly required, but keep annotation attributes for any Gson-style tooling.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# ── Keep native-callback method names used via platform channels ────────────
-keepclassmembers class * {
    @io.flutter.plugin.common.MethodChannel$MethodCallHandler *;
}

# ── Flutter deferred components / Play Core ──────────────────────────────────
# The Flutter embedding references Play Core split-install classes for deferred
# components. This app doesn't use (or bundle) deferred components, so suppress
# R8's missing-class errors for them.
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
