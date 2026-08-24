import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:flutter/material.dart';

typedef MaintTint = ({Color bg, Color fg});

const _light = <MaintenanceType, MaintTint>{
  MaintenanceType.oil: (bg: Color(0xFFFFEAC2), fg: Color(0xFF5A3D00)),
  MaintenanceType.coolant: (bg: Color(0xFFC2EDF5), fg: Color(0xFF003E48)),
  MaintenanceType.belt: (bg: Color(0xFFE4D5FA), fg: Color(0xFF3D2A57)),
  MaintenanceType.itv: (bg: Color(0xFFC8E6C9), fg: Color(0xFF1F4222)),
  MaintenanceType.repair: (bg: Color(0xFFFFDAD6), fg: Color(0xFF5A1A1A)),
  MaintenanceType.filter: (bg: Color(0xFFC2E9E2), fg: Color(0xFF1F4B45)),
  MaintenanceType.battery: (bg: Color(0xFFFFD8C2), fg: Color(0xFF5C2A00)),
  MaintenanceType.brakes: (bg: Color(0xFFFAD3DA), fg: Color(0xFF5C1A2A)),
  MaintenanceType.tires: (bg: Color(0xFFD1E4FF), fg: Color(0xFF003258)),
};

const _dark = <MaintenanceType, MaintTint>{
  MaintenanceType.oil: (bg: Color(0xFF5A3D00), fg: Color(0xFFFFDDB3)),
  MaintenanceType.coolant: (bg: Color(0xFF003E48), fg: Color(0xFFBFEAF5)),
  MaintenanceType.belt: (bg: Color(0xFF3D2A57), fg: Color(0xFFE4D5FA)),
  MaintenanceType.itv: (bg: Color(0xFF1F4222), fg: Color(0xFFC8E6C9)),
  MaintenanceType.repair: (bg: Color(0xFF5A1A1A), fg: Color(0xFFFFDAD6)),
  MaintenanceType.filter: (bg: Color(0xFF1F4B45), fg: Color(0xFFC2E9E2)),
  MaintenanceType.battery: (bg: Color(0xFF5C2A00), fg: Color(0xFFFFD8C2)),
  MaintenanceType.brakes: (bg: Color(0xFF5C1A2A), fg: Color(0xFFFAD3DA)),
  MaintenanceType.tires: (bg: Color(0xFF003258), fg: Color(0xFFD1E4FF)),
};

MaintTint getTint(MaintenanceType type, Brightness brightness) {
  return brightness == Brightness.dark ? _dark[type]! : _light[type]!;
}
