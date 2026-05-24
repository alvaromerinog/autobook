# AGENTS.md — Frontend

Flutter application for autobook. All commands must be run from the `frontend/` directory.

## Tech Stack

- **Framework**: Flutter (stable channel, managed via FVM)
- **Language**: Dart >=3.0.3
- **State management**: Riverpod (flutter_riverpod ^2.5.1) with code generation
- **Code generation**: riverpod_generator + build_runner
- **Linter**: flutter_lints + riverpod_lint + custom_lint
- **Storage**: shared_preferences
- **HTTP**: http
- **Connectivity**: connectivity_plus
- **Testing mocks**: mocktail
- **Other**: intl (i18n), uuid

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

## Code Generation

Riverpod providers use code generation. After adding or modifying a provider annotated with `@riverpod`, regenerate the `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs     # One-shot generation
dart run build_runner watch --delete-conflicting-outputs     # Watch mode (during development)
```

Generated files (`*.g.dart`) are **gitignored** — do not commit them. They are regenerated on each build or via the `build_runner` commands below.

## Testing

```bash
flutter test                         # Run all widget and unit tests
flutter test test/widget_test.dart   # Run a specific test file
```

Test files live in `test/` and follow the `*_test.dart` naming convention.

### Test conventions

- Structure every test body with `// given`, `// when`, `// then` comment
  blocks. Keep lines within each block together; separate blocks with one blank
  line.
- Group tests with `group()` — at minimum one top-level group per class, with
  nested groups per method (`build`, `add`, etc.).
- Call `addTearDown(container.dispose)` immediately after creating any
  `ProviderContainer`.
- Override service providers (`apiServiceProvider`,
  `connectivityServiceProvider`) in `ProviderContainer` — do **not** override
  `carsProvider` directly:
  ```dart
  ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(mockApi),
      connectivityServiceProvider.overrideWithValue(mockConnectivity),
    ],
  )
  ```
- Register mocktail fallback values in `setUpAll` for every non-primitive type
  passed to `any()`:
  ```dart
  setUpAll(() {
    registerFallbackValue(const Car(...));
  });
  ```
- Assert on specific exception types (`isA<GetCarsException>()`) rather than
  the base `Exception`.
- Verify mock interactions with `verify(() => mock.method()).called(n)` where
  the call count is meaningful.

## Code Style

```bash
flutter analyze         # Static analysis (uses analysis_options.yaml)
dart format lib/ test/  # Format Dart source files
```

- Use Riverpod for all state — avoid `setState` in favor of `ConsumerWidget` / `ConsumerStatefulWidget`
- Annotate providers with `@riverpod` and run build_runner to generate the `.g.dart` companion file
- Keep screens in `lib/screens/`, reusable components in `lib/widgets/`, data classes in
  `lib/models/`, providers in `lib/providers/`, and custom exceptions in `lib/exceptions/`
- Follow `flutter_lints` rules; riverpod_lint provides additional Riverpod-specific checks
- Maximum line length is 80 characters
### Variable naming

Name variables after what they contain, not their role in the flow:

- ✅ `cachedCars`, `apiCars`, `updatedCars` — ❌ `current`, `data`, `result`
- ✅ `cachedCarJsonList`, `carJson` — ❌ `decoded`, `c`, `item`
- ✅ `currentState` when holding a state record — ❌ `current`

### Exceptions

Every distinct API failure has its own exception class in `lib/exceptions/`:

```
lib/exceptions/
├── get_cars_exception.dart     # thrown by ApiService.getCars()
└── create_car_exception.dart   # thrown by ApiService.createCar()
```

Each class implements `Exception`, holds the HTTP `statusCode`, and
overrides `toString()` with a readable message. Add a new file for each new
failure scenario — do not reuse generic `Exception`.

### Riverpod patterns

- **Provider-based DI** for `AsyncNotifier` subclasses: dependencies are read
  from Riverpod providers at the start of `build()` and stored as `late` fields:
  ```dart
  class CarsProvider extends AsyncNotifier<CarsState> {
    late ApiService _apiService;
    late ConnectivityService _connectivityService;

    @override
    Future<CarsState> build() async {
      _apiService = ref.read(apiServiceProvider);
      _connectivityService = ref.read(connectivityServiceProvider);
      // ...
    }
  }
  ```
  `main.dart` uses a plain `ProviderScope` with no overrides. Tests override
  `apiServiceProvider` and `connectivityServiceProvider` directly in
  `ProviderContainer`.
