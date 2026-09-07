# DESIGN.md — Frontend

Visual and token reference for the **autobook** Flutter app. This document covers the Garage and Maintenance flows of the vehicles feature and translates the design system to the Flutter stack (Material 3, Riverpod, go_router).

- **Target framework**: Flutter (stable channel via FVM), `MaterialApp` with `useMaterial3: true`.
- **UI language**: English labels in the spec; the app ships in Spanish (`es-ES`). Formats: km via `intl` `NumberFormat`, currency `€`, dates `dd MMM yyyy`.
- **Modes**: full light and dark schemes. M3 seed: `#0061A4` (automotive blue).
- **Fonts**: Roboto (body) + JetBrains Mono (monospaced values: VIN, plate).

---

## 1. Color system (M3 token map)

Seed: `#0061A4`. The tokens below must be reflected in Flutter's `ColorScheme`, either via `ColorScheme.fromSeed(seedColor: Color(0xFF0061A4))` (recommended — produces coherent tokens), or with fixed values overriding what `fromSeed` generates.

### 1.1 Main scheme

| M3 token                | Light        | Dark         | Flutter `ColorScheme`     |
|-------------------------|--------------|--------------|---------------------------|
| `primary`               | `#0061A4`    | `#9FCAFF`    | `primary`                 |
| `onPrimary`             | `#FFFFFF`    | `#003258`    | `onPrimary`               |
| `primaryContainer`      | `#D1E4FF`    | `#00497D`    | `primaryContainer`        |
| `onPrimaryContainer`    | `#001D36`    | `#D1E4FF`    | `onPrimaryContainer`      |
| `secondary`             | `#535F70`    | `#BBC7DB`    | `secondary`               |
| `onSecondary`           | `#FFFFFF`    | `#253140`    | `onSecondary`             |
| `secondaryContainer`    | `#D7E3F7`    | `#3B4858`    | `secondaryContainer`      |
| `onSecondaryContainer`  | `#101C2B`    | `#D7E3F7`    | `onSecondaryContainer`    |
| `tertiary`              | `#695779`    | `#D5BEE4`    | `tertiary`                |
| `onTertiary`            | `#FFFFFF`    | `#3A2948`    | `onTertiary`              |
| `tertiaryContainer`     | `#F1DAFF`    | `#513F5F`    | `tertiaryContainer`       |
| `onTertiaryContainer`   | `#241432`    | `#F1DAFF`    | `onTertiaryContainer`     |
| `error`                 | `#BA1A1A`    | `#FFB4AB`    | `error`                   |
| `onError`               | `#FFFFFF`    | `#690005`    | `onError`                 |
| `errorContainer`        | `#FFDAD6`    | `#93000A`    | `errorContainer`          |
| `onErrorContainer`      | `#410002`    | `#FFDAD6`    | `onErrorContainer`        |
| `background`/`surface`  | `#FDFCFF`    | `#111416`    | `surface`                 |
| `onBackground`/`onSurface` | `#1A1C1E` | `#E2E2E5`    | `onSurface`               |
| `surfaceDim`            | `#DDD9DD`    | `#111416`    | *(non-standard M3)*       |
| `surfaceBright`         | `#FDFCFF`    | `#37393C`    | *(non-standard M3)*       |
| `surfaceVariant`        | `#DFE2EB`    | `#43474E`    | `surfaceVariant`          |
| `onSurfaceVariant`      | `#43474E`    | `#C3C7CF`    | `onSurfaceVariant`        |
| `surfaceContainerLowest`| `#FFFFFF`    | `#0B0E10`    | `surfaceContainerLowest`\* |
| `surfaceContainerLow`   | `#F6F4F8`    | `#191C1F`    | `surfaceContainerLow`\*   |
| `surfaceContainer`      | `#F0EEF2`    | `#1D2023`    | `surfaceContainer`\*      |
| `surfaceContainerHigh`  | `#EAE8EC`    | `#282A2E`    | `surfaceContainerHigh`\*  |
| `surfaceContainerHighest` | `#E4E2E6`  | `#333539`    | `surfaceContainerHighest`\* |
| `outline`               | `#73777F`    | `#8D9199`    | `outline`\*               |
| `outlineVariant`        | `#C3C7CF`    | `#43474E`    | `outlineVariant`\*        |
| `inverseSurface`        | `#2F3033`    | `#E2E2E5`    | `inverseSurface`          |
| `inverseOnSurface`      | `#F1F0F4`    | `#2F3033`    | `onInverseSurface`        |
| `inversePrimary`        | `#9FCAFF`    | `#0061A4`    | `inversePrimary`          |
| `scrim`                 | `#000000`    | `#000000`    | `scrim`\*                 |

> \* Tokens `outline`, `outlineVariant`, `scrim`, and `surfaceContainer*` exist on `ColorScheme` from Flutter 3.22 (Material 3 v6.2). If the project's Flutter version does not expose them, define them as extensions in `app/theme/` with fixed values.

