import '../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { CarsService } from './cars.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync, readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import Database from 'better-sqlite3';

const TEST_CARS = [
  {
    id: '00000000-0000-0000-0000-000000000001',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2020,
    licensePlate: 'ABC-001',
    color: 'White',
    mileage: 30000,
  },
  {
    id: '00000000-0000-0000-0000-000000000002',
    brand: 'Honda',
    model: 'Civic',
    year: 2019,
    licensePlate: 'DEF-002',
    color: null,
    mileage: null,
  },
  {
    id: '00000000-0000-0000-0000-000000000003',
    brand: 'Ford',
    model: 'Focus',
    year: 2021,
    licensePlate: 'GHI-003',
    color: 'Blue',
    mileage: 15000,
  },
];

const MIGRATIONS_DIR = join(__dirname, '../../prisma/migrations');

function applyMigrations(dbPath: string): void {
  const db = new Database(dbPath);
  readdirSync(MIGRATIONS_DIR)
    .filter((entry) => entry !== 'migration_lock.toml')
    .sort()
    .forEach((dir) => {
      const sql = readFileSync(join(MIGRATIONS_DIR, dir, 'migration.sql'), 'utf8');
      db.exec(sql);
    });
  db.close();
}

describe('CarsService (integration)', () => {
  let service: CarsService;
  let prisma: PrismaService;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-test-${randomUUID()}.db`);
    applyMigrations(dbPath);
    process.env.DATABASE_URL = `file:${dbPath}`;

    const module: TestingModule = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [CarsService],
    }).compile();

    service = module.get<CarsService>(CarsService);
    prisma = module.get<PrismaService>(PrismaService);
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
    const sorted = [...cars].sort((a, b) => a.id.localeCompare(b.id));

    expect(sorted).toHaveLength(3);
    expect(sorted[0]).toMatchObject({ id: TEST_CARS[0].id, licensePlate: TEST_CARS[0].licensePlate });
    expect(sorted[1]).toMatchObject({ id: TEST_CARS[1].id, licensePlate: TEST_CARS[1].licensePlate });
    expect(sorted[2]).toMatchObject({ id: TEST_CARS[2].id, licensePlate: TEST_CARS[2].licensePlate });
  });
});
