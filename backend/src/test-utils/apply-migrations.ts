import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import Database from 'better-sqlite3';

export const MIGRATIONS_DIR = join(process.cwd(), 'prisma/migrations');

export function applyMigrations(dbPath: string): void {
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
