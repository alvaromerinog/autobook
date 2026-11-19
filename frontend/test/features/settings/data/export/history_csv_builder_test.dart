import 'dart:convert';

import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/settings/data/export/history_csv_builder.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildHistoryCsv', () {
    test('given cars with maintenances and a car without any, '
        'when the csv is built, '
        'then each maintenance is a row with its car columns, the car '
        'without maintenances gets one row of car data only and comma '
        'values are quoted', () {
      const cars = [
        Car(
          id: 'car-1',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2020,
          licensePlate: '1234 ABC',
        ),
        Car(
          id: 'car-2',
          brand: 'Ford',
          model: 'Focus',
          year: 2019,
          licensePlate: '5678 DEF',
        ),
        Car(
          id: 'car-3',
          brand: 'Renault',
          model: 'Megane',
          year: 2022,
          licensePlate: '1111 BBB',
        ),
      ];
      const maintenances = [
        Maintenance(
          id: 'm1',
          carId: 'car-1',
          type: MaintenanceType.oil,
          date: '2026-03-12',
          mileage: 10000,
          cost: 45.5,
          garage: 'Taller Ana',
          notes: 'Oil, filter change',
        ),
        Maintenance(
          id: 'm2',
          carId: 'car-1',
          type: MaintenanceType.tires,
          date: '2026-01-20',
          mileage: 12000,
          cost: 120,
        ),
        Maintenance(
          id: 'm3',
          carId: 'car-2',
          type: MaintenanceType.brakes,
          date: '2026-02-10',
          mileage: 8000,
          cost: 90,
          garage: 'Brakes Co',
          notes: 'Front pads',
        ),
      ];
      const csvLabels = (
        brand: 'Brand',
        model: 'Model',
        year: 'Year',
        licensePlate: 'License plate',
        date: 'Date',
        type: 'Type',
        mileage: 'Mileage',
        cost: 'Cost',
        garage: 'Garage',
        notes: 'Notes',
      );
      const expectedCsv =
          'Brand,Model,Year,License plate,Date,Type,Mileage (Kilometers),'
          'Cost (€),Garage,Notes'
          '\r\n'
          'Toyota,Corolla,2020,1234 ABC,2026-03-12,oil,10000,45.5,'
          'Taller Ana,"Oil, filter change"'
          '\r\n'
          'Toyota,Corolla,2020,1234 ABC,2026-01-20,tires,12000,120.0,,'
          '\r\n'
          'Ford,Focus,2019,5678 DEF,2026-02-10,brakes,8000,90.0,'
          'Brakes Co,Front pads'
          '\r\n'
          'Renault,Megane,2022,1111 BBB,,,,,,';

      final csvBytes = buildHistoryCsv(
        cars: cars,
        maintenances: maintenances,
        labels: csvLabels,
        distanceUnitLabel: 'Kilometers',
        currencySymbol: '€',
      );
      final csvContent = utf8.decode(csvBytes);

      expect(csvContent, expectedCsv);
    });

    test('given miles and dollars as the active preferences, '
        'when the csv is built, '
        'then the headers carry them and the values stay raw', () {
      const cars = [
        Car(
          id: 'car-1',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2020,
          licensePlate: '1234 ABC',
        ),
      ];
      const maintenances = [
        Maintenance(
          id: 'm1',
          carId: 'car-1',
          type: MaintenanceType.oil,
          date: '2026-03-12',
          mileage: 10000,
          cost: 45.5,
        ),
      ];
      const csvLabels = (
        brand: 'Brand',
        model: 'Model',
        year: 'Year',
        licensePlate: 'License plate',
        date: 'Date',
        type: 'Type',
        mileage: 'Mileage',
        cost: 'Cost',
        garage: 'Garage',
        notes: 'Notes',
      );
      const expectedCsv =
          'Brand,Model,Year,License plate,Date,Type,Mileage (Miles),'
          r'Cost ($),Garage,Notes'
          '\r\n'
          'Toyota,Corolla,2020,1234 ABC,2026-03-12,oil,10000,45.5,,';

      final csvBytes = buildHistoryCsv(
        cars: cars,
        maintenances: maintenances,
        labels: csvLabels,
        distanceUnitLabel: 'Miles',
        currencySymbol: r'$',
      );
      final csvContent = utf8.decode(csvBytes);

      expect(csvContent, expectedCsv);
    });

    test('given no cars and no maintenances, '
        'when the csv is built, '
        'then only the header row is emitted', () {
      const csvLabels = (
        brand: 'Brand',
        model: 'Model',
        year: 'Year',
        licensePlate: 'License plate',
        date: 'Date',
        type: 'Type',
        mileage: 'Mileage',
        cost: 'Cost',
        garage: 'Garage',
        notes: 'Notes',
      );
      const expectedCsv =
          'Brand,Model,Year,License plate,Date,Type,Mileage (Kilometers),'
          'Cost (€),Garage,Notes';

      final csvBytes = buildHistoryCsv(
        cars: const [],
        maintenances: const [],
        labels: csvLabels,
        distanceUnitLabel: 'Kilometers',
        currencySymbol: '€',
      );
      final csvContent = utf8.decode(csvBytes);

      expect(csvContent, expectedCsv);
    });
  });
}
