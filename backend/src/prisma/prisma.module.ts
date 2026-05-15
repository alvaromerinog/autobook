import { Global, Module } from '@nestjs/common';
import { PrismaDatabase } from './infrastructure/prisma.database';

@Global()
@Module({
  providers: [PrismaDatabase],
  exports: [PrismaDatabase],
})
export class PrismaModule {}
