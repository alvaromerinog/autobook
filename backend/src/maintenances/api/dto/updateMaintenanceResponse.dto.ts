import { ApiProperty } from '@nestjs/swagger';

export class UpdateMaintenanceResponseDto {
  @ApiProperty()
  id: string;

  constructor(id: string) {
    this.id = id;
  }
}
