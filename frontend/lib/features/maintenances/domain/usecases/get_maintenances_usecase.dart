import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class GetMaintenancesUseCase {
  const GetMaintenancesUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<List<Maintenance>> call(String carId) => _repo.getAll(carId);
}
