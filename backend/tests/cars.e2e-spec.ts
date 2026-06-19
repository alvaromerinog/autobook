import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaDatabase } from '../src/prisma/infrastructure/prisma.database';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync, readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import Database from 'better-sqlite3';

const CAR_PAYLOAD = {
  id: 'a0000000-0000-0000-0000-000000000001',
  brand: 'Toyota',
  model: 'Corolla',
  year: 2020,
  licensePlate: 'ABC-001',
  color: 'White',
  mileage: 30000,
};

const MIGRATIONS_DIR = join(__dirname, '../prisma/migrations');

function applyMigrations(dbPath: string): void {
  const db = new Database(dbPath);
  readdirSync(MIGRATIONS_DIR)
    .filter((entry) => entry !== 'migration_lock.toml')
    .sort()
    .forEach((dir) => {
      const sql = readFileSync(
        join(MIGRATIONS_DIR, dir, 'migration.sql'),
        'utf8',
      );
      db.exec(sql);
    });
  db.close();
}

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
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
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

      expect(response.body.cars).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ id: CAR_PAYLOAD.id }),
        ]),
      );
    });
  });
});
