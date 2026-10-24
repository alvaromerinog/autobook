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
}
