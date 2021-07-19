class Maintenance{
  final String registration;
  final String idMaintenance;
  final String? date;
  final int? odometer;
  final int idType;
  final String? type;

  Maintenance({required this.registration, required this.idMaintenance, this.date, this.odometer, required this.idType, this.type});

  factory Maintenance.fromMap(Map<String, dynamic> data){
    return Maintenance(
      registration: data['registration'],
      idMaintenance: data['id_maintenance'],
      date: data['date'],
      odometer: data['odometer'],
      idType: data['id_type'],
      type: data['type'],
    );
  }
}