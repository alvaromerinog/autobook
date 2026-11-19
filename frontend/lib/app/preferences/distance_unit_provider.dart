import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distance_unit_provider.g.dart';

const _distanceUnitStorageKey = 'distance_unit';

enum DistanceUnit {
  kilometers('kilometers'),
  miles('miles');

  const DistanceUnit(this.code);

  final String code;
}

DistanceUnit? distanceUnitFromCode(String? code) {
  for (final unit in DistanceUnit.values) {
    if (unit.code == code) {
      return unit;
    }
  }
  return null;
}

@Riverpod(keepAlive: true)
class DistanceUnitSetting extends _$DistanceUnitSetting {
  @override
  Future<DistanceUnit> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final storedCode = preferences.getString(_distanceUnitStorageKey);
      return distanceUnitFromCode(storedCode) ?? DistanceUnit.kilometers;
    } catch (_) {
      return DistanceUnit.kilometers;
    }
  }

  Future<void> select(DistanceUnit unit) async {
    state = AsyncData(unit);
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setString(_distanceUnitStorageKey, unit.code);
    } catch (_) {
      return;
    }
  }
}
