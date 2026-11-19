import 'package:autobook/app/preferences/currency_provider.dart';
import 'package:autobook/app/preferences/distance_unit_provider.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String distanceUnitLabel(DistanceUnit unit, AppLocalizations l10n) =>
    switch (unit) {
      DistanceUnit.kilometers => 'km',
      DistanceUnit.miles => l10n.unitMiles,
    };

String currencySymbol(Currency currency) => switch (currency) {
  Currency.euro => '€',
  Currency.dollar => '\$',
};

String formatMileage(
  int mileage,
  DistanceUnit unit,
  Locale locale,
  AppLocalizations l10n,
) {
  final mileageNumber = NumberFormat.decimalPattern(
    locale.toString(),
  ).format(mileage);
  return '$mileageNumber ${distanceUnitLabel(unit, l10n)}';
}

String formatCost(
  double cost,
  Currency currency,
  Locale locale, {
  int decimalDigits = 2,
}) {
  return NumberFormat.currency(
    locale: locale.toString(),
    symbol: currencySymbol(currency),
    decimalDigits: decimalDigits,
  ).format(cost);
}
