import 'package:autobook/app/preferences/currency_provider.dart';
import 'package:autobook/app/preferences/distance_unit_provider.dart';
import 'package:autobook/app/preferences/measurement_labels.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('distanceUnitLabel', () {
    late AppLocalizations english;
    late AppLocalizations spanish;

    setUp(() async {
      english = await AppLocalizations.delegate.load(const Locale('en'));
      spanish = await AppLocalizations.delegate.load(const Locale('es'));
    });

    test('kilometers map to the constant km symbol', () {
      final englishLabel = distanceUnitLabel(DistanceUnit.kilometers, english);
      final spanishLabel = distanceUnitLabel(DistanceUnit.kilometers, spanish);

      expect(englishLabel, 'km');
      expect(spanishLabel, 'km');
    });

    test('miles map to the localized long label', () {
      final englishLabel = distanceUnitLabel(DistanceUnit.miles, english);
      final spanishLabel = distanceUnitLabel(DistanceUnit.miles, spanish);

      expect(englishLabel, 'miles');
      expect(spanishLabel, 'millas');
    });
  });

  group('currencySymbol', () {
    test('maps each currency to its symbol', () {
      final euroSymbol = currencySymbol(Currency.euro);
      final dollarSymbol = currencySymbol(Currency.dollar);

      expect(euroSymbol, '€');
      expect(dollarSymbol, '\$');
    });
  });

  group('formatMileage', () {
    late AppLocalizations english;
    late AppLocalizations spanish;

    setUp(() async {
      english = await AppLocalizations.delegate.load(const Locale('en'));
      spanish = await AppLocalizations.delegate.load(const Locale('es'));
    });

    test('labels kilometers with the constant km symbol', () {
      final mileage = formatMileage(
        12500,
        DistanceUnit.kilometers,
        const Locale('en'),
        english,
      );

      expect(mileage, '12,500 km');
    });

    test('labels miles without converting the raw number', () {
      final englishMileage = formatMileage(
        12500,
        DistanceUnit.miles,
        const Locale('en'),
        english,
      );
      final spanishMileage = formatMileage(
        12500,
        DistanceUnit.miles,
        const Locale('es'),
        spanish,
      );

      expect(englishMileage, '12,500 miles');
      expect(spanishMileage, '12.500 millas');
    });
  });

  group('formatCost', () {
    test('keeps the cost digits and swaps the currency symbol', () {
      final euroCost = formatCost(1234.5, Currency.euro, const Locale('en'));
      final dollarCost = formatCost(
        1234.5,
        Currency.dollar,
        const Locale('en'),
      );

      expect(euroCost, '€1,234.50');
      expect(dollarCost, '\$1,234.50');
    });

    test('follows the Spanish grouping and symbol placement', () {
      final cost = formatCost(1234.5, Currency.euro, const Locale('es'));

      expect(cost, '1.234,50\u00A0€');
    });

    test('supports zero decimal digits for stat totals', () {
      final cost = formatCost(
        1235,
        Currency.euro,
        const Locale('es'),
        decimalDigits: 0,
      );

      expect(cost, '1.235\u00A0€');
    });
  });
}