### 1.2 Extended semantic tokens (not on standard `ColorScheme`)

Used in situ (maintenance type pills, timeline dots, stats bars, ITS/MOT success states). Define them as constants in `app/theme/extra_colors.dart` with light/dark variants:

| Token     | Light       | Dark        | Use                                       |
|-----------|-------------|-------------|-------------------------------------------|
| `success` | `#2E7D32`   | `#A5D6A7`   | Positive states (favorable inspection)    |

### 1.3 Maintenance type tints

Each maintenance type has a base color with a `bg`/`fg` pair distinct for light and dark. Use them in type pills, timeline dots, the type-selection grid, and stats bars. Define them in `features/vehicles/presentation/theme/maint_tints.dart`:

| Type      | Base color | Light `bg`  | Light `fg`  | Dark `bg`   | Dark `fg`   |
|-----------|------------|-------------|-------------|-------------|-------------|
| `oil`     | amber      | `#FFEAC2`   | `#5A3D00`   | `#5A3D00`   | `#FFDDB3`   |
| `coolant` | cyan       | `#C2EDF5`   | `#003E48`   | `#003E48`   | `#BFEAF5`   |
| `belt`    | purple     | `#E4D5FA`   | `#3D2A57`   | `#3D2A57`   | `#E4D5FA`   |
| `itv`     | green      | `#C8E6C9`   | `#1F4222`   | `#1F4222`   | `#C8E6C9`   |
| `repair`  | red        | `#FFDAD6`   | `#5A1A1A`   | `#5A1A1A`   | `#FFDAD6`   |
| `filter`  | teal       | `#C2E9E2`   | `#1F4B45`   | `#1F4B45`   | `#C2E9E2`   |
| `battery` | orange     | `#FFD8C2`   | `#5C2A00`   | `#5C2A00`   | `#FFD8C2`   |
| `brakes`  | rose       | `#FAD3DA`   | `#5C1A2A`   | `#5C1A2A`   | `#FAD3DA`   |
| `tires`   | blue       | `#D1E4FF`   | `#003258`   | `#003258`   | `#D1E4FF`   |

Lookup: `getTint(maintType.color, themeMode) → { bg, fg }`. In Flutter: pure function or `ThemeExtension<MaintTints>` with the per-type pairs.

---

## 2. Typography

Font: **Roboto** (300/400/500/700) for all body text, **JetBrains Mono** (400/500) for monospaced values (VIN, plate). Load via `google_fonts` or local assets and map it onto `ThemeData.textTheme`.

### 2.1 M3 scale

| M3 style          | Size   | Line-height | Letter-spacing | Weight | Flutter `TextTheme`     |
|-------------------|--------:------------:|---------------:|-------:|-------------------------|
| `displayLarge`    | 57 px  | 64          | -0.25          | 400    | `displayLarge`          |
| `displayMedium`   | 45 px  | 52          |  0             | 400    | `displayMedium`         |
| `displaySmall`    | 36 px  | 44          |  0             | 400    | `displaySmall`         |
| `headlineLarge`   | 32 px  | 40          |  0             | 400    | `headlineLarge`        |
| `headlineMedium`  | 28 px  | 36          |  0             | 400    | `headlineMedium`       |
| `headlineSmall`   | 24 px  | 32          |  0             | 400    | `headlineSmall`        |
| `titleLarge`      | 22 px  | 28          |  0             | 400    | `titleLarge`           |
| `titleMedium`     | 16 px  | 24          |  0.15          | 500    | `titleMedium`          |
| `titleSmall`      | 14 px  | 20          |  0.10          | 500    | `titleSmall`           |
| `bodyLarge`       | 16 px  | 24          |  0.50          | 400    | `bodyLarge`            |
| `bodyMedium`      | 14 px  | 20          |  0.25          | 400    | `bodyMedium`           |
| `bodySmall`       | 12 px  | 16          |  0.40          | 400    | `bodySmall`            |
| `labelLarge`      | 14 px  | 20          |  0.10          | 500    | `labelLarge`           |
| `labelMedium`     | 12 px  | 16          |  0.50          | 500    | `labelMedium`          |
| `labelSmall`      | 11 px  | 16          |  0.50          | 500    | `labelSmall`           |

### 2.2 Usage by pattern

- **Screen header** (Garage): `bodyMedium` `onSurfaceVariant` above, `headlineLarge` `onSurface` below, `letterSpacing -0.5`.
- **Section labels** (`SectionLabel`): `labelMedium` `onSurfaceVariant`, `letterSpacing 1`, uppercase.
- **List-style labels** (`NEXT SERVICE`, `NOTES`, `ATTACHMENTS`): `labelMedium` or `labelLarge` `onSurfaceVariant`, `letterSpacing 0.8`, uppercase.
- **Large stat values** (total spent, big stat rows): `displaySmall` with `letterSpacing -1` weight 500, or `titleLarge` with `letterSpacing -0.2`.
- **Monospaced values**: JetBrains Mono 13 px `letterSpacing 0.5` (VIN); plates in `labelLarge` `letterSpacing 1.2`.

