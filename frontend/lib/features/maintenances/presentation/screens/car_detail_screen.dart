import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/app/router/back_navigation.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maintenance_dialog.dart';
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
    if (!deleted || !context.mounted) return;
    if (windowSizeClassOf(context) == WindowSizeClass.expanded) {
      context.go('/');
    } else {
      goBack(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final carsState = ref.watch(carListProvider).value;
    Car? car;
    if (carsState != null) {
      for (final candidate in carsState.cars) {
        if (candidate.id == carId) {
          car = candidate;
          break;
        }
      }
    }
    final selectedCar = car;
    final maintAsync = ref.watch(maintenanceListProvider(carId));
    final embedded = windowSizeClassOf(context) == WindowSizeClass.expanded;

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
        leading: embedded ? null : BackButton(onPressed: () => goBack(context)),
      ),
      body: carsState == null
          ? const Center(child: CircularProgressIndicator())
          : selectedCar == null
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
                              '${selectedCar.year} · ${selectedCar.brand}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              selectedCar.model,
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
                          selectedCar.licensePlate,
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
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          // Reserves the buttons' 24px overhang so their
                          // centres stay inside the Stack's hit-test bounds
                          // (a Positioned child past the edge is not tappable).
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _StatStrip(
                            km: selectedCar.mileage?.toString() ?? '—',
                            spent: costFmt.format(totalSpent),
                            entries: s.maintenances.length.toString(),
                          ),
                        ),
                        Positioned(
                          right: 36, // _StatStrip's padding 20 + 16px inset
                          bottom: 0, // 24px reserve → centre on the card edge
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _DetailActionButton(
                                icon: Icons.edit_outlined,
                                tooltip: 'Editar vehículo',
                                discColor: cs.primary,
                                iconColor: cs.onPrimary,
                                onPressed: () =>
                                    _openEditCar(context, ref, selectedCar),
                              ),
                              const SizedBox(width: 8),
                              _DetailActionButton(
                                icon: Icons.delete_outlined,
                                tooltip: 'Eliminar vehículo',
                                discColor: cs.error,
                                iconColor: cs.onError,
                                onPressed: () =>
                                    _openDeleteCar(context, ref, selectedCar),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de mantenimientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final count =
                              maintAsync.value?.maintenances.length ?? 0;
                          return Text(
                            '$count ${count == 1 ? 'entrada' : 'entradas'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        },
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
                                context.go('/cars/$carId/maintenances/$id'),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final draft = await showMaintenanceDialog(context);
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

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    required this.icon,
    required this.tooltip,
    required this.discColor,
    required this.iconColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color discColor;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: discColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        color: iconColor,
        onPressed: onPressed,
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
        key: const Key('stat-strip-card'),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
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
