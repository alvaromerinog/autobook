import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/widgets/delete_car_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/car_fixtures.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, Car car, List<bool?> result) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
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
      // given
      final result = <bool?>[null];
      await pumpDialog(tester, toyotaCorolla, result);
      expect(find.text('Eliminar vehículo'), findsOneWidget);

      // when
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // then
      expect(result[0], isTrue);
      expect(find.text('Eliminar vehículo'), findsNothing);
    });

    testWidgets('given the dialog, when Cancelar is pressed, '
        'then it pops with false and closes', (tester) async {
      // given
      final result = <bool?>[null];
      await pumpDialog(tester, toyotaCorolla, result);
      expect(
        find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
        findsOneWidget,
      );

      // when
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // then
      expect(result[0], isFalse);
      expect(find.text('Eliminar vehículo'), findsNothing);
    });
  });
}
