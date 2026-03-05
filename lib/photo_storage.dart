// lib/photo_storage.dart
// Conditional export — Flutter picks the right implementation at compile time.
// Android / iOS  → photo_storage_io.dart   (dart:io filesystem)
// Web            → photo_storage_web.dart  (base64 + SharedPreferences)
// Other          → photo_storage_stub.dart (throws UnsupportedError)

export 'photo_storage_stub.dart'
    if (dart.library.io)   'photo_storage_io.dart'
    if (dart.library.html) 'photo_storage_web.dart';
