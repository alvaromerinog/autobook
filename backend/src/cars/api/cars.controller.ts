import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  NotFoundException,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
} from '@nestjs/swagger';
import { CarsService } from '../application/cars.service';
import { CarDto } from './dto/car.dto';
import { GetCarsResponseDto } from './dto/getCarsResponse.dto';
import { CreateCarResponseDto } from './dto/createCarResponse.dto';
import { UpdateCarResponseDto } from './dto/updateCarResponse.dto';

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
  async createCar(@Body() body: CarDto): Promise<CreateCarResponseDto> {
    const car = await this.carsService.createCar(CarDto.toDomain(body));
    return new CreateCarResponseDto(car.id);
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
