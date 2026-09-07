import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizeClass = windowSizeClassOf(context);
    final carId = GoRouterState.of(context).pathParameters['carId'];
    Widget layout;
    if (sizeClass == WindowSizeClass.compact) {
      layout = child;
    } else {
      if (sizeClass == WindowSizeClass.medium) {
        layout = Scaffold(
          body: Row(
            children: [
              const AppSidebar(extended: false),
              const VerticalDivider(width: 1),
              Expanded(
                child: carId == null ? const GarageListContent() : child,
              ),
            ],
          ),
        );
      } else {
        layout = Scaffold(
          body: Row(
            children: [
              const AppSidebar(extended: true),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: GarageListContent(selectedCarId: carId)),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: carId == null ? const _DetailPlaceholder() : child,
              ),
            ],
          ),
        );
      }
    }

    // Guard system / hardware / web back, which never goes through any
    // BackButton. Can't live on the screens themselves: go_router nests a
    // Navigator inside the shell, and the back dispatcher only interrogates
    // the shell's own route. Navigate with `go`, never `pop`: a pop here
    // would be re-intercepted while the Navigator is locked.
    return PopScope<Object?>(
      canPop: carId == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: layout,
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

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
            'Selecciona un vehículo',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
