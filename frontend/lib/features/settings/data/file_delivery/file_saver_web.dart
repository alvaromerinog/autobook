import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> deliverFile({
  required String fileName,
  required Uint8List bytes,
}) async {
  final fileExtension = fileName.split('.').last;
  final mimeType = switch (fileExtension) {
    'pdf' => 'application/pdf',
    _ => 'text/csv',
  };
  final blob = web.Blob(
    <web.BlobPart>[bytes.toJS as web.BlobPart].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final blobUrl = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = blobUrl
    ..download = fileName;
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(blobUrl);
}
