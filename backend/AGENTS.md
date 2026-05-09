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

`PrismaService` strips the `file:` prefix and passes the path to `PrismaBetterSqlite3`. The Prisma CLI reads the URL from `prisma.config.ts`.

## Database

Prisma v7 separates the datasource URL from the schema:

- **Schema** (`prisma/schema.prisma`): defines models only — no `url` in the `datasource` block
- **CLI config** (`prisma.config.ts`): provides the URL to the Prisma CLI for migrations
- **Runtime** (`PrismaService`): creates a `PrismaBetterSqlite3` adapter and passes it to the `PrismaClient` constructor

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

- Test files live in `src/` and follow the `*.spec.ts` naming convention, colocated with the source file they test.
- `src/test-setup.ts` is loaded via Jest `setupFiles` and injects `env/test.env` into `process.env` before any module is instantiated.
- Integration tests use the real SQLite database and clean relevant tables in `beforeEach`.
- Test descriptions follow the format: **given** {state} **when** {function} **then** {expected result}.

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
└── test.env                  # Environment variables for tests
prisma/
├── schema.prisma             # Data models (no URL — managed via prisma.config.ts)
└── migrations/               # Migration history
prisma.config.ts              # Prisma CLI config (datasource URL, schema path)
src/
├── app.module.ts             # Root module
├── app.controller.ts         # Root controller
├── app.service.ts            # Root service
├── main.ts                   # Entry point (bootstrap)
├── test-setup.ts             # Jest setup: loads env/test.env
├── prisma/
│   ├── prisma.module.ts      # Global Prisma module
│   └── prisma.service.ts     # PrismaClient wrapper with better-sqlite3 adapter
└── cars/
    ├── cars.module.ts        # Cars feature module
    ├── cars.controller.ts    # GET /cars
    ├── cars.service.ts       # Business logic + Car interface
    └── cars.service.spec.ts  # Integration tests
test/
└── jest-e2e.json             # e2e Jest configuration
```

New features should be added as NestJS modules under `src/<feature>/`.
