// lib/photo_file_image_stub.dart
// Web stub — FileImage not available on web. Never actually called on web
// because kIsWeb guard in photo_manager.dart prevents reaching this path.

import 'package:flutter/material.dart';

ImageProvider photoFileImage(String path) {
  throw UnsupportedError('FileImage not available on this platform.');
}
