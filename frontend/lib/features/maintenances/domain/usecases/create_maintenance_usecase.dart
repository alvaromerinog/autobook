import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';

typedef MaintenanceDraft = ({
  MaintenanceType type,
  String date,
  int mileage,
  double cost,
  String? garage,
  String? notes,
});

class CreateMaintenanceUseCase {
  const CreateMaintenanceUseCase(this._repo, this._ids);

  final IMaintenanceRepository _repo;
  final IdGenerator _ids;

  Future<Maintenance> call(
    MaintenanceDraft draft,
    String carId,
  ) async {
    final maintenance = Maintenance(
      id: _ids.newId(),
      carId: carId,
      type: draft.type,
      date: draft.date,
      mileage: draft.mileage,
      cost: draft.cost,
      garage: draft.garage,
      notes: draft.notes,
    );
    await _repo.create(maintenance);
    return maintenance;
  }
}