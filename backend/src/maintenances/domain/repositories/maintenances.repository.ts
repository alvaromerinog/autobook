import { Maintenance } from '../entities/maintenance.entity';

export abstract class MaintenancesRepository {
  abstract getAll(carId: string): Promise<Maintenance[]>;
  abstract getOne(id: string, carId: string): Promise<Maintenance | null>;
  abstract create(input: Maintenance): Promise<Maintenance>;
  abstract update(input: Maintenance): Promise<{ id: string } | null>;
  abstract delete(id: string, carId: string): Promise<{ id: string } | null>;
}