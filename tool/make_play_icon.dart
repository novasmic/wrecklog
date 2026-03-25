// tool/make_play_icon.dart
// Generates a 512x512 icon for Google Play Store.
// Run with: dart run tool/make_play_icon.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('assets/icon/icon_ios.png').readAsBytesSync());
  if (src == null) {
    // ignore: avoid_print
    print('ERROR: could not decode icon_ios.png');
    exit(1);
  }
  final resized = img.copyResize(src, width: 512, height: 512,
      interpolation: img.Interpolation.cubic);
  File('icon_512.png').writeAsBytesSync(img.encodePng(resized));
  // ignore: avoid_print
  print('Done — icon_512.png saved to Desktop');
}
