import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  ConflictException,
  NotFoundException,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiConflictResponse,
} from '@nestjs/swagger';
import { CarsService } from '../application/cars.service';
import { CarDto } from './dto/car.dto';
import { GetCarsResponseDto } from './dto/getCarsResponse.dto';
import { CreateCarResponseDto } from './dto/createCarResponse.dto';
import { UpdateCarResponseDto } from './dto/updateCarResponse.dto';
import { CarConflictError } from '../domain/errors/car-conflict.error';

@Controller('cars')
@UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
export class CarsController {
  constructor(private readonly carsService: CarsService) {}

  @Get()
  @ApiOkResponse({ type: GetCarsResponseDto })
  async getCars(): Promise<GetCarsResponseDto> {
    const { cars } = await this.carsService.getCars();
    return new GetCarsResponseDto(cars.map((car) => CarDto.fromDomain(car)));
  }

  @Post()
  @ApiCreatedResponse({ type: CreateCarResponseDto })
  @ApiConflictResponse()
  async createCar(@Body() body: CarDto): Promise<CreateCarResponseDto> {
    const carData = body.toDomain();
    try {
      const car = await this.carsService.createCar(carData);
      return new CreateCarResponseDto(car.id);
    } catch (error) {
      if (error instanceof CarConflictError)
        throw new ConflictException(error.message);
      throw error;
    }
  }

  @Put()
  @ApiOkResponse({ type: UpdateCarResponseDto })
  @ApiNotFoundResponse()
  async updateCar(@Body() body: CarDto): Promise<UpdateCarResponseDto> {
    const carData = body.toDomain();
    const result = await this.carsService.updateCar(carData);
    if (!result) throw new NotFoundException();
    return new UpdateCarResponseDto(result.id);
  }
}
