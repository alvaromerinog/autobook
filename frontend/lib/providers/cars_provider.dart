import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import 'shared_preferences_provider.dart';

typedef CarsState = ({
  List<Car> cars,
  Exception? syncError,
  bool hasPendingSync,
});

final carsProvider =
    AsyncNotifierProvider<CarsProvider, CarsState>(CarsProvider.new);

class CarsProvider extends AsyncNotifier<CarsState> {
  static const _carsStorageKey = 'cars';
  static const _pendingCarsKey = 'pending_cars';

  late ApiService _apiService;
  late ConnectivityService _connectivityService;
  bool _isSyncing = false;

  @override
  Future<CarsState> build() async {
    _apiService = ref.read(apiServiceProvider);
    _connectivityService = ref.read(connectivityServiceProvider);
    _listenForConnectivityRestore();

    final isConnected = await _connectivityService.isConnected();
    final cachedCars = await _readCachedCars();
    final pendingCars = await _readPendingCars();

    if (!isConnected) {
      return (
        cars: cachedCars,
        syncError: null,
        hasPendingSync: pendingCars.isNotEmpty,
      );
    }

    try {
      final apiCars = await _apiService.getCars();
      final mergedCars = _mergeWithPending(apiCars, pendingCars);
      await _persistCars(mergedCars);
      if (pendingCars.isNotEmpty) {
        await syncPendingCars();
      }
      final remainingPendingCars = await _readPendingCars();
      return (
        cars: mergedCars,
        syncError: null,
        hasPendingSync: remainingPendingCars.isNotEmpty,
      );
    } catch (e) {
      return (
        cars: cachedCars,
        syncError: e is Exception ? e : Exception(e.toString()),
        hasPendingSync: pendingCars.isNotEmpty,
      );
    }
  }

  Future<void> add(Car newCar) async {
    final currentState = await future;
    final updatedCars = [...currentState.cars, newCar];
    state = AsyncData((
      cars: updatedCars,
      syncError: null,
      hasPendingSync: currentState.hasPendingSync,
    ));
    await _persistCars(updatedCars);

    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      await _queuePendingCar(newCar);
      state = AsyncData((
        cars: updatedCars,
        syncError: null,
        hasPendingSync: true,
      ));
      return;
    }

    try {
      await _apiService.createCar(newCar);
    } catch (e) {
      await _queuePendingCar(newCar);
      state = AsyncData((
        cars: updatedCars,
        syncError: null,
        hasPendingSync: true,
      ));
      rethrow;
    }
  }

  Future<void> syncPendingCars() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final pendingCars = await _readPendingCars();
      if (pendingCars.isEmpty) return;

      final syncedIds = <String>[];
      for (final pendingCar in pendingCars) {
        try {
          await _apiService.createCar(pendingCar);
          syncedIds.add(pendingCar.id);
        } catch (_) {
          continue;
        }
      }

      if (syncedIds.isEmpty) return;

      await _removeSyncedPendingCars(syncedIds);
      final remainingPendingCars = await _readPendingCars();
      final currentState = state.valueOrNull;
      if (currentState == null) return;
      state = AsyncData((
        cars: currentState.cars,
        syncError: currentState.syncError,
        hasPendingSync: remainingPendingCars.isNotEmpty,
      ));
    } finally {
      _isSyncing = false;
    }
  }

  void _listenForConnectivityRestore() {
    final subscription = _connectivityService.connectivityChanges.listen(
      (isConnected) async {
        if (isConnected) await syncPendingCars();
      },
    );
    ref.onDispose(subscription.cancel);
  }

  List<Car> _mergeWithPending(List<Car> apiCars, List<Car> pendingCars) {
    final apiCarIds = apiCars.map((car) => car.id).toSet();
    final localOnlyCars =
        pendingCars.where((car) => !apiCarIds.contains(car.id)).toList();
    return [...apiCars, ...localOnlyCars];
  }

  Future<List<Car>> _readCachedCars() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    final storedJson = preferences.getString(_carsStorageKey);
    if (storedJson == null) return [];
    final cachedCarJsonList = jsonDecode(storedJson) as List;
    return cachedCarJsonList
        .map((carJson) => Car.fromJson(carJson as Map<String, dynamic>))
        .toList();
  }

  Future<List<Car>> _readPendingCars() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    final pendingJson = preferences.getString(_pendingCarsKey);
    if (pendingJson == null) return [];
    final pendingCarJsonList = jsonDecode(pendingJson) as List;
    return pendingCarJsonList
        .map((carJson) => Car.fromJson(carJson as Map<String, dynamic>))
        .toList();
  }

  Future<void> _queuePendingCar(Car car) async {
    final pendingCars = await _readPendingCars();
    if (pendingCars.any((pendingCar) => pendingCar.id == car.id)) return;
    final updatedPendingCars = [...pendingCars, car];
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(
      _pendingCarsKey,
      jsonEncode(updatedPendingCars.map((car) => car.toJson()).toList()),
    );
  }

  Future<void> _removeSyncedPendingCars(List<String> syncedIds) async {
    final pendingCars = await _readPendingCars();
    final remainingCars =
        pendingCars.where((car) => !syncedIds.contains(car.id)).toList();
    final preferences = await ref.read(sharedPreferencesProvider.future);
    if (remainingCars.isEmpty) {
      await preferences.remove(_pendingCarsKey);
    } else {
      await preferences.setString(
        _pendingCarsKey,
        jsonEncode(remainingCars.map((car) => car.toJson()).toList()),
      );
    }
  }

  Future<void> _persistCars(List<Car> cars) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(
      _carsStorageKey,
      jsonEncode(cars.map((car) => car.toJson()).toList()),
    );
  }
}
