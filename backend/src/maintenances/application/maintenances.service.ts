import { Injectable } from '@nestjs/common';
import { Maintenance } from '../domain/entities/maintenance.entity';
import { MaintenancesRepository } from '../domain/repositories/maintenances.repository';

@Injectable()
export class MaintenancesService {
  constructor(private readonly repo: MaintenancesRepository) {}

  async getForCar(carId: string): Promise<{ maintenances: Maintenance[] }> {
    const maintenances = await this.repo.getAll(carId);
    return { maintenances };
  }

  async getOne(id: string, carId: string): Promise<Maintenance | null> {
    return this.repo.getOne(id, carId);
  }

  async create(input: Maintenance): Promise<Maintenance> {
    return this.repo.create(input);
  }

  async update(input: Maintenance): Promise<{ id: string } | null> {
    return this.repo.update(input);
  }

  async delete(id: string, carId: string): Promise<{ id: string } | null> {
    return this.repo.delete(id, carId);
  }
}
