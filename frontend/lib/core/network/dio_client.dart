import 'package:autobook/config.dart';
import 'package:dio/dio.dart';

Dio buildDioClient() {
  return Dio(BaseOptions(baseUrl: apiBaseUrl));
}
