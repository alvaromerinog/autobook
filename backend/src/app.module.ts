import { Module } from '@nestjs/common';
import { CarsModule } from './cars/cars.module';
import { MaintenancesModule } from './maintenances/maintenances.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, CarsModule, MaintenancesModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
