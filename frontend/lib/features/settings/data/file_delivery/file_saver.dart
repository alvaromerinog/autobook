export 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart';

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'file_saver_io.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    as file_saver_impl;

part 'file_saver.g.dart';

typedef FileDelivery =
    Future<void> Function({required String fileName, required Uint8List bytes});

@Riverpod(keepAlive: true)
FileDelivery fileDelivery(Ref ref) => file_saver_impl.deliverFile;
