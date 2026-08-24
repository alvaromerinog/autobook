import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class HasPendingMaintenancesUseCase {
  const HasPendingMaintenancesUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<bool> call(String carId) => _repo.hasPending(carId);
}