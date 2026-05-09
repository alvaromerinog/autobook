import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface Car {
  id: string;
  brand: string;
  model: string;
  year: number;
  licensePlate: string;
  color: string | null;
  mileage: number | null;
}

@Injectable()
export class CarsService {
  constructor(private readonly prisma: PrismaService) {}

  async getCars(): Promise<{ cars: Car[] }> {
    const cars = await this.prisma.car.findMany();
    return { cars };
  }
}
