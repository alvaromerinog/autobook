import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/settings/data/export/history_csv_builder.dart';
import 'package:autobook/features/settings/data/export/history_pdf_builder.dart';
import 'package:autobook/features/settings/data/file_delivery/file_saver.dart';
import 'package:autobook/features/settings/data/repositories/autobook_data_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

enum ExportFormat { csv, pdf }

sealed class ExportResult {
  const ExportResult();
}

class ExportSucceeded extends ExportResult {
  const ExportSucceeded();
}

class ExportFailed extends ExportResult {
  const ExportFailed(this.cause);

  final Failure cause;
}

String exportFileName(ExportFormat format, DateTime timestamp) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final datePart =
      '${timestamp.year}${twoDigits(timestamp.month)}'
      '${twoDigits(timestamp.day)}';
  final timePart = '${twoDigits(timestamp.hour)}${twoDigits(timestamp.minute)}';
  return 'autobook_export_${datePart}_$timePart.${format.name}';
}

@riverpod
ExportController exportController(Ref ref) {
  return ExportController(ref.watch(autobookDataRepositoryProvider));
}

class ExportController {
  ExportController(this._repository);

  final AutobookDataRepository _repository;

  Future<ExportResult> exportHistory({
    required ExportFormat format,
    required HistoryCsvLabels csvLabels,
    required HistoryPdfLabels pdfLabels,
    required String distanceUnitLabel,
    required String currencySymbol,
    required String locale,
  }) async {
    try {
      final (cars, maintenances) = await _repository.loadAll();
      final exportBytes = switch (format) {
        ExportFormat.csv => buildHistoryCsv(
          cars: cars,
          maintenances: maintenances,
          labels: csvLabels,
        ),
        ExportFormat.pdf => await buildHistoryPdf(
          cars: cars,
          maintenances: maintenances,
          distanceUnitLabel: distanceUnitLabel,
          currencySymbol: currencySymbol,
          locale: locale,
          labels: pdfLabels,
        ),
      };
      final fileName = exportFileName(format, DateTime.now());
      await deliverFile(fileName: fileName, bytes: exportBytes);
      return const ExportSucceeded();
    } on Failure catch (cause) {
      return ExportFailed(cause);
    } catch (cause) {
      return ExportFailed(CacheFailure(cause.toString()));
    }
  }
}
