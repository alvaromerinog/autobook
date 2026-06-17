import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/car.dart';

class ApiService {
  static Future<void> createCar(Car car) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/cars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(car.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    }
  }
}
