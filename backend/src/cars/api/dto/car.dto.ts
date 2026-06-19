import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsOptional, IsString, Min } from 'class-validator';
import { MaxModelYear } from './isModelYear.decorator';
import { Car } from '../../domain/entities/car.entity';

export class CarDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  id: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  brand: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  model: string;

  @ApiProperty()
  @IsInt()
  @Min(1886)
  @MaxModelYear()
  year: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  licensePlate: string;

  @ApiProperty({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  color: string | null;

  @ApiProperty({ type: Number, nullable: true })
  @IsOptional()
  @IsInt()
  @Min(0)
  mileage: number | null;

  constructor(car?: Car) {
    this.id = car?.id ?? '';
    this.brand = car?.brand ?? '';
    this.model = car?.model ?? '';
    this.year = car?.year ?? 0;
    this.licensePlate = car?.licensePlate ?? '';
    this.color = car?.color ?? null;
    this.mileage = car?.mileage ?? null;
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
