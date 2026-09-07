import {
  Body,
  ConflictException,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  NotFoundException,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
} from '@nestjs/swagger';
import { MaintenancesService } from '../application/maintenances.service';
import { MaintenanceConflictError } from '../domain/errors/maintenance-conflict.error';
import { CreateMaintenanceResponseDto } from './dto/createMaintenanceResponse.dto';
import { GetMaintenancesResponseDto } from './dto/getMaintenancesResponse.dto';
import { MaintenanceDto } from './dto/maintenance.dto';
import { UpdateMaintenanceResponseDto } from './dto/updateMaintenanceResponse.dto';

@Controller('cars')
export class MaintenancesController {
  constructor(private readonly service: MaintenancesService) {}

  @Get(':carId/maintenances')
  @ApiOkResponse({ type: GetMaintenancesResponseDto })
  async list(
    @Param('carId') carId: string,
  ): Promise<GetMaintenancesResponseDto> {
    const { maintenances } = await this.service.getForCar(carId);
    return new GetMaintenancesResponseDto(
      maintenances.map((m) => MaintenanceDto.fromDomain(m)),
    );
  }

  @Post(':carId/maintenances')
  @ApiCreatedResponse({ type: CreateMaintenanceResponseDto })
  @ApiNotFoundResponse()
  @ApiConflictResponse()
  async create(
    @Param('carId') carId: string,
    @Body() body: MaintenanceDto,
  ): Promise<CreateMaintenanceResponseDto> {
    const data = body.toDomain();
    const input = { ...data, carId };
    try {
      const created = await this.service.create(input);
      return new CreateMaintenanceResponseDto(created.id);
    } catch (error) {
      if (error instanceof MaintenanceConflictError) {
        throw new ConflictException(error.message);
      }
      throw error;
    }
  }

  @Get(':carId/maintenances/:id')
  @ApiOkResponse({ type: MaintenanceDto })
  @ApiNotFoundResponse()
  async getOne(
    @Param('carId') carId: string,
    @Param('id') id: string,
  ): Promise<MaintenanceDto> {
    const maintenance = await this.service.getOne(id, carId);
    if (!maintenance) throw new NotFoundException();
    return MaintenanceDto.fromDomain(maintenance);
  }

  @Put(':carId/maintenances/:id')
  @ApiOkResponse({ type: UpdateMaintenanceResponseDto })
  @ApiNotFoundResponse()
  async update(
    @Param('carId') carId: string,
    @Param('id') id: string,
    @Body() body: MaintenanceDto,
  ): Promise<UpdateMaintenanceResponseDto> {
    const data = body.toDomain();
    const input = { ...data, id, carId };
    const result = await this.service.update(input);
    if (!result) throw new NotFoundException();
    return new UpdateMaintenanceResponseDto(result.id);
  }

  @Delete(':carId/maintenances/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse()
  @ApiNotFoundResponse()
  async remove(
    @Param('carId') carId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.service.delete(id, carId);
    if (!result) throw new NotFoundException();
  }
}
