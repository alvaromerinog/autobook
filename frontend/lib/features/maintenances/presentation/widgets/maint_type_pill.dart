import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:flutter/material.dart';

class MaintTypePill extends StatelessWidget {
  const MaintTypePill({super.key, required this.type});

  final MaintenanceType type;

  @override
  Widget build(BuildContext context) {
    final tint = getTint(type, Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 10),
      height: 26,
      decoration: BoxDecoration(
        color: tint.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(maintTypeIcon(type), size: 14, color: tint.fg),
          const SizedBox(width: 4),
          Text(
            maintTypeShort(type),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tint.fg),
          ),
        ],
      ),
    );
  }
}