### 2.3 Flutter mapping

```dart
// app/theme/app_text_theme.dart
import 'package:google_fonts/google_fonts.dart';

TextTheme appTextTheme(ColorScheme scheme) => GoogleFonts.robotoTextTheme(
  ThemeData(brightness: scheme.brightness).textTheme,
).apply(
  bodyColor: scheme.onSurface,
  displayColor: scheme.onSurface,
);

TextStyle monoStyle(Color color, double size) => GoogleFonts.jetBrainsMono(
  fontSize: size,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
  color: color,
);
```

---

## 3. Iconography

Material Symbols outlined, 24 px default, `currentColor`, `strokeWidth 1.75`, no fill except for dots and decorative marks. In Flutter: use `Icons` (Material Icons) and, where no equivalent exists or a consistent outline stroke is required, `SvgPicture` with a custom asset.

### 3.1 Garage and actions

| Prototype icon         | Use                                | Flutter equivalent            |
|------------------------|------------------------------------|-------------------------------|
| `IconCar` / `IconGarage` | Garage tab, drawer brand mark    | `Icons.directions_car_outlined` / `Icons.garage_outlined` |
| `IconPlus`             | FAB, add button                    | `Icons.add`                   |
| `IconBack`             | App bar back                       | `Icons.arrow_back`            |
| `IconMore`             | Overflow menu                      | `Icons.more_vert`             |
| `IconChevronRight`     | List item trailing                | `Icons.chevron_right`         |
| `IconChevronDown`      | Expandable selectors               | `Icons.expand_more`           |
| `IconClose`            | Close                              | `Icons.close`                 |
| `IconCheck`            | Selected chip, segmented           | `Icons.check`                 |
| `IconEdit`             | Edit                               | `Icons.edit_outlined`         |
| `IconCamera`           | AddCar photo slot                  | `Icons.camera_alt_outlined`   |
| `IconCalendar`         | Date, next service                 | `Icons.calendar_today_outlined` |
| `IconGauge`            | Mileage                            | `Icons.speed_outlined`        |
| `IconLocation`         | Shop                               | `Icons.location_on_outlined`  |
| `IconEuro`             | Cost / currency                    | `Icons.euro`                  |
| `IconAttach`           | Attachments                        | `Icons.attach_file`           |
| `IconReceipt`          | PDF invoice                        | `Icons.receipt_outlined`      |

### 3.2 Maintenance types

`type → icon` mapping:

| Type      | Prototype icon    | Flutter equivalent             |
|-----------|-------------------|--------------------------------|
| `oil`     | `IconOil`         | `Icons.oil_barrel_outlined` or custom |
| `coolant` | `IconCoolant`     | `Icons.water_drop_outlined`    |
| `belt`    | `IconBeltTiming`  | `Icons.settings_outlined` / custom |
| `itv`     | `IconInspection`  | `Icons.verified_outlined`      |
| `repair`  | `IconBuild`       | `Icons.build_outlined`         |
| `filter`  | `IconFilter`      | `Icons.filter_alt_outlined`    |
| `battery` | `IconBattery`     | `Icons.battery_charging_full_outlined` |
| `brakes`  | `IconBrake`       | `Icons.disc_full_outlined` / custom |
| `tires`   | `IconTire`        | `Icons.tire_repair_outlined`    |

Type-specific icons (timing belt, brakes) likely need custom SVG assets; keep them in `assets/icons/maint/` and store the mapping in `MaintTypeIcons`.

---

## 4. Shape and elevation

| Token                  | Value | Notes                                       |
|------------------------|------:|---------------------------------------------|
| `cardRadius`           | 16    | `Card`, `CarListRow`, `TimelineEntry`      |
| `chipRadius`           | 8     | `Chip`, plate/year badges                  |
| `fabRadius`            | 16    | Normal and extended FAB                     |
| `maintPillRadius`      | 8     | `MaintTypePill`                             |
| `maintTypeIconRadius`  | size/2 | Circular                                    |
| `snackbarRadius`       | 4     | M3 standard (4 px)                          |
| `bottomSheetRadius`    | 28    | Top-left/right                              |
| `segmentedRadius`      | 100   | Full pill                                    |
| `pillIndicatorRadius`  | 16    | Active indicator of bottom nav (64×32)      |

**State layers (M3)**:
- Hover: `onSurface` at 8 % (absolute overlay).
- Press: `onSurface` at 16 %.
- Hover with click (cards): extra subtle shadow `0 1px 2px rgba(0,0,0,0.3), 0 2px 6px 2px rgba(0,0,0,0.15)`.

