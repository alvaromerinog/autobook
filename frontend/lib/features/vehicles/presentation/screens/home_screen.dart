import 'dart:ui';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/screens/add_car_screen.dart'
    show showCarDialog;
import 'package:autobook/features/vehicles/presentation/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> _runCarMutation(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() mutation, {
  required String errorText,
}) async {
  try {
    await mutation();
  } on Failure catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorText),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () async {
            await ref.read(carListProvider.notifier).syncPendingCars();
          },
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openAddCar(BuildContext context, WidgetRef ref) async {
    final draft = await showCarDialog(context);
    if (draft == null) return;
    if (!context.mounted) return;
    await _runCarMutation(
      context,
      ref,
      () => ref.read(carListProvider.notifier).add(draft),
      errorText: 'Error al crear el vehículo',
    );
  }

  String _friendlyError(Failure failure) => switch (failure) {
    NetworkFailure() => 'No se pudo conectar con el servidor.',
    ServerFailure() =>
      'No se pudieron cargar los vehículos. Inténtalo de nuevo.',
    CacheFailure() => 'Error al acceder al almacenamiento local.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final carsAsync = ref.watch(carListProvider);

    String? bannerKind(CarListState? state) {
      if (state?.syncError != null) return 'error';
      if (state?.hasPendingSync == true) return 'pending';
      return null;
    }

    String? bannerSignature(CarListState? state) {
      if (state?.syncError != null) {
        return 'error:${state!.syncError.runtimeType}:${state.hasPendingSync}';
      }
      if (state?.hasPendingSync == true) return 'pending';
      return null;
    }

    ref.listen<AsyncValue<CarListState>>(carListProvider, (prev, next) {
      final messenger = ScaffoldMessenger.of(context);
      next.whenData((carsState) {
        final prevMessages = prev?.value?.remoteChangeMessages;
        final nextMessages = carsState.remoteChangeMessages;
        if (prevMessages != nextMessages && nextMessages.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text(nextMessages.join('\n'))),
          );
          ref.read(carListProvider.notifier).clearRemoteChangeBanner();
          return;
        }

        final prevSig = bannerSignature(prev?.value);
        final nextSig = bannerSignature(carsState);
        if (prevSig == nextSig) return;
        final nextKind = bannerKind(carsState);

        messenger.hideCurrentMaterialBanner();
        if (nextKind == 'error') {
          final pendingSuffix = carsState.hasPendingSync
              ? ' Hay vehículos pendientes de sincronización.'
              : '';
          messenger.showMaterialBanner(
            MaterialBanner(
              content: Text(
                '${_friendlyError(carsState.syncError!)}$pendingSuffix',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
              backgroundColor: colorScheme.errorContainer,
              actions: [
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentMaterialBanner();
                    ref.invalidate(carListProvider);
                  },
                  child: Text(
                    'Reintentar',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          );
        } else if (nextKind == 'pending') {
          messenger.showMaterialBanner(
            MaterialBanner(
              content: Text(
                'Vehículos pendientes de sincronización',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              actions: [
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentMaterialBanner();
                    ref.read(carListProvider.notifier).syncPendingCars();
                  },
                  child: Text(
                    'Sincronizar',
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          );
        }
      });
    });

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
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: carsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, ref, theme, error),
        data: (carsState) => carsState.cars.isEmpty
            ? _buildEmptyState(context, ref, theme)
            : _buildCarList(theme, carsState.cars),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCar(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir vehículo'),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Object error,
  ) {
    final colorScheme = theme.colorScheme;
    final message = error is Failure
        ? _friendlyError(error)
        : 'Error cargando vehículos: $error';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(carListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 60,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu garaje está vacío',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade tu primer vehículo para empezar a llevar el registro de sus mantenimientos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarList(ThemeData theme, List<Car> cars) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: cars.length,
      itemBuilder: (context, index) => _CarCard(car: cars[index]),
    );
  }
}

class _CarCard extends ConsumerWidget {
  final Car car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPendingDelete = ref.watch(
      carListProvider.select(
        (async) => async.value?.pendingDeleteIds.contains(car.id) ?? false,
      ),
    );

    return Opacity(
      opacity: isPendingDelete ? 0.45 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPendingDelete) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Pendiente de borrado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        InfoChip(label: car.year.toString()),
                        const SizedBox(width: 8),
                        InfoChip(label: car.licensePlate),
                        if (car.color != null) ...[
                          const SizedBox(width: 8),
                          InfoChip(label: car.color!),
                        ],
                      ],
                    ),
                    if (car.mileage != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          // TODO: Cambiar a km o mi según los ajustes del usuario
                          Text(
                            '${_formatMileage(context, car.mileage!)} km',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar',
                onPressed: isPendingDelete
                    ? null
                    : () => _openDeleteCar(context, ref, car),
              ),
              if (!isPendingDelete)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar vehículo',
                  onPressed: () => _openEditCar(context, ref, car),
                ),
              if (!isPendingDelete)
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMileage(BuildContext context, int mileage) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.decimalPattern(locale).format(mileage);
  }
}

Future<void> _openEditCar(BuildContext context, WidgetRef ref, Car car) async {
  final CarDraft draft = (
    brand: car.brand,
    model: car.model,
    year: car.year,
    licensePlate: car.licensePlate,
    color: car.color,
    mileage: car.mileage,
  );
  final updatedDraft = await showCarDialog(context, initial: draft);
  if (updatedDraft == null) return;
  if (!context.mounted) return;
  await _runCarMutation(
    context,
    ref,
    () => ref.read(carListProvider.notifier).updateCar(updatedDraft, car),
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
  await _runCarMutation(
    context,
    ref,
    () => ref.read(carListProvider.notifier).deleteCar(car),
    errorText: 'Error al eliminar el vehículo',
  );
}

Future<bool?> showDeleteConfirmDialog(BuildContext context, Car car) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    pageBuilder: (_, __, ___) => _DeleteConfirmDialog(car: car),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * animation.value,
          sigmaY: 6 * animation.value,
        ),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

class _DeleteConfirmDialog extends ConsumerWidget {
  const _DeleteConfirmDialog({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surface,
          elevation: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Eliminar vehículo',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¿Seguro que quieres eliminar ${car.brand} ${car.model}?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
