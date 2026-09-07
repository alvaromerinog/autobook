import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaDatabase } from '../../../prisma/infrastructure/prisma.database';
import { MaintenanceConflictError } from '../../domain/errors/maintenance-conflict.error';
import { Maintenance } from '../../domain/entities/maintenance.entity';
import { MaintenancesRepository } from '../../domain/repositories/maintenances.repository';

@Injectable()
export class PrismaMaintenancesRepository implements MaintenancesRepository {
  constructor(private readonly prisma: PrismaDatabase) {}

  private async assertCarExists(carId: string): Promise<void> {
    const car = await this.prisma.car.findFirst({
      where: { id: carId, deletedAt: null },
      select: { id: true },
    });
    if (!car) throw new NotFoundException(`Car ${carId} not found`);
  }

  async getAll(carId: string): Promise<Maintenance[]> {
    await this.assertCarExists(carId);
    return this.prisma.maintenance.findMany({
      where: { carId, deletedAt: null },
      orderBy: { date: 'desc' },
    }) as Promise<Maintenance[]>;
  }

  async getOne(id: string, carId: string): Promise<Maintenance | null> {
    await this.assertCarExists(carId);
    return this.prisma.maintenance.findFirst({
      where: { id, carId, deletedAt: null },
    }) as Promise<Maintenance | null>;
  }

  async create(input: Maintenance): Promise<Maintenance> {
    await this.assertCarExists(input.carId);
    const existing = await this.prisma.maintenance.findUnique({
      where: { id: input.id },
    });
    if (existing) throw new MaintenanceConflictError(input.id);
    return this.prisma.maintenance.create({
      data: input,
    }) as Promise<Maintenance>;
  }

  async update(input: Maintenance): Promise<{ id: string } | null> {
    const { count } = await this.prisma.maintenance.updateMany({
      where: { id: input.id, carId: input.carId, deletedAt: null },
      data: {
        type: input.type,
        date: input.date,
        mileage: input.mileage,
        cost: input.cost,
        garage: input.garage,
        notes: input.notes,
      },
    });
    return count === 1 ? { id: input.id } : null;
  }

  async delete(id: string, carId: string): Promise<{ id: string } | null> {
    const { count } = await this.prisma.maintenance.updateMany({
      where: { id, carId, deletedAt: null },
      data: { deletedAt: new Date() },
    });
    return count === 1 ? { id } : null;
  }
}
