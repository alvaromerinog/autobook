import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { PrismaDatabase } from '../src/prisma/infrastructure/prisma.database';
import { randomUUID } from 'crypto';
import { unlinkSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';
import { applyMigrations } from '../src/test-utils/apply-migrations';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaDatabase;
  let dbPath: string;

  beforeEach(async () => {
    dbPath = join(tmpdir(), `autobook-e2e-app-${randomUUID()}.db`);
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

  it('/cars (GET)', () => {
    return request(app.getHttpServer())
      .get('/cars')
      .expect(200)
      .expect((res: { body: { cars?: unknown } }) => {
        expect(res.body).toHaveProperty('cars');
        expect(res.body.cars).toEqual([]);
      });
  });
});
