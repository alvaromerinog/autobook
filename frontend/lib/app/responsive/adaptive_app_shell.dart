import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizeClass = windowSizeClassOf(context);
    if (sizeClass == WindowSizeClass.compact) return child;
    if (sizeClass == WindowSizeClass.medium) {
      if (state.uri.path == '/') {
        return const Scaffold(
          body: Row(
            children: [
              AppSidebar(extended: false),
              Expanded(child: GarageListContent()),
            ],
          ),
        );
      }
      return child;
    }
    final carId = state.pathParameters['carId'];
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(extended: true),
          const VerticalDivider(width: 1),
          const Expanded(flex: 2, child: GarageListContent()),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: carId == null
                ? const _DetailPlaceholder(message: 'Selecciona un vehículo')
                : child,
          ),
        ],
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 56,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}