import { ApiProperty } from '@nestjs/swagger';
import {
  IsDateString,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  MAINT_TYPE_KEYS,
  Maintenance,
} from '../../domain/entities/maintenance.entity';
import { IsMaintenanceType } from './isMaintenanceType.decorator';

export class MaintenanceDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  id: string;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  carId: string;

  @IsMaintenanceType()
  @ApiProperty({ enum: MAINT_TYPE_KEYS })
  type: string;

  @IsDateString()
  @ApiProperty()
  date: string;

  @IsInt()
  @Type(() => Number)
  @Min(0)
  @ApiProperty()
  mileage: number;

  @IsNumber()
  @Min(0)
  @ApiProperty()
  cost: number;

  @IsOptional()
  @IsString()
  @ApiProperty({ type: String, nullable: true })
  garage: string | null;

  @IsOptional()
  @IsString()
  @ApiProperty({ type: String, nullable: true })
  notes: string | null;

  constructor(maintenance?: Maintenance) {
    if (maintenance) {
      this.id = maintenance.id;
      this.carId = maintenance.carId;
      this.type = maintenance.type;
      this.date = maintenance.date;
      this.mileage = maintenance.mileage;
      this.cost = maintenance.cost;
      this.garage = maintenance.garage;
      this.notes = maintenance.notes;
    }
  }

  static fromDomain(m: Maintenance): MaintenanceDto {
    return new MaintenanceDto(m);
  }

  toDomain(): Maintenance {
    return {
      id: this.id,
      carId: this.carId,
      type: this.type as Maintenance['type'],
      date: this.date,
      mileage: this.mileage,
      cost: this.cost,
      garage: this.garage,
      notes: this.notes,
      deletedAt: null,
    };
  }
}