**Shadows** (light):
- Elevated card / FAB: `0 1 2 rgba(0,0,0,0.3), 0 1 3 1 rgba(0,0,0,0.15)`.
- FAB hover: `0 4 8 rgba(0,0,0,0.3), 0 6 10 4 rgba(0,0,0,0.15)`.
- Snackbar: `0 3 5 rgba(0,0,0,0.2), 0 6 10 rgba(0,0,0,0.14)`.

In Flutter use `Material(elevation: …)` and `BoxShadow` where needed (hero gradient overlays).

---

## 5. Components

M3 component catalog with variants and key props. For each, the reference Flutter widget is listed.

### 5.1 `AppBar`

Flat app bar, 64 px tall, title in a small variant (center-aligned in its slot) or `headlineMedium` below in the large variant (padding `8 20 20`). Back button on the left, actions on the right as `IconButton`. Sticky at the top with `surface` background.

```dart
AppBar(
  centerTitle: false, // prototype aligns to the right of the back slot
  leading: BackButton(...),
  title: Text('...'),
  actions: [...],
  scrolledUnderElevation: 0,
);
```

Over a photo hero (Garage → CarDetail): icons use `#fff` with a transparent `IconBtn`. Implement with `SliverAppBar` + `flexibleSpace` carrying the gradient.

### 5.2 `IconBtn`

Circular button 48×48, transparent background (or `secondaryContainer` when selected), radial state layer via `Material(stateLayerBuilder)` or `InkWell` with radius 22 (inset 4).

### 5.3 `Button`

Height 40, radius 100 (full pill). Variants:

| Variant   | Background              | Text                   | Border           | Flutter widget            |
|-----------|-------------------------|------------------------|------------------|---------------------------|
| `filled`  | `primary`               | `onPrimary`            | none             | `FilledButton`            |
| `tonal`   | `secondaryContainer`    | `onSecondaryContainer` | none             | `FilledButton.tonal`      |
| `outlined`| transparent             | `primary`              | `1px outline`    | `OutlinedButton`          |
| `text`    | transparent             | `primary`              | none             | `TextButton`              |
| `danger`  | `errorContainer`        | `onErrorContainer`     | none             | custom over `FilledButton`|
| (icon)    |                         |                        |                  | `IconButton`              |

`filled` on hover gains a light boxShadow + `brightness(0.96)`. With `icon`, left padding becomes 16 and right padding 20.

### 5.4 `FAB`

56×56 normal or extended (`padding 0 20 0 16`, `gap 12`). Radius 16. Background `primaryContainer` / text `onPrimaryContainer`. Position bottom-right (16 px). Subtle M3 elevation that intensifies on hover. Flutter: `FloatingActionButton` / `FloatingActionButton.extended`.

### 5.5 `Chip`

Height 32, radius 8. Assist (outline `outlineVariant`) or selected (`secondaryContainer` + `onSecondaryContainer` with `IconCheck`). A `leadingDot` renders an 8×8 dot in the given color. Flutter: `FilterChip` / `ChoiceChip`.

### 5.6 `Card`

Radius 16, three variants:

| Variant    | Background                 | Border                | Shadow           | Flutter                |
|------------|----------------------------|----------------------|------------------|------------------------|
| `filled`   | `surfaceContainerHighest`  | none                 | none             | `Card.filled`\*        |
| `elevated` | `surfaceContainerLow`      | none                 | M3 elevation 1   | `Card(elevation: 1)`   |
| `outlined` | `surface`                 | `1px outlineVariant` | none             | `Card.outlined`\*      |

> \* `Card.filled` and `Card.outlined` are available from Flutter 3.7+. Otherwise simulate with `Material`/`Card` + `shape`/`elevation`.

Clickable hover: `onSurface` state layer at 5 % + elevated shadow.

### 5.7 `ListItem`

One or two lines. Padding `12 16`, minimum height 56 (dense 48). Leading icon 24, trailing icon/chevron. Hover with `surfaceContainer`. Flutter: `ListTile` with adjusted typography (`titleMedium`/`bodyMedium`), or a custom `InkWell`.

### 5.8 `Divider`

Height 1, color `outlineVariant`, configurable `marginLeft inset` (16 or 56 to align below a leading icon). Flutter: `Divider(height: 1, indent: inset)`.

### 5.9 `TextField` (filled)

Background `surfaceContainerHighest`, radius 4, bottom border 1 px `onSurfaceVariant` (2 px `primary` on focus). Floating label: 16 px up, drops to 4 px and 12 px font when filled or focused. Supports `leading`, `suffix`, `supporting`, `multiline` (min 96 px). Flutter: `TextField` with `InputDecoration(filled: true, fillColor: surfaceContainerHighest, …)` and an `OutlineInputBorder` with transparent sides/top.

### 5.10 `Segmented`

