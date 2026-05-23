import '../../../../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { CarsService } from '../../../application/cars.service';
import { CarsRepository } from '../../../domain/repositories/cars.repository';
import { Car } from '../../../domain/entities/car.entity';

const TEST_CAR_1: Car = {
  id: '00000000-0000-0000-0000-000000000001',
  brand: 'Toyota',
  model: 'Corolla',
  year: 2020,
  licensePlate: 'ABC-001',
  color: 'White',
  mileage: 30000,
};

const TEST_CAR_2: Car = {
  id: '00000000-0000-0000-0000-000000000002',
  brand: 'Honda',
  model: 'Civic',
  year: 2019,
  licensePlate: 'DEF-002',
  color: null,
  mileage: null,
};

const TEST_CAR_3: Car = {
  id: '00000000-0000-0000-0000-000000000003',
  brand: 'Ford',
  model: 'Focus',
  year: 2021,
  licensePlate: 'GHI-003',
  color: 'Blue',
  mileage: 15000,
};

describe('CarsService (unit)', () => {
  let service: CarsService;
  let repository: jest.Mocked<CarsRepository>;

  beforeEach(async () => {
    const mockRepository: jest.Mocked<CarsRepository> = {
      getAll: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [CarsService, { provide: CarsRepository, useValue: mockRepository }],
    }).compile();

    service = module.get<CarsService>(CarsService);
    repository = module.get(CarsRepository);
  });

  describe('getCars', () => {
    it('given an empty repository when getCars then returns an empty list', async () => {
      repository.getAll.mockResolvedValue([]);

      const result = await service.getCars();

      expect(result).toEqual({ cars: [] });
    });

    it('given three cars in the repository when getCars then returns all cars unchanged', async () => {
      const cars = [TEST_CAR_1, TEST_CAR_2, TEST_CAR_3];
      repository.getAll.mockResolvedValue(cars);

      const result = await service.getCars();

      expect(result).toEqual({ cars });
      expect(result.cars).toHaveLength(3);
    });
  });

  describe('createCar', () => {
    it('given valid car data when createCar then delegates to the repository with the same car', async () => {
      repository.create.mockResolvedValue(TEST_CAR_1);

      await service.createCar(TEST_CAR_1);

      expect(repository.create).toHaveBeenCalledTimes(1);
      expect(repository.create).toHaveBeenCalledWith(TEST_CAR_1);
    });

    it('given a car with all fields when createCar then returns the created car unchanged', async () => {
      repository.create.mockResolvedValue(TEST_CAR_1);

      const result = await service.createCar(TEST_CAR_1);

      expect(result).toEqual(TEST_CAR_1);
    });
  });

  describe('updateCar', () => {
    it('given an existing car when updateCar then returns its id', async () => {
      repository.update.mockResolvedValue({ id: TEST_CAR_1.id });

      const result = await service.updateCar(TEST_CAR_1);

      expect(result).toEqual({ id: TEST_CAR_1.id });
    });

    it('given a non-existing car when updateCar then returns null', async () => {
      repository.update.mockResolvedValue(null);

      const result = await service.updateCar(TEST_CAR_1);

      expect(result).toBeNull();
    });
  });
});
