import 'dart:convert';
import 'dart:typed_data';

import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/settings/data/backup/backup_codec.dart';
import 'package:autobook/features/settings/data/file_delivery/file_saver.dart';
import 'package:autobook/features/settings/data/repositories/autobook_data_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

const _lastBackupAtStorageKey = 'last_backup_at';

sealed class BackupResult {
  const BackupResult();
}

class BackupSucceeded extends BackupResult {
  const BackupSucceeded();
}

class BackupFailed extends BackupResult {
  const BackupFailed(this.cause);

  final Failure cause;
}

String backupFileName(DateTime timestamp) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final datePart =
      '${timestamp.year}${twoDigits(timestamp.month)}'
      '${twoDigits(timestamp.day)}';
  final timePart = '${twoDigits(timestamp.hour)}${twoDigits(timestamp.minute)}';
  return 'autobook_backup_${datePart}_$timePart.json';
}

@Riverpod(keepAlive: true)
class LastBackupAt extends _$LastBackupAt {
  @override
  Future<DateTime?> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final storedValue = preferences.getString(_lastBackupAtStorageKey);
      if (storedValue == null) return null;
      return DateTime.tryParse(storedValue);
    } catch (_) {
      return null;
    }
  }

  Future<void> record(DateTime exportedAt) async {
    state = AsyncData(exportedAt);
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setString(
        _lastBackupAtStorageKey,
        exportedAt.toIso8601String(),
      );
    } catch (_) {
      return;
    }
  }
}

@riverpod
BackupController backupController(Ref ref) {
  return BackupController(
    repository: ref.watch(autobookDataRepositoryProvider),
    lastBackupAt: ref.watch(lastBackupAtProvider.notifier),
    deliverBackupFile: ref.watch(fileDeliveryProvider),
  );
}

class BackupController {
  BackupController({
    required AutobookDataRepository repository,
    required LastBackupAt lastBackupAt,
    required FileDelivery deliverBackupFile,
  }) : _repository = repository,
       _lastBackupAt = lastBackupAt,
       _deliverBackupFile = deliverBackupFile;

  final AutobookDataRepository _repository;
  final LastBackupAt _lastBackupAt;
  final FileDelivery _deliverBackupFile;

  Future<BackupResult> createBackup() async {
    try {
      final (cars, maintenances) = await _repository.loadAll();
      final exportedAt = DateTime.now();
      final backupJson = toBackupJson(
        cars: cars,
        maintenances: maintenances,
        exportedAt: exportedAt,
      );
      final backupBytes = utf8.encode(jsonEncode(backupJson));
      await _deliverBackupFile(
        fileName: backupFileName(exportedAt),
        bytes: backupBytes,
      );
      await _lastBackupAt.record(exportedAt);
      return const BackupSucceeded();
    } on Failure catch (cause) {
      return BackupFailed(cause);
    } catch (cause) {
      return BackupFailed(CacheFailure(cause.toString()));
    }
  }

  Future<BackupResult> restoreFromBytes(Uint8List bytes) async {
    try {
      final backup = parseBackup(utf8.decode(bytes));
      await _repository.replaceAll(
        cars: backup.cars,
        maintenances: backup.maintenances,
      );
      return const BackupSucceeded();
    } on Failure catch (cause) {
      return BackupFailed(cause);
    } catch (cause) {
      return BackupFailed(CacheFailure(cause.toString()));
    }
  }
}
