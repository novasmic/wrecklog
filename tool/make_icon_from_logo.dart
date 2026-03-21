// tool/make_icon_from_logo.dart
// Strips white background from Wrecklog_logo.png, then produces:
//   assets/icon/icon_fg.png  — transparent background (Android)
//   assets/icon/icon_ios.png — white background removed, dark bg (iOS, no alpha)
// Run with: dart run tool/make_icon_from_logo.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;

  final srcBytes = File('assets/logo/Wrecklog_logo.png').readAsBytesSync();
  final src = img.decodePng(srcBytes);
  if (src == null) {
    print('ERROR: could not decode Wrecklog_logo.png');
    exit(1);
  }

  // Resize to 1024x1024
  final resized = img.copyResize(src, width: size, height: size,
      interpolation: img.Interpolation.cubic);

  // Use flood-fill from all four corners to find background pixels.
  // This avoids removing white pixels inside the logo (e.g. the "Log" text).
  const threshold = 230;
  final transparent = img.Image(width: size, height: size, numChannels: 4);

  // Copy all pixels across first.
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = resized.getPixel(x, y);
      transparent.setPixelRgba(x, y, px.r.toInt(), px.g.toInt(), px.b.toInt(), 255);
    }
  }

  // BFS flood-fill from each corner — mark background pixels.
  final visited = List.generate(size, (_) => List.filled(size, false));
  final queue = <(int, int)>[];

  bool isBackground(int x, int y) {
    if (visited[y][x]) return false;
    final px = resized.getPixel(x, y);
    return px.r.toInt() > threshold && px.g.toInt() > threshold && px.b.toInt() > threshold;
  }

  void enqueue(int x, int y) {
    if (x < 0 || x >= size || y < 0 || y >= size) return;
    if (visited[y][x]) return;
    if (isBackground(x, y)) {
      visited[y][x] = true;
      queue.add((x, y));
    }
  }

  // Seed from all four edges.
  for (int i = 0; i < size; i++) {
    enqueue(i, 0);
    enqueue(i, size - 1);
    enqueue(0, i);
    enqueue(size - 1, i);
  }

  while (queue.isNotEmpty) {
    final (x, y) = queue.removeLast();
    transparent.setPixelRgba(x, y, 0, 0, 0, 0); // make transparent
    enqueue(x - 1, y);
    enqueue(x + 1, y);
    enqueue(x, y - 1);
    enqueue(x, y + 1);
  }

  // Save transparent version (Android fg)
  File('assets/icon/icon_fg.png').writeAsBytesSync(img.encodePng(transparent));
  print('Done — assets/icon/icon_fg.png (transparent background)');

  // iOS version: composite transparent logo onto dark background (#1A1A1A)
  final bg = img.Image(width: size, height: size);
  img.fill(bg, color: img.ColorRgb8(0x1A, 0x1A, 0x1A));
  img.compositeImage(bg, transparent);
  File('assets/icon/icon_ios.png').writeAsBytesSync(img.encodePng(bg));
  print('Done — assets/icon/icon_ios.png (dark background for iOS)');
}
