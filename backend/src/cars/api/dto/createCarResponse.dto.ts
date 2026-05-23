import { ApiProperty } from '@nestjs/swagger';

export class CreateCarResponseDto {
  @ApiProperty()
  id: string;

  constructor(id: string) {
    this.id = id;
  }
}
