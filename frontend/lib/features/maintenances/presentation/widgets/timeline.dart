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

  Map<String, List<Maintenance>> get _grouped {
    final groups = <String, List<Maintenance>>{};
    for (final m in maintenances) {
      final year = m.date.split('-').first;
      (groups[year] ??= []).add(m);
    }
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    return {for (final k in sortedKeys) k: groups[k]!};
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
                  years[gi],
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

class TimelineEntry extends StatefulWidget {
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
  State<TimelineEntry> createState() => _TimelineEntryState();
}

class _TimelineEntryState extends State<TimelineEntry> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tint = getTint(widget.maintenance.type, theme.brightness);
    final locale = Localizations.localeOf(context).toString();
    final kmFmt = NumberFormat.decimalPattern(locale);
    final costFmt = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    );
    final date = DateTime.parse(widget.maintenance.date);
    final dateLabel = DateFormat(
      'dd MMM',
      locale,
    ).format(date).replaceAll('.', '');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onOpen,
      onTapDown: (_) => setState(() => _hover = true),
      onTapCancel: () => setState(() => _hover = false),
      onTapUp: (_) => setState(() => _hover = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!widget.isFirst)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: cs.outlineVariant),
                  ),
                if (!widget.isLast)
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
                      maintTypeIcon(widget.maintenance.type),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hover
                    ? cs.surfaceContainerHigh
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Expanded(
                        child: Text(
                          maintTypeLabel(widget.maintenance.type),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        dateLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${kmFmt.format(widget.maintenance.mileage)} km',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('·', style: TextStyle(color: cs.outline)),
                      const SizedBox(width: 12),
                      Text(
                        costFmt.format(widget.maintenance.cost),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (widget.maintenance.garage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.maintenance.garage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
