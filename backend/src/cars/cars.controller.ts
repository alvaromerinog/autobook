import { Controller, Get, Put, Body, NotFoundException } from '@nestjs/common';
import { CarsService } from './cars.service';
import type { Car } from './cars.service';

@Controller('cars')
export class CarsController {
  constructor(private readonly carsService: CarsService) {}

  @Get()
  getCars(): Promise<{ cars: Car[] }> {
    return this.carsService.getCars();
  }

  @Put()
  async updateCar(@Body() body: Car): Promise<{ id: string }> {
    const result = await this.carsService.updateCar(body);
    if (!result) throw new NotFoundException();
    return result;
  }
}
