import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/car.dart';

class ApiService {
  static Future<void> createCar(Car car) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(car.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create car: ${response.statusCode}');
    }
  }
}
