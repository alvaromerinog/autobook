import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app/localization_test_harness.dart';

void main() {
  group('AppLocalizations', () {
    late AppLocalizations english;
    late AppLocalizations spanish;

    setUp(() async {
      english = await AppLocalizations.delegate.load(const Locale('en'));
      spanish = await AppLocalizations.delegate.load(const Locale('es'));
    });

    test('supports only English and Spanish', () {
      expect(
        AppLocalizations.supportedLocales,
        unorderedEquals(const [Locale('en'), Locale('es')]),
      );
    });

    group('navigation and settings labels', () {
      test('garage is translated in both catalogs', () {
        expect(english.garage, 'Garage');
        expect(spanish.garage, 'Garaje');
      });

      test('settingsTitle is translated in both catalogs', () {
        expect(english.settingsTitle, 'Settings');
        expect(spanish.settingsTitle, 'Ajustes');
      });

      test('languageLabel is translated in both catalogs', () {
        expect(english.languageLabel, 'Language');
        expect(spanish.languageLabel, 'Idioma');
      });
    });

    group('common actions', () {
      test('cancel is translated in both catalogs', () {
        expect(english.cancel, 'Cancel');
        expect(spanish.cancel, 'Cancelar');
      });

      test('delete is translated in both catalogs', () {
        expect(english.delete, 'Delete');
        expect(spanish.delete, 'Eliminar');
      });

      test('edit is translated in both catalogs', () {
        expect(english.edit, 'Edit');
        expect(spanish.edit, 'Editar');
      });

      test('retry is translated in both catalogs', () {
        expect(english.retry, 'Retry');
        expect(spanish.retry, 'Reintentar');
      });

      test('close is translated in both catalogs', () {
        expect(english.close, 'Close');
        expect(spanish.close, 'Cerrar');
      });

      test('saveChanges is translated in both catalogs', () {
        expect(english.saveChanges, 'Save changes');
        expect(spanish.saveChanges, 'Guardar cambios');
      });
    });

    group('vehicle actions', () {
      test('addCar is translated in both catalogs', () {
        expect(english.addCar, 'Add car');
        expect(spanish.addCar, 'Añadir coche');
      });

      test('addVehicle is translated in both catalogs', () {
        expect(english.addVehicle, 'Add vehicle');
        expect(spanish.addVehicle, 'Añadir vehículo');
      });

      test('selectVehicle is translated in both catalogs', () {
        expect(english.selectVehicle, 'Select a vehicle');
        expect(spanish.selectVehicle, 'Selecciona un vehículo');
      });
    });
  });

  group('localizedTestApp', () {
    Widget settingsTitleText(BuildContext context) =>
        Text(AppLocalizations.of(context)!.settingsTitle);

    testWidgets('uses the caller-supplied English locale', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          locale: const Locale('en'),
          home: Builder(builder: settingsTitleText),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('defaults to Spanish', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(home: Builder(builder: settingsTitleText)),
      );

      expect(find.text('Ajustes'), findsOneWidget);
    });
  });
}
