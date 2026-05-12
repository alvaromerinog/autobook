import { ApiProperty } from '@nestjs/swagger';
import { Car } from '../../domain/entities/car.entity';

export class CarDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  brand: string;

  @ApiProperty()
  model: string;

  @ApiProperty()
  year: number;

  @ApiProperty()
  licensePlate: string;

  @ApiProperty({ type: String, nullable: true })
  color: string | null;

  @ApiProperty({ type: Number, nullable: true })
  mileage: number | null;

  constructor(car: Car) {
    this.id = car.id;
    this.brand = car.brand;
    this.model = car.model;
    this.year = car.year;
    this.licensePlate = car.licensePlate;
    this.color = car.color;
    this.mileage = car.mileage;
  }

  static fromDomain(car: Car): CarDto {
    return new CarDto(car);
  }

  static toDomain(dto: CarDto): Car {
    return {
      id: dto.id,
      brand: dto.brand,
      model: dto.model,
      year: dto.year,
      licensePlate: dto.licensePlate,
      color: dto.color,
      mileage: dto.mileage,
    };
  }
}