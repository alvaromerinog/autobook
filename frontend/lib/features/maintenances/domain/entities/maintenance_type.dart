enum MaintenanceType {
  oil,
  coolant,
  belt,
  itv,
  repair,
  filter,
  battery,
  brakes,
  tires;

  static MaintenanceType fromString(String value) {
    return MaintenanceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown maintenance type: $value'),
    );
  }
}
