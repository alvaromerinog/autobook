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
      // given / when
      await _pumpDialog(tester);

      // then — abrir el desplegable
      await tester.tap(find.byType(DropdownButtonFormField<MaintenanceType>));
      await tester.pumpAndSettle();

      // 9 iconos de tipo visibles en el popup + 9 labels largos
      expect(find.byType(MaintTypeIcon), findsAtLeastNWidgets(9));
      expect(find.text('Cambio de aceite'), findsWidgets);
      expect(find.text('Neumáticos'), findsOneWidget);
    });

    testWidgets('given valid fields, '
        'when Guardar is tapped, '
        'then a MaintenanceDraft is returned with the selected type', (
      tester,
    ) async {
      // given
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

      // when
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // then — type por defecto oil
      expect(draft(), isNotNull);
      expect(draft()?.type, MaintenanceType.oil);
      expect(draft()?.mileage, 45000);
      expect(draft()?.cost, 120.5);
    });

    testWidgets('given an existing maintenance, '
        'when the dialog opens, '
        'then fields are preloaded with its values', (tester) async {
      // given
      final existing = buildMaintenance(
        type: MaintenanceType.brakes,
        date: '2026-02-10',
        mileage: 30000,
        cost: 80,
        garage: 'Taller Marín',
        notes: 'Pastillas nuevas',
      );

      // when
      await _pumpDialog(tester, existing: existing);

      // then
      expect(find.text('Frenos'), findsWidgets);
      expect(find.text('Taller Marín'), findsOneWidget);
    });
  });
}
