import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Timeline extends StatelessWidget {
  const Timeline({
    super.key,
    required this.maintenances,
    required this.carId,
    required this.onOpen,
  });

  final List<Maintenance> maintenances;
  final String carId;
  final void Function(String maintenanceId) onOpen;

  Map<int, List<Maintenance>> get _grouped {
    final groups = <int, List<Maintenance>>{};
    for (final m in maintenances) {
      final year = DateTime.tryParse(m.date)?.year ?? 0;
      (groups[year] ??= []).add(m);
    }
    for (final year in groups.keys) {
      groups[year]!.sort((a, b) {
        final da = DateTime.tryParse(a.date) ?? DateTime(1970);
        final db = DateTime.tryParse(b.date) ?? DateTime(1970);
        return db.compareTo(da);
      });
    }
    final sortedYears = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final y in sortedYears) y: groups[y]!};
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped;
    final years = groups.keys.toList();
    final allFlat = [for (final y in years) ...groups[y]!];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          for (int gi = 0; gi < years.length; gi++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 0, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  years[gi] == 0 ? 'Sin fecha' : years[gi].toString(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            for (int i = 0; i < groups[years[gi]]!.length; i++)
              TimelineEntry(
                maintenance: groups[years[gi]]![i],
                isFirst: identical(groups[years[gi]]![i], allFlat.first),
                isLast: identical(groups[years[gi]]![i], allFlat.last),
                onOpen: () => onOpen(groups[years[gi]]![i].id),
              ),
          ],
        ],
      ),
    );
  }
}

class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.maintenance,
    required this.isFirst,
    required this.isLast,
    required this.onOpen,
  });

  final Maintenance maintenance;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tint = getTint(maintenance.type, theme.brightness);
    final locale = Localizations.localeOf(context).toString();
    final kmFmt = NumberFormat.decimalPattern(locale);
    final costFmt = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    );
    final date = DateTime.tryParse(maintenance.date) ?? DateTime(1970);
    final dateLabel = DateFormat(
      'dd MMM',
      locale,
    ).format(date).replaceAll('.', '');

    return Semantics(
      button: true,
      label: '${maintTypeLabel(maintenance.type)} $dateLabel',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isFirst)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: cs.outlineVariant),
                    ),
                  if (!isLast)
                    Positioned(
                      top: 26,
                      bottom: 0,
                      child: Container(width: 2, color: cs.outlineVariant),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tint.bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 3),
                      ),
                      child: Icon(
                        maintTypeIcon(maintenance.type),
                        size: 16,
                        color: tint.fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Ink(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: onOpen,
                    borderRadius: BorderRadius.circular(12),
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        maintTypeLabel(maintenance.type),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(color: cs.onSurface),
                                      ),
                                    ),
                                    Text(
                                      dateLabel,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${kmFmt.format(maintenance.mileage)} km',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '·',
                                      style: TextStyle(color: cs.outline),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      costFmt.format(maintenance.cost),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                if (maintenance.garage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    maintenance.garage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
