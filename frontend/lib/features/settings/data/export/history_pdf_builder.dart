import 'dart:typed_data';

import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

typedef HistoryPdfLabels = ({
  String title,
  String date,
  String type,
  String mileage,
  String cost,
  String garage,
  String notes,
});

Future<Uint8List> buildHistoryPdf({
  required List<Car> cars,
  required List<Maintenance> maintenances,
  required String distanceUnitLabel,
  required String currencySymbol,
  required String locale,
  required HistoryPdfLabels labels,
}) async {
  final costFormat = NumberFormat.currency(
    symbol: currencySymbol,
    locale: locale,
  );
  final mileageFormat = NumberFormat.decimalPattern(locale);
  final maintenancesByCarId = <String, List<Maintenance>>{};
  for (final maintenance in maintenances) {
    maintenancesByCarId
        .putIfAbsent(maintenance.carId, () => [])
        .add(maintenance);
  }
  final sections = <pw.Widget>[pw.Header(level: 0, text: labels.title)];
  for (final car in cars) {
    final carMaintenances = maintenancesByCarId[car.id] ?? const [];
    sections.add(
      pw.Header(
        level: 1,
        text: '${car.brand} ${car.model} (${car.licensePlate})',
      ),
    );
    sections.add(
      pw.TableHelper.fromTextArray(
        headers: [
          labels.date,
          labels.type,
          labels.mileage,
          labels.cost,
          labels.garage,
          labels.notes,
        ],
        data: carMaintenances
            .map(
              (maintenance) => [
                maintenance.date,
                maintenance.type.name,
                '${mileageFormat.format(maintenance.mileage)}'
                    ' $distanceUnitLabel',
                costFormat.format(maintenance.cost),
                maintenance.garage ?? '',
                maintenance.notes ?? '',
              ],
            )
            .toList(),
      ),
    );
  }
  final pdfDocument = pw.Document();
  pdfDocument.addPage(
    pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (context) => sections),
  );
  return pdfDocument.save();
}
