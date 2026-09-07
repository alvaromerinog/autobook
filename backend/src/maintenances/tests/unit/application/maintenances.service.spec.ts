import '../../../../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { MaintenancesService } from '../../../application/maintenances.service';
import { MaintenancesRepository } from '../../../domain/repositories/maintenances.repository';
import {
  MAINTENANCES_CAR_ID,
  TEST_MAINTENANCES,
} from '../../fixtures/maintenances.fixtures';

const [M1, M2, M3] = TEST_MAINTENANCES;

describe('MaintenancesService (unit)', () => {
  let service: MaintenancesService;
  let getAllMock: jest.MockedFunction<MaintenancesRepository['getAll']>;
  let getOneMock: jest.MockedFunction<MaintenancesRepository['getOne']>;
  let createMock: jest.MockedFunction<MaintenancesRepository['create']>;
  let updateMock: jest.MockedFunction<MaintenancesRepository['update']>;
  let deleteMock: jest.MockedFunction<MaintenancesRepository['delete']>;

  beforeEach(async () => {
    getAllMock = jest.fn();
    getOneMock = jest.fn();
    createMock = jest.fn();
    updateMock = jest.fn();
    deleteMock = jest.fn();

    const mockRepository: jest.Mocked<MaintenancesRepository> = {
      getAll: getAllMock,
      getOne: getOneMock,
      create: createMock,
      update: updateMock,
      delete: deleteMock,
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MaintenancesService,
        { provide: MaintenancesRepository, useValue: mockRepository },
      ],
    }).compile();

    service = module.get<MaintenancesService>(MaintenancesService);
  });

  describe('getForCar', () => {
    it('given an empty repository when getForCar then returns an empty list', async () => {
      getAllMock.mockResolvedValue([]);

      const result = await service.getForCar(MAINTENANCES_CAR_ID);

      expect(result).toEqual({ maintenances: [] });
    });

    it('given three maintenances when getForCar then returns all unchanged', async () => {
      getAllMock.mockResolvedValue([M1, M2, M3]);

      const result = await service.getForCar(MAINTENANCES_CAR_ID);

      expect(result).toEqual({ maintenances: [M1, M2, M3] });
      expect(getAllMock).toHaveBeenCalledWith(MAINTENANCES_CAR_ID);
    });
  });

  describe('getOne', () => {
    it('given an existing maintenance when getOne then returns it', async () => {
      getOneMock.mockResolvedValue(M1);

      const result = await service.getOne(M1.id, MAINTENANCES_CAR_ID);

      expect(result).toEqual(M1);
      expect(getOneMock).toHaveBeenCalledWith(M1.id, MAINTENANCES_CAR_ID);
    });

    it('given a missing maintenance when getOne then returns null', async () => {
      getOneMock.mockResolvedValue(null);

      const result = await service.getOne(M1.id, MAINTENANCES_CAR_ID);

      expect(result).toBeNull();
    });
  });

  describe('create', () => {
    it('given valid data when create then delegates to the repository', async () => {
      createMock.mockResolvedValue(M1);

      const result = await service.create(M1);

      expect(createMock).toHaveBeenCalledTimes(1);
      expect(createMock).toHaveBeenCalledWith(M1);
      expect(result).toEqual(M1);
    });
  });

  describe('update', () => {
    it('given an existing maintenance when update then returns its id', async () => {
      updateMock.mockResolvedValue({ id: M1.id });

      const result = await service.update(M1);

      expect(result).toEqual({ id: M1.id });
    });

    it('given a missing maintenance when update then returns null', async () => {
      updateMock.mockResolvedValue(null);

      const result = await service.update(M1);

      expect(result).toBeNull();
    });
  });

  describe('delete', () => {
    it('given an existing maintenance when delete then returns its id', async () => {
      deleteMock.mockResolvedValue({ id: M1.id });

      const result = await service.delete(M1.id, MAINTENANCES_CAR_ID);

      expect(deleteMock).toHaveBeenCalledWith(M1.id, MAINTENANCES_CAR_ID);
      expect(result).toEqual({ id: M1.id });
    });

    it('given a missing maintenance when delete then returns null', async () => {
      deleteMock.mockResolvedValue(null);

      const result = await service.delete(M1.id, MAINTENANCES_CAR_ID);

      expect(result).toBeNull();
    });
  });
});
