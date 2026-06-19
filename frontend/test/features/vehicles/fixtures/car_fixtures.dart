import 'package:autobook/features/vehicles/domain/entities/car.dart';

// ---------------------------------------------------------------------------
// Named canonical instances
// ---------------------------------------------------------------------------
// Use these const values when a test needs a stable, value-equality-safe Car
// (e.g. inside const lists or direct expect() comparisons).

const toyotaCorolla = Car(
  id: '1',
  brand: 'Toyota',
  model: 'Corolla',
  year: 2020,
  licensePlate: '1234 ABC',
);

const fordFocus = Car(
  id: '2',
  brand: 'Ford',
  model: 'Focus',
  year: 2019,
  licensePlate: '5678 DEF',
);

const renaultMegane = Car(
  id: 'n1',
  brand: 'Renault',
  model: 'Megane',
  year: 2022,
  licensePlate: '1111 BBB',
);

const peugeot208 = Car(
  id: 'p1',
  brand: 'Peugeot',
  model: '208',
  year: 2021,
  licensePlate: '2222 CCC',
);

const volkswagenGolf = Car(
  id: 'f1',
  brand: 'Volkswagen',
  model: 'Golf',
  year: 2023,
  licensePlate: '3333 DDD',
);

const fiat500 = Car(
  id: 'pend1',
  brand: 'Fiat',
  model: '500',
  year: 2019,
  licensePlate: '4444 EEE',
);

const alfaGiulia = Car(
  id: 'pend2',
  brand: 'Alfa',
  model: 'Giulia',
  year: 2020,
  licensePlate: '5555 FFF',
);

/// Canonical single-element list, shared across tests that need one Car.
const oneCarList = [toyotaCorolla];

// ---------------------------------------------------------------------------
// Factory builder
// ---------------------------------------------------------------------------
// Use buildCar() when you need a Car with custom fields or want to document
// which field is relevant to a specific test. Defaults mirror toyotaCorolla.

Car buildCar({
  String id = '1',
  String brand = 'Toyota',
  String model = 'Corolla',
  int year = 2020,
  String licensePlate = '1234 ABC',
  String? color,
  int? mileage,
}) => Car(
  id: id,
  brand: brand,
  model: model,
  year: year,
  licensePlate: licensePlate,
  color: color,
  mileage: mileage,
);
