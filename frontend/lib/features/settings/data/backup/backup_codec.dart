import 'dart:convert';

import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';

const kBackupSchemaVersion = 1;

class InvalidBackupException implements Exception {
  const InvalidBackupException(this.message);

  final String message;

  @override
  String toString() => 'InvalidBackupException: $message';
}

class BackupData {
  const BackupData({
    required this.exportedAt,
    required this.cars,
    required this.maintenances,
  });

  final DateTime exportedAt;
  final List<Car> cars;
  final List<Maintenance> maintenances;
}

Map<String, dynamic> toBackupJson({
  required List<Car> cars,
  required List<Maintenance> maintenances,
  required DateTime exportedAt,
}) {
  return {
    'schemaVersion': kBackupSchemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'cars': [for (final car in cars) _carToJson(car)],
    'maintenances': [
      for (final maintenance in maintenances) _maintenanceToJson(maintenance),
    ],
  };
}

BackupData parseBackup(String raw) {
  final dynamic decodedBackup;
  try {
    decodedBackup = jsonDecode(raw);
  } on FormatException catch (error) {
    throw InvalidBackupException('malformed backup json: ${error.message}');
  }
  if (decodedBackup is! Map<String, dynamic>) {
    throw const InvalidBackupException('backup root is not a json object');
  }
  final schemaVersion = decodedBackup['schemaVersion'];
  if (schemaVersion is! int || schemaVersion != kBackupSchemaVersion) {
    throw InvalidBackupException(
      'unsupported backup schemaVersion: $schemaVersion',
    );
  }
  return BackupData(
    exportedAt: _parseExportedAt(decodedBackup['exportedAt']),
    cars: [
      for (final carRow in _expectList(decodedBackup['cars'], 'cars'))
        _carFromJson(carRow),
    ],
    maintenances: [
      for (final maintenanceRow in _expectList(
        decodedBackup['maintenances'],
        'maintenances',
      ))
        _maintenanceFromJson(maintenanceRow),
    ],
  );
}

Map<String, dynamic> _carToJson(Car car) => {
  'id': car.id,
  'brand': car.brand,
  'model': car.model,
  'year': car.year,
  'licensePlate': car.licensePlate,
  'color': car.color,
  'mileage': car.mileage,
};

Map<String, dynamic> _maintenanceToJson(Maintenance maintenance) => {
  'id': maintenance.id,
  'carId': maintenance.carId,
  'type': maintenance.type.name,
  'date': maintenance.date,
  'mileage': maintenance.mileage,
  'cost': maintenance.cost,
  'garage': maintenance.garage,
  'notes': maintenance.notes,
};

DateTime _parseExportedAt(dynamic exportedAt) {
  if (exportedAt is! String) {
    throw const InvalidBackupException('exportedAt is not a string');
  }
  final parsedExportedAt = DateTime.tryParse(exportedAt);
  if (parsedExportedAt == null) {
    throw InvalidBackupException('exportedAt is not a date: $exportedAt');
  }
  return parsedExportedAt;
}

List<dynamic> _expectList(dynamic value, String field) {
  if (value is! List) {
    throw InvalidBackupException('$field is not a list');
  }
  return value;
}

String _requiredString(Map<dynamic, dynamic> row, String field, String owner) {
  final value = row[field];
  if (value is! String) {
    throw InvalidBackupException('$owner.$field is not a string');
  }
  return value;
}

int _requiredInt(Map<dynamic, dynamic> row, String field, String owner) {
  final value = row[field];
  if (value is! int) {
    throw InvalidBackupException('$owner.$field is not an integer');
  }
  return value;
}

String? _nullableString(Map<dynamic, dynamic> row, String field, String owner) {
  final value = row[field];
  if (value == null) return null;
  if (value is! String) {
    throw InvalidBackupException('$owner.$field is not a string');
  }
  return value;
}

int? _nullableInt(Map<dynamic, dynamic> row, String field, String owner) {
  final value = row[field];
  if (value == null) return null;
  if (value is! int) {
    throw InvalidBackupException('$owner.$field is not an integer');
  }
  return value;
}

Car _carFromJson(dynamic carRow) {
  if (carRow is! Map) {
    throw const InvalidBackupException('car entry is not an object');
  }
  return Car(
    id: _requiredString(carRow, 'id', 'car'),
    brand: _requiredString(carRow, 'brand', 'car'),
    model: _requiredString(carRow, 'model', 'car'),
    year: _requiredInt(carRow, 'year', 'car'),
    licensePlate: _requiredString(carRow, 'licensePlate', 'car'),
    color: _nullableString(carRow, 'color', 'car'),
    mileage: _nullableInt(carRow, 'mileage', 'car'),
  );
}

Maintenance _maintenanceFromJson(dynamic maintenanceRow) {
  if (maintenanceRow is! Map) {
    throw const InvalidBackupException('maintenance entry is not an object');
  }
  final typeName = _requiredString(maintenanceRow, 'type', 'maintenance');
  final MaintenanceType type;
  try {
    type = MaintenanceType.fromString(typeName);
  } on ArgumentError {
    throw InvalidBackupException('unknown maintenance type: $typeName');
  }
  final cost = maintenanceRow['cost'];
  if (cost is! num) {
    throw const InvalidBackupException('maintenance.cost is not a number');
  }
  return Maintenance(
    id: _requiredString(maintenanceRow, 'id', 'maintenance'),
    carId: _requiredString(maintenanceRow, 'carId', 'maintenance'),
    type: type,
    date: _requiredString(maintenanceRow, 'date', 'maintenance'),
    mileage: _requiredInt(maintenanceRow, 'mileage', 'maintenance'),
    cost: cost.toDouble(),
    garage: _nullableString(maintenanceRow, 'garage', 'maintenance'),
    notes: _nullableString(maintenanceRow, 'notes', 'maintenance'),
  );
}
