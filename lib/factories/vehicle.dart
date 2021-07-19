class Vehicle{
  final String registration;
  final String? brand;
  final String? model;

  Vehicle({required this.registration, this.brand, this.model});

  factory Vehicle.fromMap(Map<String, dynamic> data){
    return Vehicle(
      registration: data['registration'],
      brand: data['brand'],
      model: data['model']
    );
  }
}