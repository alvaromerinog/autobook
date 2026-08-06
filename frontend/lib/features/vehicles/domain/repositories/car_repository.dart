import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';

abstract class ICarRepository {
  Future<List<Car>> getAll();
  Future<List<RemoteSyncEvent>> refreshFromRemote();
  Future<void> create(Car car);
  Future<void> update(Car car);
  Future<void> delete(Car car);
  Future<Set<String>> pendingDeleteIds();
  Future<void> syncPending();
  Future<bool> hasPending();
}
