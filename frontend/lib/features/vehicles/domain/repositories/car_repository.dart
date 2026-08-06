import 'package:autobook/features/vehicles/domain/entities/car.dart';

abstract class ICarRepository {
  Future<List<Car>> getAll();
  Future<List<String>> refreshFromRemote();
  Future<void> create(Car car);
  Future<void> update(Car car);
  Future<void> delete(Car car);
  Future<Set<String>> pendingDeleteIds();
  Future<void> syncPending();
  Future<bool> hasPending();
}