Outer border `outline`, radius 100, vertical separators `outline`. Active segments use `secondaryContainer` + `onSecondaryContainer` + `IconCheck`. Flutter: `SegmentedButton<T>` (Flutter 3.7+).

### 5.11 `Snackbar`

Background `inverseSurface`, text `inverseOnSurface`, optional action in `inversePrimary`. Position bottom 96 px, radius 4, padding `14 16`, M3 shadow. Auto-clear 3200 ms. Flutter: `ScaffoldMessenger.showSnackBar` with `SnackBarBehavior.floating`, `duration: Duration(milliseconds: 3200)`. Customize via `SnackBarThemeData`.

### 5.12 `BottomSheet`

Drag handle 32×4 `onSurfaceVariant` 40 % center-aligned, top radius 28, background `surfaceContainerLow`, max height 85 %, scrim 32 %. Flutter: `showModalBottomSheet` with `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28)))`, `useSafeArea: true`.

### 5.13 `MaintTypePill`

Small chip (26 px height, padding `0 10 0 8`, radius 8) with the type tint `bg`/`fg` + icon at 14 px + `labelMedium`. Used in `CarCard` and `CarListRow`.

### 5.14 `MaintTypeIcon`

Circle of the given size (default 40), radius size/2, type tint `bg`/`fg`, centered icon at size*0.55. Used in the timeline and the per-category bars.

---

## 6. Screens (mobile)

### 6.1 Garage (home)

- Header (`padding 12 20 16`): greeting `bodyMedium` `onSurfaceVariant` ("Hi, Andrés") + `headlineLarge` `onSurface` ("Your garage", `letterSpacing -0.5`).
- Subheader (`padding 4 20 12`, baseline space-between): "{n} vehicles" in `titleMedium` + "Total: {km} km" in `labelMedium` `onSurfaceVariant`.
- Vertical list of `CarCard` with gap 16, padding `0 20 100` (extra bottom space for the FAB).
- Extended FAB "Add car" (push to `addCar`).

**`CarCard`**:

- `Card` variant `elevated`.
- Photo region 168 px tall, `background-image center/cover`. On top:
  - Plate badge top-left (`padding 0 12`, height 28, `rgba(0,0,0,0.55)` + `backdropFilter blur 6px`, `labelMedium` `letterSpacing 1`).
  - Year badge top-right (`padding 0 10`, height 28, same style).
- Body (`padding 14 16 16`):
  - Make in `bodyMedium` `onSurfaceVariant` (mb 2).
  - Model in `titleLarge` `onSurface` (`letterSpacing -0.2`).
  - Odometer chip on the right: `padding 6 12`, radius 8, background `surfaceContainer`, `IconGauge` 16 + `labelMedium` "{n} km".
- Next service strip (mt 14, `padding 10 12`, `surfaceContainer`, radius 12):
  - 6×36 bar radius 3 on the left, color `error` if `dueDate` indicates urgent (e.g. month `Jun`) or `primary` otherwise. In the implementation compare against the real date.
  - Label `labelMedium` "NEXT SERVICE".
  - Value `bodyMedium` "{label} · {dueDate}".
  - On the right, `MaintTypePill` of the most recent maintenance (if any).

### 6.2 Car detail (`CarDetailScreen`)

- Hero 260 px tall with the car photo, vertical gradient `rgba(0,0,0,0.45) 0 → 0 30 → 0 60 → 0.55 100` for legibility. App bar overlaid: back `IconBtn`, spacer, `IconBtn` edit and more (all `#fff`).
- Text over the hero (bottom 16, left 20): `labelLarge` 85 % opacity ("{year} · {make}") + `headlineMedium` `letterSpacing -0.3` ("{model}").
- Plate badge bottom-right 18: `padding 0 14`, height 32, `rgba(0,0,0,0.55)` + blur 6, `labelLarge` `letterSpacing 1.2`.
- Stat strip: `Card` variant `elevated` with `marginTop -28` (overlaps the hero). Three columns separated by vertical dividers `outlineVariant`:
  - km (`IconGauge` + `titleMedium` value + `labelSmall` uppercase label).
  - fuel (`IconOil` + `fuel`).
  - spent (`IconEuro` + total maintenance cost for the car, integer formatted + '€').
- Vehicle info card (`Card` variant `outlined`): `InfoRow`s (label 96 px wide `bodyMedium` `onSurfaceVariant` + value `bodyMedium` `onSurface` right-aligned). Rows: VIN (mono), Color (with 18×18 swatch radius 9), Year, Fuel. Dividers with `inset 16`.
- Next service banner: `Card` variant `filled` with background `tertiaryContainer`, padding `14 16`, `IconCalendar` 22, label + `titleMedium`, remaining km on the right if present (`(dueKm - odometer) km`).
- History section: `titleMedium` "Maintenance history" + `bodyMedium` "n entries" `onSurfaceVariant`.
- `Timeline` (see below).
- Extended FAB "Add maintenance" → `addMaint`.

