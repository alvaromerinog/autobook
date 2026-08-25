import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/screens/add_maintenance_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/car_detail_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/vehicles/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/cars/:carId',
        builder: (context, state) =>
            CarDetailScreen(carId: state.pathParameters['carId']!),
      ),
      GoRoute(
        path: '/cars/:carId/maintenances/:id',
        builder: (context, state) => MaintenanceDetailScreen(
          carId: state.pathParameters['carId']!,
          maintenanceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/cars/:carId/maintenances/:id/edit',
        builder: (context, state) {
          final carId = state.pathParameters['carId']!;
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          if (extra is Maintenance && extra.id == id && extra.carId == carId) {
            return AddMaintenanceScreen(carId: carId, existing: extra);
          }
          final ref = ProviderScope.containerOf(context, listen: false);
          final cachedRows = ref
              .read(maintenanceListProvider(carId))
              .value
              ?.maintenances;
          Maintenance? match;
          for (final m in cachedRows ?? const <Maintenance>[]) {
            if (m.id == id) {
              match = m;
              break;
            }
          }
          if (match == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                leading: BackButton(onPressed: () => context.pop()),
              ),
              body: const Center(child: Text('Registro no encontrado')),
            );
          }
          return AddMaintenanceScreen(carId: carId, existing: match);
        },
      ),
      GoRoute(
        path: '/cars/:carId/add-maintenance',
        builder: (context, state) =>
            AddMaintenanceScreen(carId: state.pathParameters['carId']!),
      ),
    ],
  );
}
