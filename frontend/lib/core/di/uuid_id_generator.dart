import 'package:autobook/core/id/id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'uuid_id_generator.g.dart';

/// [IdGenerator] adapter backed by the `uuid` package. The only place in the
/// codebase that imports `package:uuid`.
class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  @override
  String newId() => const Uuid().v4();
}

@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => const UuidIdGenerator();
