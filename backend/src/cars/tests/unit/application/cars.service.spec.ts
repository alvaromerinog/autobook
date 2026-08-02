import '../../../../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { CarsService } from '../../../application/cars.service';
import { CarsRepository } from '../../../domain/repositories/cars.repository';
import { TEST_CARS } from '../../fixtures/cars.fixtures';

const [TEST_CAR_1, TEST_CAR_2, TEST_CAR_3] = TEST_CARS;

describe('CarsService (unit)', () => {
  let service: CarsService;
  let getAllMock: jest.MockedFunction<CarsRepository['getAll']>;
  let createMock: jest.MockedFunction<CarsRepository['create']>;
  let updateMock: jest.MockedFunction<CarsRepository['update']>;
  let deleteMock: jest.MockedFunction<CarsRepository['delete']>;

  beforeEach(async () => {
    getAllMock = jest.fn();
    createMock = jest.fn();
    updateMock = jest.fn();
    deleteMock = jest.fn();

    const mockRepository: jest.Mocked<CarsRepository> = {
      getAll: getAllMock,
      create: createMock,
      update: updateMock,
      delete: deleteMock,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CarsService,
        { provide: CarsRepository, useValue: mockRepository },
      ],
    }).compile();

    service = module.get<CarsService>(CarsService);
  });

  describe('getCars', () => {
    it('given an empty repository when getCars then returns an empty list', async () => {
      getAllMock.mockResolvedValue([]);

      const result = await service.getCars();

      expect(result).toEqual({ cars: [] });
    });

    it('given three cars in the repository when getCars then returns all cars unchanged', async () => {
      const cars = [TEST_CAR_1, TEST_CAR_2, TEST_CAR_3];
      getAllMock.mockResolvedValue(cars);

      const result = await service.getCars();

      expect(result).toEqual({ cars });
      expect(result.cars).toHaveLength(3);
    });
  });

  describe('createCar', () => {
    it('given valid car data when createCar then delegates to the repository with the same car', async () => {
      createMock.mockResolvedValue(TEST_CAR_1);

      await service.createCar(TEST_CAR_1);

      expect(createMock).toHaveBeenCalledTimes(1);
      expect(createMock).toHaveBeenCalledWith(TEST_CAR_1);
    });

    it('given a car with all fields when createCar then returns the created car unchanged', async () => {
      createMock.mockResolvedValue(TEST_CAR_1);

      const result = await service.createCar(TEST_CAR_1);

      expect(result).toEqual(TEST_CAR_1);
    });
  });

  describe('updateCar', () => {
    it('given an existing car when updateCar then returns its id', async () => {
      updateMock.mockResolvedValue({ id: TEST_CAR_1.id });

      const result = await service.updateCar(TEST_CAR_1);

      expect(result).toEqual({ id: TEST_CAR_1.id });
    });

    it('given a non-existing car when updateCar then returns null', async () => {
      updateMock.mockResolvedValue(null);

      const result = await service.updateCar(TEST_CAR_1);

      expect(result).toBeNull();
    });
  });

  describe('deleteCar', () => {
    it('given an existing car when deleteCar then delegates to the repository and returns its id', async () => {
      deleteMock.mockResolvedValue({ id: TEST_CAR_1.id });

      const result = await service.deleteCar(TEST_CAR_1.id);

      expect(deleteMock).toHaveBeenCalledTimes(1);
      expect(deleteMock).toHaveBeenCalledWith(TEST_CAR_1.id);
      expect(result).toEqual({ id: TEST_CAR_1.id });
    });

    it('given a non-existing car when deleteCar then returns null', async () => {
      deleteMock.mockResolvedValue(null);

      const result = await service.deleteCar(TEST_CAR_1.id);

      expect(result).toBeNull();
    });
  });
});
