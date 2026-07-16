import 'package:autobook/features/vehicles/domain/entities/car.dart';

abstract class ICarRepository {
  Future<List<Car>> getAll();
  Future<void> refreshFromRemote();
  Future<void> create(Car car);
  Future<void> syncPending();
  Future<bool> hasPending();
}
