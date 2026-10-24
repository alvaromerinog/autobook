import 'package:autobook/features/vehicles/presentation/widgets/add_car_action.dart';
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Autobook'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings),
          ),
        ],
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: const GarageListContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addCar(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
      ),
    );
  }
}
