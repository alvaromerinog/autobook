import { Controller, Get, Put, Body, NotFoundException } from '@nestjs/common';
import { ApiOkResponse, ApiNotFoundResponse } from '@nestjs/swagger';
import { CarsService } from '../application/cars.service';
import { CarDto } from './dto/car.dto';
import { GetCarsResponseDto } from './dto/getCarsResponse.dto';
import { UpdateCarResponseDto } from './dto/updateCarResponse.dto';

@Controller('cars')
export class CarsController {
  constructor(private readonly carsService: CarsService) {}

  @Get()
  @ApiOkResponse({ type: GetCarsResponseDto })
  async getCars(): Promise<GetCarsResponseDto> {
    const { cars } = await this.carsService.getCars();
    return new GetCarsResponseDto(cars.map(CarDto.fromDomain));
  }

  @Put()
  @ApiOkResponse({ type: UpdateCarResponseDto })
  @ApiNotFoundResponse()
  async updateCar(@Body() body: CarDto): Promise<UpdateCarResponseDto> {
    const result = await this.carsService.updateCar(CarDto.toDomain(body));
    if (!result) throw new NotFoundException();
    return new UpdateCarResponseDto(result.id);
  }
}