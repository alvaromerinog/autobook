import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GarageListContent extends ConsumerWidget {
  const GarageListContent({super.key, this.selectedCarId});

  /// Id of the car whose detail pane is open, or `null` when none is.
  ///
  /// Drives the selection highlight in the list column; it comes from the route
  /// so the URL stays the single source of truth.
  final String? selectedCarId;

  String _friendlyError(Failure failure) => switch (failure) {
    NetworkFailure() => 'No se pudo conectar con el servidor.',
    ServerFailure() =>
      'No se pudieron cargar los vehículos. Inténtalo de nuevo.',
    CacheFailure() => 'Error al acceder al almacenamiento local.',
  };

  String _remoteEventMessage(RemoteSyncEvent event) => switch (event) {
    RemoteDeleted(car: final car) =>
      'Coche ${car.brand} ${car.model} eliminado',
    RemoteDeletedWithPendingUpdate(car: final car) =>
      'Coche ${car.brand} ${car.model} eliminado, edición descartada',
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
        final prevMessages = prev?.value?.remoteSyncEvents;
        final nextMessages = carsState.remoteSyncEvents;
        if (prevMessages != nextMessages && nextMessages.isNotEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(nextMessages.map(_remoteEventMessage).join('\n')),
            ),
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

    return carsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, ref, theme, error),
      data: (carsState) => carsState.cars.isEmpty
          ? _buildEmptyState(context, ref, theme)
          : _buildCarList(theme, carsState.cars),
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
      key: const PageStorageKey('garage-list'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: cars.length,
      itemBuilder: (context, index) =>
          _CarCard(car: cars[index], selected: cars[index].id == selectedCarId),
    );
  }
}

class _CarCard extends ConsumerWidget {
  final Car car;
  final bool selected;

  const _CarCard({required this.car, required this.selected});

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
        color: selected ? colorScheme.secondaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected
                ? colorScheme.secondary
                : colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (windowSizeClassOf(context) == WindowSizeClass.expanded) {
              context.go('/cars/${car.id}');
            } else {
              context.push('/cars/${car.id}');
            }
          },
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          InfoChip(label: car.year.toString()),
                          InfoChip(label: car.licensePlate),
                          if (car.color != null) InfoChip(label: car.color!),
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
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
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
