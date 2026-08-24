import '../../../../test-setup';
import { NotFoundException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaModule } from '../../../../prisma/prisma.module';
import { PrismaDatabase } from '../../../../prisma/infrastructure/prisma.database';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { MaintenancesService } from '../../../application/maintenances.service';
import { MaintenancesRepository } from '../../../domain/repositories/maintenances.repository';
import { PrismaMaintenancesRepository } from '../../../infrastructure/repositories/maintenances.repository';
import { applyMigrations } from '../../../../test-utils/apply-migrations';
import {
  MAINTENANCES_CAR_ID,
  TEST_MAINTENANCES,
} from '../../fixtures/maintenances.fixtures';
import { TEST_CARS } from '../../../../cars/tests/fixtures/cars.fixtures';
import { MaintenanceConflictError } from '../../../domain/errors/maintenance-conflict.error';

const PARENT_CAR = TEST_CARS.find((c) => c.id === MAINTENANCES_CAR_ID)!;

describe('MaintenancesService (integration)', () => {
  let service: MaintenancesService;
  let prisma: PrismaDatabase;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-maint-test-${randomUUID()}.db`);
    applyMigrations(dbPath);
    process.env.DATABASE_URL = `file:${dbPath}`;

    const module: TestingModule = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [
        MaintenancesService,
        {
          provide: MaintenancesRepository,
          useClass: PrismaMaintenancesRepository,
        },
      ],
    }).compile();

    service = module.get<MaintenancesService>(MaintenancesService);
    prisma = module.get<PrismaDatabase>(PrismaDatabase);
    await prisma.car.create({ data: PARENT_CAR });
  });

  afterEach(async () => {
    await prisma.$disconnect();
    if (existsSync(dbPath)) unlinkSync(dbPath);
  });

  it('given no maintenances when getForCar then returns an empty list', async () => {
    const { maintenances } = await service.getForCar(MAINTENANCES_CAR_ID);

    expect(maintenances).toEqual([]);
  });

  it('given three maintenances when getForCar then returns them sorted by date desc', async () => {
    await prisma.maintenance.createMany({ data: TEST_MAINTENANCES });

    const { maintenances } = await service.getForCar(MAINTENANCES_CAR_ID);

    expect(maintenances).toHaveLength(3);
    expect(maintenances[0].id).toBe(TEST_MAINTENANCES[0].id);
    expect(maintenances[2].id).toBe(TEST_MAINTENANCES[2].id);
  });

  it('given a maintenance when getOne then returns it', async () => {
    await prisma.maintenance.create({ data: TEST_MAINTENANCES[0] });

    const result = await service.getOne(
      TEST_MAINTENANCES[0].id,
      MAINTENANCES_CAR_ID,
    );

    expect(result).toMatchObject({ id: TEST_MAINTENANCES[0].id });
  });

  it('given a missing maintenance when getOne then returns null', async () => {
    const result = await service.getOne(
      TEST_MAINTENANCES[0].id,
      MAINTENANCES_CAR_ID,
    );

    expect(result).toBeNull();
  });

  it('given a non-existing parent car when getForCar then throws NotFoundException', async () => {
    await expect(service.getForCar('no-such-car')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('given valid data when create then persists and returns it', async () => {
    const created = await service.create(TEST_MAINTENANCES[0]);

    expect(created).toMatchObject({ type: 'oil', cost: 145.2 });
    const persisted = await prisma.maintenance.findUnique({
      where: { id: TEST_MAINTENANCES[0].id },
    });
    expect(persisted).not.toBeNull();
  });

  it('given an existing id when create then throws MaintenanceConflictError', async () => {
    await service.create(TEST_MAINTENANCES[0]);

    await expect(service.create(TEST_MAINTENANCES[0])).rejects.toThrow(
      MaintenanceConflictError,
    );
  });

  it('given an existing maintenance when update then returns the id and persists', async () => {
    await prisma.maintenance.create({ data: TEST_MAINTENANCES[0] });
    const updated = { ...TEST_MAINTENANCES[0], cost: 200.5 };

    const result = await service.update(updated);

    expect(result).toEqual({ id: updated.id });
    const persisted = await prisma.maintenance.findUnique({
      where: { id: updated.id },
    });
    expect(persisted!.cost).toBe(200.5);
  });

  it('given a missing maintenance when update then returns null', async () => {
    const result = await service.update(TEST_MAINTENANCES[0]);

    expect(result).toBeNull();
  });

  it('given an existing maintenance when delete then returns the id and sets deletedAt', async () => {
    await prisma.maintenance.create({ data: TEST_MAINTENANCES[0] });

    const result = await service.delete(
      TEST_MAINTENANCES[0].id,
      MAINTENANCES_CAR_ID,
    );

    expect(result).toEqual({ id: TEST_MAINTENANCES[0].id });
    const persisted = await prisma.maintenance.findUnique({
      where: { id: TEST_MAINTENANCES[0].id },
    });
    expect(persisted!.deletedAt).not.toBeNull();
  });

  it('given an already soft-deleted maintenance when delete then returns null', async () => {
    await prisma.maintenance.create({ data: TEST_MAINTENANCES[0] });
    await service.delete(TEST_MAINTENANCES[0].id, MAINTENANCES_CAR_ID);

    const result = await service.delete(
      TEST_MAINTENANCES[0].id,
      MAINTENANCES_CAR_ID,
    );

    expect(result).toBeNull();
  });

  it('given a soft-deleted maintenance when getForCar then it is not listed', async () => {
    await prisma.maintenance.create({ data: TEST_MAINTENANCES[0] });
    await service.delete(TEST_MAINTENANCES[0].id, MAINTENANCES_CAR_ID);

    const { maintenances } = await service.getForCar(MAINTENANCES_CAR_ID);

    expect(maintenances).toEqual([]);
  });
});
