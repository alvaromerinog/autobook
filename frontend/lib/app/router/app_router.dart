import 'package:autobook/app/responsive/adaptive_app_shell.dart';
import 'package:autobook/features/maintenances/presentation/screens/car_detail_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/vehicles/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Shared route table so tests can build a `GoRouter` with a custom
/// [GoRouter.initialLocation] while keeping the exact production routes.
List<RouteBase> buildAppRoutes() => [
  ShellRoute(
    builder: (context, state, child) => AdaptiveAppShell(child: child),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/cars/:carId',
        builder: (context, state) =>
            CarDetailScreen(carId: state.pathParameters['carId']!),
      ),
    ],
  ),
  GoRoute(
    path: '/cars/:carId/maintenances/:id',
    builder: (context, state) => MaintenanceDetailScreen(
      carId: state.pathParameters['carId']!,
      maintenanceId: state.pathParameters['id']!,
    ),
  ),
];

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(routes: buildAppRoutes());
}
