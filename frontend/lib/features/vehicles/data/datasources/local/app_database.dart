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
  BoolColumn get wasCreated => boolean().withDefault(const Constant(false))();
  BoolColumn get wasUpdated => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CarsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(carsTable, carsTable.wasCreated);
        await m.addColumn(carsTable, carsTable.wasUpdated);
        await customUpdate(
          "UPDATE cars SET wasCreated = isPending WHERE isPending = 1",
        );
      }
    },
  );
}
