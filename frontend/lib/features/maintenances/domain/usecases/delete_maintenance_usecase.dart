import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

class DeleteMaintenanceUseCase {
  const DeleteMaintenanceUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<void> call(Maintenance maintenance) => _repo.delete(maintenance);
}
