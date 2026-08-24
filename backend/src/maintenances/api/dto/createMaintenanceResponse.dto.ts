import { ApiProperty } from '@nestjs/swagger';

export class CreateMaintenanceResponseDto {
  @ApiProperty()
  id: string;

  constructor(id: string) {
    this.id = id;
  }
}
