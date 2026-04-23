// lib/photo_file_image_io.dart
// Android/iOS — creates a FileImage from a file path.

import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider photoFileImage(String path) => FileImage(File(path));
bool photoFileExists(String path) => File(path).existsSync();
