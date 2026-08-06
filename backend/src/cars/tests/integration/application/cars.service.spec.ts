import '../../../../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { CarsService } from '../../../application/cars.service';
import { PrismaModule } from '../../../../prisma/prisma.module';
import { PrismaDatabase } from '../../../../prisma/infrastructure/prisma.database';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { CarsRepository } from '../../../domain/repositories/cars.repository';
import { PrismaCarsRepository } from '../../../infrastructure/repositories/cars.repository';
import { applyMigrations } from '../../../../test-utils/apply-migrations';
import { TEST_CARS } from '../../fixtures/cars.fixtures';
import { Car } from '@prisma/client';
import { CarConflictError } from '../../../domain/errors/car-conflict.error';

describe('CarsService (integration)', () => {
  let service: CarsService;
  let prisma: PrismaDatabase;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-test-${randomUUID()}.db`);
    applyMigrations(dbPath);
    process.env.DATABASE_URL = `file:${dbPath}`;

    const module: TestingModule = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [
        CarsService,
        { provide: CarsRepository, useClass: PrismaCarsRepository },
      ],
    }).compile();

    service = module.get<CarsService>(CarsService);
    prisma = module.get<PrismaDatabase>(PrismaDatabase);
  });

  afterEach(async () => {
    await prisma.$disconnect();
    if (existsSync(dbPath)) {
      unlinkSync(dbPath);
    }
  });

  it('given no cars in the database when getCars then returns an empty list', async () => {
    const { cars } = await service.getCars();

    expect(cars).toEqual([]);
  });

  it('given three cars inserted with known id and licensePlate when getCars then returns a list where each car id and licensePlate match the inserted values', async () => {
    await prisma.car.createMany({ data: TEST_CARS });

    const { cars } = await service.getCars();

    expect(cars).toHaveLength(3);
    expect(cars).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: TEST_CARS[0].id,
          licensePlate: TEST_CARS[0].licensePlate,
        }),
        expect.objectContaining({
          id: TEST_CARS[1].id,
          licensePlate: TEST_CARS[1].licensePlate,
        }),
        expect.objectContaining({
          id: TEST_CARS[2].id,
          licensePlate: TEST_CARS[2].licensePlate,
        }),
      ]),
    );
  });

  it('given a car exists when updateCar then returns the id and persists the new values', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    const updated = { ...TEST_CARS[0], color: 'Red', mileage: 50000 };

    const result = await service.updateCar(updated);

    expect(result).toEqual({ id: TEST_CARS[0].id });
    const car = await prisma.car.findUnique({ where: { id: TEST_CARS[0].id } });
    expect(car).toMatchObject({ color: 'Red', mileage: 50000 });
  });

  it('given an existing active car when updateCar with a deletedAt value in the input then the persisted deletedAt remains null', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    const stale = {
      ...TEST_CARS[0],
      deletedAt: new Date('2026-01-01T00:00:00.000Z'),
    };

    const result = await service.updateCar(stale);

    expect(result).toEqual({ id: TEST_CARS[0].id });
    const persisted = await prisma.car.findUnique({
      where: { id: TEST_CARS[0].id },
    });
    expect(persisted!.deletedAt).toBeNull();
  });

  it('given no car with the given id when updateCar then returns null', async () => {
    const result = await service.updateCar(TEST_CARS[0]);

    expect(result).toBeNull();
  });

  it('given not existing car and valid car data when createCar then persists and returns the created car', async () => {
    const previous = await prisma.car.findUnique({
      where: { id: TEST_CARS[0].id },
    });
    expect(previous).toBeNull();

    const car = await service.createCar(TEST_CARS[0]);

    expect(car).toMatchObject({
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
    });
    const persisted = await prisma.car.findUnique({ where: { id: car.id } });
    expect(persisted).toMatchObject({ brand: 'Toyota', model: 'Corolla' });
  });

  it('given car data with null optional fields when createCar then persists null values', async () => {
    const car = await service.createCar(TEST_CARS[1]);

    expect(car.color).toBeNull();
    expect(car.mileage).toBeNull();
    const persisted = await prisma.car.findUnique({ where: { id: car.id } });
    expect(persisted!.color).toBeNull();
    expect(persisted!.mileage).toBeNull();
  });

  it('given car data without required fields when createCar then throws an error', async () => {
    const invalidCar = {
      ...TEST_CARS[0],
      brand: undefined,
    } as unknown as Car;

    await expect(service.createCar(invalidCar)).rejects.toThrow();
  });

  it('given an existing car when deleteCar then returns its id and the row persists with deletedAt set', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });

    const result = await service.deleteCar(TEST_CARS[0].id);

    expect(result).toEqual({ id: TEST_CARS[0].id });
    const persisted = await prisma.car.findUnique({
      where: { id: TEST_CARS[0].id },
    });
    expect(persisted).not.toBeNull();
    expect(persisted!.deletedAt).not.toBeNull();
  });

  it('given a non-existing car id when deleteCar then returns null', async () => {
    const result = await service.deleteCar(TEST_CARS[0].id);

    expect(result).toBeNull();
  });

  it('given an already soft-deleted car when deleteCar then returns null', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    await service.deleteCar(TEST_CARS[0].id);

    const result = await service.deleteCar(TEST_CARS[0].id);

    expect(result).toBeNull();
  });

  it('given two cars with one soft-deleted when getCars then returns only the active car', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    await prisma.car.create({ data: TEST_CARS[1] });
    await service.deleteCar(TEST_CARS[0].id);

    const { cars } = await service.getCars();

    expect(cars).toHaveLength(1);
    expect(cars[0].id).toBe(TEST_CARS[1].id);
  });

  it('given a soft-deleted car when updateCar then returns null', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    await service.deleteCar(TEST_CARS[0].id);

    const result = await service.updateCar(TEST_CARS[0]);

    expect(result).toBeNull();
  });

  it('given a soft-deleted car id when createCar then throws CarConflictError', async () => {
    await prisma.car.create({ data: TEST_CARS[0] });
    await service.deleteCar(TEST_CARS[0].id);

    await expect(service.createCar(TEST_CARS[0])).rejects.toThrow(
      CarConflictError,
    );
  });
});
