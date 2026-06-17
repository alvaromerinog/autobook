import 'package:autobook/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/car.dart';
import '../providers/cars_provider.dart';
import 'add_car_screen.dart' show showAddCarDialog;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openAddCar(BuildContext context, WidgetRef ref) async {
    final car = await showAddCarDialog(context);
    if (car != null) {
      try {
        await ref.read(carsProvider.notifier).add(car);
      } catch (error) {
        if (context.mounted) {
          _showSyncErrorSnackBar(context, error);
        }
      }
    }
  }

  void _showSyncErrorSnackBar(BuildContext context, Object error) {
    final message = error.toString();
    final isOffline =
        message.contains('No internet') || message.contains('SocketException');
    final text = isOffline
        ? 'Sin conexión. El coche se guardó localmente y se sincronizará cuando haya internet.'
        : 'Error del servidor. El coche se guardó localmente e intentaremos sincronizarlo más tarde.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final carsAsync = ref.watch(carsProvider);

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
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error cargando vehículos: $error'),
          ),
        ),
        data: (cars) => cars.isEmpty
            ? _buildEmptyState(context, ref, theme)
            : _buildCarList(theme, cars),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddCar(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir vehículo'),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, ThemeData theme) {
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
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _openAddCar(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Añadir vehículo'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

class _CarCard extends StatelessWidget {
  final Car car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
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
                          Icon(Icons.speed,
                              size: 14, color: colorScheme.onSurfaceVariant),
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
    );
  }

  String _formatMileage(BuildContext context, int mileage) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.decimalPattern(locale).format(mileage);
  }
}
