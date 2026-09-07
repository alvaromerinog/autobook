import { ApiProperty } from '@nestjs/swagger';
import { MaintenanceDto } from './maintenance.dto';

export class GetMaintenancesResponseDto {
  @ApiProperty({ type: [MaintenanceDto] })
  maintenances: MaintenanceDto[];

  constructor(maintenances: MaintenanceDto[]) {
    this.maintenances = maintenances;
  }
}
