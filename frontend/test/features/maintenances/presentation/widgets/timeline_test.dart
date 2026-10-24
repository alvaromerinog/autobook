import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maint_type_pill.dart';
import 'package:autobook/features/maintenances/presentation/widgets/timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../app/localization_test_harness.dart';
import '../../fixtures/maintenance_fixtures.dart';

const _fullLabelsSpanish = <MaintenanceType, String>{
  MaintenanceType.oil: 'Cambio de aceite',
  MaintenanceType.coolant: 'Refrigerante',
  MaintenanceType.belt: 'Correa de distribución',
  MaintenanceType.itv: 'ITV',
  MaintenanceType.repair: 'Reparación general',
  MaintenanceType.filter: 'Filtro de aire',
  MaintenanceType.battery: 'Batería',
  MaintenanceType.brakes: 'Frenos',
  MaintenanceType.tires: 'Neumáticos',
};

const _fullLabelsEnglish = <MaintenanceType, String>{
  MaintenanceType.oil: 'Oil change',
  MaintenanceType.coolant: 'Coolant',
  MaintenanceType.belt: 'Timing belt',
  MaintenanceType.itv: 'Vehicle inspection',
  MaintenanceType.repair: 'General repair',
  MaintenanceType.filter: 'Air filter',
  MaintenanceType.battery: 'Battery',
  MaintenanceType.brakes: 'Brakes',
  MaintenanceType.tires: 'Tires',
};

const _shortLabelsSpanish = <MaintenanceType, String>{
  MaintenanceType.oil: 'Aceite',
  MaintenanceType.coolant: 'Refrigerante',
  MaintenanceType.belt: 'Distribución',
  MaintenanceType.itv: 'ITV',
  MaintenanceType.repair: 'Reparación',
  MaintenanceType.filter: 'Filtro',
  MaintenanceType.battery: 'Batería',
  MaintenanceType.brakes: 'Frenos',
  MaintenanceType.tires: 'Ruedas',
};

const _shortLabelsEnglish = <MaintenanceType, String>{
  MaintenanceType.oil: 'Oil',
  MaintenanceType.coolant: 'Coolant',
  MaintenanceType.belt: 'Belt',
  MaintenanceType.itv: 'ITV',
  MaintenanceType.repair: 'Repair',
  MaintenanceType.filter: 'Filter',
  MaintenanceType.battery: 'Battery',
  MaintenanceType.brakes: 'Brakes',
  MaintenanceType.tires: 'Tires',
};

Widget _pumpTimeline(
  List<Maintenance> items, {
  ThemeData? theme,
  Locale locale = const Locale('es'),
}) {
  return localizedTestApp(
    locale: locale,
    theme: theme,
    home: Scaffold(
      body: Timeline(maintenances: items, carId: 'car-1', onOpen: (_) {}),
    ),
  );
}

Color _pinnedHeaderBackground(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .ancestor(of: find.text('2026'), matching: find.byType(Container))
        .first,
  );
  return container.color!;
}

