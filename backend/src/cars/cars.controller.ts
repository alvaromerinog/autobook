import { Controller, Get } from '@nestjs/common';
import { CarsService, Car } from './cars.service';

@Controller('cars')
export class CarsController {
  constructor(private readonly carsService: CarsService) {}

  @Get()
  getCars(): Promise<{ cars: Car[] }> {
    return this.carsService.getCars();
  }
}
