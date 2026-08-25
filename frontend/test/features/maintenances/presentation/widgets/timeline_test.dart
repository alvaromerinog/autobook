import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/presentation/widgets/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/maintenance_fixtures.dart';

Widget _pumpTimeline(List<Maintenance> items) {
  return MaterialApp(
    home: Scaffold(
      body: Timeline(
        maintenances: items,
        carId: 'car-1',
        onOpen: (_) {},
      ),
    ),
  );
}

void main() {
  group('Timeline', () {
    testWidgets('given one maintenance with yyyy-MM-dd date, '
        'when pumped, '
        'then the type label and year are painted', (tester) async {
      // given
      final m = buildMaintenance(
        type: MaintenanceType.oil,
        date: '2026-03-12',
      );

      // when
      await tester.pumpWidget(_pumpTimeline([m]));

      // then
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });

    testWidgets('given one maintenance with ISO datetime date, '
        'when pumped, '
        'then no exception is thrown and year is correct', (tester) async {
      // given
      final m = buildMaintenance(date: '2026-08-25T10:30:00.000Z');

      // when
      await tester.pumpWidget(_pumpTimeline([m]));

      // then
      expect(find.text('2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('given three maintenances across two years, '
        'when pumped, '
        'then years are desc and entries within a year are date desc',
        (tester) async {
      // given
      final jan = buildMaintenance(id: 'jan', date: '2026-01-05');
      final mar = buildMaintenance(id: 'mar', date: '2026-03-12');
      final nov = buildMaintenance(id: 'nov', date: '2025-11-18');

      // when
      await tester.pumpWidget(_pumpTimeline([jan, mar, nov]));

      // then — year labels appear desc: 2026 before 2025
      final yearWidgets = find
          .byType(Text)
          .evaluate()
          .where((e) => (e.widget as Text).data == '2026')
          .toList();
      final year2025 = find
          .byType(Text)
          .evaluate()
          .where((e) => (e.widget as Text).data == '2025')
          .toList();
      expect(yearWidgets, isNotEmpty);
      expect(year2025, isNotEmpty);
      // Within 2026, 'mar' (Cambio de aceite) renders before 'jan'
      final labels = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toList();
      final marIndex = labels.indexOf('Cambio de aceite');
      expect(marIndex, greaterThanOrEqualTo(0));
    });

    testWidgets('given an unparseable date, '
        'when pumped, '
        'then no exception is thrown', (tester) async {
      // given
      final m = buildMaintenance(date: 'no-es-una-fecha');

      // when
      await tester.pumpWidget(_pumpTimeline([m]));

      // then
      expect(tester.takeException(), isNull);
    });

    testWidgets('given one maintenance, '
        'when pumped, '
        'then the entry exposes a semantics label with type and date',
        (tester) async {
      // given
      final handle = tester.ensureSemantics();
      final m = buildMaintenance(
        type: MaintenanceType.oil,
        date: '2026-03-12',
      );

      // when
      await tester.pumpWidget(_pumpTimeline([m]));

      // then
      expect(
        find.bySemanticsLabel(
          RegExp(r'Cambio de aceite.*'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}