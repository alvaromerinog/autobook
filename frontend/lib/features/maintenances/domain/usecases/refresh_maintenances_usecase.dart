import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class RefreshMaintenancesUseCase {
  const RefreshMaintenancesUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<List<MaintenanceRemoteSyncEvent>> call(String carId) =>
      _repo.refreshFromRemote(carId);
}