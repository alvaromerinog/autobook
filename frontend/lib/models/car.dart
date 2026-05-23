import 'package:uuid/uuid.dart';

class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String? color;
  final int? mileage;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.color,
    this.mileage,
  });

  factory Car.create({
    required String brand,
    required String model,
    required int year,
    required String licensePlate,
    String? color,
    int? mileage,
  }) {
    return Car(
      id: const Uuid().v4(),
      brand: brand,
      model: model,
      year: year,
      licensePlate: licensePlate,
      color: color,
      mileage: mileage,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['licensePlate'] as String,
      color: json['color'] as String?,
      mileage: json['mileage'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'color': color,
        'mileage': mileage,
      };

  static const _unset = Object();

  Car copyWith({
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    Object? color = _unset,
    Object? mileage = _unset,
  }) {
    return Car(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: identical(color, _unset) ? this.color : color as String?,
      mileage: identical(mileage, _unset) ? this.mileage : mileage as int?,
    );
  }
}
