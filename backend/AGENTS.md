# AGENTS.md — Backend

NestJS REST API for autobook. All commands must be run from the `backend/` directory.

## Tech Stack

- **Framework**: NestJS v11
- **Language**: TypeScript 5
- **Package manager**: pnpm
- **ORM**: Prisma v7 (`prisma-client-js` generator)
- **Database**: SQLite via `better-sqlite3` + `@prisma/adapter-better-sqlite3`
- **Test runner**: Jest (via `ts-jest`)
- **Linter**: ESLint (typescript-eslint + prettier)
- **Formatter**: Prettier

## Setup

```bash
pnpm install
pnpm exec prisma generate   # Generate Prisma client
pnpm exec prisma migrate dev  # Apply migrations (requires DATABASE_URL in env)
```

## Development

```bash
pnpm start:dev      # Start with hot-reload (watch mode)
pnpm start:debug    # Start with debugger + hot-reload
pnpm start          # Start once (no reload)
```

Server runs on `http://localhost:3000` by default.

## Environment

Environment files live in `env/`:

| File          | Purpose                  |
|---------------|--------------------------|
| `env/test.env` | Loaded automatically by Jest during tests |

The `DATABASE_URL` variable uses the SQLite file URI format: `file:./dev.db`.

The Prisma database wrapper (`src/prisma/infrastructure/prisma.database.ts`) strips the `file:` prefix and passes the path to `PrismaBetterSqlite3`. The Prisma CLI reads the URL from `prisma.config.ts`.

## Database

Prisma v7 separates the datasource URL from the schema:

- **Schema** (`prisma/schema.prisma`): defines models only — no `url` in the `datasource` block
- **CLI config** (`prisma.config.ts`): provides the URL to the Prisma CLI for migrations
- **Runtime** (`src/prisma/infrastructure/prisma.database.ts`): creates a `PrismaBetterSqlite3` adapter and passes it to the `PrismaClient` constructor

To create a new migration after changing the schema:
```bash
pnpm exec prisma migrate dev --name <migration-name>
```

## Testing

```bash
pnpm test           # Run all unit tests once
pnpm test:watch     # Run unit tests in watch mode
pnpm test:cov       # Run unit tests with coverage report (output: ../coverage/)
pnpm test:e2e       # Run end-to-end tests (config: test/jest-e2e.json)
```

- Test files live under a `tests/` folder inside the feature they cover, follow the `*.spec.ts` naming convention, and are grouped by test type. Each type mirrors the source layout — e.g. `src/cars/tests/integration/application/cars.service.spec.ts` tests `src/cars/application/cars.service.ts`.
- Three test types, by layer and isolation level:
  - **unit** (`tests/unit/`): tests for `domain/` and `application/` using mocks for any collaborators (no database, no HTTP).
  - **integration** (`tests/integration/`): tests for `application/` and `infrastructure/` using real repositories and the real SQLite database.
  - **e2e** (`tests/e2e/`): tests for the `api/` layer — exercise the HTTP endpoints end to end.
- `src/test-setup.ts` is loaded via Jest `setupFiles` and injects `env/test.env` into `process.env` before any module is instantiated.
- Integration and e2e tests use the real SQLite database and clean relevant tables in `beforeEach`.
- Test descriptions follow the format: **given** {state} **when** {function} **then** {expected result}.
- Each test is structured in three blocks: `given` (setup data and services), `when` (call to the function under test), and `then` (assertions). Lines within each block are grouped with no blank lines between them. Blocks are separated by a single blank line.

## Code Style

```bash
pnpm lint           # Lint and auto-fix TypeScript files in src/ and test/
pnpm format         # Format all TypeScript files with Prettier
```

- Follow NestJS module conventions: one module per feature folder
- Use decorators for dependency injection; avoid manual instantiation
- Keep controllers thin — business logic belongs in services
- Prettier config is in `.prettierrc`; ESLint config is in `eslint.config.mjs`

## Build

```bash
pnpm build          # Compile TypeScript to dist/ (clears output dir first)
pnpm start:prod     # Run the compiled production build
```

Output directory: `dist/`

## File Organization

```
env/
└── test.env                          # Environment variables for tests
prisma/
├── schema.prisma                     # Data models (no URL — managed via prisma.config.ts)
└── migrations/                       # Migration history
prisma.config.ts                      # Prisma CLI config (datasource URL, schema path)
src/
├── app.module.ts                     # Root module
├── main.ts                           # Entry point (bootstrap)
├── test-setup.ts                     # Jest setup: loads env/test.env
├── prisma/
│   ├── prisma.module.ts              # Global Prisma module
│   └── infrastructure/
│       └── prisma.database.ts        # PrismaClient wrapper with better-sqlite3 adapter
└── cars/                             # Cars feature (layered: api / application / domain / infrastructure)
    ├── cars.module.ts                # Cars feature module (wires controller, service, repository)
    ├── api/
    │   ├── cars.controller.ts        # HTTP layer — GET /cars, POST /cars, PUT /cars/:id, DELETE /cars/:id
    │   └── dto/
    │       ├── car.dto.ts            # Car request/response DTO (+ domain mappers)
    │       ├── getCarsResponse.dto.ts
    │       └── updateCarResponse.dto.ts
    ├── application/
    │   └── cars.service.ts           # Use cases — orchestrates the domain repository
    ├── domain/
    │   ├── entities/
    │   │   └── car.entity.ts         # Car domain model (interface)
    │   └── repositories/
    │       └── cars.repository.ts    # Repository contract (abstract class — DI token)
    ├── infrastructure/
    │   └── repositories/
    │       └── cars.repository.ts    # Prisma-backed CarsRepository implementation
    └── tests/                        # Feature tests, grouped by type, mirroring src layout
        ├── unit/                     # domain/ + application/ tests with mocks
        ├── integration/              # application/ + infrastructure/ tests with real repositories
        │   └── application/
        │       └── cars.service.spec.ts
        └── e2e/                      # api/ HTTP endpoint tests
test/
└── jest-e2e.json                     # e2e Jest configuration
```

New features should be added as NestJS modules under `src/<feature>/`, following the same `api / application / domain / infrastructure` layering: HTTP concerns and DTOs in `api/`, use cases in `application/`, entities and repository contracts in `domain/`, and concrete adapters (Prisma, etc.) in `infrastructure/`. The abstract repository class in `domain/repositories/` doubles as the DI token; bind it to its implementation in the feature module via `{ provide: XRepository, useClass: PrismaXRepository }`.
