// lib/photo_file_image.dart
// Conditional export — picks the right FileImage implementation.
// Android/iOS → photo_file_image_io.dart   (dart:io FileImage)
// Web/other   → photo_file_image_stub.dart (throws UnsupportedError)

export 'photo_file_image_stub.dart'
    if (dart.library.io) 'photo_file_image_io.dart';
