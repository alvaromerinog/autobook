import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config.dart';
import '../exceptions/create_car_exception.dart';
import '../exceptions/get_cars_exception.dart';
import '../models/car.dart';

part 'api_service.g.dart';

@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) => ApiService();

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Car>> getCars() async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw GetCarsException(response.statusCode);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final cars = body['cars'] as List;
    return cars.map((c) => Car.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<void> createCar(Car car) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(car.toJson()),
    );
    if (response.statusCode != 201) {
      throw CreateCarException(response.statusCode);
    }
  }
}
