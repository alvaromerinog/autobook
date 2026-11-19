import 'package:autobook/features/vehicles/presentation/widgets/add_car_action.dart';
import 'package:autobook/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isSettings = GoRouterState.of(context).uri.path == '/settings';
    return NavigationRail(
      extended: extended,
      selectedIndex: isSettings ? 1 : 0,
      onDestinationSelected: (index) =>
          context.go(index == 0 ? '/' : '/settings'),
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
              label: Text(l10n.addCar),
            )
          else
            IconButton(
              onPressed: () => addCar(context, ref),
              tooltip: l10n.addCar,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.garage),
          label: Text(l10n.garage),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings),
          label: Text(l10n.settingsTitle),
        ),
      ],
    );
  }
}
