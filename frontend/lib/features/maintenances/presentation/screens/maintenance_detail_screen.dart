import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:autobook/features/maintenances/presentation/widgets/big_stat.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  const MaintenanceDetailScreen({
    super.key,
    required this.carId,
    required this.maintenanceId,
  });

  final String carId;
  final String maintenanceId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Maintenance m,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar mantenimiento'),
        content: const Text('¿Seguro que quieres eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(maintenanceListProvider(carId).notifier).deleteMaint(m);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mantenimiento eliminado')));
      context.pop();
    } on Failure catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el mantenimiento')),
      );
    }
  }

  Maintenance? _findMaintenance(List<Maintenance> maintenances) {
    for (final m in maintenances) {
      if (m.id == maintenanceId) return m;
    }
    return null;
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Maintenance m) async {
    final draft = await context.push<MaintenanceDraft>(
      '/cars/$carId/maintenances/${m.id}/edit',
      extra: m,
    );
    if (draft == null || !context.mounted) return;
    try {
      await ref
          .read(maintenanceListProvider(carId).notifier)
          .updateMaint(draft, m);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
    } on Failure catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maintState = ref.watch(maintenanceListProvider(carId)).value;
    final maintenances = maintState?.maintenances ?? const <Maintenance>[];
    final m = _findMaintenance(maintenances);

    if (m == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Registro no encontrado')),
      );
    }

    final carsState = ref.watch(carListProvider).value;
    final car = carsState?.cars.firstWhere(
      (c) => c.id == carId,
      orElse: () =>
          const Car(id: '', brand: '', model: '', year: 0, licensePlate: ''),
    );
    final tint = getTint(m.type, theme.brightness);
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime.tryParse(m.date) ?? DateTime.now();
    final costFmt = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    );
    final kmFmt = NumberFormat.decimalPattern(locale);
    final dateFmt = DateFormat(
      'dd MMM',
      locale,
    ).format(date).replaceAll('.', '');
    final yearFmt = DateFormat('yyyy', locale).format(date);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _edit(context, ref, m),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'delete') _delete(context, ref, m);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            color: tint.bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(maintTypeIcon(m.type), size: 36, color: tint.fg),
                ),
                const SizedBox(height: 16),
                Text(
                  car == null ? '—' : '${car.brand} ${car.model}',
                  style: theme.textTheme.labelLarge?.copyWith(color: tint.fg),
                ),
                Text(
                  maintTypeLabel(m.type),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: tint.fg,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                BigStat(label: 'Coste', value: costFmt.format(m.cost)),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: cs.outlineVariant,
                ),
                BigStat(
                  label: 'Kilómetros',
                  value: '${kmFmt.format(m.mileage)} km',
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: cs.outlineVariant,
                ),
                BigStat(label: 'Fecha', value: dateFmt, sub: yearFmt),
              ],
            ),
          ),
          const Divider(height: 1),
          if (m.garage != null) ...[
            ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: cs.onSurfaceVariant,
              ),
              title: Text(m.garage!),
            ),
            const Divider(height: 1, indent: 56),
          ],
          if (m.notes != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'NOTAS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                m.notes!,
                style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
