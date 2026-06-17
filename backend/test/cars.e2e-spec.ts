import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaDatabase } from '../src/prisma/infrastructure/prisma.database';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { applyMigrations } from '../src/test-utils/apply-migrations';
import { TEST_CARS } from '../src/cars/tests/fixtures/cars.fixtures';

const [CAR_PAYLOAD] = TEST_CARS;

describe('CarsController (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaDatabase;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-e2e-${randomUUID()}.db`);
    applyMigrations(dbPath);
    process.env.DATABASE_URL = `file:${dbPath}`;

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    prisma = moduleFixture.get<PrismaDatabase>(PrismaDatabase);
    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true }));
    await app.init();
  });

  afterEach(async () => {
    await prisma.$disconnect();
    await app.close();
    if (existsSync(dbPath)) {
      unlinkSync(dbPath);
    }
  });

  describe('POST /cars', () => {
    it('given valid car data when POST /cars then returns 201 and the new car id', () => {
      return request(app.getHttpServer())
        .post('/cars')
        .send(CAR_PAYLOAD)
        .expect(201)
        .expect((res: { body: { id: string } }) => {
          expect(res.body.id).toBe(CAR_PAYLOAD.id);
        });
    });

    it('given a created car when GET /cars then the new car appears in the list', async () => {
      await request(app.getHttpServer())
        .post('/cars')
        .send(CAR_PAYLOAD)
        .expect(201);

      const response = await request(app.getHttpServer())
        .get('/cars')
        .expect(200);

      const body = response.body as { cars: Array<{ id: string }> };
      expect(body.cars).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ id: CAR_PAYLOAD.id }),
        ]),
      );
    });

    it('given an existing car with the same id when POST /cars then returns 409', async () => {
      await prisma.car.create({ data: CAR_PAYLOAD });

      return request(app.getHttpServer())
        .post('/cars')
        .send(CAR_PAYLOAD)
        .expect(409);
    });
  });
});
