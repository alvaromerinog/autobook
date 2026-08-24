import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';

class UpdateMaintenanceUseCase {
  const UpdateMaintenanceUseCase(this._repo);

  final IMaintenanceRepository _repo;

  Future<Maintenance> call(
    MaintenanceDraft draft,
    Maintenance existing,
  ) async {
    final updated = existing.copyWith(
      type: draft.type,
      date: draft.date,
      mileage: draft.mileage,
      cost: draft.cost,
      garage: draft.garage,
      notes: draft.notes,
    );
    await _repo.update(updated);
    return updated;
  }
}