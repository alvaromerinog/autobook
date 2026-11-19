import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/widgets/delete_car_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../app/localization_test_harness.dart';
import '../../fixtures/car_fixtures.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester,
    Car car,
    List<bool?> result, {
    Locale locale = const Locale('es'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          locale: locale,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result[0] = await showDeleteConfirmDialog(context, car);
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  group('DeleteCarDialog', () {
    testWidgets('given the dialog, when Eliminar is pressed, '
        'then it pops with true and closes', (tester) async {
      final result = <bool?>[null];
      await pumpDialog(tester, toyotaCorolla, result);
      expect(find.text('Eliminar vehículo'), findsOneWidget);

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(result[0], isTrue);
      expect(find.text('Eliminar vehículo'), findsNothing);
    });

    testWidgets('given the dialog, when Cancelar is pressed, '
        'then it pops with false and closes', (tester) async {
      final result = <bool?>[null];
      await pumpDialog(tester, toyotaCorolla, result);
      expect(
        find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result[0], isFalse);
      expect(find.text('Eliminar vehículo'), findsNothing);
    });

    testWidgets('given the dialog in English, then the confirmation and '
        'actions are translated', (tester) async {
      final result = <bool?>[null];
      await pumpDialog(
        tester,
        toyotaCorolla,
        result,
        locale: const Locale('en'),
      );

      expect(find.text('Delete vehicle'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete Toyota Corolla?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result[0], isTrue);
    });
  });
}
