import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class PendingDeleteIdsUseCase {
  const PendingDeleteIdsUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<Set<String>> call(String carId) => _repo.pendingDeleteIds(carId);
}