import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/widgets/timeline.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/screens/add_car_screen.dart'
    show showCarDialog;
import 'package:autobook/features/vehicles/presentation/widgets/delete_car_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CarDetailScreen extends ConsumerWidget {
  const CarDetailScreen({super.key, required this.carId});

  final String carId;

  Future<bool> _runMutation(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() mutation, {
    required String errorText,
  }) async {
    try {
      await mutation();
      return true;
    } on Failure catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorText)));
      }
      return false;
    }
  }

  Future<void> _openEditCar(
    BuildContext context,
    WidgetRef ref,
    Car car,
  ) async {
    final draft = (
      brand: car.brand,
      model: car.model,
      year: car.year,
      licensePlate: car.licensePlate,
      color: car.color,
      mileage: car.mileage,
    );
    final updated = await showCarDialog(context, initial: draft);
    if (updated == null || !context.mounted) return;
    await _runMutation(
      context,
      ref,
      () => ref.read(carListProvider.notifier).updateCar(updated, car),
      errorText: 'Error al actualizar el vehículo',
    );
  }

  Future<void> _openDeleteCar(
    BuildContext context,
    WidgetRef ref,
    Car car,
  ) async {
    final confirmed = await showDeleteConfirmDialog(context, car);
    if (confirmed != true || !context.mounted) return;
    final deleted = await _runMutation(
      context,
      ref,
      () => ref.read(carListProvider.notifier).deleteCar(car),
      errorText: 'Error al eliminar el vehículo',
    );
    if (deleted && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final carsState = ref.watch(carListProvider).value;
    final car = carsState?.cars.firstWhere(
      (c) => c.id == carId,
      orElse: () =>
          const Car(id: '', brand: '', model: '', year: 0, licensePlate: ''),
    );
    final maintAsync = ref.watch(maintenanceListProvider(carId));

    ref.listen<
      AsyncValue<MaintenanceListState>
    >(maintenanceListProvider(carId), (prev, next) {
      next.whenData((s) {
        if (s.remoteSyncEvents.isEmpty) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.remoteSyncEvents
                  .map(
                    (e) => e.when(
                      remoteDeleted: (m) => 'Mantenimiento ${m.id} eliminado',
                      remoteDeletedWithPendingUpdate: (m) =>
                          'Mantenimiento ${m.id} eliminado, edición descartada',
                    ),
                  )
                  .join('\n'),
            ),
          ),
        );
        ref
            .read(maintenanceListProvider(carId).notifier)
            .clearRemoteChangeBanner();
      });
    });

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          if (car != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar vehículo',
              onPressed: () => _openEditCar(context, ref, car),
            ),
          if (car != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'delete') _openDeleteCar(context, ref, car);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar vehículo'),
                ),
              ],
            ),
        ],
      ),
      body: car == null
          ? const Center(child: Text('Vehículo no encontrado'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.year} · ${car.brand}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              car.model,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: cs.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          border: Border.all(color: cs.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.licensePlate,
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                maintAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (s) {
                    final totalSpent = s.maintenances.fold<double>(
                      0,
                      (sum, m) => sum + m.cost,
                    );
                    final locale = Localizations.localeOf(context).toString();
                    final costFmt = NumberFormat.currency(
                      locale: locale,
                      symbol: '€',
                      decimalDigits: 0,
                    );
                    return _StatStrip(
                      km: car.mileage?.toString() ?? '—',
                      spent: costFmt.format(totalSpent),
                      entries: s.maintenances.length.toString(),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de mantenimientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${maintAsync.value?.maintenances.length ?? 0} entradas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: maintAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (s) => s.maintenances.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text('Sin mantenimientos registrados'),
                            ),
                          )
                        : Timeline(
                            maintenances: s.maintenances,
                            carId: carId,
                            onOpen: (id) =>
                                context.push('/cars/$carId/maintenances/$id'),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final draft = await context
              .push<
                ({
                  MaintenanceType type,
                  String date,
                  int mileage,
                  double cost,
                  String? garage,
                  String? notes,
                })
              >('/cars/$carId/add-maintenance');
          if (draft == null) return;
          try {
            await ref.read(maintenanceListProvider(carId).notifier).add(draft);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mantenimiento registrado')),
            );
          } on Failure catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al crear el mantenimiento')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir mantenimiento'),
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  const _StatStrip({
    required this.km,
    required this.spent,
    required this.entries,
  });

  final String km;
  final String spent;
  final String entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _Stat(icon: Icons.speed_outlined, value: km, label: 'KM'),
              _Divider(),
              _Stat(icon: Icons.euro, value: spent, label: 'GASTADO'),
              _Divider(),
              _Stat(
                icon: Icons.receipt_outlined,
                value: entries,
                label: 'ENTRADAS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