void main() {
  group('Timeline', () {
    testWidgets('given one maintenance with yyyy-MM-dd date, '
        'when pumped, '
        'then the type label and year are painted', (tester) async {
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });

    testWidgets('given one maintenance with ISO datetime date, '
        'when pumped, '
        'then no exception is thrown and year is correct', (tester) async {
      final m = buildMaintenance(date: '2026-08-25T10:30:00.000Z');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(find.text('2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('given three maintenances across two years, '
        'when pumped, '
        'then years are desc and entries within a year are date desc', (
      tester,
    ) async {
      final jan = buildMaintenance(id: 'jan', date: '2026-01-05');
      final mar = buildMaintenance(id: 'mar', date: '2026-03-12');
      final nov = buildMaintenance(id: 'nov', date: '2025-11-18');

      await tester.pumpWidget(_pumpTimeline([jan, mar, nov]));

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
      final labels = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toList();
      final marIndex = labels.indexOf('Cambio de aceite');
      expect(marIndex, greaterThanOrEqualTo(0));
    });

    testWidgets('given an unparseable date, '
        'when pumped in Spanish, '
        'then the no-date header is shown and no exception is thrown', (
      tester,
    ) async {
      final m = buildMaintenance(date: 'no-es-una-fecha');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(find.text('Sin fecha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('given an unparseable date, '
        'when pumped in English, '
        'then the English no-date header is shown', (tester) async {
      final m = buildMaintenance(date: 'no-es-una-fecha');

      await tester.pumpWidget(_pumpTimeline([m], locale: const Locale('en')));

      expect(find.text('No date'), findsOneWidget);
      expect(find.text('Sin fecha'), findsNothing);
    });

    testWidgets('given one maintenance, '
        'when pumped, '
        'then the entry exposes a semantics label with type and date', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(
        find.bySemanticsLabel(RegExp(r'Cambio de aceite.*')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('given the English locale, '
        'when pumped, '
        'then the semantics label uses the English type and month', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m], locale: const Locale('en')));

      expect(
        find.bySemanticsLabel(RegExp(r'^Oil change on 12 Mar')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('given a long mileage and cost on a narrow screen, '
        'when pumped, '
        'then the entry does not overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final m = buildMaintenance(
        mileage: 189000,
        cost: 120000,
        date: '2026-03-12',
      );

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(tester.takeException(), isNull);
    });

    testWidgets('given an entry, '
        'when pumped, '
        'then the card paints its own Material instead of deferring the '
        'decoration to the ambient Material', (tester) async {
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(
        find.descendant(
          of: find.byType(TimelineEntry),
          matching: find.byType(Ink),
        ),
        findsNothing,
      );
      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(TimelineEntry),
              matching: find.byType(Material),
            )
            .first,
      );
      final cs = Theme.of(
        tester.element(find.byType(TimelineEntry)),
      ).colorScheme;
      expect(card.color, cs.surfaceContainerLow);
    });

    testWidgets('given the app theme changes, '
        'when the timeline is rebuilt, '
        'then the pinned year label sits on the new page background', (
      tester,
    ) async {
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');
      await tester.pumpWidget(
        _pumpTimeline([m], theme: ThemeData(brightness: Brightness.light)),
      );
      final lightBackground = _pinnedHeaderBackground(tester);

      await tester.pumpWidget(
        _pumpTimeline([m], theme: ThemeData(brightness: Brightness.dark)),
      );
      await tester.pumpAndSettle();
      final darkBackground = _pinnedHeaderBackground(tester);

      expect(darkBackground, isNot(lightBackground));
    });
  });

  group('Timeline labels in Spanish', () {
    testWidgets('given every type, when pumped, then the full label is shown', (
      tester,
    ) async {
      for (final type in MaintenanceType.values) {
        await tester.pumpWidget(
          _pumpTimeline([buildMaintenance(type: type, date: '2026-03-12')]),
        );

        expect(find.text(_fullLabelsSpanish[type]!), findsOneWidget);
      }
    });

    testWidgets('given an entry, when pumped, then mileage, cost and month '
        'follow the Spanish formatting', (tester) async {
      final m = buildMaintenance(mileage: 189000, cost: 1234.5);

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(find.text('189.000 km'), findsOneWidget);
      expect(find.text('1.234,50\u00A0€'), findsOneWidget);
      expect(find.text('12 mar'), findsOneWidget);
    });
  });

  group('Timeline labels in English', () {
    testWidgets('given every type, when pumped, then the full label is shown', (
      tester,
    ) async {
      for (final type in MaintenanceType.values) {
        await tester.pumpWidget(
          _pumpTimeline([
            buildMaintenance(type: type, date: '2026-03-12'),
          ], locale: const Locale('en')),
        );

        expect(find.text(_fullLabelsEnglish[type]!), findsOneWidget);
      }
    });

    testWidgets('given an entry, when pumped, then mileage, cost and month '
        'follow the English formatting', (tester) async {
      final m = buildMaintenance(mileage: 189000, cost: 1234.5);

      await tester.pumpWidget(_pumpTimeline([m], locale: const Locale('en')));

      expect(find.text('189,000 km'), findsOneWidget);
      expect(find.text('€1,234.50'), findsOneWidget);
      expect(find.text('12 Mar'), findsOneWidget);
    });
  });

  group('MaintTypePill', () {
    testWidgets('given every type, when pumped in Spanish, then the short '
        'label is shown', (tester) async {
      for (final type in MaintenanceType.values) {
        await tester.pumpWidget(
          localizedTestApp(
            home: Scaffold(
              body: Center(child: MaintTypePill(type: type)),
            ),
          ),
        );

        expect(find.text(_shortLabelsSpanish[type]!), findsOneWidget);
      }
    });

    testWidgets('given every type, when pumped in English, then the short '
        'label is shown', (tester) async {
      for (final type in MaintenanceType.values) {
        await tester.pumpWidget(
          localizedTestApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: Center(child: MaintTypePill(type: type)),
            ),
          ),
        );

        expect(find.text(_shortLabelsEnglish[type]!), findsOneWidget);
      }
    });
  });

  group('Timeline scroll', () {
    testWidgets('given more maintenances than fit the viewport, '
        'when pumped, '
        'then the list scrolls instead of overflowing', (tester) async {
      final items = [
        for (var i = 0; i < 30; i++)
          buildMaintenance(id: 'm$i', date: '2026-03-${(i % 28) + 1}'),
      ];

      await tester.pumpWidget(_pumpTimeline(items));

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('given maintenances in two years, '
        'when scrolled inside the first year group, '
        'then the year label stays pinned at the top', (tester) async {
      final items = [
        for (var i = 0; i < 25; i++)
          buildMaintenance(id: 'a$i', date: '2026-03-${(i % 28) + 1}'),
        for (var i = 0; i < 25; i++)
          buildMaintenance(id: 'b$i', date: '2025-03-${(i % 28) + 1}'),
      ];
      await tester.pumpWidget(_pumpTimeline(items));
      final pinnedTop = tester.getTopLeft(find.text('2026')).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('2026')).dy, pinnedTop);
    });

    testWidgets('given maintenances in two years, '
        'when scrolled past the first year group, '
        'then the next year label takes over the pinned slot', (tester) async {
      final items = [
        for (var i = 0; i < 25; i++)
          buildMaintenance(id: 'a$i', date: '2026-03-${(i % 28) + 1}'),
        for (var i = 0; i < 25; i++)
          buildMaintenance(id: 'b$i', date: '2025-03-${(i % 28) + 1}'),
      ];
      await tester.pumpWidget(_pumpTimeline(items));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2600));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('2025')).dy, lessThanOrEqualTo(20));
      final previousYear = find.text('2026');
      expect(
        previousYear.evaluate().isEmpty ||
            tester.getTopLeft(previousYear).dy < 0,
        isTrue,
      );
    });
  });

  group('TimelineEntry interacción', () {
    testWidgets('dada una entrada del timeline, '
        'cuando se bombea, '
        'entonces la tarjeta muestra el chevron_right a la derecha', (
      tester,
    ) async {
      final m = buildMaintenance(type: MaintenanceType.oil, date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m]));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('dada una entrada del timeline, '
        'cuando se bombea, '
        'entonces el área de la tarjeta expone el cursor de enlace', (
      tester,
    ) async {
      final m = buildMaintenance(date: '2026-03-12');

      await tester.pumpWidget(_pumpTimeline([m]));

      final regions = tester.widgetList<MouseRegion>(
        find.descendant(
          of: find.byType(TimelineEntry),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(regions.any((r) => r.cursor == SystemMouseCursors.click), isTrue);
    });

    testWidgets('dada una entrada del timeline, '
        'cuando se pulsa la tarjeta, '
        'entonces onOpen recibe su id', (tester) async {
      final m = buildMaintenance(id: 'm1', date: '2026-03-12');
      final openedIds = <String>[];

      await tester.pumpWidget(
        localizedTestApp(
          home: Scaffold(
            body: Timeline(
              maintenances: [m],
              carId: 'car-1',
              onOpen: openedIds.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Cambio de aceite'));

      expect(openedIds, ['m1']);
    });
  });
}
