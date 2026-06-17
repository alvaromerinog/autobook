import { Module } from '@nestjs/common';
import { CarsController } from './api/cars.controller';
import { CarsService } from './application/cars.service';
import { PrismaCarsRepository } from './infrastructure/repositories/cars.repository';
import { CarsRepository } from './domain/repositories/cars.repository';

@Module({
  controllers: [CarsController],
  providers: [
    CarsService,
    { provide: CarsRepository, useClass: PrismaCarsRepository },
  ],
})
export class CarsModule {}
