// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get garage => 'Garage';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get addCar => 'Add car';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get selectVehicle => 'Select a vehicle';

  @override
  String get garageEmptyTitle => 'Your garage is empty';

  @override
  String get garageEmptyHint =>
      'Add your first vehicle to start tracking its maintenance.';

  @override
  String get vehicleNetworkFailure => 'Could not connect to the server.';

  @override
  String get vehicleServerFailure =>
      'The vehicles could not be loaded. Please try again.';

  @override
  String get vehicleCacheFailure => 'Could not access local storage.';

  @override
  String vehicleLoadErrorDetails(String error) {
    return 'Error loading vehicles: $error';
  }

  @override
  String get vehiclesPendingSync => 'Vehicles pending synchronization';

  @override
  String get syncAction => 'Sync';

  @override
  String vehicleSyncErrorWithPending(String error) {
    return '$error Some vehicles are pending synchronization.';
  }

  @override
  String vehicleRemoteDeleted(String brand, String model) {
    return 'Car $brand $model deleted';
  }

  @override
  String vehicleRemoteDeletedDiscarded(String brand, String model) {
    return 'Car $brand $model deleted, edits discarded';
  }

  @override
  String get vehiclePendingDelete => 'Pending deletion';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get vehicleDetailsSection => 'Vehicle details';

  @override
  String get vehicleAdditionalInfoSection =>
      'Additional information (optional)';

  @override
  String get vehicleBrandLabel => 'Brand';

  @override
  String get vehicleBrandHint => 'E.g. Toyota, Ford, BMW...';

  @override
  String get vehicleModelLabel => 'Model';

  @override
  String get vehicleModelHint => 'E.g. Corolla, Focus, 3 Series...';

  @override
  String get vehicleYearLabel => 'Year';

  @override
  String get vehicleYearHint => 'E.g. 2020';

  @override
  String get vehicleLicensePlateLabel => 'License plate';

  @override
  String get vehicleLicensePlateHint => 'E.g. 1234 ABC';

  @override
  String get vehicleColorLabel => 'Color';

  @override
  String get vehicleColorHint => 'E.g. White...';

  @override
  String get vehicleMileageLabel => 'Mileage';

  @override
  String get vehicleMileageHint => 'E.g. 45000';

  @override
  String get saveVehicle => 'Save vehicle';

  @override
  String get vehicleBrandRequired => 'Brand is required';

  @override
  String get vehicleModelRequired => 'Model is required';

  @override
  String get fieldRequired => 'Required';

  @override
  String get vehicleLicensePlateRequired => 'License plate is required';

  @override
  String get vehicleYearInvalid => 'Invalid year';

  @override
  String get vehicleYearOutOfRange => 'Out of range';

  @override
  String get vehicleMileageInvalid => 'Invalid mileage';

  @override
  String get deleteVehicleTitle => 'Delete vehicle';

  @override
  String deleteVehicleConfirmation(String vehicleName) {
    return 'Are you sure you want to delete $vehicleName?';
  }

  @override
  String get vehicleCreateError => 'Could not create the vehicle';

  @override
  String get vehicleUpdateError => 'Could not update the vehicle';

  @override
  String get vehicleDeleteError => 'Could not delete the vehicle';

  @override
  String get addMaintenance => 'Add maintenance';

  @override
  String get maintenanceNewTitle => 'New maintenance';

  @override
  String get maintenanceEditTitle => 'Edit maintenance';

  @override
  String get maintenanceDetailsSection => 'Maintenance details';

  @override
  String get maintenanceTypeFieldLabel => 'Maintenance type';

  @override
  String get maintenanceTypeRequired => 'Select a type';

  @override
  String get maintenanceMileageLabel => 'Mileage';

  @override
  String get maintenanceMileageHint => 'E.g. 45000';

  @override
  String get maintenanceMileageRequired => 'Mileage is required';

  @override
  String get maintenanceMileageInvalid => 'Invalid mileage';

  @override
  String get maintenanceCostLabel => 'Cost';

  @override
  String get maintenanceCostHint => 'E.g. 145.20';

  @override
  String get maintenanceCostRequired => 'Cost is required';

  @override
  String get maintenanceCostInvalid => 'Invalid cost';

  @override
  String get maintenanceNegativeNotAllowed => 'Cannot be negative';

  @override
  String get maintenanceDateLabel => 'Date';

  @override
  String get maintenanceAdditionalInfoSection =>
      'Additional information (optional)';

  @override
  String get maintenanceGarageLabel => 'Workshop';

  @override
  String get maintenanceGarageHint => 'E.g. Marín Workshop · Madrid';

  @override
  String get maintenanceNotesLabel => 'Notes';

  @override
  String get maintenanceNotesHint => 'Service details...';

  @override
  String get save => 'Save';

  @override
  String get maintenanceHistoryTitle => 'Maintenance history';

  @override
  String get maintenanceHistoryEmpty => 'No maintenance records yet';

  @override
  String maintenanceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get maintenanceCreated => 'Maintenance recorded';

  @override
  String get maintenanceCreateError => 'Could not create the maintenance';

  @override
  String maintenanceErrorDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get maintenanceStatsKmLabel => 'KM';

  @override
  String get maintenanceStatsSpentLabel => 'SPENT';

  @override
  String get maintenanceStatsEntriesLabel => 'ENTRIES';

  @override
  String get vehicleNotFound => 'Vehicle not found';

  @override
  String get maintenanceNotFound => 'Record not found';

  @override
  String get deleteMaintenanceTitle => 'Delete maintenance';

  @override
  String get deleteMaintenanceConfirmation =>
      'Are you sure you want to delete this record?';

  @override
  String get maintenanceDeleted => 'Maintenance deleted';

  @override
  String get maintenanceDeleteError => 'Could not delete the maintenance';

  @override
  String get maintenanceUpdateError => 'Could not update the maintenance';

  @override
  String get maintenanceNotesSection => 'NOTES';

  @override
  String get timelineNoDate => 'No date';

  @override
  String timelineEntrySemantics(String type, String date) {
    return '$type on $date';
  }

  @override
  String maintenanceRemoteDeleted(String id) {
    return 'Maintenance $id deleted';
  }

  @override
  String maintenanceRemoteDeletedDiscarded(String id) {
    return 'Maintenance $id deleted, edits discarded';
  }

  @override
  String get maintTypeOil => 'Oil change';

  @override
  String get maintTypeOilShort => 'Oil';

  @override
  String get maintTypeCoolant => 'Coolant';

  @override
  String get maintTypeCoolantShort => 'Coolant';

  @override
  String get maintTypeBelt => 'Timing belt';

  @override
  String get maintTypeBeltShort => 'Belt';

  @override
  String get maintTypeItv => 'Vehicle inspection';

  @override
  String get maintTypeItvShort => 'ITV';

  @override
  String get maintTypeRepair => 'General repair';

  @override
  String get maintTypeRepairShort => 'Repair';

  @override
  String get maintTypeFilter => 'Air filter';

  @override
  String get maintTypeFilterShort => 'Filter';

  @override
  String get maintTypeBattery => 'Battery';

  @override
  String get maintTypeBatteryShort => 'Battery';

  @override
  String get maintTypeBrakes => 'Brakes';

  @override
  String get maintTypeBrakesShort => 'Brakes';

  @override
  String get maintTypeTires => 'Tires';

  @override
  String get maintTypeTiresShort => 'Tires';
}
