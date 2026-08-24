import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/screens/add_maintenance_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/car_detail_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/vehicles/presentation/screens/home_screen.dart';
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
          final ref = ProviderScope.containerOf(context, listen: false);
          final carId = state.pathParameters['carId']!;
          final id = state.pathParameters['id']!;
          final state_ = ref.read(maintenanceListProvider(carId)).value;
          final existing = state_?.maintenances.firstWhere(
            (m) => m.id == id,
            orElse: () => throw StateError('maintenance $id not cached'),
          );
          return AddMaintenanceScreen(carId: carId, existing: existing);
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
