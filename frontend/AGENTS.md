# AGENTS.md — Frontend

Flutter application for autobook. All commands must be run from the `frontend/` directory.

## Tech Stack

- **Framework**: Flutter (stable channel, managed via FVM)
- **Language**: Dart >=3.1.0
- **Architecture**: DDD + Hexagonal, feature-based folder structure
- **State management**: Riverpod (flutter_riverpod ^2.5.1) with code generation
- **Code generation**: riverpod_generator + freezed + json_serializable + retrofit_generator + drift_dev + build_runner
- **Linter**: flutter_lints + riverpod_lint + custom_lint
- **Local storage**: Drift (SQLite via drift_flutter)
- **HTTP**: Dio + Retrofit
- **Routing**: go_router
- **Connectivity**: connectivity_plus
- **Testing mocks**: mocktail
- **Other**: intl (i18n), uuid (only in `core/di/uuid_id_generator.dart`), freezed_annotation, json_annotation, shared_preferences

## Setup

```bash
fvm use stable      # Ensure correct Flutter version (defined in .fvmrc)
flutter pub get     # Install dependencies
```

If FVM is not installed: `dart pub global activate fvm`

## Development

```bash
flutter run                     # Run on connected device/emulator
flutter run -d chrome           # Run as web app
flutter run -d <device_id>      # Run on a specific device
flutter devices                 # List available devices
```

The API base URL is read from the `AUTOBOOK_API_URL` environment variable at build time:

```bash
flutter run --dart-define=AUTOBOOK_API_URL=http://localhost:3000
```

If the variable is not provided, it defaults to `http://localhost:3000`.

## Code Generation

After adding or modifying any annotated class (`@riverpod`, `@freezed`, `@RestApi`, `@DriftDatabase`), regenerate all output files:

```bash
dart run build_runner build --delete-conflicting-outputs     # One-shot generation
dart run build_runner watch --delete-conflicting-outputs     # Watch mode (during development)
```

Generated files (`*.g.dart`, `*.freezed.dart`) are **gitignored** — do not commit them. They are regenerated on each build or via the commands above.

## Testing

```bash
flutter test                    # Run all tests
flutter test test/path/to/file  # Run a specific test file
```

Test files live in `test/` mirroring the `lib/` structure: a file at `lib/a/b/foo.dart` has its test at `test/a/b/foo_test.dart`.

### Test conventions

- Structure every test body with `// given`, `// when`, `// then` comment blocks. Keep lines within each block together; separate blocks with one blank line.
- Group tests with `group()` — at minimum one top-level group per class, with nested groups per method (`getAll`, `create`, `syncPending`, etc.).
- Create a `setUp` that builds fresh mocks and the system-under-test; call `addTearDown(container.dispose)` immediately after creating any `ProviderContainer`.
- Use cases and repositories are tested by injecting mocks through their constructor (no `ProviderContainer` needed) — e.g. `CreateCarUseCase(mockRepo, mockIds)` with `MockCarRepository`/`MockIdGenerator` implementing the ports. Their tests live in `test/features/vehicles/domain/usecases/`.
- To test a notifier/provider whose graph depends on `ICarRepository`, override `carRepositoryProvider` in `ProviderContainer`:
  ```dart
  ProviderContainer(
    overrides: [
      carRepositoryProvider.overrideWithValue(mockCarRepository),
    ],
  )
  ```
- Register mocktail fallback values in `setUpAll` for every non-primitive type passed to `any()` or `captureAny()`.
- Assert on specific `Failure` subtypes (`isA<ServerFailure>()`, `isA<NetworkFailure>()`) rather than the base `Failure`.
- Verify mock interactions with `verify(() => mock.method()).called(n)` where the call count is meaningful.

## Code Style

```bash
flutter analyze         # Static analysis (uses analysis_options.yaml)
dart format lib/ test/  # Format Dart source files
```

- Use Riverpod for all state — avoid `setState` in favor of `ConsumerWidget` / `ConsumerStatefulWidget`
- Annotate providers with `@riverpod` or `@Riverpod(keepAlive: true)` and run build_runner to generate the `.g.dart` companion file
- The whole `domain/` layer is pure Dart — **no** imports of Flutter, Riverpod, `uuid`, Dio/Drift, or the `data/` layer. Entities and ports use only `freezed_annotation` (compile-time code-gen). Dependencies point inward only: `data → domain` and `presentation → domain`.
- Domain entities use `freezed` for value equality and `copyWith`; they carry no factories that pull in infrastructure (e.g. id generation goes through the `IdGenerator` port, see below)
- Maximum line length is 80 characters

