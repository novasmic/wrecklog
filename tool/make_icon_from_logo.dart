// tool/make_icon_from_logo.dart
// Strips black background from Wrecklog_logo.png, then produces:
//   assets/icon/icon_fg.png  — transparent background (Android)
//   assets/icon/icon_ios.png — black background removed, dark bg (iOS, no alpha)
// Run with: dart run tool/make_icon_from_logo.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;

  final srcBytes = File('assets/logo/Wrecklog_logo.png').readAsBytesSync();
  final src = img.decodePng(srcBytes);
  if (src == null) {
    // ignore: avoid_print
    print('ERROR: could not decode Wrecklog_logo.png');
    exit(1);
  }

  // Resize to 1024x1024
  final resized = img.copyResize(src, width: size, height: size,
      interpolation: img.Interpolation.cubic);

  // Use flood-fill from all four edges to find background pixels.
  // Background is black/near-black — threshold is max channel value to qualify.
  const threshold = 60;
  final transparent = img.Image(width: size, height: size, numChannels: 4);

  // Copy all pixels across first.
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = resized.getPixel(x, y);
      transparent.setPixelRgba(x, y, px.r.toInt(), px.g.toInt(), px.b.toInt(), 255);
    }
  }

  // BFS flood-fill from each edge — mark black background pixels.
  final visited = List.generate(size, (_) => List.filled(size, false));
  final queue = <(int, int)>[];

  bool isBackground(int x, int y) {
    if (visited[y][x]) return false;
    final px = resized.getPixel(x, y);
    return px.r.toInt() <= threshold && px.g.toInt() <= threshold && px.b.toInt() <= threshold;
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
  // that is near-black gets its alpha reduced proportionally to its darkness.
  // This removes the anti-aliased black halo without touching interior darks.
  const fringeThreshold = 55;
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
      // Darkness 0..255 (0 = bright, 255 = black)
      final darkness = 255 - (r + g + b) ~/ 3;
      if (darkness > (255 - fringeThreshold)) {
        // Scale alpha down — the darker the pixel, the more transparent it becomes.
        final newAlpha = ((255 - darkness) * 255 ~/ fringeThreshold).clamp(0, 255);
        transparent.setPixelRgba(x, y, r, g, b, newAlpha);
      }
    }
  }

  // Auto-crop: find bounding box of sufficiently opaque pixels.
  // Use threshold > 30 to ignore faint anti-alias fringe that bloats the box.
  int minX = size, maxX = 0, minY = size, maxY = 0;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = transparent.getPixel(x, y);
      if (px.a.toInt() > 30) {
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

  // Scale cropped content back to 1024x1024, preserving aspect ratio.
  final srcAspect = cropW / cropH;
  final int scaledW, scaledH;
  if (srcAspect >= 1.0) {
    scaledW = size;
    scaledH = (size / srcAspect).round();
  } else {
    scaledH = size;
    scaledW = (size * srcAspect).round();
  }
  final scaledContent = img.copyResize(cropped, width: scaledW, height: scaledH,
      interpolation: img.Interpolation.cubic);

  // Centre on a 1024x1024 transparent canvas.
  final scaled = img.Image(width: size, height: size, numChannels: 4);
  final offsetX = (size - scaledW) ~/ 2;
  final offsetY = (size - scaledH) ~/ 2;
  img.compositeImage(scaled, scaledContent, dstX: offsetX, dstY: offsetY);

  // Save transparent version (Android fg + home screen)
  File('assets/icon/icon_fg.png').writeAsBytesSync(img.encodePng(scaled));
  // ignore: avoid_print
  print('Done — assets/icon/icon_fg.png (transparent background, cropped)');

  // Adaptive foreground: scale logo down to 60% so it fits within Android's
  // inner 66% safe zone, then centre on a 1024x1024 transparent canvas.
  const safeScale = 0.60;
  final adaptiveSize = (size * safeScale).round();
  final adaptiveContent = img.copyResize(scaledContent,
      width: adaptiveSize, height: (adaptiveSize / srcAspect).round(),
      interpolation: img.Interpolation.cubic);
  final adaptive = img.Image(width: size, height: size, numChannels: 4);
  final aOffsetX = (size - adaptiveContent.width) ~/ 2;
  final aOffsetY = (size - adaptiveContent.height) ~/ 2;
  img.compositeImage(adaptive, adaptiveContent, dstX: aOffsetX, dstY: aOffsetY);
  File('assets/icon/icon_adaptive_fg.png').writeAsBytesSync(img.encodePng(adaptive));
  // ignore: avoid_print
  print('Done — assets/icon/icon_adaptive_fg.png (60% safe zone, adaptive foreground)');

  // iOS version: composite onto dark background (#1A1A1A)
  final bg = img.Image(width: size, height: size);
  img.fill(bg, color: img.ColorRgb8(0x1A, 0x1A, 0x1A));
  img.compositeImage(bg, scaled);
  File('assets/icon/icon_ios.png').writeAsBytesSync(img.encodePng(bg));
  // ignore: avoid_print
  print('Done — assets/icon/icon_ios.png (dark background for iOS)');

  // Home screen version: crop the ORIGINAL logo (no stripping) to just the
  // content area, scaled to 1024px wide at natural aspect ratio.
  // This preserves all black outlines (part of the design) and avoids any
  // visible border when displayed with BoxFit.contain on the dark home screen.
  const contentThreshold = 40; // pixel is "content" if any channel > this
  int hMinX = src.width, hMaxX = 0, hMinY = src.height, hMaxY = 0;
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final px = src.getPixel(x, y);
      if (px.r.toInt() > contentThreshold ||
          px.g.toInt() > contentThreshold ||
          px.b.toInt() > contentThreshold) {
        if (x < hMinX) hMinX = x;
        if (x > hMaxX) hMaxX = x;
        if (y < hMinY) hMinY = y;
        if (y > hMaxY) hMaxY = y;
      }
    }
  }
  final padPx = ((hMaxX - hMinX) * 0.03).toInt();
  final hCropX = (hMinX - padPx).clamp(0, src.width - 1);
  final hCropY = (hMinY - padPx).clamp(0, src.height - 1);
  final hCropW = (hMaxX - hMinX + padPx * 2 + 1).clamp(1, src.width - hCropX);
  final hCropH = (hMaxY - hMinY + padPx * 2 + 1).clamp(1, src.height - hCropY);

  final homeCropped = img.copyCrop(src,
      x: hCropX, y: hCropY, width: hCropW, height: hCropH);
  final homeScaledH = (size * hCropH / hCropW).round();
  final homeScaled = img.copyResize(homeCropped,
      width: size, height: homeScaledH,
      interpolation: img.Interpolation.cubic);
  File('assets/icon/icon_home.png').writeAsBytesSync(img.encodePng(homeScaled));
  // ignore: avoid_print
  print('Done — assets/icon/icon_home.png (${size}x$homeScaledH, natural aspect)');
}
