import '../test-setup';
import { Test, TestingModule } from '@nestjs/testing';
import { CarsService } from './cars.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';

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

describe('CarsService (integration)', () => {
  let service: CarsService;
  let prisma: PrismaService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [PrismaModule],
      providers: [CarsService],
    }).compile();

    service = module.get<CarsService>(CarsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    await prisma.car.deleteMany();
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
