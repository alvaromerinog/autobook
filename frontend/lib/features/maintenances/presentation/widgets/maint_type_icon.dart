import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:flutter/material.dart';

class MaintTypeIcon extends StatelessWidget {
  const MaintTypeIcon({
    super.key,
    required this.type,
    this.size = 40,
    this.iconSize,
  });

  final MaintenanceType type;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final tint = getTint(type, Theme.of(context).brightness);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tint.bg, shape: BoxShape.circle),
      child: Icon(
        maintTypeIcon(type),
        size: iconSize ?? size * 0.55,
        color: tint.fg,
      ),
    );
  }
}
