import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaBetterSqlite3 } from '@prisma/adapter-better-sqlite3';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaDatabase extends PrismaClient implements OnModuleInit {
  constructor() {
    const url = (process.env.DATABASE_URL ?? 'file:./dev.db').replace(/^file:/, '');
    const adapter = new PrismaBetterSqlite3({ url });
    super({ adapter });
  }

  async onModuleInit() {
    await this.$connect();
  }
}
