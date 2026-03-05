import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadTextFile(String filename, String content) {
  final bytes = Uint8List.fromList(content.codeUnits);
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..setAttribute('download', filename)
    ..click();
  web.URL.revokeObjectURL(url);
}
