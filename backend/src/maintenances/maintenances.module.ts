import { Module } from '@nestjs/common';
import { MaintenancesController } from './api/maintenances.controller';
import { MaintenancesService } from './application/maintenances.service';
import { MaintenancesRepository } from './domain/repositories/maintenances.repository';
import { PrismaMaintenancesRepository } from './infrastructure/repositories/maintenances.repository';

@Module({
  controllers: [MaintenancesController],
  providers: [
    MaintenancesService,
    {
      provide: MaintenancesRepository,
      useClass: PrismaMaintenancesRepository,
    },
  ],
})
export class MaintenancesModule {}
