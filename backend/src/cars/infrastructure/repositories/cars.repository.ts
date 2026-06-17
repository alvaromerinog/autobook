import { Car } from '../../domain/entities/car.entity';
import { CarsRepository } from '../../domain/repositories/cars.repository';
import { CarConflictError } from '../../domain/errors/car-conflict.error';
import { PrismaDatabase } from '../../../prisma/infrastructure/prisma.database';
import { Injectable } from '@nestjs/common';

@Injectable()
export class PrismaCarsRepository implements CarsRepository {
  constructor(private readonly prisma: PrismaDatabase) {}

  async getAll(): Promise<Car[]> {
    const cars = await this.prisma.car.findMany();
    return cars;
  }

  async create(input: Car): Promise<Car> {
    const existing = await this.prisma.car.findUnique({
      where: { id: input.id },
    });
    if (existing) throw new CarConflictError(input.id);
    return this.prisma.car.create({ data: input });
  }

  async update(input: Car): Promise<{ id: string } | null> {
    const existing = await this.prisma.car.findUnique({
      where: { id: input.id },
    });
    if (!existing) return null;
    const car = await this.prisma.car.update({
      where: { id: input.id },
      data: input,
    });
    return { id: car.id };
  }
}
