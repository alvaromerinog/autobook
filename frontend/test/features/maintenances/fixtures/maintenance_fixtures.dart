import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';

Maintenance buildMaintenance({
  String id = 'm1',
  String carId = 'car-1',
  MaintenanceType type = MaintenanceType.oil,
  String date = '2026-03-12',
  int mileage = 1000,
  double cost = 50,
  String? garage,
  String? notes,
}) => Maintenance(
  id: id,
  carId: carId,
  type: type,
  date: date,
  mileage: mileage,
  cost: cost,
  garage: garage,
  notes: notes,
);