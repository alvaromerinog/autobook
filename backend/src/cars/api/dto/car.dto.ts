import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsInt, IsOptional, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';
import { Car } from '../../domain/entities/car.entity';

export class CarDto {
  @IsUUID()
  @ApiProperty()
  id: string;

  @IsString()
  @ApiProperty()
  brand: string;

  @IsString()
  @ApiProperty()
  model: string;

  @IsInt()
  @Type(() => Number)
  @ApiProperty()
  year: number;

  @IsString()
  @ApiProperty()
  licensePlate: string;

  @IsOptional()
  @IsString()
  @ApiProperty({ type: String, nullable: true })
  color: string | null;

  @IsOptional()
  @IsInt()
  @Type(() => Number)
  @ApiProperty({ type: Number, nullable: true })
  mileage: number | null;

  constructor(car?: Car) {
    if (car) {
      this.id = car.id;
      this.brand = car.brand;
      this.model = car.model;
      this.year = car.year;
      this.licensePlate = car.licensePlate;
      this.color = car.color;
      this.mileage = car.mileage;
    }
  }

  static fromDomain(car: Car): CarDto {
    return new CarDto(car);
  }

  toDomain = (): Car => {
    return {
      id: this.id,
      brand: this.brand,
      model: this.model,
      year: this.year,
      licensePlate: this.licensePlate,
      color: this.color,
      mileage: this.mileage,
    };
  };
}
