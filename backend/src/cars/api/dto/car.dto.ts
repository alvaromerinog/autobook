import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { MaxModelYear } from './isModelYear.decorator';
import { Car } from '../../domain/entities/car.entity';

export class CarDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  id: string;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  brand: string;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  model: string;

  @IsInt()
  @Type(() => Number)
  @Min(1886)
  @MaxModelYear()
  @ApiProperty()
  year: number;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  licensePlate: string;

  @IsOptional()
  @IsString()
  @ApiProperty({ type: String, nullable: true })
  color: string | null;

  @IsOptional()
  @IsInt()
  @Type(() => Number)
  @Min(0)
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

  toDomain(): Car {
    return {
      id: this.id,
      brand: this.brand,
      model: this.model,
      year: this.year,
      licensePlate: this.licensePlate,
      color: this.color,
      mileage: this.mileage,
      deletedAt: null,
    };
  }
}
