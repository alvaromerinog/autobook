import 'package:autobook/features/vehicles/presentation/widgets/add_car_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return NavigationRail(
      extended: extended,
      selectedIndex: 0,
      onDestinationSelected: (_) => context.go('/'),
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Icon(Icons.directions_car, color: colorScheme.primary),
                const SizedBox(height: 4),
                Text(
                  'Autobook',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (extended)
            FilledButton.tonalIcon(
              onPressed: () => addCar(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Añadir coche'),
            )
          else
            IconButton(
              onPressed: () => addCar(context, ref),
              tooltip: 'Añadir coche',
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.garage),
          label: Text('Garaje'),
        ),
      ],
    );
  }
}
