import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('CarEntry')
class CarsTable extends Table {
  @override
  String get tableName => 'cars';

  TextColumn get id => text()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get licensePlate => text()();
  TextColumn get color => text().nullable()();
  IntColumn get mileage => integer().nullable()();
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CarsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
