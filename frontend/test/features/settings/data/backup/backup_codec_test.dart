import 'dart:convert';

import 'package:autobook/features/settings/data/backup/backup_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../maintenances/fixtures/maintenance_fixtures.dart';
import '../../../vehicles/fixtures/car_fixtures.dart';

void main() {
  final exportedAt = DateTime.utc(2026, 11, 19, 10, 30);

  group('toBackupJson', () {
    test('given cars and maintenances, '
        'when the backup json is built, '
        'then every field is serialized explicitly', () {
      final restoredCar = buildCar(color: 'Red', mileage: 45000);
      final garageMaintenance = buildMaintenance(
        garage: 'Taller Ruiz',
        notes: 'Changed front pads',
      );

      final backupJson = toBackupJson(
        cars: [restoredCar],
        maintenances: [garageMaintenance],
        exportedAt: exportedAt,
      );

      expect(backupJson['schemaVersion'], kBackupSchemaVersion);
      expect(backupJson['exportedAt'], exportedAt.toIso8601String());
      expect(backupJson['cars'], [
        {
          'id': '1',
          'brand': 'Toyota',
          'model': 'Corolla',
          'year': 2020,
          'licensePlate': '1234 ABC',
          'color': 'Red',
          'mileage': 45000,
        },
      ]);
      expect(backupJson['maintenances'], [
        {
          'id': 'm1',
          'carId': 'car-1',
          'type': 'oil',
          'date': '2026-03-12',
          'mileage': 1000,
          'cost': 50,
          'garage': 'Taller Ruiz',
          'notes': 'Changed front pads',
        },
      ]);
    });
  });

  group('parseBackup', () {
    test('given a valid backup document, '
        'when parseBackup is called, '
        'then it returns structurally equal entities', () {
      final backedUpCars = [toyotaCorolla, buildCar(color: 'Red')];
      final backedUpMaintenances = [
        oilChangeMarch,
        buildMaintenance(garage: 'Taller Ruiz', notes: 'Rotated tires'),
      ];
      final rawBackup = jsonEncode(
        toBackupJson(
          cars: backedUpCars,
          maintenances: backedUpMaintenances,
          exportedAt: exportedAt,
        ),
      );

      final backupData = parseBackup(rawBackup);

      expect(backupData.exportedAt, exportedAt);
      expect(backupData.cars, backedUpCars);
      expect(backupData.maintenances, backedUpMaintenances);
    });

    test('given a document with null car fields and null '
        'maintenance garage and notes, '
        'when parseBackup is called, '
        'then the nullable fields stay null', () {
      final rawBackup = jsonEncode(
        toBackupJson(
          cars: [toyotaCorolla],
          maintenances: [oilChangeMarch],
          exportedAt: exportedAt,
        ),
      );

      final backupData = parseBackup(rawBackup);

      expect(backupData.cars.single.color, isNull);
      expect(backupData.cars.single.mileage, isNull);
      expect(backupData.maintenances.single.garage, isNull);
      expect(backupData.maintenances.single.notes, isNull);
    });

    test('given malformed json, '
        'when parseBackup is called, '
        'then it throws InvalidBackupException', () {
      const rawBackup = '{not json at all';

      expect(
        () => parseBackup(rawBackup),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('given a backup with schemaVersion 2, '
        'when parseBackup is called, '
        'then it throws InvalidBackupException', () {
      final rawBackup = jsonEncode({
        'schemaVersion': 2,
        'exportedAt': exportedAt.toIso8601String(),
        'cars': <dynamic>[],
        'maintenances': <dynamic>[],
      });

      expect(
        () => parseBackup(rawBackup),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('given a backup whose cars is not a list, '
        'when parseBackup is called, '
        'then it throws InvalidBackupException', () {
      final rawBackup = jsonEncode({
        'schemaVersion': kBackupSchemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'cars': 'nope',
        'maintenances': <dynamic>[],
      });

      expect(
        () => parseBackup(rawBackup),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('given a backup with a car whose year is a string, '
        'when parseBackup is called, '
        'then it throws InvalidBackupException', () {
      final rawBackup = jsonEncode({
        'schemaVersion': kBackupSchemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'cars': [
          {
            'id': '1',
            'brand': 'Toyota',
            'model': 'Corolla',
            'year': '2020',
            'licensePlate': '1234 ABC',
          },
        ],
        'maintenances': <dynamic>[],
      });

      expect(
        () => parseBackup(rawBackup),
        throwsA(isA<InvalidBackupException>()),
      );
    });

    test('given a backup with an unknown maintenance type, '
        'when parseBackup is called, '
        'then it throws InvalidBackupException', () {
      final rawBackup = jsonEncode({
        'schemaVersion': kBackupSchemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'cars': <dynamic>[],
        'maintenances': [
          {
            'id': 'm1',
            'carId': 'car-1',
            'type': 'hovering',
            'date': '2026-03-12',
            'mileage': 1000,
            'cost': 50,
          },
        ],
      });

      expect(
        () => parseBackup(rawBackup),
        throwsA(isA<InvalidBackupException>()),
      );
    });
  });
}
