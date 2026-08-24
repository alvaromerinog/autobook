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
import {
  MAINTENANCES_CAR_ID,
  TEST_MAINTENANCES,
} from '../src/maintenances/tests/fixtures/maintenances.fixtures';

const PARENT_CAR = TEST_CARS.find((c) => c.id === MAINTENANCES_CAR_ID)!;
const [M1] = TEST_MAINTENANCES;

describe('MaintenancesController (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaDatabase;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-maint-e2e-${randomUUID()}.db`);
    applyMigrations(dbPath);
    process.env.DATABASE_URL = `file:${dbPath}`;

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    prisma = moduleFixture.get<PrismaDatabase>(PrismaDatabase);
    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    await app.init();
    await prisma.car.create({ data: PARENT_CAR });
  });

  afterEach(async () => {
    await prisma.$disconnect();
    await app.close();
    if (existsSync(dbPath)) unlinkSync(dbPath);
  });

  describe('POST /cars/:carId/maintenances', () => {
    it('given valid data when POST then returns 201 and the new id', () => {
      return request(app.getHttpServer())
        .post(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .send(M1)
        .expect(201)
        .expect((res: { body: { id: string } }) => {
          expect(res.body.id).toBe(M1.id);
        });
    });

    it('given a created maintenance when GET list then it appears', async () => {
      await request(app.getHttpServer())
        .post(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .send(M1)
        .expect(201);

      const response = await request(app.getHttpServer())
        .get(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .expect(200);

      const body = response.body as {
        maintenances: Array<{ id: string; deletedAt?: Date }>;
      };
      expect(body.maintenances).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ id: M1.id }),
        ]),
      );
      const m = body.maintenances.find((x) => x.id === M1.id);
      expect(m).not.toHaveProperty('deletedAt');
    });

    it('given a non-existing car when POST then returns 404', () => {
      return request(app.getHttpServer())
        .post('/cars/no-such-car/maintenances')
        .send({ ...M1, carId: 'no-such-car' })
        .expect(404);
    });

    it('given an existing id when POST then returns 409', async () => {
      await prisma.maintenance.create({ data: M1 });

      return request(app.getHttpServer())
        .post(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .send(M1)
        .expect(409);
    });
  });

  describe('GET /cars/:carId/maintenances/:id', () => {
    it('given an existing maintenance when GET then returns it', async () => {
      await prisma.maintenance.create({ data: M1 });

      return request(app.getHttpServer())
        .get(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .expect(200)
        .expect((res: { body: { id: string } }) => {
          expect(res.body.id).toBe(M1.id);
        });
    });

    it('given a missing maintenance when GET then returns 404', () => {
      return request(app.getHttpServer())
        .get(`/cars/${MAINTENANCES_CAR_ID}/maintenances/missing`)
        .expect(404);
    });
  });

  describe('PUT /cars/:carId/maintenances/:id', () => {
    it('given an existing maintenance when PUT then returns 200 and the id', async () => {
      await prisma.maintenance.create({ data: M1 });

      return request(app.getHttpServer())
        .put(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .send({ ...M1, cost: 200 })
        .expect(200)
        .expect((res: { body: { id: string } }) => {
          expect(res.body.id).toBe(M1.id);
        });
    });

    it('given a missing maintenance when PUT then returns 404', () => {
      return request(app.getHttpServer())
        .put(`/cars/${MAINTENANCES_CAR_ID}/maintenances/missing`)
        .send(M1)
        .expect(404);
    });

    it('given a soft-deleted maintenance when PUT then returns 404', async () => {
      await prisma.maintenance.create({ data: M1 });
      await request(app.getHttpServer())
        .delete(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .expect(204);

      return request(app.getHttpServer())
        .put(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .send(M1)
        .expect(404);
    });
  });

  describe('DELETE /cars/:carId/maintenances/:id', () => {
    it('given an existing maintenance when DELETE then returns 204 and it is no longer listed', async () => {
      await prisma.maintenance.create({ data: M1 });

      await request(app.getHttpServer())
        .delete(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .expect(204);

      const response = await request(app.getHttpServer())
        .get(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .expect(200);
      const body = response.body as { maintenances: Array<{ id: string }> };
      expect(body.maintenances).toHaveLength(0);
    });

    it('given a missing maintenance when DELETE then returns 404', () => {
      return request(app.getHttpServer())
        .delete(`/cars/${MAINTENANCES_CAR_ID}/maintenances/missing`)
        .expect(404);
    });

    it('given an already deleted maintenance when DELETE then returns 404', async () => {
      await prisma.maintenance.create({ data: M1 });
      await request(app.getHttpServer())
        .delete(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .expect(204);

      return request(app.getHttpServer())
        .delete(`/cars/${MAINTENANCES_CAR_ID}/maintenances/${M1.id}`)
        .expect(404);
    });
  });

  describe('POST /cars with invalid type', () => {
    it('given an unknown type when POST then returns 400', () => {
      return request(app.getHttpServer())
        .post(`/cars/${MAINTENANCES_CAR_ID}/maintenances`)
        .send({ ...M1, type: 'wiper' })
        .expect(400);
    });
  });
});