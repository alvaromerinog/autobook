import { Car } from '../../domain/entities/car.entity';
import { CarsRepository } from '../../domain/repositories/cars.repository';
import { CarConflictError } from '../../domain/errors/car-conflict.error';
import { PrismaDatabase } from '../../../prisma/infrastructure/prisma.database';
import { Injectable } from '@nestjs/common';

@Injectable()
export class PrismaCarsRepository implements CarsRepository {
  constructor(private readonly prisma: PrismaDatabase) {}

  async getAll(): Promise<Car[]> {
    const cars = await this.prisma.car.findMany({
      where: { deletedAt: null },
    });
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
    const updateData = {
      brand: input.brand,
      model: input.model,
      year: input.year,
      licensePlate: input.licensePlate,
      color: input.color,
      mileage: input.mileage,
    };
    const { count } = await this.prisma.car.updateMany({
      where: { id: input.id, deletedAt: null },
      data: updateData,
    });
    return count === 1 ? { id: input.id } : null;
  }

  async delete(id: string): Promise<{ id: string } | null> {
    return this.prisma.$transaction(async (tx) => {
      const { count } = await tx.car.updateMany({
        where: { id, deletedAt: null },
        data: { deletedAt: new Date() },
      });
      if (count !== 1) return null;
      await tx.maintenance.updateMany({
        where: { carId: id, deletedAt: null },
        data: { deletedAt: new Date() },
      });
      return { id };
    });
  }
}
