import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  for (final fname in ['assets/icon/icon_fg.png', 'assets/icon/icon_home.png']) {
    final bytes = File(fname).readAsBytesSync();
    final image = img.decodePng(bytes)!;
    final corner = image.getPixel(0, 0);
    final center = image.getPixel(image.width ~/ 2, image.height ~/ 2);
    // ignore: avoid_print
    print('$fname:');
    // ignore: avoid_print
    print('  corner: r=${corner.r.toInt()} g=${corner.g.toInt()} b=${corner.b.toInt()} a=${corner.a.toInt()}');
    // ignore: avoid_print
    print('  center: r=${center.r.toInt()} g=${center.g.toInt()} b=${center.b.toInt()} a=${center.a.toInt()}');
  }
}
