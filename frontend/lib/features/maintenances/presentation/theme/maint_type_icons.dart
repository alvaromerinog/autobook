import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:flutter/material.dart';

IconData maintTypeIcon(MaintenanceType type) {
  switch (type) {
    case MaintenanceType.oil:
      return Icons.oil_barrel_outlined;
    case MaintenanceType.coolant:
      return Icons.water_drop_outlined;
    case MaintenanceType.belt:
      return Icons.settings_outlined;
    case MaintenanceType.itv:
      return Icons.verified_outlined;
    case MaintenanceType.repair:
      return Icons.build_outlined;
    case MaintenanceType.filter:
      return Icons.filter_alt_outlined;
    case MaintenanceType.battery:
      return Icons.battery_charging_full_outlined;
    case MaintenanceType.brakes:
      return Icons.disc_full_outlined;
    case MaintenanceType.tires:
      return Icons.tire_repair_outlined;
  }
}

String maintTypeLabel(MaintenanceType type) {
  switch (type) {
    case MaintenanceType.oil:
      return 'Cambio de aceite';
    case MaintenanceType.coolant:
      return 'Refrigerante';
    case MaintenanceType.belt:
      return 'Correa de distribución';
    case MaintenanceType.itv:
      return 'ITV';
    case MaintenanceType.repair:
      return 'Reparación general';
    case MaintenanceType.filter:
      return 'Filtro de aire';
    case MaintenanceType.battery:
      return 'Batería';
    case MaintenanceType.brakes:
      return 'Frenos';
    case MaintenanceType.tires:
      return 'Neumáticos';
  }
}

String maintTypeShort(MaintenanceType type) {
  switch (type) {
    case MaintenanceType.oil:
      return 'Aceite';
    case MaintenanceType.coolant:
      return 'Refrigerante';
    case MaintenanceType.belt:
      return 'Distribución';
    case MaintenanceType.itv:
      return 'ITV';
    case MaintenanceType.repair:
      return 'Reparación';
    case MaintenanceType.filter:
      return 'Filtro';
    case MaintenanceType.battery:
      return 'Batería';
    case MaintenanceType.brakes:
      return 'Frenos';
    case MaintenanceType.tires:
      return 'Ruedas';
  }
}
