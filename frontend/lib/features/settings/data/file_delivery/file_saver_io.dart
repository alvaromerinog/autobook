import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> deliverFile({
  required String fileName,
  required Uint8List bytes,
}) async {
  final fileExtension = fileName.split('.').last;
  final mimeType = switch (fileExtension) {
    'pdf' => 'application/pdf',
    _ => 'text/csv',
  };
  final shareFile = XFile.fromData(bytes, name: fileName, mimeType: mimeType);
  await SharePlus.instance.share(ShareParams(files: [shareFile]));
}
