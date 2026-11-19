import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

String maintTypeLabel(BuildContext context, MaintenanceType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case MaintenanceType.oil:
      return l10n.maintTypeOil;
    case MaintenanceType.coolant:
      return l10n.maintTypeCoolant;
    case MaintenanceType.belt:
      return l10n.maintTypeBelt;
    case MaintenanceType.itv:
      return l10n.maintTypeItv;
    case MaintenanceType.repair:
      return l10n.maintTypeRepair;
    case MaintenanceType.filter:
      return l10n.maintTypeFilter;
    case MaintenanceType.battery:
      return l10n.maintTypeBattery;
    case MaintenanceType.brakes:
      return l10n.maintTypeBrakes;
    case MaintenanceType.tires:
      return l10n.maintTypeTires;
  }
}

String maintTypeShort(BuildContext context, MaintenanceType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case MaintenanceType.oil:
      return l10n.maintTypeOilShort;
    case MaintenanceType.coolant:
      return l10n.maintTypeCoolantShort;
    case MaintenanceType.belt:
      return l10n.maintTypeBeltShort;
    case MaintenanceType.itv:
      return l10n.maintTypeItvShort;
    case MaintenanceType.repair:
      return l10n.maintTypeRepairShort;
    case MaintenanceType.filter:
      return l10n.maintTypeFilterShort;
    case MaintenanceType.battery:
      return l10n.maintTypeBatteryShort;
    case MaintenanceType.brakes:
      return l10n.maintTypeBrakesShort;
    case MaintenanceType.tires:
      return l10n.maintTypeTiresShort;
  }
}