### Variable naming

Name variables after what they contain, not their role in the flow:

- ✅ `cachedCars`, `remoteCars`, `pendingCars` — ❌ `current`, `data`, `result`
- ✅ `carEntry`, `carDto`, `car` — ❌ `decoded`, `c`, `item`
- ✅ `currentState` when holding a state record — ❌ `current`

### Errors

Domain failures are modelled as a `sealed class Failure` in `lib/core/error/failures.dart`:

```
sealed class Failure
├── NetworkFailure       — no connectivity or connection refused
├── ServerFailure(int statusCode)  — HTTP error from the backend
└── CacheFailure(String message)   — local storage error
```

The repository layer converts low-level exceptions (DioException, Drift errors) into `Failure` subtypes before rethrowing. Presentation code uses a `switch` on `Failure` to show user-friendly messages.

### Use cases & dependency wiring

- Use case classes (`GetCarsUseCase`, `CreateCarUseCase`, `RefreshCarsUseCase`, `SyncPendingCarsUseCase`, `HasPendingCarsUseCase`) live in `domain/usecases/` as **pure** Dart with a single `call()`; they depend only on ports (`ICarRepository`, `IdGenerator`) and carry **no** `@riverpod` annotation.
- The `@riverpod` functions that instantiate use cases with their concrete dependencies live in each feature's composition layer at `features/<feature>/presentation/providers/usecase_providers.dart` (currently `vehicles` and `maintenances`) — this is the only place in the feature that imports `data/` and `core/di/`.
- `CreateCarUseCase` takes a `CarDraft` (a pure record typedef of the form fields), assembles the `Car` with an id from the injected `IdGenerator`, persists it via the repository, and returns it. Screens collect raw input (`AddCarScreen` returns a `CarDraft`); they never build entities or generate ids.
- Presentation depends **only** on use case providers, never on `carRepositoryProvider` directly.

### IdGenerator port

- `IdGenerator` (`core/id/id_generator.dart`) is a pure-Dart port for producing unique ids.
- `UuidIdGenerator` (`core/di/uuid_id_generator.dart`) is its only adapter and the only file importing `package:uuid`; expose it via the `idGeneratorProvider` (`@Riverpod(keepAlive: true)`).

### Riverpod patterns

- Infrastructure providers in `core/di/` use `@Riverpod(keepAlive: true)`.
- Feature providers co-locate the `@riverpod`-annotated function or class with the implementation file (data-layer repository/datasource providers); use case providers are the exception and sit in `presentation/providers/` (see above).
- `AsyncNotifier` subclasses expose `build()` returning the initial state; side-effect methods (`add`, `syncPendingCars`) update `state` directly.
- Stream subscriptions created inside a notifier are cancelled via `ref.onDispose(subscription.cancel)`.
- Side effects (banners, snackbars) triggered by state changes use `ref.listen` in `build()`, not widgets embedded in the tree.

### Offline-first & connectivity

The app is offline-first: local Drift DB is always the source of truth for reads.

- `ConnectivityService` (`core/network/connectivity_service.dart`) wraps `connectivity_plus`.
- `CarRepository.refreshFromRemote()` attempts to fetch from the backend and upsert into Drift; it silently returns if offline, and throws a `Failure` if the network call fails.
- `CarRepository.create(Car)` always writes the car as pending to Drift first; if online it also pushes to the backend and marks the row as synced.
- `CarRepository.syncPending()` retries all pending rows; individual failures are skipped so the rest of the queue is still processed.
- `MaintenanceRepository` (`features/maintenances/data/repositories/`) follows the same offline-first pattern, plus a `pendingDelete` state: deletions mark the row locally, queue its id via `pendingDeleteIds()`, replay it in `syncPending()` (a 404 tombstone counts as settled), and `refreshFromRemote()` reconciles rows removed remotely, surfacing them as `MaintenanceRemoteSyncEvent`s.
- `SyncCoordinator` (`core/sync/sync_coordinator.dart`) holds the connectivity stream subscription and invokes registered callbacks when connectivity is restored.

## Build

