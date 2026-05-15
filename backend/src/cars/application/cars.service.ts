import { Injectable } from '@nestjs/common';
import { Car } from '../domain/entities/car.entity';
import { CarsRepository } from '../domain/repositories/cars.repository';

@Injectable()
export class CarsService {
  constructor(private readonly carsRepository: CarsRepository) {}

  async getCars(): Promise<{ cars: Car[] }> {
    const cars = await this.carsRepository.getAll();
    return { cars };
  }

  async createCar(input: Car): Promise<Car> {
    return this.carsRepository.create(input);
  }

  async updateCar(input: Car): Promise<{ id: string } | null> {
    const updateCar = await this.carsRepository.update(input);
    return updateCar;
  }
}
