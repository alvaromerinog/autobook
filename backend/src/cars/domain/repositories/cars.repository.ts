import { Car } from '../entities/car.entity';

export abstract class CarsRepository {
  abstract getAll(): Promise<Car[]>;
  abstract create(input: Car): Promise<Car>;
  abstract update(input: Car): Promise<{ id: string } | null>;
  abstract delete(id: string): Promise<{ id: string } | null>;
}
