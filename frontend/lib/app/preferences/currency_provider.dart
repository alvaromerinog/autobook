import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currency_provider.g.dart';

const _currencyStorageKey = 'currency';

enum Currency {
  euro('euro'),
  dollar('dollar');

  const Currency(this.code);

  final String code;
}

Currency? currencyFromCode(String? code) {
  for (final currency in Currency.values) {
    if (currency.code == code) {
      return currency;
    }
  }
  return null;
}

@Riverpod(keepAlive: true)
class CurrencySetting extends _$CurrencySetting {
  @override
  Future<Currency> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final storedCode = preferences.getString(_currencyStorageKey);
      return currencyFromCode(storedCode) ?? Currency.euro;
    } catch (_) {
      return Currency.euro;
    }
  }

  Future<void> select(Currency currency) async {
    state = AsyncData(currency);
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setString(_currencyStorageKey, currency.code);
    } catch (_) {
      return;
    }
  }
}
