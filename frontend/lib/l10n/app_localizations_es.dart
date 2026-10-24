// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get garage => 'Garaje';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get addCar => 'Añadir coche';

  @override
  String get addVehicle => 'Añadir vehículo';

  @override
  String get selectVehicle => 'Selecciona un vehículo';

  @override
  String get garageEmptyTitle => 'Tu garaje está vacío';

  @override
  String get garageEmptyHint =>
      'Añade tu primer vehículo para empezar a llevar el registro de sus mantenimientos.';

  @override
  String get vehicleNetworkFailure => 'No se pudo conectar con el servidor.';

  @override
  String get vehicleServerFailure =>
      'No se pudieron cargar los vehículos. Inténtalo de nuevo.';

  @override
  String get vehicleCacheFailure => 'Error al acceder al almacenamiento local.';

  @override
  String vehicleLoadErrorDetails(String error) {
    return 'Error cargando vehículos: $error';
  }

  @override
  String get vehiclesPendingSync => 'Vehículos pendientes de sincronización';

  @override
  String get syncAction => 'Sincronizar';

  @override
  String vehicleSyncErrorWithPending(String error) {
    return '$error Hay vehículos pendientes de sincronización.';
  }

  @override
  String vehicleRemoteDeleted(String brand, String model) {
    return 'Coche $brand $model eliminado';
  }

  @override
  String vehicleRemoteDeletedDiscarded(String brand, String model) {
    return 'Coche $brand $model eliminado, edición descartada';
  }

  @override
  String get vehiclePendingDelete => 'Pendiente de borrado';

  @override
  String get editVehicle => 'Editar vehículo';

  @override
  String get vehicleDetailsSection => 'Datos del vehículo';

  @override
  String get vehicleAdditionalInfoSection => 'Información adicional (opcional)';

  @override
  String get vehicleBrandLabel => 'Marca';

  @override
  String get vehicleBrandHint => 'Ej. Toyota, Ford, BMW...';

  @override
  String get vehicleModelLabel => 'Modelo';

  @override
  String get vehicleModelHint => 'Ej. Corolla, Focus, Serie 3...';

  @override
  String get vehicleYearLabel => 'Año';

  @override
  String get vehicleYearHint => 'Ej. 2020';

  @override
  String get vehicleLicensePlateLabel => 'Matrícula';

  @override
  String get vehicleLicensePlateHint => 'Ej. 1234 ABC';

  @override
  String get vehicleColorLabel => 'Color';

  @override
  String get vehicleColorHint => 'Ej. Blanco...';

  @override
  String get vehicleMileageLabel => 'Kilometraje';

  @override
  String get vehicleMileageHint => 'Ej. 45000';

  @override
  String get saveVehicle => 'Guardar vehículo';

  @override
  String get vehicleBrandRequired => 'La marca es obligatoria';

  @override
  String get vehicleModelRequired => 'El modelo es obligatorio';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get vehicleLicensePlateRequired => 'Obligatoria';

  @override
  String get vehicleYearInvalid => 'Año inválido';

  @override
  String get vehicleYearOutOfRange => 'Fuera de rango';

  @override
  String get vehicleMileageInvalid => 'Kilometraje inválido';

  @override
  String get deleteVehicleTitle => 'Eliminar vehículo';

  @override
  String deleteVehicleConfirmation(String vehicleName) {
    return '¿Seguro que quieres eliminar $vehicleName?';
  }

  @override
  String get vehicleCreateError => 'Error al crear el vehículo';

  @override
  String get vehicleUpdateError => 'Error al actualizar el vehículo';

  @override
  String get vehicleDeleteError => 'Error al eliminar el vehículo';

  @override
  String get addMaintenance => 'Añadir mantenimiento';

  @override
  String get maintenanceNewTitle => 'Nuevo mantenimiento';

  @override
  String get maintenanceEditTitle => 'Editar mantenimiento';

  @override
  String get maintenanceDetailsSection => 'Datos del mantenimiento';

  @override
  String get maintenanceTypeFieldLabel => 'Tipo de mantenimiento';

  @override
  String get maintenanceTypeRequired => 'Selecciona un tipo';

  @override
  String get maintenanceMileageLabel => 'Kilómetros';

  @override
  String get maintenanceMileageHint => 'Ej. 45000';

  @override
  String get maintenanceMileageRequired => 'Los kilómetros son obligatorios';

  @override
  String get maintenanceMileageInvalid => 'Km inválido';

  @override
  String get maintenanceCostLabel => 'Coste';

  @override
  String get maintenanceCostHint => 'Ej. 145.20';

  @override
  String get maintenanceCostRequired => 'El coste es obligatorio';

  @override
  String get maintenanceCostInvalid => 'Coste inválido';

  @override
  String get maintenanceNegativeNotAllowed => 'No puede ser negativo';

  @override
  String get maintenanceDateLabel => 'Fecha';

  @override
  String get maintenanceAdditionalInfoSection =>
      'Información adicional (opcional)';

  @override
  String get maintenanceGarageLabel => 'Taller';

  @override
  String get maintenanceGarageHint => 'Ej. Taller Marín · Madrid';

  @override
  String get maintenanceNotesLabel => 'Notas';

  @override
  String get maintenanceNotesHint => 'Detalles del servicio...';

  @override
  String get save => 'Guardar';

  @override
  String get maintenanceHistoryTitle => 'Historial de mantenimientos';

  @override
  String get maintenanceHistoryEmpty => 'Sin mantenimientos registrados';

  @override
  String maintenanceEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$_temp0';
  }

  @override
  String get maintenanceCreated => 'Mantenimiento registrado';

  @override
  String get maintenanceCreateError => 'Error al crear el mantenimiento';

  @override
  String maintenanceErrorDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get maintenanceStatsKmLabel => 'KM';

  @override
  String get maintenanceStatsSpentLabel => 'GASTADO';

  @override
  String get maintenanceStatsEntriesLabel => 'ENTRADAS';

  @override
  String get vehicleNotFound => 'Vehículo no encontrado';

  @override
  String get maintenanceNotFound => 'Registro no encontrado';

  @override
  String get deleteMaintenanceTitle => 'Eliminar mantenimiento';

  @override
  String get deleteMaintenanceConfirmation =>
      '¿Seguro que quieres eliminar este registro?';

  @override
  String get maintenanceDeleted => 'Mantenimiento eliminado';

  @override
  String get maintenanceDeleteError => 'Error al eliminar el mantenimiento';

  @override
  String get maintenanceUpdateError => 'Error al actualizar el mantenimiento';

  @override
  String get maintenanceNotesSection => 'NOTAS';

  @override
  String get timelineNoDate => 'Sin fecha';

  @override
  String timelineEntrySemantics(String type, String date) {
    return '$type $date';
  }

  @override
  String maintenanceRemoteDeleted(String id) {
    return 'Mantenimiento $id eliminado';
  }

  @override
  String maintenanceRemoteDeletedDiscarded(String id) {
    return 'Mantenimiento $id eliminado, edición descartada';
  }

  @override
  String get maintTypeOil => 'Cambio de aceite';

  @override
  String get maintTypeOilShort => 'Aceite';

  @override
  String get maintTypeCoolant => 'Refrigerante';

  @override
  String get maintTypeCoolantShort => 'Refrigerante';

  @override
  String get maintTypeBelt => 'Correa de distribución';

  @override
  String get maintTypeBeltShort => 'Distribución';

  @override
  String get maintTypeItv => 'ITV';

  @override
  String get maintTypeItvShort => 'ITV';

  @override
  String get maintTypeRepair => 'Reparación general';

  @override
  String get maintTypeRepairShort => 'Reparación';

  @override
  String get maintTypeFilter => 'Filtro de aire';

  @override
  String get maintTypeFilterShort => 'Filtro';

  @override
  String get maintTypeBattery => 'Batería';

  @override
  String get maintTypeBatteryShort => 'Batería';

  @override
  String get maintTypeBrakes => 'Frenos';

  @override
  String get maintTypeBrakesShort => 'Frenos';

  @override
  String get maintTypeTires => 'Neumáticos';

  @override
  String get maintTypeTiresShort => 'Ruedas';
}
