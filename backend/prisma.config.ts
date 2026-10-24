import 'dotenv/config';
import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    // Falls back to the local dev database, mirroring the runtime default in
    // src/prisma/infrastructure/prisma.database.ts. Set DATABASE_URL (or add
    // a .env file) to point the CLI somewhere else.
    url: process.env.DATABASE_URL ?? 'file:./dev.db',
  },
});
