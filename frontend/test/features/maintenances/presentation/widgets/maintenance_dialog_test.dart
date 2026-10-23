import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maintenance_dialog.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maint_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/maintenance_fixtures.dart';

Future<MaintenanceDraft? Function()> _pumpDialog(
  WidgetTester tester, {
  Maintenance? existing,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  MaintenanceDraft? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showMaintenanceDialog(
                  context,
                  existing: existing,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  group('showMaintenanceDialog', () {
    testWidgets('given the dialog opened, '
        'when the type dropdown is opened, '
        'then 9 options are shown, each with icon and long label', (
      tester,
    ) async {
      await _pumpDialog(tester);

      await tester.tap(find.byType(DropdownButtonFormField<MaintenanceType>));
      await tester.pumpAndSettle();

      expect(find.byType(MaintTypeIcon), findsAtLeastNWidgets(9));
      expect(find.text('Cambio de aceite'), findsWidgets);
      expect(find.text('Neumáticos'), findsOneWidget);
    });

    testWidgets('given valid fields, '
        'when Guardar is tapped, '
        'then a MaintenanceDraft is returned with the selected type', (
      tester,
    ) async {
      final draft = await _pumpDialog(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kilómetros'),
        '45000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Coste'),
        '120.50',
      );
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(draft(), isNotNull);
      expect(draft()?.type, MaintenanceType.oil);
      expect(draft()?.mileage, 45000);
      expect(draft()?.cost, 120.5);
    });

    testWidgets('given an existing maintenance, '
        'when the dialog opens, '
        'then fields are preloaded with its values', (tester) async {
      final existing = buildMaintenance(
        type: MaintenanceType.brakes,
        date: '2026-02-10',
        mileage: 30000,
        cost: 80,
        garage: 'Taller Marín',
        notes: 'Pastillas nuevas',
      );

      await _pumpDialog(tester, existing: existing);

      expect(find.text('Frenos'), findsWidgets);
      expect(find.text('Taller Marín'), findsOneWidget);
    });

    testWidgets('given the dialog open in create mode, '
        'when it renders, '
        'then both section headers show above their fields', (tester) async {
      await _pumpDialog(tester);

      final header1 = find.text('Datos del mantenimiento');
      final header2 = find.text('Información adicional (opcional)');
      expect(header1, findsOneWidget);
      expect(header2, findsOneWidget);

      final yHeader1 = tester.getTopLeft(header1).dy;
      final yHeader2 = tester.getTopLeft(header2).dy;
      expect(yHeader1, lessThan(tester.getTopLeft(find.text('Coste')).dy));
      expect(yHeader2, lessThan(tester.getTopLeft(find.text('Taller')).dy));
      expect(yHeader1, lessThan(yHeader2));
    });

    testWidgets('given an empty Coste, '
        'when the dialog renders, '
        'then the save button stays enabled and validates on tap', (
      tester,
    ) async {
      final draft = await _pumpDialog(tester);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(draft(), isNull);
      expect(find.text('El coste es obligatorio'), findsOneWidget);
    });

    testWidgets('given a valid Coste but cleared Kilómetros, '
        'when Guardar is tapped, '
        'then the obligatory kilometers message is shown', (tester) async {
      final draft = await _pumpDialog(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kilómetros'),
        '',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Coste'),
        '120.50',
      );
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(draft(), isNull);
      expect(find.text('Los kilómetros son obligatorios'), findsOneWidget);
    });

    testWidgets('given valid Kilómetros and Coste, '
        'when the done action fires on Kilómetros, '
        'then the dialog pops a draft', (tester) async {
      final draft = await _pumpDialog(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kilómetros'),
        '45000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Coste'),
        '120.50',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(TextFormField, 'Kilómetros'));
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(draft(), isNotNull);
      expect(draft()?.type, MaintenanceType.oil);
      expect(draft()?.mileage, 45000);
      expect(draft()?.cost, 120.5);
    });

    testWidgets('given an empty Coste, '
        'when the done action fires on Kilómetros, '
        'then the form validates and stays open', (tester) async {
      final draft = await _pumpDialog(tester);
      await tester.tap(find.widgetWithText(TextFormField, 'Kilómetros'));
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(draft(), isNull);
      expect(find.text('El coste es obligatorio'), findsOneWidget);
    });

    testWidgets('given the Notas field, '
        'when the done action fires on it, '
        'then it keeps newline and never submits the form', (tester) async {
      final draft = await _pumpDialog(tester);
      final notasField = find.descendant(
        of: find.widgetWithText(TextFormField, 'Notas'),
        matching: find.byType(TextField),
      );

      expect(
        tester.widget<TextField>(notasField).textInputAction,
        TextInputAction.newline,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notas'),
        'Revisar filtro',
      );
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(draft(), isNull);
      expect(find.text('El coste es obligatorio'), findsNothing);
    });

    testWidgets('given an existing maintenance, '
        'when Guardar cambios is tapped, '
        'then the edit dialog stays enabled and pops the draft', (
      tester,
    ) async {
      final draft = await _pumpDialog(
        tester,
        existing: buildMaintenance(
          type: MaintenanceType.brakes,
          date: '2026-02-10',
          mileage: 30000,
          cost: 80,
          garage: 'Taller Marín',
          notes: 'Pastillas nuevas',
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(draft(), isNotNull);
      expect(draft()?.type, MaintenanceType.brakes);
      expect(draft()?.date, '2026-02-10');
      expect(draft()?.mileage, 30000);
      expect(draft()?.cost, 80);
      expect(draft()?.garage, 'Taller Marín');
      expect(draft()?.notes, 'Pastillas nuevas');
    });
  });
}