```bash
flutter build apk           # Android APK
flutter build appbundle     # Android App Bundle (Play Store)
flutter build ios           # iOS (requires macOS + Xcode)
flutter build web           # Web
flutter build macos         # macOS desktop
```

## File Organization

```
lib/
├── main.dart               # Entry point: ProviderScope + MaterialApp.router
├── config.dart             # App-wide constants (AUTOBOOK_API_URL via --dart-define)
│
├── core/                   # Cross-cutting infrastructure, no feature business logic
│   ├── error/              # Sealed Failure hierarchy shared across features
│   ├── id/                 # IdGenerator port (pure Dart)
│   ├── network/            # HTTP client configuration and ConnectivityService
│   ├── sync/               # SyncCoordinator: auto-sync on connectivity restore
│   └── di/                 # Riverpod root providers for infrastructure deps (Dio, DB, UuidIdGenerator)
│
├── features/
│   ├── vehicles/           # All cars / vehicle functionality
│       ├── domain/         # Pure Dart: entities, repository interfaces, use cases (NO riverpod/data imports)
│       │   ├── entities/   # Car entity (freezed, no JSON)
│       │   ├── repositories/ # ICarRepository abstract class (port)
│       │   └── usecases/   # Get/Create/Refresh/SyncPending/HasPendingCars (pure call() wrappers); CarDraft typedef
│       ├── data/           # Adapters: DTOs, datasources, repository implementation
│       │   ├── models/     # CarDto (freezed + json_serializable) and response wrappers
│       │   ├── datasources/
│       │   │   ├── local/  # Drift AppDatabase schema + CarLocalDataSource
│       │   │   └── remote/ # Retrofit CarRemoteDataSource (HTTP)
│       │   └── repositories/ # CarRepository: implements ICarRepository, wires local + remote
│       └── presentation/   # UI layer for the vehicles feature
│           ├── providers/  # usecase_providers.dart (@riverpod wiring) + CarListNotifier consuming use cases
│           ├── screens/    # Full-page screens (HomeScreen, AddCarScreen dialog returning CarDraft)
│           └── widgets/    # Feature-scoped reusable widgets (InfoChip, CustomFormField)
│   └── maintenances/       # All maintenance records functionality (scoped to a car)
│       ├── domain/         # Pure Dart: entities, repository interfaces, use cases (NO riverpod/data imports)
│       │   ├── entities/   # Maintenance (freezed), MaintenanceType enum, MaintenanceRemoteSyncEvent (sealed freezed union)
│       │   ├── repositories/ # IMaintenanceRepository abstract class (port)
│       │   └── usecases/   # Get/Create/Update/Delete/Refresh/SyncPending/HasPending/PendingDeleteIds (pure call() wrappers); MaintenanceDraft typedef (create_maintenance_usecase.dart)
│       ├── data/           # Adapters: DTOs, datasources, repository implementation
│       │   ├── models/     # MaintenanceDto (freezed + json_serializable)
│       │   ├── datasources/
│       │   │   ├── local/  # MaintenanceLocalDataSource over the shared Drift AppDatabase (maintenances table)
│       │   │   └── remote/ # Retrofit MaintenanceRemoteDataSource (HTTP)
│       │   └── repositories/ # MaintenanceRepository: implements IMaintenanceRepository, wires local + remote
│       └── presentation/   # UI layer for the maintenances feature
│           ├── providers/  # usecase_providers.dart (@riverpod wiring) + MaintenanceList notifier (family per carId)
│           ├── screens/    # CarDetailScreen (car timeline), AddMaintenanceScreen dialog returning MaintenanceDraft, MaintenanceDetailScreen
│           ├── widgets/    # Feature-scoped reusable widgets (Timeline, MaintTypePill, MaintTypeIcon, BigStat)
│           └── theme/      # Per-type icon/tint mappings (maint_type_icons.dart, maint_tints.dart)
│
└── app/
    ├── router/             # GoRouter configuration (appRouterProvider)
    └── theme/              # AppTheme (light/dark ThemeData)

test/                       # Mirrors lib/ structure; each *_test.dart sits beside its subject
```

### API base URL

`config.dart` reads the API host from the `AUTOBOOK_API_URL` compile-time variable (default: `http://localhost:3000`). Pass it via `--dart-define`:

```bash
flutter run --dart-define=AUTOBOOK_API_URL=http://10.0.2.2:3000   # Android emulator
```