**`Timeline`**:

- Groups maintenances by year (extracted from `date.split(' ').last`), sorted descending.
- Each group starts with `labelLarge` `onSurfaceVariant` `letterSpacing 1` (year), padding `12 0 4 40`.
- `TimelineEntry`:
  - Left gutter 40 px: 2 px connector line in `outlineVariant` (hidden above the first and below the last), circular dot 32×32 radius 16 with `3 px surface border` (content-box), background/foreground from the type tint, centered icon at 16.
  - Card on the right (`marginLeft 16`, `mb 12`, background `surfaceContainerLow` → `surfaceContainerHigh` on hover, radius 12, padding `12 14`):
    - `titleMedium` (type label) + `labelMedium` (day month in `onSurfaceVariant`).
    - `bodyMedium` `onSurfaceVariant`: "{km} km · {cost} €" (cost with `fontWeight 500` and `onSurface`).
    - `bodySmall` shop.

### 6.3 Maintenance detail (`MaintDetailScreen`)

- `AppBar` small with back, edit, more.
- Hero (padding `8 24 28`) with background `tint.bg` and color `tint.fg`:
  - 64×64 square radius 20, background `rgba(255,255,255,0.25)`, centered icon at 36.
  - `labelLarge` 80 % opacity: "{make} {model} · {plate}".
  - `headlineMedium` `letterSpacing -0.3`: "{maint.label}".
- Big stats row (padding `20 0 8`): three `BigStat` separated by vertical dividers:
  - Cost (`titleLarge` "X.XX €" `letterSpacing -0.2`).
  - Kilometers (`titleLarge` "X km", `es-ES` grouping).
  - Date (`titleLarge` "DD MMM" + `bodyMedium` year).
- Full `Divider`.
- Shop `ListItem`: leading `IconLocation` `onSurfaceVariant`, headline = shop, supporting = "Tap to view map".
- `Divider inset 56`.
- NOTES block: `labelMedium` `onSurfaceVariant` `letterSpacing 0.8` + `bodyLarge` `onSurface`.
- ATTACHMENTS block: `Card` variant `outlined`, row with 64×80 thumbnail radius 8 with a diagonal pattern (repeating linear-gradient 135deg `surfaceContainerHigh`/`Highest` every 6 px) + `IconReceipt`, content `{name}.pdf` `titleMedium` + "184 KB · PDF" `bodyMedium`, action `IconBtn` with `IconAttach`.

### 6.4 Add car (`AddCarScreen`)

- `AppBar` small with back + action "Save" (`Button` filled if `make && model && plate`, `text` + disabled otherwise).
- Photo slot (padding `8 20 20`): 160 px box, radius 16, background repeating-linear-gradient 135deg `surfaceContainerHigh`/`surfaceContainer` every 8/16 px, border `1px dashed outline`, `IconCamera` 32 + `labelLarge` "Add car photo" + `bodySmall` outline "Optional · camera or gallery".
- `SectionLabel` "Identification":
  - `TextField` Make (leading `IconCar`, autofocus).
  - `TextField` Model.
  - Row (gap 12): Year (flex 1, type number) + Plate (flex 1.4).
  - `TextField` Color.
  - `TextField` VIN (`supporting "17 characters"`).
- `SectionLabel` "Details":
  - `TextField` Current mileage (type number, suffix "km", leading `IconGauge`).
  - Fuel: `bodyMedium` "Fuel" + wrap of `Chip` selection: Petrol, Diesel, Hybrid, Electric, LPG. One selected with border/`secondaryContainer`.
- Bottom padding 32.

### 6.5 Add maintenance (`AddMaintScreen`)

- `AppBar` small with back + action `Button filled` "Save".
- Car selector (padding `4 20 16`): `Card` variant `filled` with background `surfaceContainerLow`, padding `10 14`, 40×40 thumbnail radius 12 with the car photo, `titleMedium` "{make} {model}", `bodySmall` `onSurfaceVariant` "{plate}", trailing `IconChevronDown`.
- `SectionLabel` "Maintenance type": 3-column grid, gap 10, 8 types. Each cell is a button with `2px primary` border + `primaryContainer` background if selected, else `1px outlineVariant` + `surface`. Contains a 36×36 circle radius 18 with `tint.bg`/`tint.fg` + icon at 18, and below a `labelMedium` with `MAINT_TYPES[type].short` (active → `onPrimaryContainer`).
- `SectionLabel` "Details":
  - Row (gap 12): Date (flex 1.2, leading `IconCalendar`) + Kilometers (flex 1, suffix "km", type number).
  - Cost (type number, suffix "€", leading `IconEuro`).
  - Shop (leading `IconLocation`).
  - Notes (multiline).
