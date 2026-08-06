# Plan: Alinear app.e2e-spec.ts al patrón de DB temporal

PRD: comentario [Major 1] de la PR — `tests/app.e2e-spec.ts › GET /cars` falla con 500 porque usa el `file:./dev.db` local (sin `deletedAt`) en lugar de migrar una DB temporal.

## Objetivo

Convertir `backend/tests/app.e2e-spec.ts` al patrón de base de datos temporal + `applyMigrations()` que ya usa `backend/tests/cars.e2e-spec.ts`, para que no dependa del estado del `dev.db` local gitignoreado yRightarrow 500 por esquema desfasado.

## Ficheros afectados

- `backend/tests/app.e2e-spec.ts` — único fichero a modificar.

No se tocarán: `prisma.database.ts` (el fallback `file:./dev.db` se mantiene para `start:dev` y entornos no-test), `cars.e2e-spec.ts` (es el patrón de referencia), ni `apply-migrations.ts` (ya existe y se reutiliza).

## Pasos

- [x] **1. Importar utilidades de DB temporal** — `backend/tests/app.e2e-spec.ts` — añadir imports de `randomUUID` (`crypto`), `unlinkSync`/`existsSync` (`fs`), `join` (`path`), `tmpdir` (`os`) y `applyMigrations` (`../src/test-utils/apply-migrations`). Criterio: `pnpm build` sin errores de resolución de módulos; `pnpm lint` limpio.
- [x] **2. Añadir variables de fixture** — `backend/tests/app.e2e-spec.ts` — declarar `let prisma: PrismaDatabase;` y `let dbPath: string;` en el bloque `describe`, e importar `PrismaDatabase` (`../src/prisma/infrastructure/prisma.database`). Criterio: tipado correcto (compila con `pnpm build`).
- [x] **3. Crear y migrar DB temporal en `beforeEach`** — `backend/tests/app.e2e-spec.ts` — al inicio del `beforeEach`: `dbPath = join(tmpdir(), \`autobook-e2e-app-${randomUUID()}.db\`); applyMigrations(dbPath); process.env.DATABASE_URL = \`file:${dbPath}\`;` antes de `Test.createTestingModule`. Recuperar `prisma` del módulo con `moduleFixture.get<PrismaDatabase>(PrismaDatabase)` tras compilar. Criterio: el `AppModule` instanciado apunta a la DB temporal recién migrada (con columna `deletedAt`).
- [x] **4. Añadir `afterEach` de limpieza** — `backend/tests/app.e2e-spec.ts` — tras el `beforeEach`, añadir `afterEach` que haga `await prisma.$disconnect(); await app.close(); if (existsSync(dbPath)) unlinkSync(dbPath);`. Criterio: no quedan `.db` residuales en `tmpdir()` tras ejecutar la suite; Robo aislamiento entre tests.
- [x] **5. Ajustar el test `/cars (GET)`** — `backend/tests/app.e2e-spec.ts` — mantener la aserción de 200 + `cars` array, pero ahora la DB está vacía y migrada (sin `dev.db` heredado). Verificación: el array `cars` debe ser `[]` (no hay seed). Criterio: el test espera `body.cars` como array vacío además de `toHaveProperty('cars')` (opcional: `expect(res.body.cars).toEqual([])`).
- [x] **6. Ejecutar la suite completa** — desde `backend/`: `pnpm test:e2e` — Criterio: las 9 pruebas pasan (1 de `app.e2e-spec.ts` + 8 de `cars.e2e-spec.ts`), sin 500 ni errores de columna `deletedAt`.

## Tests a añadir o modificar

- **Modificado**: `backend/tests/app.e2e-spec.ts › AppController (e2e) › /cars (GET)` — ahora corre contra DB temporal migrada; se mantiene la aserción de 200/`cars` array y se añade expectativa de array vacío (DB sin seed).

No se añaden tests nuevos: el scope es puramente arreglar el fallo del hepático existente, no ampliar cobertura.

## Dudas o riesgos

- **`process.env.DATABASE_URL` global**: `cars.e2e-spec.ts` y `app.e2e-spec.ts` mutan `process.env.DATABASE_URL` en `beforeEach`. Hoy Jest ejecuta los ficheros secuenciales por defecto (no paralelo dentro de un fichero, pero sí entre ficheros de la misma suite e2e con `--maxWorkers`). Si ambos specs corriesen en paralelo en el mismo worker, el segundo pisaría la variable del primero. **Riesgo mitigado**: el `replace(/^file:/, '')` y la creación del `PrismaClient` ocurren **dentro** del `beforeEach` (antes del `app.init()`), por lo que cada instancia de módulo captura su propio path. Jest e2e aquí corre con `testEnvironment: node` y sin `--maxWorkers` explícito en `jest-e2e.json`, por lo que los ficheros se ejecutan en procesos separados → sin colisión. Mismo comportamiento que ya tiene `cars.e2e-spec.ts`.
- **El nombre del fichero DB incluye sufijo `-app-`** para evitar colisión nominal con los `.db` que crea `cars.e2e-spec.ts` (ambos en `tmpdir()`), aunque el `randomUUID()` ya garantiza unicidad; es solo legibilidad al depurar.
- No se modifica `prisma.database.ts`: el fallback `file:./dev.db` sigue siendo válido para `pnpm start:dev`. La corrección es exclusivamente de测试 ergonomía — los tests no deben depender del estado de `dev.db`.