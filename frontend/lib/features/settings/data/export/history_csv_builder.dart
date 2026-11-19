import 'dart:convert';
import 'dart:typed_data';

import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:csv/csv.dart';

typedef HistoryCsvLabels = ({
  String brand,
  String model,
  String year,
  String licensePlate,
  String date,
  String type,
  String mileage,
  String cost,
  String garage,
  String notes,
});

Uint8List buildHistoryCsv({
  required List<Car> cars,
  required List<Maintenance> maintenances,
  required HistoryCsvLabels labels,
  required String distanceUnitLabel,
  required String currencySymbol,
}) {
  final rows = <List<String>>[
    [
      labels.brand,
      labels.model,
      labels.year,
      labels.licensePlate,
      labels.date,
      labels.type,
      '${labels.mileage} ($distanceUnitLabel)',
      '${labels.cost} ($currencySymbol)',
      labels.garage,
      labels.notes,
    ],
  ];
  for (final car in cars) {
    final carColumns = [
      car.brand,
      car.model,
      car.year.toString(),
      car.licensePlate,
    ];
    final carMaintenances = maintenances.where((m) => m.carId == car.id);
    if (carMaintenances.isEmpty) {
      rows.add([...carColumns, '', '', '', '', '', '']);
      continue;
    }
    for (final maintenance in carMaintenances) {
      rows.add([
        ...carColumns,
        maintenance.date,
        maintenance.type.name,
        maintenance.mileage.toString(),
        maintenance.cost.toString(),
        maintenance.garage ?? '',
        maintenance.notes ?? '',
      ]);
    }
  }
  return utf8.encode(const CsvEncoder().convert(rows));
}