- Attachments (padding `16 20 100`): full-width button `padding 14 16`, transparent background, `1px dashed outline` border, radius 12, `IconAttach` + `bodyMedium` "Attach invoice or photo".

---

## 7. Navigation and routing

### 7.1 Root navigation

The Garage is the home/root destination. From the Garage the user navigates along a push stack that descends into the vehicle and its maintenance entries. The bottom navigation bar is visible only at the root; pushed screens replace it with a back action in the app bar.

```
Garage ──(tap car)──▶ Car detail ──(tap entry)──▶ Maintenance detail
   │                       │
   └──(FAB)──▶ Add car     └──(FAB)──▶ Add maintenance
```

In Flutter: `StatefulShellRoute.indexedStack` in go_router with the Garage as the home branch; pushed routes (`car/:id`, `maint/:id`, `addCar`, `addMaint`) use `context.pushNamed`. Returning to the root resets to the Garage.

### 7.2 Action feedback

Snackbar on save (auto-clear 3200 ms):

| Action                  | Message                     |
|-------------------------|-----------------------------|
| Save new car            | "Car added to the garage"   |
| Save maintenance        | "Maintenance registered"     |

Implement via `ref.listen` in the notifier (see `frontend/AGENTS.md` §Riverpod patterns) — never embedded in the tree.

---

## 8. Responsive layouts

Three breakpoints sharing the same screens with different composition:

### 8.1 Mobile (compact, 412 × 892)

- Bottom navigation bar 80 px at the root.
- Full-screen vertical scrolling.
- Extended FAB over the content.
- Sticky app bar.

Flutter: `StatefulShellRoute.indexedStack` + `Scaffold.bottomNavigationBar: NavigationBar`. Detect via `MediaQuery.size.width < 600`.

### 8.2 Tablet (1180 × 820, foldable)

- **NavRail** 88 px wide:
  - FAB-style brand mark 56×56 radius 16 in `primaryContainer`/`onPrimaryContainer` + `IconPlus` → "Add car".
  - Destination items 80 px wide, column: 56×32 pill radius 16 in `secondaryContainer` when active, icon 24 + `labelMedium` (weight 600 active, 500 otherwise, `letterSpacing 0.3`).
  - `surface` background + right border `outlineVariant`.
- **Master pane 360 px** (visible on the Garage tab):
  - `CarListMaster`: header (`bodyMedium` "{n} vehicles" + `headlineMedium` "Garage"), list of `CarListRow` (button radius 16, padding 10, gap 12, 72×72 thumbnail radius 12, `titleMedium` model, `bodySmall` "plate · km", optional `MaintTypePill`, trailing `IconChevronRight`). Selected → `secondaryContainer`.
- **Detail pane** flex 1, remaining width. Renders `CarDetailScreen` without back button (the master stays visible).

Flutter: `NavigationRail` (with `extended: false` and a `leading` FAB) + `Row` with the master + `Expanded` detail. Detect via `width >= 600 && < 1200`.

### 8.3 Desktop (1440 × 900, Chrome OS / web)

- **NavDrawer** 260 px expanded, background `surfaceContainerLow`, right border `outlineVariant`:
  - Header (`padding 0 24 16`, gap 12): 36×36 square radius 10 in `primary`/`onPrimary` + `IconCar` 20, next to `titleLarge` "Autoboook" `letterSpacing -0.3`.
  - `Button filled` full-width with `icon Plus`: "Add car".
  - Destination items: 56 px tall button, radius 28, padding `0 16 0 24`. Active → `secondaryContainer`/`onSecondaryContainer` (weight 600). Inactive → `onSurfaceVariant` (weight 500).
  - Footer (`padding 16 24`): 36 px circle in `tertiaryContainer`/`onTertiaryContainer` with "A", `bodyMedium` "Andrés Ruiz" + `bodySmall` "3 vehicles".
- **Master pane 380 px**: same as tablet.
- **Detail pane** flex 1 with `surface` background.

Flutter: `NavigationDrawer` (M3) inside a `Row` + master + detail. Detect via `width >= 1200`. On web/desktop use a permanent `NavigationDrawer` (not modal).

### 8.4 Layout selector

```dart
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth >= 1200) return DesktopShell(...);
  if (constraints.maxWidth >= 600)  return TabletShell(...);
  return MobileShell(...);
});
```

Each shell renders its own navigator and a `DetailPane` that delegates to the individual screens described above. Screens are agnostic to the shell that hosts them.

---

## 9. Spacing and layout tokens

