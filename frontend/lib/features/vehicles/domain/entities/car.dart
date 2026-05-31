import 'package:freezed_annotation/freezed_annotation.dart';

part 'car.freezed.dart';

@freezed
abstract class Car with _$Car {
  const Car._();

  const factory Car({
    required String id,
    required String brand,
    required String model,
    required int year,
    required String licensePlate,
    String? color,
    int? mileage,
  }) = _Car;
}
