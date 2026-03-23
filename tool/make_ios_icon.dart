// tool/make_ios_icon.dart
// Composites icon_fg.png onto a solid green background and saves as icon_ios.png.
// Run with: dart run tool/make_ios_icon.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final green = img.ColorRgb8(0x2E, 0x7D, 0x32);
  const size = 1024;

  // Load foreground
  final fgBytes = File('assets/icon/icon_fg.png').readAsBytesSync();
  final fg = img.decodePng(fgBytes);
  if (fg == null) {
    print('ERROR: could not decode icon_fg.png');
    exit(1);
  }

  // Create solid green background
  final bg = img.Image(width: size, height: size);
  img.fill(bg, color: green);

  // Resize foreground to 1024x1024 and composite onto background
  final fgResized = img.copyResize(fg, width: size, height: size,
      interpolation: img.Interpolation.cubic);
  img.compositeImage(bg, fgResized);

  // Save
  final outBytes = img.encodePng(bg);
  File('assets/icon/icon_ios.png').writeAsBytesSync(outBytes);
  // ignore: avoid_print
  print('Done — assets/icon/icon_ios.png created.');
}
