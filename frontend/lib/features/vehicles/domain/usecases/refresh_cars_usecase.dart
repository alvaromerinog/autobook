import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class RefreshCarsUseCase {
  const RefreshCarsUseCase(this._repo);

  final ICarRepository _repo;

  Future<List<RemoteSyncEvent>> call() => _repo.refreshFromRemote();
}
