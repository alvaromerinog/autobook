import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Dismisses a dialog or form without saving changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Removes the selected record permanently.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Opens the editor for the selected record.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Retries the failed network or sync operation.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Closes the current screen or overlay.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Persists the edits made in a form.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Navigation label for the list of the user's cars.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// Title of the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for the language selector in settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Action that opens the form to create a car.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addCar;

  /// Title of the form that creates a vehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// Placeholder prompting the user to pick a car first.
  ///
  /// In en, this message translates to:
  /// **'Select a vehicle'**
  String get selectVehicle;

  /// Heading shown when the user has no vehicles yet.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty'**
  String get garageEmptyTitle;

  /// Explanation shown under the empty garage heading.
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to start tracking its maintenance.'**
  String get garageEmptyHint;

  /// Shown when a vehicle sync fails because the network is unreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get vehicleNetworkFailure;

  /// Shown when the backend rejects the vehicle request.
  ///
  /// In en, this message translates to:
  /// **'The vehicles could not be loaded. Please try again.'**
  String get vehicleServerFailure;

  /// Shown when the local vehicle database cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Could not access local storage.'**
  String get vehicleCacheFailure;

  /// Prefix for an unexpected vehicle load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading vehicles: {error}'**
  String vehicleLoadErrorDetails(String error);

  /// Banner telling the user that vehicles wait to be synced.
  ///
  /// In en, this message translates to:
  /// **'Vehicles pending synchronization'**
  String get vehiclesPendingSync;

  /// Starts synchronizing the pending records.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncAction;

  /// Sync failure banner combined with the pending vehicles notice.
  ///
  /// In en, this message translates to:
  /// **'{error} Some vehicles are pending synchronization.'**
  String vehicleSyncErrorWithPending(String error);

  /// Snackbar reporting a vehicle removed by another device.
  ///
  /// In en, this message translates to:
  /// **'Car {brand} {model} deleted'**
  String vehicleRemoteDeleted(String brand, String model);

  /// Snackbar reporting a remotely deleted vehicle with unsynced edits.
  ///
  /// In en, this message translates to:
  /// **'Car {brand} {model} deleted, edits discarded'**
  String vehicleRemoteDeletedDiscarded(String brand, String model);

  /// Label on a vehicle whose deletion still waits to sync.
  ///
  /// In en, this message translates to:
  /// **'Pending deletion'**
  String get vehiclePendingDelete;

  /// Title of the form that edits an existing vehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get editVehicle;

  /// Section heading for the identifying vehicle fields.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get vehicleDetailsSection;

  /// Section heading for the optional vehicle fields.
  ///
  /// In en, this message translates to:
  /// **'Additional information (optional)'**
  String get vehicleAdditionalInfoSection;

  /// Label for the vehicle brand field.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get vehicleBrandLabel;

  /// Hint for the vehicle brand field.
  ///
  /// In en, this message translates to:
  /// **'E.g. Toyota, Ford, BMW...'**
  String get vehicleBrandHint;

  /// Label for the vehicle model field.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get vehicleModelLabel;

  /// Hint for the vehicle model field.
  ///
  /// In en, this message translates to:
  /// **'E.g. Corolla, Focus, 3 Series...'**
  String get vehicleModelHint;

  /// Label for the vehicle year field.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehicleYearLabel;

  /// Hint for the vehicle year field.
  ///
  /// In en, this message translates to:
  /// **'E.g. 2020'**
  String get vehicleYearHint;

  /// Label for the vehicle license plate field.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get vehicleLicensePlateLabel;

  /// Hint for the vehicle license plate field.
  ///
  /// In en, this message translates to:
  /// **'E.g. 1234 ABC'**
  String get vehicleLicensePlateHint;

  /// Label for the optional vehicle color field.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get vehicleColorLabel;

  /// Hint for the optional vehicle color field.
  ///
  /// In en, this message translates to:
  /// **'E.g. White...'**
  String get vehicleColorHint;

  /// Label for the optional vehicle mileage field.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get vehicleMileageLabel;

  /// Hint for the optional vehicle mileage field.
  ///
  /// In en, this message translates to:
  /// **'E.g. 45000'**
  String get vehicleMileageHint;

  /// Submits the vehicle creation form.
  ///
  /// In en, this message translates to:
  /// **'Save vehicle'**
  String get saveVehicle;

  /// Validation message when the brand field is empty.
  ///
  /// In en, this message translates to:
  /// **'Brand is required'**
  String get vehicleBrandRequired;

  /// Validation message when the model field is empty.
  ///
  /// In en, this message translates to:
  /// **'Model is required'**
  String get vehicleModelRequired;

  /// Generic validation message for an empty mandatory field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Validation message when the license plate is empty.
  ///
  /// In en, this message translates to:
  /// **'License plate is required'**
  String get vehicleLicensePlateRequired;

  /// Validation message when the year is not a number.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get vehicleYearInvalid;

  /// Validation message when the year is not a plausible car year.
  ///
  /// In en, this message translates to:
  /// **'Out of range'**
  String get vehicleYearOutOfRange;

  /// Validation message when the mileage is not a number.
  ///
  /// In en, this message translates to:
  /// **'Invalid mileage'**
  String get vehicleMileageInvalid;

  /// Title of the vehicle deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle'**
  String get deleteVehicleTitle;

  /// Body of the vehicle deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {vehicleName}?'**
  String deleteVehicleConfirmation(String vehicleName);

  /// Snackbar shown when creating a vehicle fails.
  ///
  /// In en, this message translates to:
  /// **'Could not create the vehicle'**
  String get vehicleCreateError;

  /// Snackbar shown when updating a vehicle fails.
  ///
  /// In en, this message translates to:
  /// **'Could not update the vehicle'**
  String get vehicleUpdateError;

  /// Snackbar shown when deleting a vehicle fails.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the vehicle'**
  String get vehicleDeleteError;

  /// Action that opens the form to create a maintenance.
  ///
  /// In en, this message translates to:
  /// **'Add maintenance'**
  String get addMaintenance;

  /// Title of the form that creates a maintenance record.
  ///
  /// In en, this message translates to:
  /// **'New maintenance'**
  String get maintenanceNewTitle;

  /// Title of the form that edits a maintenance record.
  ///
  /// In en, this message translates to:
  /// **'Edit maintenance'**
  String get maintenanceEditTitle;

  /// Section heading for the identifying maintenance fields.
  ///
  /// In en, this message translates to:
  /// **'Maintenance details'**
  String get maintenanceDetailsSection;

  /// Label for the maintenance type dropdown.
  ///
  /// In en, this message translates to:
  /// **'Maintenance type'**
  String get maintenanceTypeFieldLabel;

  /// Validation message when no maintenance type is selected.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get maintenanceTypeRequired;

  /// Label for the maintenance mileage field.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get maintenanceMileageLabel;

  /// Hint for the maintenance mileage field.
  ///
  /// In en, this message translates to:
  /// **'E.g. 45000'**
  String get maintenanceMileageHint;

  /// Validation message when the mileage field is empty.
  ///
  /// In en, this message translates to:
  /// **'Mileage is required'**
  String get maintenanceMileageRequired;

  /// Validation message when the mileage is not a number.
  ///
  /// In en, this message translates to:
  /// **'Invalid mileage'**
  String get maintenanceMileageInvalid;

  /// Label for the maintenance cost field.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get maintenanceCostLabel;

  /// Hint for the maintenance cost field.
  ///
  /// In en, this message translates to:
  /// **'E.g. 145.20'**
  String get maintenanceCostHint;

  /// Validation message when the cost field is empty.
  ///
  /// In en, this message translates to:
  /// **'Cost is required'**
  String get maintenanceCostRequired;

  /// Validation message when the cost is not a number.
  ///
  /// In en, this message translates to:
  /// **'Invalid cost'**
  String get maintenanceCostInvalid;

  /// Validation message when a numeric field is negative.
  ///
  /// In en, this message translates to:
  /// **'Cannot be negative'**
  String get maintenanceNegativeNotAllowed;

  /// Label for the maintenance date field.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get maintenanceDateLabel;

  /// Section heading for the optional maintenance fields.
  ///
  /// In en, this message translates to:
  /// **'Additional information (optional)'**
  String get maintenanceAdditionalInfoSection;

  /// Label for the optional maintenance workshop field.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get maintenanceGarageLabel;

  /// Hint for the optional maintenance workshop field.
  ///
  /// In en, this message translates to:
  /// **'E.g. Marín Workshop · Madrid'**
  String get maintenanceGarageHint;

  /// Label for the optional maintenance notes field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get maintenanceNotesLabel;

  /// Hint for the optional maintenance notes field.
  ///
  /// In en, this message translates to:
  /// **'Service details...'**
  String get maintenanceNotesHint;

  /// Submits the form with its current values.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Heading of the maintenance history section of a car.
  ///
  /// In en, this message translates to:
  /// **'Maintenance history'**
  String get maintenanceHistoryTitle;

  /// Shown when a car has no maintenance records.
  ///
  /// In en, this message translates to:
  /// **'No maintenance records yet'**
  String get maintenanceHistoryEmpty;

  /// Number of maintenance records shown under the history heading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String maintenanceEntryCount(int count);

  /// Snackbar shown when a maintenance is created.
  ///
  /// In en, this message translates to:
  /// **'Maintenance recorded'**
  String get maintenanceCreated;

  /// Snackbar shown when creating a maintenance fails.
  ///
  /// In en, this message translates to:
  /// **'Could not create the maintenance'**
  String get maintenanceCreateError;

  /// Prefix for an unexpected maintenance load error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String maintenanceErrorDetails(String error);

  /// Label of the mileage statistic of a car.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get maintenanceStatsKmLabel;

  /// Label of the money spent statistic of a car.
  ///
  /// In en, this message translates to:
  /// **'SPENT'**
  String get maintenanceStatsSpentLabel;

  /// Label of the maintenance entry count statistic.
  ///
  /// In en, this message translates to:
  /// **'ENTRIES'**
  String get maintenanceStatsEntriesLabel;

  /// Shown when the requested car does not exist.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found'**
  String get vehicleNotFound;

  /// Shown when the requested maintenance does not exist.
  ///
  /// In en, this message translates to:
  /// **'Record not found'**
  String get maintenanceNotFound;

  /// Title of the maintenance deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete maintenance'**
  String get deleteMaintenanceTitle;

  /// Body of the maintenance deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteMaintenanceConfirmation;

  /// Snackbar shown when a maintenance is deleted.
  ///
  /// In en, this message translates to:
  /// **'Maintenance deleted'**
  String get maintenanceDeleted;

  /// Snackbar shown when deleting a maintenance fails.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the maintenance'**
  String get maintenanceDeleteError;

  /// Snackbar shown when updating a maintenance fails.
  ///
  /// In en, this message translates to:
  /// **'Could not update the maintenance'**
  String get maintenanceUpdateError;

  /// Heading of the maintenance notes section.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get maintenanceNotesSection;

  /// Timeline group heading for records without a valid date.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get timelineNoDate;

  /// Screen reader label of a timeline maintenance entry.
  ///
  /// In en, this message translates to:
  /// **'{type} on {date}'**
  String timelineEntrySemantics(String type, String date);

  /// Snackbar reporting a maintenance removed by another device.
  ///
  /// In en, this message translates to:
  /// **'Maintenance {id} deleted'**
  String maintenanceRemoteDeleted(String id);

  /// Snackbar reporting a remotely deleted maintenance with unsynced edits.
  ///
  /// In en, this message translates to:
  /// **'Maintenance {id} deleted, edits discarded'**
  String maintenanceRemoteDeletedDiscarded(String id);

  /// Full label of the oil change maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Oil change'**
  String get maintTypeOil;

  /// Short label of the oil change maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Oil'**
  String get maintTypeOilShort;

  /// Full label of the coolant maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Coolant'**
  String get maintTypeCoolant;

  /// Short label of the coolant maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Coolant'**
  String get maintTypeCoolantShort;

  /// Full label of the timing belt maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Timing belt'**
  String get maintTypeBelt;

  /// Short label of the timing belt maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Belt'**
  String get maintTypeBeltShort;

  /// Full label of the vehicle inspection maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle inspection'**
  String get maintTypeItv;

  /// Short label of the vehicle inspection maintenance type.
  ///
  /// In en, this message translates to:
  /// **'ITV'**
  String get maintTypeItvShort;

  /// Full label of the general repair maintenance type.
  ///
  /// In en, this message translates to:
  /// **'General repair'**
  String get maintTypeRepair;

  /// Short label of the general repair maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get maintTypeRepairShort;

  /// Full label of the air filter maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Air filter'**
  String get maintTypeFilter;

  /// Short label of the air filter maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get maintTypeFilterShort;

  /// Full label of the battery maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get maintTypeBattery;

  /// Short label of the battery maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get maintTypeBatteryShort;

  /// Full label of the brakes maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get maintTypeBrakes;

  /// Short label of the brakes maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get maintTypeBrakesShort;

  /// Full label of the tires maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get maintTypeTires;

  /// Short label of the tires maintenance type.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get maintTypeTiresShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
