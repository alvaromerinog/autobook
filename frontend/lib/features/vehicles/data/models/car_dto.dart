import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_dto.freezed.dart';
part 'car_dto.g.dart';

@freezed
abstract class CarDto with _$CarDto {
  const CarDto._();

  const factory CarDto({
    required String id,
    required String brand,
    required String model,
    required int year,
    required String licensePlate,
    String? color,
    int? mileage,
  }) = _CarDto;

  factory CarDto.fromJson(Map<String, dynamic> json) => _$CarDtoFromJson(json);

  factory CarDto.fromDomain(Car car) => CarDto(
        id: car.id,
        brand: car.brand,
        model: car.model,
        year: car.year,
        licensePlate: car.licensePlate,
        color: car.color,
        mileage: car.mileage,
      );

  Car toDomain() => Car(
        id: id,
        brand: brand,
        model: model,
        year: year,
        licensePlate: licensePlate,
        color: color,
        mileage: mileage,
      );
}

@freezed
abstract class CarsListResponse with _$CarsListResponse {
  const factory CarsListResponse({required List<CarDto> cars}) =
      _CarsListResponse;

  factory CarsListResponse.fromJson(Map<String, dynamic> json) =>
      _$CarsListResponseFromJson(json);
}
