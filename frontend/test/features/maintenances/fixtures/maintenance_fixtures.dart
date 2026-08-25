import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';

// ---------------------------------------------------------------------------
// Named canonical instances
// ---------------------------------------------------------------------------
// Use these const values when a test needs a stable, value-equality-safe
// Maintenance (e.g. inside const lists or direct expect() comparisons).

const oilChangeMarch = Maintenance(
  id: '1',
  carId: 'car-1',
  type: MaintenanceType.oil,
  date: '2026-03-12',
  mileage: 10000,
  cost: 45.5,
);

const tireSwapJanuary = Maintenance(
  id: '2',
  carId: 'car-1',
  type: MaintenanceType.tires,
  date: '2026-01-20',
  mileage: 12000,
  cost: 120,
);

const coolantFlushJune = Maintenance(
  id: 'n1',
  carId: 'car-1',
  type: MaintenanceType.coolant,
  date: '2026-06-01',
  mileage: 15000,
  cost: 30,
);

const brakesPending = Maintenance(
  id: 'pend1',
  carId: 'car-1',
  type: MaintenanceType.brakes,
  date: '2026-02-10',
  mileage: 11000,
  cost: 90,
);

const batteryPending = Maintenance(
  id: 'pend2',
  carId: 'car-1',
  type: MaintenanceType.battery,
  date: '2026-04-05',
  mileage: 13000,
  cost: 75,
);

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
