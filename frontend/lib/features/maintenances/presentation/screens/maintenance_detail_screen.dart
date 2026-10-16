import 'package:autobook/app/router/back_navigation.dart';
import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:autobook/features/maintenances/presentation/widgets/big_stat.dart';
import 'package:autobook/features/maintenances/presentation/widgets/maintenance_dialog.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      goBack(context);
    } on Failure catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el mantenimiento')),
      );
    }
  }

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    Maintenance m,
  ) async {
    final draft = await showMaintenanceDialog(context, existing: m);
    if (draft == null || !context.mounted) return;
    try {
      await ref
          .read(maintenanceListProvider(carId).notifier)
          .updateMaint(draft, m);
    } on Failure catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el mantenimiento')),
      );
    }
  }

  Maintenance? _findMaintenance(List<Maintenance> maintenances) {
    for (final m in maintenances) {
      if (m.id == maintenanceId) return m;
    }
    return null;
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
          leading: BackButton(onPressed: () => goBack(context)),
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
        leading: BackButton(onPressed: () => goBack(context)),
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
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  // Reserves the buttons' 24px overhang so their centres
                  // stay inside the Stack's hit-test bounds (a Positioned
                  // child past the edge is not tappable).
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      key: const Key('maintenance-stats-card'),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 24),
                        child: Row(
                          children: [
                            BigStat(
                              label: 'Coste',
                              value: costFmt.format(m.cost),
                            ),
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
                            BigStat(
                              label: 'Fecha',
                              value: dateFmt,
                              sub: yearFmt,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 36, // outer padding 20 + 16px card inset
                  bottom: 0, // 24px reserve → centre on the card edge
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DetailActionButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Editar',
                        discColor: cs.primary,
                        iconColor: cs.onPrimary,
                        onPressed: () => _openEdit(context, ref, m),
                      ),
                      const SizedBox(width: 8),
                      _DetailActionButton(
                        icon: Icons.delete_outlined,
                        tooltip: 'Eliminar',
                        discColor: cs.surface,
                        iconColor: cs.error,
                        onPressed: () => _delete(context, ref, m),
                      ),
                    ],
                  ),
                ),
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
