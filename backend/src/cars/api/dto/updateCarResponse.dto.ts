import { ApiProperty } from '@nestjs/swagger';

export class UpdateCarResponseDto {
  @ApiProperty()
  id: string;

  constructor(id: string) {
    this.id = id;
  }
}
