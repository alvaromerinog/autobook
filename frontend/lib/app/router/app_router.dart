import 'package:autobook/app/responsive/adaptive_app_shell.dart';
import 'package:autobook/features/maintenances/presentation/screens/car_detail_screen.dart';
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/vehicles/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final List<RouteBase> _routes = [
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

/// The app's router.
///
/// [initialLocation] lets a caller start anywhere in the tree, which is what
/// deep links and widget tests need.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref, {String initialLocation = '/'}) =>
    GoRouter(initialLocation: initialLocation, routes: _routes);
