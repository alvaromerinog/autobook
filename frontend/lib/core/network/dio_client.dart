import 'package:autobook/config.dart';
import 'package:dio/dio.dart';

Dio buildDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
}
