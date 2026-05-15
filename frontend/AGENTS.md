# AGENTS.md — Frontend

Flutter application for autobook. All commands must be run from the `frontend/` directory.

## Tech Stack

- **Framework**: Flutter (stable channel, managed via FVM)
- **Language**: Dart >=3.0.3
- **State management**: Riverpod (flutter_riverpod ^2.5.1) with code generation
- **Code generation**: riverpod_generator + build_runner
- **Linter**: flutter_lints + riverpod_lint + custom_lint
- **Storage**: shared_preferences
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

Generated files (`*.g.dart`) are committed to the repository — do not delete them manually.

## Testing

```bash
flutter test                         # Run all widget and unit tests
flutter test test/widget_test.dart   # Run a specific test file
```

Test files live in `test/` and follow the `*_test.dart` naming convention.

## Code Style

```bash
flutter analyze         # Static analysis (uses analysis_options.yaml)
dart format lib/ test/  # Format Dart source files
```

- Use Riverpod for all state — avoid `setState` in favor of `ConsumerWidget` / `ConsumerStatefulWidget`
- Annotate providers with `@riverpod` and run build_runner to generate the `.g.dart` companion file
- Keep screens in `lib/screens/`, reusable components in `lib/widgets/`, data classes in `lib/models/`, and providers in `lib/providers/`
- Follow `flutter_lints` rules; riverpod_lint provides additional Riverpod-specific checks

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
├── main.dart               # Entry point, ProviderScope setup
├── models/                 # Pure data classes (e.g. Car)
├── providers/              # Riverpod providers + generated *.g.dart files
├── screens/                # Full-page UI screens
└── widgets/                # Reusable UI components
```