import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app/localization_test_harness.dart';

void main() {
  group('AppLocalizations', () {
    late AppLocalizations english;
    late AppLocalizations spanish;

    setUp(() async {
      english = await AppLocalizations.delegate.load(const Locale('en'));
      spanish = await AppLocalizations.delegate.load(const Locale('es'));
    });

    test('supports only English and Spanish', () {
      expect(
        AppLocalizations.supportedLocales,
        unorderedEquals(const [Locale('en'), Locale('es')]),
      );
    });

    group('navigation and settings labels', () {
      test('garage is translated in both catalogs', () {
        expect(english.garage, 'Garage');
        expect(spanish.garage, 'Garaje');
      });

      test('settingsTitle is translated in both catalogs', () {
        expect(english.settingsTitle, 'Settings');
        expect(spanish.settingsTitle, 'Ajustes');
      });

      test('languageLabel is translated in both catalogs', () {
        expect(english.languageLabel, 'Language');
        expect(spanish.languageLabel, 'Idioma');
      });
    });

    group('common actions', () {
      test('cancel is translated in both catalogs', () {
        expect(english.cancel, 'Cancel');
        expect(spanish.cancel, 'Cancelar');
      });

      test('delete is translated in both catalogs', () {
        expect(english.delete, 'Delete');
        expect(spanish.delete, 'Eliminar');
      });

      test('edit is translated in both catalogs', () {
        expect(english.edit, 'Edit');
        expect(spanish.edit, 'Editar');
      });

      test('retry is translated in both catalogs', () {
        expect(english.retry, 'Retry');
        expect(spanish.retry, 'Reintentar');
      });

      test('close is translated in both catalogs', () {
        expect(english.close, 'Close');
        expect(spanish.close, 'Cerrar');
      });

      test('saveChanges is translated in both catalogs', () {
        expect(english.saveChanges, 'Save changes');
        expect(spanish.saveChanges, 'Guardar cambios');
      });
    });

    group('vehicle actions', () {
      test('addCar is translated in both catalogs', () {
        expect(english.addCar, 'Add car');
        expect(spanish.addCar, 'Añadir coche');
      });

      test('addVehicle is translated in both catalogs', () {
        expect(english.addVehicle, 'Add vehicle');
        expect(spanish.addVehicle, 'Añadir vehículo');
      });

      test('selectVehicle is translated in both catalogs', () {
        expect(english.selectVehicle, 'Select a vehicle');
        expect(spanish.selectVehicle, 'Selecciona un vehículo');
      });
    });

    group('vehicle garage states', () {
      test('garage empty copy is translated in both catalogs', () {
        expect(english.garageEmptyTitle, 'Your garage is empty');
        expect(spanish.garageEmptyTitle, 'Tu garaje está vacío');
        expect(
          english.garageEmptyHint,
          'Add your first vehicle to start tracking its maintenance.',
        );
        expect(
          spanish.garageEmptyHint,
          'Añade tu primer vehículo para empezar a llevar el registro de '
          'sus mantenimientos.',
        );
      });

      test('failure messages are translated in both catalogs', () {
        expect(
          english.vehicleNetworkFailure,
          'Could not connect to the server.',
        );
        expect(
          spanish.vehicleNetworkFailure,
          'No se pudo conectar con el '
          'servidor.',
        );
        expect(
          english.vehicleServerFailure,
          'The vehicles could not be loaded. Please try again.',
        );
        expect(
          spanish.vehicleServerFailure,
          'No se pudieron cargar los vehículos. Inténtalo de nuevo.',
        );
        expect(english.vehicleCacheFailure, 'Could not access local storage.');
        expect(
          spanish.vehicleCacheFailure,
          'Error al acceder al almacenamiento '
          'local.',
        );
      });

      test('load error details keep the diagnostic error in both catalogs', () {
        expect(
          english.vehicleLoadErrorDetails('Connection closed'),
          'Error loading vehicles: Connection closed',
        );
        expect(
          spanish.vehicleLoadErrorDetails('Connection closed'),
          'Error cargando vehículos: Connection closed',
        );
      });

      test('pending sync copy is translated in both catalogs', () {
        expect(english.vehiclesPendingSync, 'Vehicles pending synchronization');
        expect(
          spanish.vehiclesPendingSync,
          'Vehículos pendientes de '
          'sincronización',
        );
        expect(english.syncAction, 'Sync');
        expect(spanish.syncAction, 'Sincronizar');
        expect(english.vehiclePendingDelete, 'Pending deletion');
        expect(spanish.vehiclePendingDelete, 'Pendiente de borrado');
      });

      test('combined sync error and pending copy keeps the error', () {
        expect(
          english.vehicleSyncErrorWithPending(
            'Could not connect to the server.',
          ),
          'Could not connect to the server. Some vehicles are pending '
          'synchronization.',
        );
        expect(
          spanish.vehicleSyncErrorWithPending(
            'Could not connect to the server.',
          ),
          'Could not connect to the server. Hay vehículos pendientes de '
          'sincronización.',
        );
      });
    });

    group('vehicle remote events', () {
      test('remote deletion is translated in both catalogs', () {
        expect(
          english.vehicleRemoteDeleted('Ford', 'Focus'),
          'Car Ford Focus deleted',
        );
        expect(
          spanish.vehicleRemoteDeleted('Ford', 'Focus'),
          'Coche Ford Focus eliminado',
        );
      });

      test('discarded edit is translated in both catalogs', () {
        expect(
          english.vehicleRemoteDeletedDiscarded('Ford', 'Focus'),
          'Car Ford Focus deleted, edits discarded',
        );
        expect(
          spanish.vehicleRemoteDeletedDiscarded('Ford', 'Focus'),
          'Coche Ford Focus eliminado, edición descartada',
        );
      });

      test('remote messages preserve brand and model placeholders', () {
        expect(
          english.vehicleRemoteDeleted('Ford', 'Focus RS'),
          contains('Ford Focus RS'),
        );
        expect(
          spanish.vehicleRemoteDeletedDiscarded('Ford', 'Focus RS'),
          contains('Ford Focus RS'),
        );
        expect(
          spanish.vehicleRemoteDeleted('Ford', 'Focus RS'),
          contains('Ford Focus RS'),
        );
      });
    });

    group('vehicle form', () {
      test('headings and sections are translated in both catalogs', () {
        expect(english.editVehicle, 'Edit vehicle');
        expect(spanish.editVehicle, 'Editar vehículo');
        expect(english.vehicleDetailsSection, 'Vehicle details');
        expect(spanish.vehicleDetailsSection, 'Datos del vehículo');
        expect(
          english.vehicleAdditionalInfoSection,
          'Additional information (optional)',
        );
        expect(
          spanish.vehicleAdditionalInfoSection,
          'Información adicional (opcional)',
        );
        expect(english.saveVehicle, 'Save vehicle');
        expect(spanish.saveVehicle, 'Guardar vehículo');
      });

      test('field labels and hints are translated in both catalogs', () {
        expect(english.vehicleBrandLabel, 'Brand');
        expect(spanish.vehicleBrandLabel, 'Marca');
        expect(english.vehicleBrandHint, 'E.g. Toyota, Ford, BMW...');
        expect(spanish.vehicleBrandHint, 'Ej. Toyota, Ford, BMW...');
        expect(english.vehicleModelLabel, 'Model');
        expect(spanish.vehicleModelLabel, 'Modelo');
        expect(english.vehicleModelHint, 'E.g. Corolla, Focus, 3 Series...');
        expect(spanish.vehicleModelHint, 'Ej. Corolla, Focus, Serie 3...');
        expect(english.vehicleYearLabel, 'Year');
        expect(spanish.vehicleYearLabel, 'Año');
        expect(english.vehicleYearHint, 'E.g. 2020');
        expect(spanish.vehicleYearHint, 'Ej. 2020');
        expect(english.vehicleLicensePlateLabel, 'License plate');
        expect(spanish.vehicleLicensePlateLabel, 'Matrícula');
        expect(english.vehicleLicensePlateHint, 'E.g. 1234 ABC');
        expect(spanish.vehicleLicensePlateHint, 'Ej. 1234 ABC');
        expect(english.vehicleColorLabel, 'Color');
        expect(spanish.vehicleColorLabel, 'Color');
        expect(english.vehicleColorHint, 'E.g. White...');
        expect(spanish.vehicleColorHint, 'Ej. Blanco...');
        expect(english.vehicleMileageLabel, 'Mileage');
        expect(spanish.vehicleMileageLabel, 'Kilometraje');
        expect(english.vehicleMileageHint, 'E.g. 45000');
        expect(spanish.vehicleMileageHint, 'Ej. 45000');
      });

      test('validation messages are translated in both catalogs', () {
        expect(english.vehicleBrandRequired, 'Brand is required');
        expect(spanish.vehicleBrandRequired, 'La marca es obligatoria');
        expect(english.vehicleModelRequired, 'Model is required');
        expect(spanish.vehicleModelRequired, 'El modelo es obligatorio');
        expect(english.fieldRequired, 'Required');
        expect(spanish.fieldRequired, 'Obligatorio');
        expect(
          english.vehicleLicensePlateRequired,
          'License plate is required',
        );
        expect(spanish.vehicleLicensePlateRequired, 'Obligatoria');
        expect(english.vehicleYearInvalid, 'Invalid year');
        expect(spanish.vehicleYearInvalid, 'Año inválido');
        expect(english.vehicleYearOutOfRange, 'Out of range');
        expect(spanish.vehicleYearOutOfRange, 'Fuera de rango');
        expect(english.vehicleMileageInvalid, 'Invalid mileage');
        expect(spanish.vehicleMileageInvalid, 'Kilometraje inválido');
      });
    });

    group('vehicle mutations', () {
      test('delete confirmation and title are translated in both catalogs', () {
        expect(english.deleteVehicleTitle, 'Delete vehicle');
        expect(spanish.deleteVehicleTitle, 'Eliminar vehículo');
        expect(
          english.deleteVehicleConfirmation('Toyota Corolla'),
          'Are you sure you want to delete Toyota Corolla?',
        );
        expect(
          spanish.deleteVehicleConfirmation('Toyota Corolla'),
          '¿Seguro que quieres eliminar Toyota Corolla?',
        );
        expect(
          english.deleteVehicleConfirmation('Toyota Corolla'),
          contains('Toyota Corolla'),
        );
      });

      test('mutation failure messages are translated in both catalogs', () {
        expect(english.vehicleCreateError, 'Could not create the vehicle');
        expect(spanish.vehicleCreateError, 'Error al crear el vehículo');
        expect(english.vehicleUpdateError, 'Could not update the vehicle');
        expect(spanish.vehicleUpdateError, 'Error al actualizar el vehículo');
        expect(english.vehicleDeleteError, 'Could not delete the vehicle');
        expect(spanish.vehicleDeleteError, 'Error al eliminar el vehículo');
      });
    });

    group('maintenance type labels', () {
      test('all nine full labels are translated in both catalogs', () {
        expect(english.maintTypeOil, 'Oil change');
        expect(spanish.maintTypeOil, 'Cambio de aceite');
        expect(english.maintTypeCoolant, 'Coolant');
        expect(spanish.maintTypeCoolant, 'Refrigerante');
        expect(english.maintTypeBelt, 'Timing belt');
        expect(spanish.maintTypeBelt, 'Correa de distribución');
        expect(english.maintTypeItv, 'Vehicle inspection');
        expect(spanish.maintTypeItv, 'ITV');
        expect(english.maintTypeRepair, 'General repair');
        expect(spanish.maintTypeRepair, 'Reparación general');
        expect(english.maintTypeFilter, 'Air filter');
        expect(spanish.maintTypeFilter, 'Filtro de aire');
        expect(english.maintTypeBattery, 'Battery');
        expect(spanish.maintTypeBattery, 'Batería');
        expect(english.maintTypeBrakes, 'Brakes');
        expect(spanish.maintTypeBrakes, 'Frenos');
        expect(english.maintTypeTires, 'Tires');
        expect(spanish.maintTypeTires, 'Neumáticos');
      });

      test('all nine short labels are translated in both catalogs', () {
        expect(english.maintTypeOilShort, 'Oil');
        expect(spanish.maintTypeOilShort, 'Aceite');
        expect(english.maintTypeCoolantShort, 'Coolant');
        expect(spanish.maintTypeCoolantShort, 'Refrigerante');
        expect(english.maintTypeBeltShort, 'Belt');
        expect(spanish.maintTypeBeltShort, 'Distribución');
        expect(english.maintTypeItvShort, 'ITV');
        expect(spanish.maintTypeItvShort, 'ITV');
        expect(english.maintTypeRepairShort, 'Repair');
        expect(spanish.maintTypeRepairShort, 'Reparación');
        expect(english.maintTypeFilterShort, 'Filter');
        expect(spanish.maintTypeFilterShort, 'Filtro');
        expect(english.maintTypeBatteryShort, 'Battery');
        expect(spanish.maintTypeBatteryShort, 'Batería');
        expect(english.maintTypeBrakesShort, 'Brakes');
        expect(spanish.maintTypeBrakesShort, 'Frenos');
        expect(english.maintTypeTiresShort, 'Tires');
        expect(spanish.maintTypeTiresShort, 'Ruedas');
      });
    });

    group('maintenance plurals and placeholders', () {
      test('entry count is an ICU plural in both catalogs', () {
        expect(english.maintenanceEntryCount(1), '1 entry');
        expect(english.maintenanceEntryCount(2), '2 entries');
        expect(spanish.maintenanceEntryCount(1), '1 entrada');
        expect(spanish.maintenanceEntryCount(2), '2 entradas');
      });

      test('remote maintenance messages keep their identifiers', () {
        expect(
          english.maintenanceRemoteDeleted('maint-01/A'),
          contains('maint-01/A'),
        );
        expect(
          english.maintenanceRemoteDeleted('maint-01/A'),
          'Maintenance maint-01/A deleted',
        );
        expect(
          spanish.maintenanceRemoteDeleted('maint-01/A'),
          'Mantenimiento maint-01/A eliminado',
        );
        expect(
          english.maintenanceRemoteDeletedDiscarded('maint-01/A'),
          'Maintenance maint-01/A deleted, edits discarded',
        );
        expect(
          spanish.maintenanceRemoteDeletedDiscarded('maint-01/A'),
          'Mantenimiento maint-01/A eliminado, edición descartada',
        );
      });

      test('diagnostic details keep the raw error', () {
        expect(
          english.maintenanceErrorDetails('Connection closed'),
          'Error: Connection closed',
        );
        expect(
          spanish.maintenanceErrorDetails('Connection closed'),
          'Error: Connection closed',
        );
      });

      test('timeline semantics keep type and date', () {
        expect(
          english.timelineEntrySemantics('Oil change', '12 Mar'),
          'Oil change on 12 Mar',
        );
        expect(
          spanish.timelineEntrySemantics('Cambio de aceite', '12 mar'),
          'Cambio de aceite 12 mar',
        );
      });
    });

    group('maintenance screens copy', () {
      test('form copy is translated in both catalogs', () {
        expect(english.maintenanceNewTitle, 'New maintenance');
        expect(spanish.maintenanceNewTitle, 'Nuevo mantenimiento');
        expect(english.maintenanceEditTitle, 'Edit maintenance');
        expect(spanish.maintenanceEditTitle, 'Editar mantenimiento');
        expect(english.maintenanceDetailsSection, 'Maintenance details');
        expect(spanish.maintenanceDetailsSection, 'Datos del mantenimiento');
        expect(english.maintenanceTypeFieldLabel, 'Maintenance type');
        expect(spanish.maintenanceTypeFieldLabel, 'Tipo de mantenimiento');
        expect(english.maintenanceTypeRequired, 'Select a type');
        expect(spanish.maintenanceTypeRequired, 'Selecciona un tipo');
        expect(english.maintenanceMileageLabel, 'Mileage');
        expect(spanish.maintenanceMileageLabel, 'Kilómetros');
        expect(english.maintenanceMileageHint, 'E.g. 45000');
        expect(spanish.maintenanceMileageHint, 'Ej. 45000');
        expect(english.maintenanceCostLabel, 'Cost');
        expect(spanish.maintenanceCostLabel, 'Coste');
        expect(english.maintenanceCostHint, 'E.g. 145.20');
        expect(spanish.maintenanceCostHint, 'Ej. 145.20');
        expect(english.maintenanceDateLabel, 'Date');
        expect(spanish.maintenanceDateLabel, 'Fecha');
        expect(english.maintenanceGarageLabel, 'Workshop');
        expect(spanish.maintenanceGarageLabel, 'Taller');
        expect(english.maintenanceGarageHint, 'E.g. Marín Workshop · Madrid');
        expect(spanish.maintenanceGarageHint, 'Ej. Taller Marín · Madrid');
        expect(english.maintenanceNotesLabel, 'Notes');
        expect(spanish.maintenanceNotesLabel, 'Notas');
        expect(english.maintenanceNotesHint, 'Service details...');
        expect(spanish.maintenanceNotesHint, 'Detalles del servicio...');
        expect(
          english.maintenanceAdditionalInfoSection,
          'Additional information (optional)',
        );
        expect(
          spanish.maintenanceAdditionalInfoSection,
          'Información adicional (opcional)',
        );
        expect(english.save, 'Save');
        expect(spanish.save, 'Guardar');
      });

      test('validation messages are translated in both catalogs', () {
        expect(english.maintenanceMileageRequired, 'Mileage is required');
        expect(
          spanish.maintenanceMileageRequired,
          'Los kilómetros son '
          'obligatorios',
        );
        expect(english.maintenanceMileageInvalid, 'Invalid mileage');
        expect(spanish.maintenanceMileageInvalid, 'Km inválido');
        expect(english.maintenanceCostRequired, 'Cost is required');
        expect(spanish.maintenanceCostRequired, 'El coste es obligatorio');
        expect(english.maintenanceCostInvalid, 'Invalid cost');
        expect(spanish.maintenanceCostInvalid, 'Coste inválido');
        expect(english.maintenanceNegativeNotAllowed, 'Cannot be negative');
        expect(spanish.maintenanceNegativeNotAllowed, 'No puede ser negativo');
      });

      test('history copy is translated in both catalogs', () {
        expect(english.addMaintenance, 'Add maintenance');
        expect(spanish.addMaintenance, 'Añadir mantenimiento');
        expect(english.maintenanceHistoryTitle, 'Maintenance history');
        expect(spanish.maintenanceHistoryTitle, 'Historial de mantenimientos');
        expect(english.maintenanceHistoryEmpty, 'No maintenance records yet');
        expect(
          spanish.maintenanceHistoryEmpty,
          'Sin mantenimientos '
          'registrados',
        );
        expect(english.maintenanceCreated, 'Maintenance recorded');
        expect(spanish.maintenanceCreated, 'Mantenimiento registrado');
        expect(
          english.maintenanceCreateError,
          'Could not create the '
          'maintenance',
        );
        expect(
          spanish.maintenanceCreateError,
          'Error al crear el mantenimiento',
        );
        expect(english.maintenanceStatsKmLabel, 'KM');
        expect(spanish.maintenanceStatsKmLabel, 'KM');
        expect(english.maintenanceStatsSpentLabel, 'SPENT');
        expect(spanish.maintenanceStatsSpentLabel, 'GASTADO');
        expect(english.maintenanceStatsEntriesLabel, 'ENTRIES');
        expect(spanish.maintenanceStatsEntriesLabel, 'ENTRADAS');
        expect(english.vehicleNotFound, 'Vehicle not found');
        expect(spanish.vehicleNotFound, 'Vehículo no encontrado');
      });

      test('detail copy is translated in both catalogs', () {
        expect(english.maintenanceNotFound, 'Record not found');
        expect(spanish.maintenanceNotFound, 'Registro no encontrado');
        expect(english.deleteMaintenanceTitle, 'Delete maintenance');
        expect(spanish.deleteMaintenanceTitle, 'Eliminar mantenimiento');
        expect(
          english.deleteMaintenanceConfirmation,
          'Are you sure you want to delete this record?',
        );
        expect(
          spanish.deleteMaintenanceConfirmation,
          '¿Seguro que quieres eliminar este registro?',
        );
        expect(english.maintenanceDeleted, 'Maintenance deleted');
        expect(spanish.maintenanceDeleted, 'Mantenimiento eliminado');
        expect(
          english.maintenanceDeleteError,
          'Could not delete the '
          'maintenance',
        );
        expect(
          spanish.maintenanceDeleteError,
          'Error al eliminar el '
          'mantenimiento',
        );
        expect(
          english.maintenanceUpdateError,
          'Could not update the '
          'maintenance',
        );
        expect(
          spanish.maintenanceUpdateError,
          'Error al actualizar el '
          'mantenimiento',
        );
        expect(english.maintenanceNotesSection, 'NOTES');
        expect(spanish.maintenanceNotesSection, 'NOTAS');
      });

      test('timeline no-date copy is translated in both catalogs', () {
        expect(english.timelineNoDate, 'No date');
        expect(spanish.timelineNoDate, 'Sin fecha');
      });
    });
  });

  group('localizedTestApp', () {
    Widget settingsTitleText(BuildContext context) =>
        Text(AppLocalizations.of(context)!.settingsTitle);

    testWidgets('uses the caller-supplied English locale', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          locale: const Locale('en'),
          home: Builder(builder: settingsTitleText),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('defaults to Spanish', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(home: Builder(builder: settingsTitleText)),
      );

      expect(find.text('Ajustes'), findsOneWidget);
    });
  });
}