- **Side effects** (banners, snackbars) triggered by state changes use
  `ref.listen` in `build()`, not widgets embedded in the tree.
- **API calls must always be awaited.** Failures surface to the caller via
  `rethrow` so the UI can inform the user and offer a retry.
- **Stream subscriptions** created inside a notifier must be cancelled via
  `ref.onDispose(subscription.cancel)` to avoid leaks.
- **Service disposal**: providers that own resources (e.g. `ApiService` holding
  an `http.Client`) call `ref.onDispose(service.dispose)` inside the provider
  function so the resource is released when the provider is torn down.

### Offline-first & connectivity

The app is offline-first: cached data is always preferred when the device has
no connection, and writes are queued locally and synced when connectivity
returns.

`ConnectivityService` (`lib/services/connectivity_service.dart`) wraps
`connectivity_plus` and exposes:

- `Future<bool> isConnected()` — one-shot check for the current state.
- `Stream<bool> connectivityChanges` — emits `true`/`false` on every change.

`CarsState` carries a `hasPendingSync` flag alongside `cars` and `syncError`:

```dart
typedef CarsState = ({
  List<Car> cars,
  Exception? syncError,
  bool hasPendingSync,
});
```

**`CarsProvider.build()` strategy:**

1. Read `apiServiceProvider` and `connectivityServiceProvider` via `ref.read`
   and assign to `late` fields.
2. Subscribe to `connectivityChanges` (cancel on dispose) to trigger sync when
   connectivity is restored at runtime.
3. Read cached cars and the pending-car queue from `shared_preferences`.
4. If offline → return cached cars immediately, no API call.
5. If online → call `getCars()`; on success merge API cars with pending ones
   (to prevent overwriting unsynced writes), persist, then call
   `syncPendingCars()` if there are pending cars (auto-syncs on startup).
   Return with `hasPendingSync` reflecting whether any cars are still pending
   after the sync attempt. On failure → return cached cars with `syncError` set.

**`CarsProvider.add()` strategy:**

1. Optimistically append the car to the local list and persist.
2. If offline → queue the car in `pending_cars`, set `hasPendingSync: true`,
   return without error.
3. If online → `await createCar(car)`. On failure → queue it, set
   `hasPendingSync: true`, and `rethrow` so the UI can show an error.

**`CarsProvider.syncPendingCars()` strategy:**

Guards against concurrent invocations with an `_isSyncing` flag (important
because the method is called both from `build()` and from the connectivity
stream listener). Iterates the `pending_cars` queue; for each car attempts
`createCar()`. Collects successfully-synced IDs, removes them from the queue,
and updates `hasPendingSync`. Failures for individual cars are silently skipped
so the rest of the queue is still processed.

**Merging pending cars with the API response:**

When `getCars()` returns, pending cars whose IDs are not yet in the API
response are appended to avoid data loss. Cars that the server already knows
about (same ID) are not duplicated.

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
├── main.dart               # Entry point, plain ProviderScope (no overrides)
├── config.dart             # App-wide constants; AUTOBOOK_API_URL read via --dart-define
├── exceptions/             # One file per typed exception (e.g. GetCarsException)
├── models/                 # Pure data classes (e.g. Car)
├── providers/              # Riverpod providers (*.g.dart generated, gitignored)
├── screens/                # Full-page UI screens
├── services/               # External service classes (ApiService, ConnectivityService)
└── widgets/                # Reusable UI components
```

### API base URL

`config.dart` reads the API host from the `AUTOBOOK_API_URL` compile-time
variable (default: `http://localhost:3000`). Pass it via `--dart-define` when
running locally or via Docker build args / environment in Docker Compose:

```bash
flutter run --dart-define=AUTOBOOK_API_URL=http://10.0.2.2:3000   # Android emulator
AUTOBOOK_API_URL=http://my-server task docker/dev                   # Docker dev
```