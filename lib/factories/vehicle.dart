class Vehicle{
  final String? registration;
  final String? brand;
  final String? model;

  Vehicle({this.registration, this.brand, this.model});

  factory Vehicle.fromMap(Map<String, String> data){
    return Vehicle(
      registration: data['registration'],
      brand: data['brand'],
      model: data['model']
    );
  }
}