import 'package:drift/drift.dart';

part 'app_database.g.dart';

enum SyncStateEnum { synced, pendingCreate, pendingUpdate }

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
  TextColumn get syncState => textEnum<SyncStateEnum>().withDefault(
    Constant(SyncStateEnum.synced.name),
  )();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CarsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(carsTable, carsTable.syncState);
        await customUpdate(
          "UPDATE cars SET syncState = 'pendingCreate' WHERE isPending = 1",
        );
        await customStatement('ALTER TABLE cars DROP COLUMN isPending');
        if (from >= 2) {
          await customStatement('ALTER TABLE cars DROP COLUMN wasCreated');
          await customStatement('ALTER TABLE cars DROP COLUMN wasUpdated');
        }
      }
    },
  );
}
