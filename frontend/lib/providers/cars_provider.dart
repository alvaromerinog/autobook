import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/car.dart';
import 'shared_preferences_provider.dart';

part 'cars_provider.g.dart';

@Riverpod(keepAlive: true)
class Cars extends _$Cars {
  static const _carsStorageKey = 'cars';

  @override
  Future<List<Car>> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    final storedCarsJson = preferences.getString(_carsStorageKey);
    if (storedCarsJson == null) return [];
    final decodedCars = jsonDecode(storedCarsJson) as List;
    return decodedCars
        .map((carMap) => Car.fromJson(carMap as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(Car newCar) async {
    final currentCars = await future;
    final updatedCars = [...currentCars, newCar];
    state = AsyncData(updatedCars);
    await _persistCars(updatedCars);
  }

  Future<void> _persistCars(List<Car> carsToPersist) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    final encodedCars = jsonEncode(
      carsToPersist.map((car) => car.toJson()).toList(),
    );
    await preferences.setString(_carsStorageKey, encodedCars);
  }
}
