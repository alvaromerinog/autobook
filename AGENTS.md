# AGENTS.md

## Project Overview

**autobook** is a car maintenance records app. It is structured as a monorepo with two independent subprojects:

| Directory    | Technology          | Purpose                        |
|-------------|---------------------|--------------------------------|
| `backend/`  | NestJS + TypeScript | REST API server                |
| `frontend/` | Flutter + Dart      | Mobile/web/desktop client app  |

## Navigation

- Editing API endpoints, services, or backend logic → see [`backend/AGENTS.md`](backend/AGENTS.md)
- Editing UI screens, widgets, providers, or models → see [`frontend/AGENTS.md`](frontend/AGENTS.md)

Each subproject has its own dependencies, toolchain, and workflows. Always `cd` into the relevant directory before running commands.

## Documentation

When looking up library APIs, configuration options, or version-specific behavior, use Context7 if available (`/find-docs`). Prefer it over training knowledge for any library, as APIs change between versions.

## Repository Structure

```
autobook/
├── backend/          # NestJS REST API
└── frontend/         # Flutter application
```