| Token               | Value       | Use                                              |
|---------------------|-------------|--------------------------------------------------|
| `padScreenH`        | 20 px       | Standard horizontal padding on mobile screens    |
| `gapCardList`       | 16 px       | Vertical gap between `CarCard`                   |
| `gapRowList`        | 8 px        | Gap between `CarListRow` in the master           |
| `fabInset`          | 16 px       | FAB bottom/right                                  |
| `tabBarHeight`      | 80 px       | Bottom navigation bar height                      |
| `appBarHeight`      | 64 px       | Small app bar height                              |
| `heroPhotoH`        | 260 px      | Car detail hero                                   |
| `carCardPhotoH`      | 168 px      | Car card photo                                     |
| `addCarPhotoH`       | 160 px      | AddCar photo slot                                  |
| `bottomPaddingFAB`  | 100 px      | Extra bottom padding to avoid overlapping the FAB |
| `scrimOpacity`      | 32 %        | Bottom sheet overlay                              |

Relative z-order (in Flutter: tree order + `Stack`):

- FAB: 4
- AppBar: 5
- Snackbar: 10
- BottomSheet: 20

---

## 10. Sample data

To reproduce the same look in widget/fixture tests:

- **Cars** (3):
  - `gti` — Golf GTI Performance, 2022, plate "3456 KLM", Tornado Red `#C8262B`, 45 200 km, Petrol. Next service: oil change, 50 000 km, 15 Jul 2026.
  - `320d` — BMW 320d Touring, 2019, plate "7821 NPQ", Alpine White `#EFEFEF`, 87 500 km, Diesel. Next service: inspection, 02 Jun 2026.
  - `corolla` — Corolla Hybrid, 2021, plate "9054 BCD", Metallic Silver `#B7BCC2`, 32 800 km, Hybrid. Next service: cabin filter, 35 000 km, 20 Sep 2026.
- **Maintenances** (~17): distributed across the three cars from 2024 to 2026 (oil, tires, brakes, filters, inspection, timing belt, coolant, battery, repair).

Photos in the prototype are generated SVG data-uris with a gradient + car silhouette; in the real app use user photos or an equivalent SVG placeholder.

---

## 11. Flutter migration notes

- **Global theme**:
  ```dart
  ThemeData appTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0061A4),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: appTextTheme(scheme),
      cardTheme: const CardThemeData(shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      )),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        indicatorColor: scheme.secondaryContainer,
        backgroundColor: scheme.surfaceContainer,
      ),
    );
  }
  ```
- **`surfaceContainer*` tokens**: available on `ColorScheme` from Flutter 3.22. For earlier versions, expose them via `ThemeExtension<AppExtraColors>` with the fixed values from §1.
- **Outlined/filled cards**: use `Card.outlined` / `Card.filled` (Flutter 3.7+). If `outlineVariant` is needed instead of the default `outline`, override `CardThemeData.shape`.
- **Buttons**: `FilledButton` (filled), `FilledButton.tonal` (tonal), `OutlinedButton`, `TextButton`. The `danger` variant is built over `FilledButton` with `errorContainer`/`onErrorContainer`.
- **Extended FAB**: `FloatingActionButton.extended(icon: Icon(Icons.add), label: Text('Add car'), onPressed: …)`.
- **Fuel chips**: `Wrap` of `FilterChip(selected: form.fuel == f, onSelected: …)`. `MaintTypePill`/`MaintTypeIcon` as custom widgets in `features/vehicles/presentation/widgets/`.
- **Filled TextField**: `InputDecoration(filled: true, fillColor: surfaceContainerHighest, …)` with an `OutlineInputBorder` whose sides/top are transparent to mimic the M3 outlined-bottom look.
- **Timeline**: `CustomPaint` or a `Column` with a `Stack` per entry (dot + connector). Reuse `MaintTypeIcon` for the 32×32 dot with a 3 px `surface` border.
- **NavigationBar / NavigationRail / NavigationDrawer**: use the native M3 widgets. On desktop/web the `NavigationDrawer` becomes permanent inside a `Row` (not modal).
- **Responsive shell**: `LayoutBuilder` + `Row` with the three shells. `StatefulShellRoute.indexedStack` from go_router keeps state per branch. Screens (`GarageScreen`, `CarDetailScreen`, etc.) remain shell-agnostic and consume the navigation provider.
- **Snackbar**: `ScaffoldMessenger.of(context).showSnackBar(...)` triggered from `ref.listen` in notifiers (not embedded in the tree — see `frontend/AGENTS.md` §Riverpod patterns).
- **Monospaced font**: `GoogleFonts.jetBrainsMono(...)` for VIN and plate.
- **Hero gradient**: `Container(decoration: BoxDecoration(image: DecorationImage(...)))` + `DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x73000000), Colors.transparent, Color(0x8C000000)])))`.

---

## 12. Pending

Gaps to implement in future iterations (split into tickets as needed):

- **Filter and sort** in the car list (the Garage header reserves a slot for it).
- **Edit car / maintenance**: the `IconEdit` action exists but no material screen is designed yet.
- **Shop map**: the shop `ListItem` ("Tap to view map") has no destination.
- **Attachments**: visual mocking only; real uploader and preview are missing.
- **Export maintenance history** (CSV or PDF).