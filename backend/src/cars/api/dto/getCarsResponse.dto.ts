import { ApiProperty } from '@nestjs/swagger';
import { CarDto } from './car.dto';

export class GetCarsResponseDto {
  @ApiProperty({ type: [CarDto] })
  cars: CarDto[];

  constructor(cars: CarDto[]) {
    this.cars = cars;
  }
}