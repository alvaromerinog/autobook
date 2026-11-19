import 'dart:convert';
import 'dart:io' show ZLibDecoder;
import 'dart:typed_data';

import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/settings/data/export/history_pdf_builder.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:flutter_test/flutter_test.dart';

String decodedPdfContent(Uint8List pdfBytes) {
  const streamStartMarker = 'stream\n';
  const streamEndMarker = '\nendstream';
  final pdfText = latin1.decode(pdfBytes, allowInvalid: true);
  final contentText = StringBuffer();
  var searchFrom = 0;
  while (true) {
    final streamStart = pdfText.indexOf(streamStartMarker, searchFrom);
    if (streamStart < 0) break;
    final streamEnd = pdfText.indexOf(streamEndMarker, streamStart);
    if (streamEnd < 0) break;
    final streamSegment = pdfText.substring(
      streamStart + streamStartMarker.length,
      streamEnd,
    );
    try {
      final decompressedSegment = ZLibDecoder().convert(
        streamSegment.codeUnits,
      );
      contentText.write(latin1.decode(decompressedSegment, allowInvalid: true));
    } catch (_) {
      contentText.write(streamSegment);
    }
    searchFrom = streamEnd + streamEndMarker.length;
  }
  return contentText.toString();
}

void main() {
  group('buildHistoryPdf', () {
    test('given a history of two cars, '
        'when the pdf is built, '
        'then the bytes are non-empty and start with the pdf header', () async {
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
      ];
      const pdfLabels = (
        title: 'Maintenance history',
        date: 'Date',
        type: 'Type',
        mileage: 'Mileage',
        cost: 'Cost',
        garage: 'Garage',
        notes: 'Notes',
      );

      final pdfBytes = await buildHistoryPdf(
        cars: cars,
        maintenances: maintenances,
        distanceUnitLabel: 'km',
        currencySymbol: r'$',
        locale: 'en',
        labels: pdfLabels,
      );

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.sublist(0, 4)), '%PDF');
    });

    test('given a car with maintenances and a car without any, '
        'when the pdf is built, '
        'then each car gets its own section in order, with formatted '
        'mileage and cost, including the car without maintenances', () async {
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
        ),
        Maintenance(
          id: 'm2',
          carId: 'car-1',
          type: MaintenanceType.tires,
          date: '2026-01-20',
          mileage: 12000,
          cost: 120,
        ),
      ];
      const pdfLabels = (
        title: 'Maintenance history',
        date: 'Date',
        type: 'Type',
        mileage: 'Mileage',
        cost: 'Cost',
        garage: 'Garage',
        notes: 'Notes',
      );

      final pdfBytes = await buildHistoryPdf(
        cars: cars,
        maintenances: maintenances,
        distanceUnitLabel: 'km',
        currencySymbol: r'$',
        locale: 'en',
        labels: pdfLabels,
      );
      final content = decodedPdfContent(pdfBytes);
      final corollaSection = content.indexOf('Corolla');
      final meganeSection = content.indexOf('Megane');

      expect(corollaSection, greaterThanOrEqualTo(0));
      expect(meganeSection, greaterThan(corollaSection));
      expect(content, contains('Maintenance'));
      expect(content, contains('10,000'));
      expect(content, contains('km'));
      expect(content, contains(r'$45.50'));
      expect(content, contains(r'$120.00'));
      expect(content, contains('2026-03-12'));
      expect(content, contains('oil'));
    });
  });
}
