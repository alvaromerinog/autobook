import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { CarsModule } from './cars/cars.module';
import { LoggingInterceptor } from './logging/logging.interceptor';
import { MaintenancesModule } from './maintenances/maintenances.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, CarsModule, MaintenancesModule],
  controllers: [],
  providers: [{ provide: APP_INTERCEPTOR, useClass: LoggingInterceptor }],
})
export class AppModule {}
