import { Module } from '@nestjs/common';
import { CarsModule } from './cars/cars.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, CarsModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
