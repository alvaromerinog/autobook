import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/widgets/info_chip.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GarageListContent extends ConsumerWidget {
  const GarageListContent({super.key, this.selectedCarId});

  final String? selectedCarId;

  String _friendlyError(AppLocalizations l10n, Failure failure) =>
      switch (failure) {
        NetworkFailure() => l10n.vehicleNetworkFailure,
        ServerFailure() => l10n.vehicleServerFailure,
        CacheFailure() => l10n.vehicleCacheFailure,
      };

  String _remoteEventMessage(AppLocalizations l10n, RemoteSyncEvent event) =>
      switch (event) {
        RemoteDeleted(car: final car) => l10n.vehicleRemoteDeleted(
          car.brand,
          car.model,
        ),
        RemoteDeletedWithPendingUpdate(car: final car) =>
          l10n.vehicleRemoteDeletedDiscarded(car.brand, car.model),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
              content: Text(
                nextMessages
                    .map((event) => _remoteEventMessage(l10n, event))
                    .join('\n'),
              ),
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
          final failure = carsState.syncError!;
          final errorText = _friendlyError(l10n, failure);
          final message = carsState.hasPendingSync
              ? l10n.vehicleSyncErrorWithPending(errorText)
              : errorText;
          messenger.showMaterialBanner(
            MaterialBanner(
              content: Text(
                message,
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
                    l10n.retry,
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
                l10n.vehiclesPendingSync,
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
                    l10n.syncAction,
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
    final l10n = AppLocalizations.of(context)!;
    final message = error is Failure
        ? _friendlyError(l10n, error)
        : l10n.vehicleLoadErrorDetails(error.toString());
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
              label: Text(l10n.retry),
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.garageEmptyTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.garageEmptyHint,
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
    final l10n = AppLocalizations.of(context)!;
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
                          l10n.vehiclePendingDelete,
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
