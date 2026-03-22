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

  // Second pass: clean up fringe — any pixel adjacent to a transparent pixel
  // that is near-white gets its alpha reduced proportionally to its whiteness.
  // This removes the anti-aliased white halo without touching interior whites.
  const fringeThreshold = 200;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = transparent.getPixel(x, y);
      if (px.a.toInt() == 0) continue; // already transparent

      // Check if any neighbour is transparent.
      bool hasTransparentNeighbour = false;
      for (final (nx, ny) in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]) {
        if (nx < 0 || nx >= size || ny < 0 || ny >= size) continue;
        if (transparent.getPixel(nx, ny).a.toInt() == 0) {
          hasTransparentNeighbour = true;
          break;
        }
      }
      if (!hasTransparentNeighbour) continue;

      final r = px.r.toInt();
      final g = px.g.toInt();
      final b = px.b.toInt();
      // Whiteness 0..255
      final whiteness = (r + g + b) ~/ 3;
      if (whiteness > fringeThreshold) {
        // Scale alpha down — the whiter the pixel, the more transparent it becomes.
        final newAlpha = ((255 - whiteness) * 255 ~/ (255 - fringeThreshold)).clamp(0, 255);
        transparent.setPixelRgba(x, y, r, g, b, newAlpha);
      }
    }
  }

  // Auto-crop: find bounding box of non-transparent pixels.
  int minX = size, maxX = 0, minY = size, maxY = 0;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = transparent.getPixel(x, y);
      if (px.a.toInt() > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Add 4% padding around content.
  final contentW = maxX - minX;
  final contentH = maxY - minY;
  final pad = ((contentW > contentH ? contentW : contentH) * 0.04).toInt();
  final cropX = (minX - pad).clamp(0, size - 1);
  final cropY = (minY - pad).clamp(0, size - 1);
  final cropW = (maxX - minX + pad * 2 + 1).clamp(1, size - cropX);
  final cropH = (maxY - minY + pad * 2 + 1).clamp(1, size - cropY);

  final cropped = img.copyCrop(transparent, x: cropX, y: cropY, width: cropW, height: cropH);

  // Scale cropped content back to 1024x1024.
  final scaled = img.copyResize(cropped, width: size, height: size,
      interpolation: img.Interpolation.cubic);

  // Save transparent version (Android fg)
  File('assets/icon/icon_fg.png').writeAsBytesSync(img.encodePng(scaled));
  print('Done — assets/icon/icon_fg.png (transparent background, cropped)');

  // iOS version: composite onto dark background (#1A1A1A)
  final bg = img.Image(width: size, height: size);
  img.fill(bg, color: img.ColorRgb8(0x1A, 0x1A, 0x1A));
  img.compositeImage(bg, scaled);
  File('assets/icon/icon_ios.png').writeAsBytesSync(img.encodePng(bg));
  print('Done — assets/icon/icon_ios.png (dark background for iOS)');
}
