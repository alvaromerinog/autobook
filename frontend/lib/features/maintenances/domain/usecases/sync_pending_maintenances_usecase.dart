import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class SyncPendingMaintenancesUseCase {
  const SyncPendingMaintenancesUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<void> call() => _repo.syncPending();
}
